function test_suite = testDataSlice %#ok<STOUT>
% Unit tests for dataSlice
initTestSuite;

function values = setup %#ok<DEFNU>
values = [];

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test


% function testNormalConstructor(values) %#ok<INUSD,DEFNU>
% % Unit test for dataSlice normal constructor normal constructor
% fprintf('\nUnit tests for dataSlice for normal constructor\n');
% 
% fprintf('It should construct a valid generic slice when constructor has no parameters\n');
% ds = viscore.dataSlice();
% assertTrue(isvalid(ds));
% [slices, names] = ds.getParameters([]);
% 
% fprintf('A generic slice should have 3 dimensions\n');
% assertEqual(3, length(slices));
% assertEqual(3, length(names));
% 
% fprintf('A generic slice has names: Element, Sample, Block\n');
% assertTrue(strcmp(names{1}, 'Element'));
% assertTrue(strcmp(names{2}, 'Sample'));
% assertTrue(strcmp(names{3}, 'Block'));
% 
% 
% fprintf('It should handle a Slices parameter for three dimensions\n');
% ds = viscore.dataSlice('Slices', {':', ':', '3'});
% assertTrue(isvalid(ds));
% [s, names] = ds.getParameters([]);
% assertEqual(3, length(names));
% assertEqual(3, length(s));
% assertTrue(strcmp(s{1}, ':'));
% assertTrue(strcmp(s{2}, ':'));
% assertTrue(strcmp(s{3}, '3'));
% assertTrue(strcmp(names{1}, 'Element'));
% assertTrue(strcmp(names{2}, 'Sample'));
% assertTrue(strcmp(names{3}, 'Block'));
% 
% fprintf('It should handle a Slices parameter for two dimensions\n');
% ds = viscore.dataSlice('Slices', {'4', ':'});
% assertTrue(isvalid(ds));
% [s, names] = ds.getParameters([]);
% assertEqual(2, length(names));
% assertEqual(2, length(s));
% assertTrue(strcmp(s{1}, '4'));
% assertTrue(strcmp(s{2}, ':'));
% assertTrue(strcmp(names{1}, 'Element'));
% assertTrue(strcmp(names{2}, 'Sample'));
% 
% fprintf('It should handle a Slices parameter for one dimensions\n');
% ds = viscore.dataSlice('Slices', {'4'});
% assertTrue(isvalid(ds));
% [s, names] = ds.getParameters([]);
% assertEqual(1, length(names));
% assertEqual(1, length(s));
% assertTrue(strcmp(s{1}, '4'));
% assertTrue(strcmp(names{1}, 'Element'));
% 
% fprintf('It should handle an empty Slices parameter\n');
% ds = viscore.dataSlice('Slices', {});
% assertTrue(isvalid(ds));
% [s, names] = ds.getParameters([]);
% assertEqual(3, length(names));
% assertEqual(3, length(s));
% assertTrue(strcmp(s{1}, ':'));
% assertTrue(strcmp(s{2}, ':'));
% assertTrue(strcmp(s{3}, ':'));
% assertTrue(strcmp(names{1}, 'Element'));
% assertTrue(strcmp(names{2}, 'Sample'));
% assertTrue(strcmp(names{3}, 'Block'));
% 
% fprintf('It should handle a DimNames parameter shorter than dimension\n');
% ds = viscore.dataSlice(4, 'DimNames', {'x', 'y'});
% assertTrue(isvalid(ds));
% [s, n] = ds.getParameters([]);
% assertEqual(4, length(n));
% assertEqual(4, length(s));
% assertTrue(strcmp(n{1}, 'x'));
% assertTrue(strcmp(n{2}, 'y'));
% assertTrue(strcmp(n{3}, 'Block'));
% assertTrue(strcmp(n{4}, 'Dim4'));
% 
% fprintf('It should handle a DimNames parameter longer than dimension\n');
% ds = viscore.dataSlice(2, 'DimNames', {'x', 'y', 'z', 'w'});
% assertTrue(isvalid(ds));
% [s, n] = ds.getParameters([]);
% assertEqual(2, length(n));
% assertEqual(2, length(s));
% assertTrue(strcmp(n{1}, 'x'));
% assertTrue(strcmp(n{2}, 'y'));
% 
% fprintf('It should handle a CombineMethod parameter\n');
% ds = viscore.dataSlice(4, 'CombineMethod', 'min');
% assertTrue(isvalid(ds));
% [s, n, c, m] = ds.getParameters([]); %#ok<ASGLU>
% assertTrue(strcmpi(m, 'min') == 1);
% 
% fprintf('It should use default method when no CombineParameter is passed\n');
% ds = viscore.dataSlice();
% assertTrue(isvalid(ds));
% [s, n, c, m] = ds.getParameters([]); %#ok<ASGLU>
% assertTrue(strcmpi(m, 'mean') == 1);
% 
% fprintf('It should use default method when an invalid CombineParameter is passed\n');
% ds = viscore.dataSlice('CombineMethod', 'apple');
% assertTrue(isvalid(ds));
% [s, n, c, m] = ds.getParameters([]); %#ok<ASGLU>
% assertTrue(strcmpi(m, 'mean') == 1);
% 
% fprintf('It should use throw an exception when a non-character is passed\n');
% ds = @() viscore.dataSlice('CombineMethod', []);
% assertExceptionThrown(ds, 'MATLAB:invalidType');
% 
% function testGetSliceParameters(values) %#ok<INUSD,DEFNU>
% % Unit test for dataSlice getSliceParameters
% fprintf('\nUnit tests for the getSliceParameters method of dataSlice:\n');
% 
% fprintf('It should handle requests of same dimension as slice\n');
% ds = viscore.dataSlice();
% [slices, names] = ds.getParameters (3);
% assertTrue(strcmpi(names{1}, 'Element'));
% assertTrue(strcmpi(names{2}, 'Sample'));
% assertTrue(strcmpi(names{3}, 'Block'));
% assertTrue(strcmpi(':', slices{3}));
% 
% fprintf('It should handle requests with fewer dimensions than the slice\n');
% [slices, names] = ds.getParameters (2);
% assertTrue(strcmpi(names{1}, 'Element'));
% assertTrue(strcmpi(names{2}, 'Sample'));
% assertEqual(length(slices), 2);
% 
% fprintf('It should handle requests with more dimensions than the slice\n');
% [slices, names] = ds.getParameters (4);
% assertTrue(strcmpi(names{1}, 'Element'));
% assertTrue(strcmpi(names{2}, 'Sample'));
% assertTrue(strcmpi(names{3}, 'Block'));
% assertTrue(strcmpi(names{4}, 'Dim4'));
% assertTrue(strcmpi(':', slices{4}));
% 
% fprintf('It should return the appropriate combine dimensions')
% slice = viscore.dataSlice('Slices', {':', ':', '2:4'}, ...
%     'DimNames', {'Channel', 'Sample', 'Window'}, 'CombineDim', 3);
% 
% [slices, names, cDims] = slice.getParameters(3);
% assertTrue(~isempty(cDims));
% assertTrue(~isempty(slices));
% assertTrue(~isempty(names));


