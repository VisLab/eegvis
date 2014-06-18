function createHDF5(data,varargin)
parser = inputParser();
parser.addRequired('Data', @(x) validateattributes(x, ...
    {'numeric'}, {'nonempty'}));
parser.addParamValue('HDF5File', [pwd,filesep,'data.hdf5'], ...
    @(x) validateattributes(x, {'char'}, {'nonempty'}));
parser.addParamValue('AddFunctions', false, @(x) ...
    isa(x,'visfunc.functionObj'));
parser.parse(data, varargin{:});
pdata = parser.Results;
hdf5file = formatFile(pdata.HDF5File);
h5create(hdf5file, '/data', size(data));
h5write(hdf5file, '/data', data);

    function file = formatFile(file)
        if isdir(file)
            if isempty(regexp(file,'[\\/]$', 'once'))
                file = [file,filesep,'data.hdf5'];
            else
                file = [file,'data.hdf5'];
            end
        end
    end

end

