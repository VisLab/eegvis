function computedblocks = computeblocks(data, blocksize, func)
numelements = size(data,1);
numframes = size(data,2);
numblocks = ceil(numframes/blocksize);
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

