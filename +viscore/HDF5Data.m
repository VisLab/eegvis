% viscore.blockedData   manages a data array for visualization
%
% Usage:
%   >>  viscore.blockedData(data, dataID)
%   >>  viscore.blockedData(data, dataID, 'key1', 'value1', ...)
%   >>  obj = viscore.blockedData(...)
%
% Description:
% viscore.blockedData(data, dataID) creates a data object for the
%    visualization. The data parameter is an array, and the dataID is
%    a string identifying the data. This ID is used as part of visualization
%    titles.
%
%    Blocked data objects can be reshaped or reblocked along a specified
%    dimension called the BlockDim. A summary function such as standard
%    deviation or kurtosis is applied along this dimension to provide a
%    summary of the function.
%
%    The data of blockData objects is always converted to double, even if it
%    comes in as single or some other type.
%
%
% viscore.blockedData(data, dataID, 'key1', 'value1', ...| specifies
%     optional name/value parameter pairs:
%   'BlockDim'         array dimension for reblocking (defaults to 2)
%   'BlockSize'        window size for reblocking the data
%   'BlockStartTimes'  times in seconds of begining of each block
%   'BlockTimeScale'   times corresponding to block samples
%   'ElementLocations' structure of element (channel) locations
%   'Epoched'          if true, data is epoched and can't be reblocked
%   'Events'           blockedEvents object if this data has events
%   'PadValue'         numeric value to pad uneven blocks (defaults to 0)
%   'SampleRate'       sampling rate in Hz for data (defaults to 1)
%
% obj = viscore.blockedData(...) returns a handle to the newly created
% object.
%
% Example 1:
% Create a blocked data object for a random array
%   data = random('normal', 0, 1, [32, 1000, 20]);
%   bd = viscore.blockedData(data, 'Normal(0, 1)');
%
% Example 2:
% Reblock a data object in blocks of 500 frames
%   data = random('normal', 0, 1, [32, 1000, 20]);
%   bd = viscore.blockedData(data, 'Normal(0, 1)');
%   bd.reblock(500);
%   [rows, cols, blks] = bd.getDataSize();
%
% Notes:
%  - Data that is initially epoched cannot be reblocked.
%  - An empty sampling rate implies that the data is not sampled at a fixed
%    sampling rate. This feature will be supported in the future in a child class.
%  - This data object has a version ID that changes each time the data
%    is modified. The version ID enables functions to know whether
%    to recompute their values.
%  - The BlockDim is set in the constructor and later changes do not affect
%    the blocking.
%  - The|BlockTimeScale| is in ms if epoched and s if not epoched
%
% The ElementLocations structure follows the standard EEGLAB chanlocs
% structure with the following fields:
%    theta    polar coordinates theta for flattened scalp
%    radius   polar-coordinate radii (arc_lengths) for flattened scalp
%    labels   short label of element name
%    X        x coordinate of element location (nose is +X direction)
%    Y        y coordinate of element location
%    Z        z coordinate of element location
%
%
%
% Class documentation:
% Execute the following in the MATLAB command window to view the class
% documentation for viscore.blockedData:
%
%    doc viscore.blockedData
%
% See also: viscore.dataSlice and visviews.DualView
%

%1234567890123456789012345678901234567890123456789012345678901234567890

% Copyright (C) Kay Robbins, UTSA, July 1, 2011, krobbins@cs.utsa.edu
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
%
% $Log: blockedData.m,v $
% $Revision: 1.00 04-Dec-2011 09:11:20 krobbins $
% $Initial version $
%

classdef hdf5Data < hgsetget & viscore.blockedData
    
    properties (Access = private)
        HDF5File;             % hdf5 file that contains a data array
    end % private properties
    
    methods
        
        function obj = hdf5Data(data, dataID, hdf5File, varargin)
            % Constructor parses parameters and sets up initial data
            obj = obj@viscore.blockedData(dataID, varargin{:});
            obj.parseParameters(data, hdf5File);
        end % blockedData constructor
        
        function values = funEval(obj, fh, fn)
            try
                % Get data from file if it exists
                values = h5read(obj.HDF5File, ['/',fn,...
                    '_',num2str(obj.BlockSize)]);
            catch
                % Compute the data and store it in the file
                values = obj.computeBlocks(fh);
                h5create(obj.HDF5File,['/',fn,...
                    '_',num2str(obj.BlockSize)],size(values));
                h5write(obj.HDF5File,['/',fn,...
                    '_',num2str(obj.BlockSize)], values);
            end
        end % funEval
        
        function data = getData(obj)
            data = h5read(obj.HDF5File, '/data');
        end % getData
        
        function [nElements, nSamples, nBlocks] = getDataSize(obj)
            % Return number of elements, samples and blocks in data
            dims = h5read(obj.HDF5File, '/dims');
            nElements = dims(1);
            nSamples = obj.BlockSize;
            if length(dims) == 2
                nBlocks = ceil(dims(2) / obj.BlockSize);
            else
                if ~obj.isEpoched
                    nBlocks = ceil(dims(2) * dims(3) / obj.BlockSize);
                else
                    nSamples = dims(2);
                    nBlocks = dims(3);
                end
            end
        end % getDataSize
        
        function [values, sValues] = getDataSlice(obj, dSlice)
            % Return function values and starting indices corresponding to this slice
            if ~isempty(dSlice)
                slices = dSlice.getParameters(3);
            else
                slices = [];
            end
            [values, sValues] = viscore.dataSlice.getHDF5Slice(...
                obj, slices, [], []);
        end % getDataSlice
        
        function hdf5File = getHDF5File(obj)
           hdf5File = obj.HDF5File; 
        end % getHDF5File
        
        
        function [tMean, tStd, tLow, tHigh] = getTrimValues(obj, percent, data)
            % Return trim mean, trim std, trim low cutoff, trim high cutoff
            % NEED TO REWRITE THIS
            if nargin == 3
                myData = data(:);
            else
                myData = viscore.dataSlice.getHDF5Slice(...
                obj, {':', ':', ':'}, [], []);
                myData = myData(:);
            end
            if isempty(percent) || percent <= 0 || percent >= 100
                tLow = min(myData);
                tHigh = max(myData);
            else
                tValues = prctile(myData, [percent/2, 100 - percent/2]);
                tLow = tValues(1);
                tHigh = tValues(2);
                myData(myData < tLow | myData > tHigh) = [];
            end
            tMean = mean(myData);
            tStd = std(myData, 1);
        end % getTrimValues
        
        function reblock(obj, blockSize)
            c = viscore.counter.getInstance();
            obj.VersionID = num2str(c.getNext());
            obj.BlockSize = blockSize;
        end
        
    end % public methods
    
    methods(Access = private)
        
        function parseParameters(obj, data, hdf5File)
            % Parse parameters provided by user in constructor
            parser = viscore.hdf5Data.getParser();
            parser.parse(data, hdf5File, obj.UnmatchedArguments)
            pdata = parser.Results;
            % Check the hdf5 file
            checkHDF5File(obj, pdata);
            setBlocks(obj);
            obj.setEvents();
        end % parseParameters
        
        function checkHDF5File(obj, pdata)
            % Case 1
            if ~isempty(pdata.Data) && ...
                    ~exist(pdata.HDF5File, 'file')
                createHDF5(double(pdata.Data), pdata.HDF5File);
                obj.HDF5File = pdata.HDF5File;
                % Case 2
            elseif ~isempty(pdata.Data) && ...
                    exist(pdata.HDF5File, 'file')
                if pdata.Overwrite
                    delete(pdata.HDF5File);
                    createHDF5(double(pdata.Data), pdata.HDF5File);
                end
                obj.HDF5File = pdata.HDF5File;
                % Case 3
            elseif isempty(pdata.Data) && ...
                    exist(pdata.HDF5File, 'file')
                obj.HDF5File = pdata.HDF5File;
                % Case 4
            elseif isempty(pdata.Data) && ...
                    ~exist(pdata.HDF5File, 'file')
                throw(MException('HDF5Chk:NoData', ...
                    'Data and HDF5 file cannot be empty'));
            end
        end % compareDataAndHDF5File
        
        
        function computedBlocks = computeBlocks(obj, fh)
            dims = h5read(obj.HDF5File, '/dims');
            if length(dims) == 2
                numFrames = dims(2);
            else
                numFrames = dims(2) * dims(3);
            end
            [numElements, numSamples, numBlocks] = getDataSize(obj);
            computedBlocks = zeros(numElements, numBlocks);
            readFrames = 0;
            realBlockSize = min(numSamples, numFrames - readFrames);
            for a = 1:numBlocks
                for b = 1:numElements
                    computedBlocks(b,a) = fh([h5read(obj.HDF5File, ...
                        '/data', ...
                        [(readFrames * numElements + b) 1], ...
                        [realBlockSize 1], [numElements 1])', ...
                        repmat(obj.PadValue, ...
                        [1, numSamples - realBlockSize])]);
                end
                readFrames = readFrames + realBlockSize;
                realBlockSize = min(obj.BlockSize, numFrames - readFrames);
            end
        end % computeBlocks
        
        function [] = setBlocks(obj)
            % Helper function to set epochs
            if ~obj.Epoched
                return;
            end
            dims = h5read(obj.HDF5File, '/dims');
            obj.BlockSize = dims(obj.BlockDim);
            if isempty(obj.BlockTimeScale)
                obj.BlockTimeScale = (0:(obj.BlockSize - 1))./obj.SampleRate;
            end
            if isempty(obj.BlockStartTimes)
                obj.BlockStartTimes = obj.BlockSize*...
                    (0:(dims(3) - 1))./obj.SampleRate;
            end
        end % setBlocks
        
        function setEvents(obj)
            % Helper function to set events
            if isempty(obj.Events)
                return;
            elseif obj.Epoched
                bStarts = obj.BlockStartTimes;
                maxTime = [];
            else
                bStarts = [];
                [~, ~, nBlocks] = getDataSize(obj);
                maxTime = obj.BlockSize*nBlocks./ ...
                    obj.SampleRate;
            end
            obj.Events = viscore.blockedEvents(obj.Events, ...
                'BlockStartTimes', bStarts, 'MaxTime', maxTime, ...
                'BlockTime', obj.BlockSize./obj.SampleRate);
        end % setEvents
        
    end % private methods
    
    methods(Static = true)
        
        function parser = getParser()
            % Create a parser for blockedData
            parser = inputParser;
            parser.addRequired('Data', ...
                @(x) (isempty(x) || isnumeric(x)));
            parser.addRequired('HDF5File', ...
                @(x) (isempty(x) || ischar(x)));
            parser.addParamValue('Overwrite', false, ...
                @(x) validateattributes(x, {'logical'}, {}));
        end % getParser
        
    end % static methods
    
end % blockedData