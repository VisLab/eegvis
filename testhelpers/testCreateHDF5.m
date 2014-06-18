function test_suite = testCreateHDF5 %#ok<STOUT>
% Unit tests for createHDF5
initTestSuite;

function values = setup %#ok<DEFNU>
load('EEG.mat');
values.data = double(EEG.data);
path = which('EEG.mat');  
values.HDF5Dir1 = regexprep(path, '[\\/]EEG.mat$', '');
values.HDF5Dir2 = regexprep(path, 'EEG.mat$', '');
values.HDF5File = regexprep(path, 'EEG.mat$', 'EEG.hdf5');

function teardown(values) %#ok<INUSD,DEFNU>

% Function executed after each test

function testNoAdditionalArguments(values) %#ok<DEFNU>
% Unit test for createHDF5 function
fprintf('\nUnit tests for createHDF5 with no additional arguments\n');

fprintf(['It should create a hdf5 file with an array containing the' ...
    ' data\n']);
createHDF5(values.data);
HDF5File = [pwd,filesep,'data.hdf5'];
data = h5read(HDF5File, '/data');
assertEqual(data, values.data);

fprintf(['It should create a hdf5 file in the current directory named' ...
    ' data.hdf5\n']);
assertEqual(exist(HDF5File, 'file'), 2);
delete(HDF5File);

function testHDF5FileArgument(values) %#ok<DEFNU>
% Unit test for createHDF5 function
fprintf('\nUnit tests for createHDF5 with HDF5File agrument\n');

fprintf(['It should create a hdf5 file named data.hdf5 in the' ...
    ' specified directory not ending with a file separator\n']);
createHDF5(values.data, 'HDF5File', values.HDF5Dir1);
HDF5File = [values.HDF5Dir1,filesep,'data.hdf5'];
assertEqual(exist(HDF5File, 'file'), 2);
delete(HDF5File);

fprintf(['It should create a hdf5 file named data.hdf5 in the' ...
    ' specified directory ending with a file separator\n']);
createHDF5(values.data, 'HDF5File', values.HDF5Dir2);
HDF5File = [values.HDF5Dir2,'data.hdf5'];
assertEqual(exist(HDF5File, 'file'), 2);
delete(HDF5File);

fprintf('It should create a hdf5 file with the specified name\n');
createHDF5(values.data, 'HDF5File', values.HDF5File);
HDF5File = values.HDF5File;
assertEqual(exist(HDF5File, 'file'), 2);
delete(HDF5File);