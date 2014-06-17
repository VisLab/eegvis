function createHDF5(eegfile, blocksize, varargin)
parser = inputParser();
parser.addRequired('eegfile', @(x) validateattributes(x, ...
    {'char'}, {'nonempty'}));
parser.addRequired('blocksize',  @(x) validateattributes(x, ...
    {'numeric'},{'scalar', 'nonempty', 'positive'}));
parser.addOptional('hdf5dir', pwd, ...
    @(x) validateattributes(x, {'char'}, {'nonempty'}));
parser.parse(eegfile, blocksize, varargin{:});
p = parser.Results;
EEG = pop_loadset(p.eegfile);
data = EEG.data;
hdf5file = [checkdirsepeartor(p.hdf5dir),...
    regexprep(EEG.filename,'\..*$', '.hdf5')];
numelements = size(data,1);
numframes = size(data,2);
numblocks = ceil(numframes/blocksize);
h5create(hdf5file, '/numelements', 1, 'Datatype', 'uint64');
h5write(hdf5file, '/numelements', uint64(size(data,1)));
h5create(hdf5file, '/numblocks', 1, 'Datatype', 'uint64');
h5write(hdf5file, '/numblocks', uint64(numblocks));
h5create(hdf5file, '/blocksize', 1, 'Datatype', 'uint64');
h5write(hdf5file, '/blocksize', uint64(blocksize));
h5create(hdf5file, '/data', size(data));
h5write(hdf5file, '/data', data);
h5create(hdf5file, ['/Kurtosis_',num2str(blocksize)], ...
    [1, numelements * numblocks]);
h5write(hdf5file, ['/Kurtosis_',num2str(blocksize)], computeblocks(data,...
    numelements, numframes, numblocks, blocksize, ...
    '@(x) (kurtosis(x, 1, 2))'));
h5create(hdf5file, ['/StandardDeviation_',num2str(blocksize)], ...
    [1, numelements * numblocks]);
h5write(hdf5file, ['/StandardDeviation_',num2str(blocksize)], ...
    computeblocks(data, numelements, numframes, numblocks, blocksize, ...
    '@(x) (std(x, 0, 2))'));


    function computedblocks = computeblocks(data, numelements, ...
            numframes, numblocks, blocksize, func)
        computedblocks = zeros(1, numelements * numblocks);
        readframes = 0;
        index = 1;
        realblocksize = min(blocksize, numframes - readframes);
        funchand = str2func(func);
        for a = 1:numblocks
            for b = 1:numelements
                computedblocks(index) = funchand(data(b,...
                    readframes + 1:readframes + realblocksize));
                index = index + 1;
            end
            readframes = readframes + realblocksize;
            realblocksize = min(blocksize, numframes - readframes);
        end
    end

    function dir = checkdirsepeartor(dir)
        if isempty(regexp(dir,[filesep,'$'], 'ONCE'))
            dir = [dir,filesep];
        end
    end

end

