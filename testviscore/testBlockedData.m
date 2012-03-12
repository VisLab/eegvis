function test_suite = testDataSource %#ok<FNDEF,STOUT>
% Unit tests for blockedData
initTestSuite;

function testNormalConstructor %#ok<DEFNU>
% Unit test for blockedData normal constructor
fprintf('\nUnit tests for viscore.blockedData valid constructor');

fprintf('It should construct a valid generic slice when constructor has no parameters\n');
data = random('normal', 0, 1, [32, 1000, 20]);
vd = viscore.blockedData(data, 'ID1');
assertTrue(isvalid(vd));
assertTrue(strcmp(vd.DataID, 'ID1'));

function testBadConstructor %#ok<DEFNU>
% Unit test for viscore.blockedData bad constructor
fprintf('\nUnit tests for viscore.blockedData invalid constructor parameters\n');

fprintf('It should throw an exception when no parameters are passed\n');
f = @() viscore.blockedData();
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when only one parameter is passed\n');
data = random('normal', 0, 1, [32, 1000, 20]);
f = @() viscore.blockedData(data);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});


function testReblockSimple %#ok<DEFNU>
% Unit test for viscore.blockedData reblocking
fprintf('\nUnit tests for viscore.blockedData reblocking\n');

fprintf('It should reblock data when data is unepoched\n')
n = [32, 1000, 20];
data = 1:prod(n);
data1 = reshape(data, [32, 1000, 20]);
vd = viscore.blockedData(data1, 'ID1');
assertTrue(isvalid(vd));
vd.reblock(500);
assertElementsAlmostEqual(data1(1, 1, 2), 32001);
a = vd.getData();
assertVectorsAlmostEqual(size(a), [32, 500, 40]);
assertElementsAlmostEqual(a(1, 1, 2), 16001);

fprintf('It should not reblock when data is epoched')
data2 = random('normal', 0, 1, [32, 1000, 20]);
vd2 = viscore.blockedData(data2, 'ID1', 'Epoched', true);
assertTrue(isvalid(vd2));
assertTrue(vd2.isEpoched())
vd2.reblock(500);
a = vd2.getData();
assertVectorsAlmostEqual(size(a), [32, 1000, 20]);
assertElementsAlmostEqual(a(:), data2(:));

function testConstructorWithElementLocations %#ok<DEFNU>
% Unit test for viscore.blockedData with element locations
fprintf('\nUnit tests for viscore.blockedData with element locations\n');
data = random('normal', 0, 1, [32, 1000, 20]);

fprintf('It should allow element locations specified by structure array\n')
elocs(32) = struct('X', 2, 'Y', 3, 'Z', 1, 'labels', {'FPOZ'});
vd1 = viscore.blockedData(data, 'ID1', 'ElementLocations', elocs);
assertTrue(isvalid(vd1));
fprintf('It should allow an empty element location structure if ElementLocations parameter is given\n')
vd2 = viscore.blockedData(data, 'ID1', 'ElementLocations', struct());
assertTrue(isvalid(vd2));
fprintf('It should allow not allow empty element locations if ElementLocations parameter is given\n')
f = @() viscore.blockedData(data, 'ID1', 'ElementLocations', []);
assertExceptionThrown(f, 'MATLAB:invalidType');
f = @() viscore.blockedData(data, 'ID1', 'ElementLocations', '');
assertExceptionThrown(f, 'MATLAB:invalidType');

function testConstructorFewerThanThreeDimensions %#ok<DEFNU>
% Unit test for viscore.blockedData with fewer than 3 dimensions
data2 = random('exp', 1, [1, 1000, 20]);
fprintf('\nUnit tests for viscore.blockedData with singleton dimensions\n');

fprintf('It should allow a data array with a singleton first dimension\n');
testVD2 = viscore.blockedData(data2, 'Rand2');
[x, y, z] = testVD2.getDataSize();
assertVectorsAlmostEqual([x, y, z], [1, 1000, 20]);

fprintf('It should allow a data array with two dimensions\n');
n = [1000, 20];
data2 = reshape(1:prod(n), n);
testVD2 = viscore.blockedData(data2, 'Numeric', 'BlockDim', 1);
[x, y, z] = testVD2.getDataSize();
assertVectorsAlmostEqual([x, y, z], [1000, 20, 1]);

