% viscore.memoryData   manages a data array for visualization
%
% Usage:
%   >>  viscore.memoryData(data, dataID)
%   >>  viscore.memoryData(data, dataID, 'key1', 'value1', ...)
%   >>  obj = viscore.memoryData(...)
%
% Description:
% viscore.memoryData(data, dataID) creates a data object for the
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
% viscore.memoryData(data, dataID, 'key1', 'value1', ...| specifies
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
% obj = viscore.memoryData(...) returns a handle to the newly created
% object.
%
% Example 1:
% Create a blocked data object for a random array
%   data = random('normal', 0, 1, [32, 1000, 20]);
%   bd = viscore.memoryData(data, 'Normal(0, 1)');
%
% Example 2:
% Reblock a data object in blocks of 500 frames
%   data = random('normal', 0, 1, [32, 1000, 20]);
%   bd = viscore.memoryData(data, 'Normal(0, 1)');
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
% documentation for viscore.memoryData:
%
%    doc viscore.memoryData
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
% $Log: memoryData.m,v $
% $Revision: 1.00 04-Dec-2011 09:11:20 krobbins $
% $Initial version $
%

classdef memoryData < hgsetget & viscore.blockedData

    properties (Access = private)
        Data;                 % 2D or 3D array of data, first dim for elements
    end % private properties
    
    properties (Constant)
        ElementFields = {'radius', 'theta', 'labels', 'X', 'Y', 'Z'};
    end
    
    methods
        
        function obj = memoryData(data, dataID, varargin)
            % Constructor parses parameters and sets up initial data
            obj = obj@viscore.blockedData(dataID, varargin{:});
            obj.parseParameters(data);
        end % memoryData constructor
        
        function [values, blockMean, blockStd] = funEval(obj, fObj)
            [e, s, b] = obj.getDataSize(); %#ok<ASGLU>
            fh = str2func(fObj.getDefinition());
            values = reshape(...
                feval(fh, obj.getData()), e, b);
            blockMean = nanmean(values(:));
            blockStd = nanstd(values(:));
        end % funEval
        
             
        function data = getData(obj)
            % Return the blocked data (may have padding at the end)
            data = obj.Data;
        end % getData
        
        
        function [nElements, nSamples, nBlocks] = getDataSize(obj)
            % Return number of elements, samples and blocks in data
            [nElements, nSamples, nBlocks] = size(obj.Data);
        end % getDataSize
        
        function [values, sValues, sSizes] = getDataSlice(obj, slices, cDims, method)
            % Return function values and starting indices corresponding to this slice
            [values, sValues, sSizes] = viscore.dataSlice.getDataSlice(...
                                      obj.Data, slices, cDims, method);
        end % getDataSlice
       
        
        function [tMean, tStd, tLow, tHigh] = getTrimValues(obj, percent, data)
            % Return trim mean, trim std, trim low cutoff, trim high cutoff
            if nargin == 3
                myData = data(:);
            else
                myData = obj.Data(:);
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
        
        
        function value = getValue(obj, element, sample, block)
            % Return the value of element, sample, block ****needs testing
            
            value = obj.Data(element, sample, block);
        end
       
        function reblock(obj, blockSize)
            % Reblock the data to a new blocksize if not epoched
            %
            % Inputs:
            %    blockSize    size to make the windows
            %
            % Notes:
            %  - no action is taken if data is epoched or blockSize <= 0
            %  - handles repadding or clipping as needed for blockSize
            %
            if isempty(blockSize) || blockSize <= 0 || obj.Epoched
                return;
            end
            
            % Compute the sizes of different dimensions
            p = obj.BlockDim;
            nds = max(ndims(obj.Data), p + 1);
            dDims = ones(1, nds);
            for k = 1:nds
                dDims(k) = size(obj.Data, k);
            end
            
            % Check to see if already the right size or shouldn't be blocked
            tBlock = round(blockSize);
            if ~isempty(obj.BlockSize) && obj.BlockSize == tBlock && ...
                    dDims(p) == tBlock
                return;
            end  %  Already the right size
            
            % Reblocking so the version changes
            c = viscore.counter.getInstance();
            obj.VersionID = num2str(c.getNext());  %
            obj.BlockSize = tBlock;
            
            % Calculate the dimensions for reblocking and reshape
            dStart = [];  % Dimensions before the reblocked dimension
            if p > 1    % The reblock dimension is not the first
                dStart = dDims(1:p - 1);
            end
            dEnd = [];  % Dimensions after the reblocked dimension
            if p < length(dDims) - 1
                dEnd = dDims((p + 2):end);
            end
            newDims = [dStart dDims(p)*dDims(p+1), dEnd];
            if length(newDims) == 1
                newDims = [newDims, 1];
            end
            obj.Data = reshape(obj.Data, newDims);

            % Calculate actual size of reblocked dimensions and pad as needed
            aSize = obj.TotalValues;
            rStart = '';
            for k = 1:p - 1
                aSize = aSize/dDims(k);
                rStart = [rStart ':, ']; %#ok<AGROW>
            end
            rEnd = [];
            for k = p+2:length(dDims)
                aSize = aSize/dDims(k);
                rEnd = [rEnd ', :']; %#ok<AGROW>
            end
            
            blocks = ceil(aSize/double(obj.BlockSize));
            needed = blocks*double(obj.BlockSize);
            leftOver = needed - dDims(p)*dDims(p+1);
            if leftOver > 0  % Need to pad before reblocking
                obj.Data = [obj.Data, repmat(obj.PadValue, [dStart, leftOver, dEnd])];
            elseif leftOver < 0  % Need to remove extra padding
                eString = ['obj.Data(' rStart '1:needed' rEnd ')'];
                obj.Data = eval(eString);
            end
            obj.Data = reshape(obj.Data, [dStart, obj.BlockSize, blocks, dEnd]);
            
%             if ~isempty(obj.Events)
%                 bTime = obj.BlockSize./obj.SampleRate;
%                 obj.Events.reblock(bTime, blocks*bTime);  % fix this later
%             end
        end % reblock
        
    end % public methods
    
    methods(Access = private)
        
        function parseParameters(obj, data)
            % Parse parameters provided by user in constructor
            parser = viscore.memoryData.getParser();
            parser.parse(data);
            pdata = parser.Results;
            
            % Now handle the data
            obj.Data = double(pdata.Data);
            obj.OriginalMean = mean(obj.Data(:));
            obj.OriginalStd = std(obj.Data(:));
            obj.TotalValues = length(obj.Data(:));
            setBlocks(obj);           % handle block time information         
            obj.reblock(obj.BlockSize);     
            obj.setEvents();
        end % parseParameters
       
        
        function [] = setBlocks(obj)
            % Helper function to set epochs
            if ~obj.Epoched
                return;
            end
            obj.BlockSize = size(obj.Data, obj.BlockDim);                               
            if isempty(obj.BlockTimeScale) 
                obj.BlockTimeScale = (0:(obj.BlockSize - 1))./obj.SampleRate;
            end
            if isempty(obj.BlockStartTimes)
                  obj.BlockStartTimes = obj.BlockSize*...
                       (0:(size(obj.Data, 3) - 1))./obj.SampleRate;
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
                maxTime = obj.BlockSize*size(obj.Data, obj.BlockDim + 1)./ ...
                    obj.SampleRate;
            end
            
            obj.Events = viscore.blockedEvents(obj.Events, ...
                'BlockStartTimes', bStarts, 'MaxTime', maxTime, ...
                'BlockTime', obj.BlockSize./obj.SampleRate);
        end % setEvents     
           
    end % private methods
    
    methods(Static = true)

        
        function parser = getParser()
            % Create a parser for memoryData
            parser = inputParser;
            parser.addRequired('Data', ...
                @(x) (~isempty(x) && isnumeric(x)));
        end % getParser
        
    end % static methods
    
end % memoryData

