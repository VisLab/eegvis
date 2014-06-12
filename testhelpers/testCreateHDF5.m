function test_suite = testCreateHDF5 %#ok<STOUT>
% Unit tests for createHDF5
initTestSuite;

function values = setup %#ok<DEFNU>
values.eegfile = which('eeg.set');  
values.outputdir = strrep(values.eegfile, 'eeg.set', '');

function teardown(values) %#ok<INUSD,DEFNU>
delete('eeg.hdf5');
% Function executed after each test

function testValidParameters(values) %#ok<DEFNU>
% Unit test for createHDF5 function
fprintf('\nUnit tests for createHDF5 with valid constructor\n');
fprintf('It should create a hdf5 file with a valid parameters');
createHDF5(values.eegfile, 1000, values.outputdir);
hdf5file = strrep(values.eegfile, 'eeg.set', 'eeg.hdf5');
assertEqual(exist(hdf5file, 'file'), 2);

function testArrays(values) %#ok<DEFNU>
fprintf('\nUnit tests for createHDF5 with computed arrays\n');
fprintf(['It should create a hdf5 file containing the original data, ' ...
    'and precomputed data arrays']);
createHDF5(values.eegfile, 1000, values.outputdir);
hdf5file = strrep(values.eegfile, 'eeg.set', 'eeg.hdf5');
datadataset = '/data';
data = h5read(hdf5file,datadataset);
stdblockvalue = std(data(1,1:1000));
kurtosisblockvalue = kurtosis(data(1,1:1000));
stddataset = '/SD_1000';
stdarray = h5read(hdf5file,stddataset);
assertEqual(length(stdarray), 992);
assertElementsAlmostEqual(stdblockvalue, stdarray(1), 'relative', .0001);
stddataset = '/Kurtosis_1000';
kurtosisarray = h5read(hdf5file,stddataset);
assertEqual(length(kurtosisarray), 992);
assertElementsAlmostEqual(kurtosisblockvalue, kurtosisarray(1), ...
    'relative', .0001);