testVD3 = viscore.blockedData(data2, 'Numeric2');
[x, y, z] = testVD3.getDataSize();
assertVectorsAlmostEqual([x, y, z], [1000, 20, 1]);

testVD4 = viscore.blockedData(data2, 'Numeric3', 'BlockDim', 3);
[x, y, z] = testVD4.getDataSize();
assertVectorsAlmostEqual([x, y, z], [1000, 20, 1]);

function testConstructorWithEpochs %#ok<DEFNU>
% Unit test for viscore.blockedData epoch parameters
fprintf('\nUnit tests for viscore.blockedData epoch start times\n');
data = random('exp', 1, [1, 1000, 20]);

fprintf('Non-epoched data should have empty epoch start times\n');
testVD1 = viscore.blockedData(data, 'Rand exp');
assertTrue(isempty(testVD1.EpochStartTimes));

fprintf('Epoched data with no start times should have defaults\n');
testVD2 = viscore.blockedData(data, 'Rand exp', 'Epoched', true);
assertElementsAlmostEqual(testVD2.EpochStartTimes, (0:19)*1000);

fprintf('Epoched data with no start times should be correct when sampling rate not 1\n');
testVD3 = viscore.blockedData(data, 'Rand exp', 'Epoched', true, ...
    'SampleRate', 2);
assertElementsAlmostEqual(testVD3.EpochStartTimes, (0:19)*500);


fprintf('Epoched data with explicit start times should match\n');
testVD4 = viscore.blockedData(data, 'Rand exp', 'Epoched', true, ...
    'EpochStartTimes', (0:19)*500);
assertElementsAlmostEqual(testVD4.EpochStartTimes, (0:19)*500);

fprintf('Epoched data with no sampling rate and epoch times should have correct defaults\n')
testVD5 = viscore.blockedData(data, 'Rand exp', 'Epoched', true);
assertElementsAlmostEqual(testVD5.EpochTimes, (0:999)*1000);

fprintf('Epoched data with sampling rate and no epoch times should have correctdefaults\n')
testVD5 = viscore.blockedData(data, 'Rand exp', 'Epoched', true, ...
    'SampleRate', 250);
assertElementsAlmostEqual(testVD5.EpochTimes, (0:999)*4);

function testReblock %#ok<DEFNU>
% Unit test for blockedData reblock
fprintf('\nUnit tests for viscore.blockedData reblock\n');
data = random('normal', 0, 1, [32, 1000*20]);

fprintf('It should allow reblock a two dimensional array to be 3D\n');
vd = viscore.blockedData(data, 'ID1', 'BlockSize', 1000);
assertTrue(isvalid(vd));
[x, y, z] = vd.getDataSize();
assertElementsAlmostEqual(x, 32);
assertElementsAlmostEqual(y, 1000);
assertElementsAlmostEqual(z, 20);
oldID = vd.getVersionID();

fprintf('It should reblock with padding if blocksize doesn''t divide evenly\n');
vd.reblock(1300);
[x, y, z] = vd.getDataSize();
assertElementsAlmostEqual(x, 32);
assertElementsAlmostEqual(y, 1300);
assertElementsAlmostEqual(z, 16);
newID = vd.getVersionID();
assertTrue(strcmp(oldID, newID)== 0);

fprintf('It should reblock with padding if blocksize with even division after padding\n');
vd.reblock(500);
[x, y, z] = vd.getDataSize();
assertElementsAlmostEqual(x, 32);
assertElementsAlmostEqual(y, 500);
assertElementsAlmostEqual(z, 40);
newID = vd.getVersionID();
assertTrue(strcmp(oldID, newID)== 0);
vd.reblock(1000);
[x, y, z] = vd.getDataSize();
assertElementsAlmostEqual(x, 32);
assertElementsAlmostEqual(y, 1000);
assertElementsAlmostEqual(z, 20);
newID = vd.getVersionID();
assertTrue(strcmp(oldID, newID)== 0);
data1 = vd.getData();
assertVectorsAlmostEqual(data(:), data1(:));

