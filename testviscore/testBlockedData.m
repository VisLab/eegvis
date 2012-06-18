function test_suite = testBlockedData %#ok<STOUT>
% Unit tests for blockedData
initTestSuite;

function testNormalConstructor %#ok<DEFNU>
% Unit test for blockedData normal constructor
fprintf('\nUnit tests for viscore.blockedData valid constructor\n');

fprintf('It should construct a valid generic slice when constructor has no parameters\n');
data = random('normal', 0, 1, [32, 1000, 20]);
vd = viscore.blockedData(data, 'ID1');
assertTrue(isvalid(vd));
assertTrue(strcmp(vd.getDataID(), 'ID1'));

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
elocs(32) = struct('X', 2, 'Y', 3, 'Z', 1, 'labels', {'FPOZ'}, 'theta', 3, 'radius', 4);
vd1 = viscore.blockedData(data, 'ID1', 'ElementLocations', elocs);
assertTrue(isvalid(vd1));
fprintf('It should ignore the element locations if parameter is empty\n');
vd2 = viscore.blockedData(data, 'ID2', 'ElementLocations', []);
assertTrue(isvalid(vd2));
assertTrue(isempty(vd2.getElementLocations));
fprintf('It should ignore the element locations if parameter is empty structure\n');
vd3 = viscore.blockedData(data, 'ID2', 'ElementLocations', []);
assertTrue(isvalid(vd3));
assertTrue(isempty(vd3.getElementLocations));
vd4 = viscore.blockedData(data, 'ID2', 'ElementLocations', '');
assertTrue(isvalid(vd4));
assertTrue(isempty(vd4.getElementLocations));
fprintf('It should throw an exception of required location fields not present\n');
elocs1(32) = struct('X', 2, 'Y', 3, 'Z', 1, 'labels', {'FPOZ'});
f = @() viscore.blockedData(data, 'ID1', 'ElementLocations', elocs1);
assertExceptionThrown(f, 'MATLAB:InputParser:ArgumentFailedValidation');

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

testVD3 = viscore.blockedData(data2, 'Numeric2', 'BlockSize', 10);
[x, y, z] = testVD3.getDataSize();
assertVectorsAlmostEqual([x, y, z], [1000, 10, 2]);

testVD4 = viscore.blockedData(data2, 'Numeric3', 'BlockDim', 3, 'BlockSize', 1);
[x, y, z] = testVD4.getDataSize();
assertVectorsAlmostEqual([x, y, z], [1000, 20, 1]);

function testConstructorWithEpochs %#ok<DEFNU>
% Unit test for viscore.blockedData epoch parameters
fprintf('\nUnit tests for viscore.blockedData epoch start times\n');
data = random('exp', 1, [30, 500, 20]);

fprintf('Non-epoched data should have empty epoch start times\n');
testVD1 = viscore.blockedData(data, 'Rand exp');
assertTrue(isempty(testVD1.getEpochStartTimes()));

fprintf('Epoched data with no start times should have defaults\n');
testVD2 = viscore.blockedData(data, 'Rand exp', 'Epoched', true);
assertElementsAlmostEqual(testVD2.getEpochStartTimes(), (0:19)*500);

fprintf('Epoched data with no start times should be correct when sampling rate not 1\n');
testVD3 = viscore.blockedData(data, 'Rand exp', 'Epoched', true, ...
    'SampleRate', 2);
assertElementsAlmostEqual(testVD3.getEpochStartTimes(), (0:19)*250);
fprintf('Epoched data should have blocksize that agrees with epoch size\n');
assertEqual(testVD3.getBlockSize(), 500);

fprintf('Epoched data with explicit start times should match\n');
testVD4 = viscore.blockedData(data, 'Rand exp', 'Epoched', true, ...
    'EpochStartTimes', (0:19)*2000);
assertElementsAlmostEqual(testVD4.getEpochStartTimes(), (0:19)*2000);

fprintf('Epoched data with no sampling rate and epoch times should have correct defaults\n')
testVD5 = viscore.blockedData(data, 'Rand exp', 'Epoched', true);
assertElementsAlmostEqual(testVD5.getEpochTimeScale(), 0:499);

fprintf('Epoched data with sampling rate and no epoch times should have correctdefaults\n')
testVD5 = viscore.blockedData(data, 'Rand exp', 'Epoched', true, ...
    'SampleRate', 250);
assertElementsAlmostEqual(testVD5.getEpochTimeScale(), (0:499)*4/1000);

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

function testSinglePrecision %#ok<DEFNU>
% Unit test for viscore.blockedData for single precession
fprintf('\nUnit tests for viscore.blockedData when data is single precision:\n');

data = single(random('exp', 1, [1, 1000, 20]));
testVD = viscore.blockedData(data, 'Random single precision data');
storedData = testVD.getData();
assertTrue(isa(storedData, 'double'));

function testConstructorWithEvents %#ok<DEFNU>
% Unit test for viscore.blockedData with eventData
fprintf('\nUnit tests for viscore.blockedData with events\n');

fprintf('It should have an empty events, if none are passed in\n');
data = random('normal', 0, 1, [32, 1000, 20]);
vd1 = viscore.blockedData(data, 'ID1');
assertTrue(isvalid(vd1));
assertTrue(isempty(vd1.getEvents()));

fprintf('It should return the eventData, if it is passed in\n');
load('EEGData.mat');   
tEvents = EEG.event;
types = {tEvents.type}';
                                      % Convert to seconds since beginning
startTimes = (round(double(cell2mat({EEG.event.latency}))') - 1)./EEG.srate; 
endTimes = startTimes + 1/EEG.srate;
event = struct('type', types, 'startTime', num2cell(startTimes), ...
    'endTime', num2cell(endTimes));

vd2 = viscore.blockedData(data, 'ID2', 'Events', event, ...
           'SampleRate', 128, 'BlockSize', 1000);
assertTrue(isvalid(vd2));
ed1 = vd2.getEvents();
assertTrue(isvalid(ed1));
assertTrue(isa(ed1, 'viscore.eventData'));
fprintf('It should have the right event counts\n');
endTimes = ed1.getEndTimes();
numBlocks = ceil(max(endTimes)/ed1.getBlockTime());
counts = ed1.getEventCounts(1, numBlocks);
assertEqual(size(counts, 1), length(ed1.getUniqueTypes()));
assertEqual(size(counts, 2), numBlocks);
assertEqual(sum(counts(:)), length(event));

function testGetEpochTimes(event) %#ok<INUSD,DEFNU>
% Unit test for viscore.blockedData with getEpochTimes
fprintf('\nUnit tests for viscore.blockedData with getEpochTimes\n');
load('EEGEpoch.mat');
fprintf('It should have the correct number of start times\n');
[event, startTimes, timeScale] = viscore.eventData.getEEGTimes(EEGEpoch);
assertEqual(length(startTimes), length(EEGEpoch.epoch));
fprintf('It should have the correct number of time scale values\n');
assertEqual(length(timeScale), length(EEGEpoch.times));
fprintf('It should have the correct epoch start times (to within a sample)\n');
assertElementsAlmostEqual(startTimes(1), 0.0);
assertTrue( abs(startTimes(2)- 0.6953) < 10-05);
assertTrue( abs(startTimes(3)- 3.7081) < 10-05);