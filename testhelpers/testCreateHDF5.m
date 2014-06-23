function test_suite = testCreateHDF5 %#ok<STOUT>
% Unit tests for createHDF5
initTestSuite;

function values = setup %#ok<DEFNU>
load('EEG.mat');
values.Data = double(EEG.data);
path = which('EEG.mat');  
values.HDF5File = regexprep(path, 'EEG.mat$', 'EEG.hdf5');

function teardown(values)  %#ok<DEFNU>
delete(values.HDF5File);
% Function executed after each test

function testNoAdditionalArguments(values) %#ok<DEFNU>
% Unit test for createHDF5 function
fprintf('\nUnit tests for createHDF5 with no additional arguments\n');

fprintf('It should create a hdf5 file with the specified name\n');
createHDF5(values.Data, values.HDF5File);
assertEqual(exist(values.HDF5File, 'file'), 2);
assertTrue(~isempty(h5read(values.HDF5File,'/data')));
assertEqual(reshape(h5read(values.HDF5File,'/data'), ...
    h5read(values.HDF5File,'/dims')), values.Data);
assertEqual(h5read(values.HDF5File,'/dims'), size(values.Data));