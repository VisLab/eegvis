function createHDF5(data, hdf5file)
parser = inputParser();
parser.addRequired('Data', @(x) validateattributes(x, ...
    {'numeric'}, {'nonempty'}));
parser.addRequired('HDF5File', @(x) validateattributes(x, ...
    {'char'}, {'nonempty'}));
parser.parse(data, hdf5file);
pdata = parser.Results;
h5create(pdata.HDF5File, '/dims', [1 ndims(pdata.Data)]);
h5write(pdata.HDF5File, '/dims', size(pdata.Data));
h5create(pdata.HDF5File, '/data', size(pdata.Data(:)));
h5write(pdata.HDF5File, '/data', double(pdata.Data(:)));
end

