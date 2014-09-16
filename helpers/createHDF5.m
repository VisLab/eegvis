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
h5create(pdata.HDF5File, '/data', [numel(pdata.Data) 1]);
h5write(pdata.HDF5File, '/data', pdata.Data(:));
% dims = size(pdata.Data);
% numElements = dims(1);
% numFrames = dims(2);
% for a = 1:numFrames
%     data =  pdata.Data(:, a);
%     start = [((numElements * (a - 1)) + 1) 1];
%     count = [numElements 1];
%     h5write(pdata.HDF5File, '/data', data, start, count);
% end

