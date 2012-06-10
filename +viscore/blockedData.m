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
%   'SampleRate'       sampling rate in Hz for data (defaults to 1)
%   'BlockSize'        window size for reblocking the data
%   'BlockDim'         array dimension for reblocking (defaults to 2)
%   'ElementLocations' structure of element (channel) locations
%   'Epoched'          if true, data is epoched and can't be reblocked
%   'EpochStartTimes'  if data is epoched, times in seconds of epoch beginnings
%   'EpochTimes'       if data is epoched, times corresponding to epoch samples
%   'Events'           eventData object if this data has events 
%   'PadValue'         numeric value to pad uneven blocks (defaults to 0)
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

classdef blockedData < hgsetget
    
    properties
        BlockDim              % dimension used for reblocking (default 2)
        DataID                % ID of the data contained in this object
        EpochStartTimes = []  % start times of epochs in seconds
        EpochTimes = [];      % time offsets in ms for epoch samples
        PadValue = 0;         % use to pad data if not divisible by BlockSize
        SampleRate = 1;       % sampling rate in Hz of data
    end % public properties
    
    properties (Access = private)
        ActualBlockDim        % block dimension currently being used
        BlockSize = [];       % window size to use when data is reshaped
        Data;                 % 2D or 3D array of data, first dim for elements
        ElementLocations = [];  % element locations structure with ElementFields
        Epoched;              % true if the data is epoched
        Events;               % blockedEvent object if this object has events
        OriginalMean          % overall mean of data set (before padding)
        OriginalStd           % overall std of data set (before padding)
        TotalValues           % total number of values in original data
        VersionID             % version ID of this data
    end % private properties
    
    properties (Constant)
        ElementFields = {'radius', 'theta', 'labels', 'X', 'Y', 'Z'};
    end
    
    methods
        
        function obj = blockedData(data, dataID, varargin)
            % Constructor parses parameters and sets up initial data
            c = viscore.counter.getInstance();
            obj.VersionID = num2str(c.getNext());  % Get a unique ID
            obj.parseParameters(data, dataID, varargin{:});
        end % blockedData constructor
        
        function blockSize = getBlockSize(obj)
            % Return current block size
            blockSize = obj.BlockSize;
        end % getBlockSize
        
        function data = getData(obj)
            % Return the blocked data (may have padding at the end)
            data = obj.Data;
        end % getData
        
        function [nElements, nSamples, nBlocks] = getDataSize(obj)
            % Return number of elements, samples and blocks in data
            [nElements, nSamples, nBlocks] = size(obj.Data);
        end % getDataSize
        
        function [values, sValues] = getDataSlice(obj, dSlice)
            % Return function values and starting indices corresponding to this slice
            if ~isempty(dSlice)
                slices = dSlice.getParameters(3);
            else
                slices = [];
            end
            [values, sValues] = viscore.dataSlice.getDataSlice(...
                                      obj.Data, slices, [], []);
        end % getDataSlice
        
        function elocs = getElementLocations(obj)
            % Return the structure containing element locations
            elocs = obj.ElementLocations;
        end % getElementLocations
        
        function events = getEvents(obj)
            % Return the eventData object containing events for this data
            events = obj.Events;
        end % getEvents
        
        function oMean = getOriginalMean(obj)
            % Return the overall mean of original data
            oMean = obj.OriginalMean;
        end % getOriginalMean
        
        function oStd = getOriginalStd(obj)
            % Return the overall standard deviation of original data
            oStd = obj.OriginalStd;
        end % getOriginalStd
        
        function nValues = getTotalValues(obj)
            % Return total number of values in original data (before padding)
            nValues = obj.TotalValues;
        end % getTotalValues
        
        function value = getValue(obj, element, sample, block)
            % Return the value of element, sample, block ****needs testing
            value = obj.Data(element, sample, block);
        end
        
        function version = getVersionID(obj)
            % Return version ID of this data source
            version = obj.VersionID;
        end % getVersionID
        
        function e = isEpoched(obj)
            % Return true if data is epoched and false otherwise
            e = obj.Epoched;
        end % isEpoched
       
        
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
            p = obj.ActualBlockDim;
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
            
            if ~isempty(obj.Events)
                obj.Events.reblock(obj.BlockSize, blocks);  % fix this later
            end
        end % reblock
        
    end % public methods
    
    methods(Access = private)
        
        function parseParameters(obj, data, dataID, varargin)
            % Parse parameters provided by user in constructor
            parser = viscore.blockedData.getParser();
            obj.SampleRate = 1;
            obj.BlockDim = 2;
            parser.parse(data, dataID, varargin{:})
            % Get the parsed results
            pdata = parser.Results;
            % Override public properties with explicit user settings
            myFields = properties(obj);
            for k = 1:length(myFields)
                if isfield(pdata, myFields{k}) && ~isempty(pdata.(myFields{k}))
                    obj.(myFields{k}) = pdata.(myFields{k});
                end
            end
            % Assign specified private properties
            obj.BlockSize = pdata.BlockSize;
            obj.Epoched = pdata.Epoched;
            obj.Events = pdata.Events;
            
            % Element locations
            obj.ElementLocations = [];
            if isfield(pdata, 'ElementLocations') && ~isempty(pdata.ElementLocations)
                eFields = fieldnames(pdata.ElementLocations);
                intFields = intersect(eFields, obj.ElementFields);
                diffFields = setdiff(obj.ElementFields, intFields);
                if ~isempty(diffFields)
                   sString = diffFields{1};
                   for k = 2:length(diffFields)
                       sString = [sString ' ' diffFields{k}]; %#ok<AGROW>
                   end
                   error('blockedData:ElementLocationIssue', ...
                    ['The following required fields are missing:' sString '\n']);
                end
                obj.ElementLocations = pdata.ElementLocations;       
            end
            
            % Now handle the data
            obj.Data = double(pdata.Data);
            obj.OriginalMean = mean(obj.Data(:));
            obj.OriginalStd = std(obj.Data(:));
            obj.TotalValues = length(obj.Data(:));
            
            if isempty(obj.BlockSize) || obj.Epoched
                obj.BlockSize = size(pdata.Data, obj.BlockDim);
            else
                obj.BlockSize = pdata.BlockSize;
            end
            obj.ActualBlockDim = obj.BlockDim; % Set the one used
            
            % Handle blocking and epoching
            if ~obj.Epoched
                obj.reblock(obj.BlockSize);
                if ~isempty(pdata.EpochTimes) && ~obj.Epoched
                    warning('blockedData:EpochIssue', ...
                        'Data is not epoched so EpochTimes are ignored');
                end
                return
            end
            
            % Epoched data
            if isempty(obj.EpochTimes)
                obj.EpochTimes = 1000.*(0:(obj.BlockSize - 1))./obj.SampleRate;
            elseif ~isempty(pdata.EpochTimes) && ...
                    length(pdata.EpochTimes) ~= obj.BlockSize
                error('blockedData:EpochIssue', ...
                    ['Argument ''EpochTimes'' has length %d' ...
                    ' but match size(signalData, %d): %d'], ...
                    length(pdata.EpochTimes), obj.BlockDim, obj.BlockSize);
            end
            if isempty(obj.EpochStartTimes)
                  obj.EpochStartTimes = obj.BlockSize*...
                       (0:(size(obj.Data, 3) - 1))./obj.SampleRate;
            elseif ~isempty(pdata.EpochStartTimes) && ...
                    length(pdata.EpochStartTimes) ~= size(obj.Data, 3)
                error('blockedData:EpochIssue', ...
                    ['Argument ''EpochStartTimes'' has length %d' ...
                    ' but match size(signalData, %d): %d'], ...
                    length(pdata.EpochStartTimes), obj.BlockDim, obj.BlockSize);
            end
        end % parseParameters
        
        
    end % private methods
    
    methods(Static = true)
        
        function parser = getParser()
            % Create a parser for blockedData
            parser = inputParser;
            parser.addRequired('Data', ...
                @(x) (~isempty(x) && isnumeric(x)));
            parser.addRequired('DataID', ...
                @(x) validateattributes(x, {'char'}, {}));
            parser.addParamValue('SampleRate', 1, ...
                @(x) validateattributes(x, {'numeric'}, ...
                {'scalar', 'nonempty', 'positive'}));
            parser.addParamValue('ElementLocations', [], ...
                @(x) validateattributes(x, {'struct'}, ...
                {}));
            parser.addParamValue('BlockDim', 2, ...
                @(x) validateattributes(x, {'numeric'}, ...
                {'scalar', 'nonnegative'}));
            parser.addParamValue('BlockSize', [], ...
                @(x) validateattributes(x, {'numeric'}, ...
                {'scalar', 'nonnegative'}));
            parser.addParamValue('Epoched', false, ...
                @(x) validateattributes(x, {'logical'}, ...
                {}));
            parser.addParamValue('EpochTimes', [], ...
                @(x) validateattributes(x, {'numeric'}, ...
                {}));
            parser.addParamValue('EpochStartTimes', [], ...
                @(x) validateattributes(x, {'numeric'}, ...
                {}));
            parser.addParamValue('Events', [], ...
                @(x) validateattributes(x, {'viscore.eventData'}, ...
                {}));
            parser.addParamValue('PadValue', 0, ...
                @(x) validateattributes(x, {'numeric'}, {'scalar'}));
        end % getParser
        
    end % static methods
    
end % blockedData

