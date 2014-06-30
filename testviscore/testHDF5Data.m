function test_suite = testHDF5Data %#ok<STOUT>
% Unit tests for blockedData
initTestSuite;

function values = setup %#ok<DEFNU>
load('EEG.mat');
values.Data = double(EEG.data);
values.HDF5NewFile = regexprep(which('EEG.mat'), 'EEG.mat$', 'EEG.hdf5');
values.HDF5ExistingFile = regexprep(which('EEG.mat'), 'EEG.mat$', ...
    'EEG_DATA.hdf5');

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testNormalConstructor(values) %#ok<DEFNU>
% Unit test for hdf5Data normal constructor
fprintf('\nUnit tests for viscore.hdf5Data valid constructor\n');

fprintf(['It should create an HDF5 file that consists of the data' ...
    ' passed in\n']);
bd = viscore.hdf5Data(values.Data, 'ID1', values.HDF5NewFile);
assertTrue(strcmp(bd.getDataID(), 'ID1'));
assertEqual(exist(values.HDF5NewFile, 'file'), 2);
assertTrue(~isempty(h5read(values.HDF5NewFile,'/data')));
assertEqual(reshape(h5read(values.HDF5NewFile,'/data'), ...
    h5read(values.HDF5NewFile,'/dims')), values.Data);
assertEqual(h5read(values.HDF5NewFile,'/dims'), size(values.Data));
delete(values.HDF5NewFile);

fprintf(['It should use the data from the hdf5 file when Overwrite is' ...
    ' false and non-empty data is passed in']);
bd = viscore.hdf5Data(values.Data, 'ID2', values.HDF5ExistingFile);
assertTrue(strcmp(bd.getDataID(), 'ID2'));
assertEqual(exist(values.HDF5ExistingFile, 'file'), 2);
assertTrue(~isempty(h5read(values.HDF5ExistingFile,'/data')));
assertEqual(reshape(h5read(values.HDF5ExistingFile,'/data'), ...
    h5read(values.HDF5ExistingFile,'/dims')), values.Data);
assertEqual(h5read(values.HDF5ExistingFile,'/dims'), size(values.Data));

fprintf(['It should use the data from the hdf5 file when empty data is' ...
    ' passed in']);
bd = viscore.hdf5Data([], 'ID3', values.HDF5ExistingFile);
assertTrue(strcmp(bd.getDataID(), 'ID3'));
assertEqual(exist(values.HDF5ExistingFile, 'file'), 2);
assertTrue(~isempty(h5read(values.HDF5ExistingFile,'/data')));
assertEqual(reshape(h5read(values.HDF5ExistingFile,'/data'), ...
    h5read(values.HDF5ExistingFile,'/dims')), values.Data);
assertEqual(h5read(values.HDF5ExistingFile,'/dims'), size(values.Data));

fprintf(['It should throw an exception when the hdf5 file doesn''t ' ...
    ' exist and empty data is passed in']);
assertExceptionThrown(...
    @() error(viscore.hdf5Data([], 'ID4', values.HDF5NewFile)),...
    'HDF5Chk:NoData');



