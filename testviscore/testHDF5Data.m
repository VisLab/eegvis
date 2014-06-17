function test_suite = testHDF5Data %#ok<STOUT>
% Unit tests for blockedData
initTestSuite;

function values = setup %#ok<DEFNU>
values.hdf5file = which('eeglab_data.hdf5');

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testNormalConstructor(values) %#ok<DEFNU>
% Unit test for HDF5Data normal constructor
fprintf('\nUnit tests for viscore.HDF5Data valid constructor\n');

fprintf('It should construct a valid generic slice when constructor has no parameters\n');
vd = viscore.HDF5Data(values.hdf5file, 'ID1');
assertTrue(isvalid(vd));
assertTrue(strcmp(vd.getDataID(), 'ID1'));

function testReadHDF5Data(values) %#ok<DEFNU>
% Unit test for HDF5Data readData
fprintf('\nUnit tests for viscore.HDF5Data readHDF5Data \n');

fprintf('It should read the data from a valid HDF5 file\n');
vd = viscore.HDF5Data(values.hdf5file, 'ID1');
kData = vd.readHDF5Data('/Kurtosis_1000');
assertTrue(~isempty(kData));
stdData = vd.readHDF5Data('/StandardDeviation_1000');
assertTrue(~isempty(stdData));




