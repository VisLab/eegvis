function createHDF5(eegfile, hdf5file, blocksize)
parser = inputparser();
parser.addRequired('eegfile', @(x) validateattributes(x, {'char'}, {}));
parser.addRequired('hdf5file',@(x) validateattributes(x, {'char'}, {}));
parser.addRequired('blocksize',  @(x) validateattributes(x, ...
    {'numeric'},{'scalar', 'nonempty', 'positive'}));
parser.parse(eegfile, hdf5file, blocksize);
EEG = pop_loadset(eegfile);
data = EEG.data;


% std = zeros(numelements, blocksize, numblocks);
h5create(hdf5file, '/data', size(data));
h5write(hdf5file, '/data', data);
h5create(hdf5file, ['Kurtosis_',num2str(blocksize)], size(kurtosis));
h5write(hdf5file, ['Kurtosis_',num2str(blocksize)], kurtosis);
h5create(hdf5file, ['SD_',num2str(blocksize)], size(std));
h5write(hdf5file, ['SD_',num2str(blocksize)], std);


    function computedblocks = computeblocks(data, blocksize, func)
        numelements = size(data,1);
        numframes = size(data,2);
        numblocks = ceil(numframes/blocksize);
        computedblocks = zeros(1, numelements * numblocks);
        readframes = 0;
        index = 1;
        realblocksize = min(blocksize, numframes - readframes);
        for a = 1:numblocks
            for b = 1:numelements
                    computedblocks(index) = ...
                        arrayfun(str2func(func),(data(b,...
                        readframes + 1:readframes + realblocksize)));
                    index = index + 1;
                readframes = readframes + realblocksize;
                realblocksize = min(blocksize, numframes - readframes);
            end
        end
    end