% function testSlicesToString(values) %#ok<INUSD,DEFNU>
% % Unit test for dataSlice static slicesToString method
% fprintf('\nUnit tests for static slicesToString method of dataSlice:\n');
% 
% fprintf('It should return a string\n');
% ds = viscore.dataSlice('Slices', {':', ':', num2str(3)});
% slices = ds.getParameters([]);
% sString = viscore.dataSlice.slicesToString(slices);
% assertTrue(ischar(sString));


% function testGetDataSlice(values) %#ok<INUSD,DEFNU>
% % Unit test for dataSlice getDataSlice static method 
% fprintf('\nTesting getDataSlice static method of dataSlice\n');
% 
% fprintf('It should take a data slice when slice is too short\n');
% data = random('normal', 0, 1, [32, 1000, 20]);
% [dSlice, sStart, sSizes] = viscore.dataSlice.getDataSlice(data, {':', ':'}, [], []);
% assertVectorsAlmostEqual(size(dSlice), [32, 1000, 20]);
% assertVectorsAlmostEqual(sStart, [1, 1, 1]);
% assertVectorsAlmostEqual(sSizes, [32, 1000, 20]);
% 
% fprintf('It should take a data slice when slice is too long\n');
% [dSlice, sStart, sSizes] =  viscore.dataSlice.getDataSlice(data, {':', ':', '4:5', ':'}, [], []);
% assertVectorsAlmostEqual(size(dSlice), [32, 1000, 2]);
% assertVectorsAlmostEqual(dSlice, data(:, :, 4:5));
% assertVectorsAlmostEqual(sStart, [1, 1, 4]);
% assertVectorsAlmostEqual(sSizes, [32, 1000, 2]);
% 
% fprintf('It should take the right slice when slice falls off the end\n');
% [dSlice, sStart, sSizes] =  viscore.dataSlice.getDataSlice(data, {'5:38', ':', '4:5', ':'}, [], []);
% assertVectorsAlmostEqual(size(dSlice), [28, 1000, 2]);
% assertVectorsAlmostEqual(dSlice, data(5:32, :, 4:5));
% assertVectorsAlmostEqual(sStart, [5, 1, 4]);
% assertVectorsAlmostEqual(sSizes, [28, 1000, 2]);
% 
% fprintf('It should return original data when slice is empty\n');
% [dSlice, sStart, sSizes] =  viscore.dataSlice.getDataSlice(data, {}, [], '');
% assertVectorsAlmostEqual(size(dSlice), size(data));
% assertVectorsAlmostEqual(dSlice(:), data(:));
% assertVectorsAlmostEqual(sStart, [1, 1, 1]);
% assertVectorsAlmostEqual(sSizes, [32, 1000, 20]);
% 
% fprintf('It should return original data for empty slice when data is 4D\n'); 
% data2 = random('normal', 0, 1, [32, 1000, 20, 36]);
% [dSlice2, sStart2, sSizes2] =  viscore.dataSlice.getDataSlice(data2, '');
% assertVectorsAlmostEqual(size(dSlice2), size(data2));
% assertVectorsAlmostEqual(dSlice2(:), data2(:));
% assertVectorsAlmostEqual(sStart2, [1, 1, 1, 1]);
% assertVectorsAlmostEqual(sSizes2, [32, 1000, 20, 36]);
% 
% fprintf('It should handle slices in the middle of the data\n');
% [dSlice2, sStart2, sSizes2] = viscore.dataSlice.getDataSlice(data2, {':',  '3', ':'}, [], '');
% assertVectorsAlmostEqual(size(squeeze(dSlice2)), [32, 20, 36]);
% assertVectorsAlmostEqual(squeeze(dSlice2), squeeze(data2(:, 3, :, :)));
% fprintf('It should return slices unsqeezed\n');
% assertVectorsAlmostEqual(size(dSlice2), [32, 1, 20, 36]);
% assertVectorsAlmostEqual(sStart2, [1, 3, 1, 1]);
% assertVectorsAlmostEqual(sSizes2, [32, 1, 20, 36]);
% 
% fprintf('It should work when all parameters are non-empty\n');
% [dSlice, sStart, sSizes] =  viscore.dataSlice.getDataSlice(data, {':', ':', '5:8'}, 3, 'mean');
% assertVectorsAlmostEqual(size(dSlice), [32, 1000]);
% dNew = data(:, :, 5:8);
% dNew = mean(dNew, 3);
% assertVectorsAlmostEqual(dSlice(:), dNew(:));
% assertVectorsAlmostEqual(sStart, [1, 1, 5]);
% assertVectorsAlmostEqual(sSizes, [32, 1000, 4]);
% 
% fprintf('It should return data when slice has multiple elements')
% slice = viscore.dataSlice('Slices', {':', ':', '2:5'}, ...
%     'DimNames', {'Channel', 'Sample', 'Window'}, 'CombineDim', 3);
% 
% [slices, names, cDims] = slice.getParameters(3);
% data = random('normal', 0, 1, [32, 1000, 20]);
% [signals, start, sSizes] = viscore.dataSlice.getDataSlice(data, ...
%                    slices, cDims, []);
% assertTrue(~isempty(names));
% assertTrue(~isempty(signals));
% [rows, cols, dep] = size(signals);
% assertEqual(rows, 32);
% assertEqual(cols, 1000);
% assertEqual(dep, 4);
% assertEqual(start(3), 2);
% assertVectorsAlmostEqual(sSizes, [32, 1000, 4]);