function testMeans %#ok<DEFNU>
% Unit test for blockedData various means
fprintf('\nUnit tests for viscore.blockedData mean\n');
data = random('normal', 0, 1, [1, 32, 1000*20]);
data = permute(data, [2, 3, 1]);

fprintf('It should compute the mean of original data ignoring padding\n');
vd = viscore.blockedData(data, 'ID1');
assertTrue(isvalid(vd));
[r, c, d] = vd.getDataSize(); %#ok<ASGLU,NASGU>
% Test overall statistics
assertElementsAlmostEqual(c, vd.getBlockSize());
dm = vd.getOriginalMean();
assertTrue(isnumeric(dm));
assertEqual(length(dm), 1);
ds = vd.getOriginalStd();
assertTrue(isnumeric(ds));
assertEqual(length(ds), 1);

function testGetDataSlice %#ok<DEFNU>
% Unit test for viscore.blockedData for getBlockSlice
fprintf('\nUnit tests for viscore.blockedData getDataSlice :\n');

fprintf('It should return 1 block of values for each element when blocks are sliced\n');
data = random('exp', 1, [32, 1000, 20]);
testVD = viscore.blockedData(data, 'Rand1');
dSlice1 = viscore.dataSlice('Slices', {':', ':', '3'});
[values, sValues] = testVD.getDataSlice(dSlice1);
assertEqual(size(values), [32, 1000]);
assertVectorsAlmostEqual(values, data(:, :, 3));
assertVectorsAlmostEqual(sValues, [1, 1, 3]);

fprintf('It should return all blocks of value for each element when elements are sliced\n');
dSlice2 = viscore.dataSlice('Slices', {'5', ':', ':'});
[values, sValues] = testVD.getDataSlice(dSlice2);
assertVectorsAlmostEqual(size(values), [1, 1000, 20]);
assertVectorsAlmostEqual(values, data(5, :, :));
assertVectorsAlmostEqual(sValues, [5, 1, 1]);

fprintf('It should return a single value when data is 2D and slice is by element\n');
data = random('exp', 1, [32, 1000]);
testVD = viscore.blockedData(data, 'Rand1');
dSlice1 = viscore.dataSlice('Slices', {'2', ':', ':'});
[values, sValues] = testVD.getDataSlice(dSlice1);
assertEqual(size(values, 1), 1);
assertEqual(size(values, 2), 1000);
assertVectorsAlmostEqual(values, data(2, :));
assertVectorsAlmostEqual(sValues, [2, 1, 1]);

function testGetDataSliceOneElement %#ok<DEFNU>
% Unit test for viscore.blockedData for getDataSlice
fprintf('\nUnit tests for viscore.blockedData getDataSlice when data has one element:\n');

data = random('exp', 1, [1, 1000, 20]);
testVD = viscore.blockedData(data, 'Rand1');

fprintf('It should return 1 value when blocks are sliced\n');
dSlice1 = viscore.dataSlice('Slices', {':', ':', '3'});
[values, sValues] = testVD.getDataSlice(dSlice1);
assertEqual(size(values), [1, 1000]);
assertVectorsAlmostEqual(values, data(1, :, 3));
assertVectorsAlmostEqual(sValues, [1, 1, 3]);


fprintf('It should return 1 value for each block when elements are sliced\n');
dSlice2 = viscore.dataSlice('Slices', {'1', ':', ':'});
[values, sValues] = testVD.getDataSlice(dSlice2);
assertVectorsAlmostEqual(size(values), [1, 1000, 20]);
assertVectorsAlmostEqual(values, data(1, :, :));
assertVectorsAlmostEqual(sValues, [1, 1, 1]);

fprintf('It should return a single value when data is 2D and slice is by element\n');
data = random('exp', 1, [32, 1000]);
testVD = viscore.blockedData(data, 'Rand1');
dSlice1 = viscore.dataSlice('Slices', {'2', ':', ':'});
[values, sValues] = testVD.getDataSlice(dSlice1);
assertEqual(size(values, 1), 1);
assertEqual(size(values, 2), 1000);
assertVectorsAlmostEqual(values, data(2, :));
assertVectorsAlmostEqual(sValues, [2, 1, 1]);