function testGetHDF5Slice(values) %#ok<INUSD,DEFNU>
% Unit test for dataSlice getDataSlice static method 
fprintf('\nTesting getDataSlice static method of dataSlice\n');

fprintf('It should take a data slice when slice is too short\n');
data = random('normal', 0, 1, [32, 1000, 20]);
hdf5File1 = regexprep(which('EEG.mat'), 'EEG.mat$', 'EEG_NO_DATA1.hdf5');
testVD1 = viscore.hdf5Data(data, 'random', hdf5File1);
[dSlice, sStart, sSizes] = viscore.dataSlice.getHDF5Slice(testVD1, {':', ':'}, [], []);
assertVectorsAlmostEqual(size(dSlice), [32, 1000, 20]);
assertVectorsAlmostEqual(sStart, [1, 1, 1]);
assertVectorsAlmostEqual(sSizes, [32, 1000, 20]);

fprintf('It should take a data slice when slice is too long\n');
[dSlice, sStart, sSizes] =  viscore.dataSlice.getHDF5Slice(testVD1, {':', ':', '4:5', ':'}, [], []);
assertVectorsAlmostEqual(size(dSlice), [32, 1000, 2]);
assertVectorsAlmostEqual(dSlice, data(:, :, 4:5));
assertVectorsAlmostEqual(sStart, [1, 1, 4]);
assertVectorsAlmostEqual(sSizes, [32, 1000, 2]);

fprintf('It should take the right slice when slice falls off the end\n');
[dSlice, sStart, sSizes] =  viscore.dataSlice.getHDF5Slice(testVD1, {'5:38', ':', '4:5', ':'}, [], []);
assertVectorsAlmostEqual(size(dSlice), [28, 1000, 2]);
assertVectorsAlmostEqual(dSlice, data(5:32, :, 4:5));
assertVectorsAlmostEqual(sStart, [5, 1, 4]);
assertVectorsAlmostEqual(sSizes, [28, 1000, 2]);

fprintf('It should return original data when slice is empty\n');
[dSlice, sStart, sSizes] =  viscore.dataSlice.getHDF5Slice(testVD1, {}, [], '');
assertVectorsAlmostEqual(size(dSlice), size(data));
assertVectorsAlmostEqual(dSlice(:), data(:));
assertVectorsAlmostEqual(sStart, [1, 1, 1]);
assertVectorsAlmostEqual(sSizes, [32, 1000, 20]);

% fprintf('It should return original data for empty slice when data is 4D\n'); 
% data2 = random('normal', 0, 1, [32, 1000, 20, 36]);
% hdf5File2 = regexprep(which('EEG.mat'), 'EEG.mat$', 'EEG_NO_DATA2.hdf5');
% testVD2 = viscore.hdf5Data(data2, 'random', hdf5File2);
% [dSlice2, sStart2, sSizes2] =  viscore.dataSlice.getHDF5Slice(testVD2, '');
% assertVectorsAlmostEqual(size(dSlice2), size(data2));
% assertVectorsAlmostEqual(dSlice2(:), data2(:));
% assertVectorsAlmostEqual(sStart2, [1, 1, 1, 1]);
% assertVectorsAlmostEqual(sSizes2, [32, 1000, 20, 36]);
% 
% fprintf('It should handle slices in the middle of the data\n');
% [dSlice2, sStart2, sSizes2] = viscore.dataSlice.getHDF5Slice(testVD2, {':',  '3', ':'}, [], '');
% assertVectorsAlmostEqual(size(squeeze(dSlice2)), [32, 20, 36]);
% assertVectorsAlmostEqual(squeeze(dSlice2), squeeze(data2(:, 3, :, :)));
% fprintf('It should return slices unsqeezed\n');
% assertVectorsAlmostEqual(size(dSlice2), [32, 1, 20, 36]);
% assertVectorsAlmostEqual(sStart2, [1, 3, 1, 1]);
% assertVectorsAlmostEqual(sSizes2, [32, 1, 20, 36]);

fprintf('It should work when all parameters are non-empty\n');
[dSlice, sStart, sSizes] =  viscore.dataSlice.getHDF5Slice(testVD1, {':', ':', '5:8'}, 3, 'mean');
assertVectorsAlmostEqual(size(dSlice), [32, 1000]);
dNew = data(:, :, 5:8);
dNew = mean(dNew, 3);
assertVectorsAlmostEqual(dSlice(:), dNew(:));
assertVectorsAlmostEqual(sStart, [1, 1, 5]);
assertVectorsAlmostEqual(sSizes, [32, 1000, 4]);

fprintf('It should return data when slice has multiple elements')
slice = viscore.dataSlice('Slices', {':', ':', '2:5'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'}, 'CombineDim', 3);

[slices, names, cDims] = slice.getParameters(3);
data = random('normal', 0, 1, [32, 1000, 20]);
hdf5File3 = regexprep(which('EEG.mat'), 'EEG.mat$', 'EEG_NO_DATA3.hdf5');
testVD3 = viscore.hdf5Data(data, 'random', hdf5File3);
[signals, start, sSizes] = viscore.dataSlice.getHDF5Slice(testVD3, ...
                   slices, cDims, []);
assertTrue(~isempty(names));
assertTrue(~isempty(signals));
[rows, cols, dep] = size(signals);
assertEqual(rows, 32);
assertEqual(cols, 1000);
assertEqual(dep, 4);
assertEqual(start(3), 2);
assertVectorsAlmostEqual(sSizes, [32, 1000, 4]);

delete(hdf5File1);
% delete(hdf5File2);
delete(hdf5File3);

% function testGetSliceEvaluation(values) %#ok<INUSD,DEFNU>
% % Unit test for dataSlice getSliceEvaluation static method 
% fprintf('\nTesting getSliceEvaluation static method of dataSlice\n');
% 
% fprintf('It should take a data slice when slice is too short\n');
% aSizes =  [32, 1000, 20];
% [eSlice, sStart, sSlice] = viscore.dataSlice.getSliceEvaluation(aSizes, {':', ':'});
% assertVectorsAlmostEqual(sStart, [1, 1, 1]);
% assertTrue(strcmp(eSlice, ':,:,:'));
% assertVectorsAlmostEqual(sSlice, [32, 1000, 20]);
% 
% fprintf('It should take a data slice when slice is too long\n');
% aSizes =  [32, 1000, 20];
% [eSlice, sStart, sSlice] =  viscore.dataSlice.getSliceEvaluation(aSizes, {':', ':', '4:5', ':'});
% assertVectorsAlmostEqual(sStart, [1, 1, 4]);
% assertTrue(strcmp(eSlice, [':,:,[' num2str(4:5) ']']));
% assertVectorsAlmostEqual(sSlice, [32, 1000, 2]);
% 
% fprintf('It should take the right slice when slice falls off the end\n');
% aSizes =  [32, 1000, 20];
% [eSlice, sStart, sSlice] =  viscore.dataSlice.getSliceEvaluation(aSizes, {'5:38', ':', '4:5', ':'});
% assertVectorsAlmostEqual(sStart, [5, 1, 4]);
% assertTrue(strcmp(eSlice, ['[' num2str(5:32) '],:,[' num2str(4:5) ']']));
% assertVectorsAlmostEqual(sSlice, [28, 1000, 2]);
% 
% fprintf('It should return empty values when slice is empty\n');
% aSizes =  [32, 1000, 20];
% [eSlice, sStart, sSlice] =  viscore.dataSlice.getSliceEvaluation(aSizes, []);
% assertTrue(isempty(eSlice));
% assertVectorsAlmostEqual(sStart, ones(1, length(aSizes)));
% assertVectorsAlmostEqual(sSlice, [32, 1000, 20]);
% 
% fprintf('It should return empty values when the sizes are empty\n');
% [eSlice, sStart, sSlice] =  viscore.dataSlice.getSliceEvaluation([], {':', ':'});
% assertTrue(isempty(eSlice));
% assertTrue(isempty(sStart));
% assertTrue(isempty(sSlice));
% 
% fprintf('It should return original data for empty slice when data is 4D\n'); 
% aSizes = [5, 10, 4, 6];
% [eSlice, sStart, sSlice] =  viscore.dataSlice.getSliceEvaluation(aSizes, {':', ':'});
% assertVectorsAlmostEqual(sStart, [1, 1, 1, 1]);
% assertTrue(strcmp(eSlice, ':,:,:,:'));
% assertVectorsAlmostEqual(sSlice, [5, 10, 4, 6]);
% 
% fprintf('It should handle slices in the middle of the data\n');
% aSizes = [32, 1000, 20, 36];
% [eSlice, sStart, sSlice] =  viscore.dataSlice.getSliceEvaluation(aSizes, {':',  '3', ':'});
% assertVectorsAlmostEqual(sStart, [1, 3, 1, 1]);
% assertTrue(strcmp(eSlice, ':,[3],:,:'));
% assertVectorsAlmostEqual(sSlice, [32, 1, 20, 36]);
% 
% function testRangeString(values) %#ok<INUSD,DEFNU>
% % Unit test for dataSlice rangeString static method 
% fprintf('\nTesting rangeString static method of dataSlice\n');
% fprintf('It should just have string representing a single value if numValues is 1\n');
% assertTrue(strcmp('1', viscore.dataSlice.rangeString(1, 1)));
% assertTrue(strcmp('4', viscore.dataSlice.rangeString(4, 1)));
% fprintf('It should have a colon range if numValues > 1\n');
% assertTrue(strcmp('1:4', viscore.dataSlice.rangeString(1, 4)));
% assertTrue(strcmp('3:4', viscore.dataSlice.rangeString(3, 2)));
% 
% function testCombineDims(values) %#ok<INUSD,DEFNU>
% % Unit test for dataSlice combineDims static method 
% fprintf('\nTesting combineDims static method of dataSlice\n');
% data = random('normal', 0, 1, [32, 1000, 20, 5]);
% fprintf('It should just combine dimensions correctly for mean\n');
% 
% dComb = viscore.dataSlice.combineDims(data, 3, 'mean');
% assertVectorsAlmostEqual(dComb, mean(data, 3));
% 
% fprintf('It should combine dimensions correctly for sum\n');
% dComb2 = viscore.dataSlice.combineDims(data, 1, 'sum');
% assertVectorsAlmostEqual(dComb2, sum(data, 1));
