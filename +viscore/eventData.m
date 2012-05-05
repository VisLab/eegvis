% viscore.eventData   manages an array of events for visualization
%
% Usage:
%   >>  viscore.eventData(types, startTimes)
%   >>  viscore.eventData(types, startTimes, endTimes)
%   >>  obj = viscore.eventData(..., 'Name', 'Value')
%
% Description:
% viscore.eventData(types, startTimes) creates an object to hold events for
%    visualization. The events parameter is an array of structures,
%    and the eventsID is a string identifying this set of events.
%    This ID is used as part of visualization titles.
%
%
% viscore.eventData(events, eventsID, 'key1', 'value1', ...| specifies
%     optional name/value parameter pairs:
%   'EventOrder'        cell array specifying display order of event types
%   'Probabilities'     cell array specifying display order of event types
%
% The event order is alphabetical by default. The order is relevant for
% the order in which events occur in the visualization. The EventOrder
% parameter allows users to over-ride this behavior by specifying the
% types of events that should appear first (and hence are displayed more
% prominently). Any event types not mentioned follow the specified ones
% in alphabetical order.
%
% obj = viscore.eventData(...) returns a handle to the newly created
% object.
%
% Example 1:
% Create a blocked data object for a random array
%   data = random('normal', 0, 1, [32, 1000, 20]);
%   bd = viscore.eventData(data, 'Normal(0, 1)');
%
% Example 2:
% Reblock a data object in blocks of 500 frames
%   data = random('normal', 0, 1, [32, 1000, 20]);
%   bd = viscore.eventData(data, 'Normal(0, 1)');
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
% The events structure array should contain the following fields fields:
%    type        a string identifying the type of event
%    startTime   double time in seconds of the start of the event from the
%                beginning
%    endTime     double specifying the time in sections of the end of
%                the event from the beginning
% The Events structure array may have other fields, which are ignored.
%
%
%
% Class documentation:
% Execute the following in the MATLAB command window to view the class
% documentation for viscore.eventData:
%
%    doc viscore.eventData
%
% See also: viscore.blockData
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
% $Log: eventData.m,v $
% $Revision: 1.00 04-Dec-2011 09:11:20 krobbins $
% $Initial version $
%

classdef eventData < hgsetget
    
    properties (Access = private)
 
        BlockEvents;         % cell array indexing events in block
        BlockRange;          % array indicating block range each event
        BlockSize;           % size of the
        EndTimes;            % double array of event end times
        Epoched;             % true if the data is epoched
        MaxTime;             % maximum time to block for
        SamplingRate;        % sampling rate for current block size
        StartTimes;          % double array of event start times
        Types;               % cell array of event types
        UniqueTypes;         % cell array of unique in desired order
        VersionID            % version ID of this event set
    end % private properties
    
    methods
        
        function obj = eventData(types, startTimes, varargin)
            % Constructor parses parameters and sets up initial data
            c = viscore.counter.getInstance();
            obj.VersionID = num2str(c.getNext());  % Get a unique ID
            obj.parseParameters(types, startTimes, varargin{:});
        end % eventData constructor
        
        function blocks = getBlocks(obj)
            % Return the cell array of block event lists
            blocks = obj.Blocks;
        end % getBlocks
        
        function block = getBlock(obj, k)
            % Return the row vector of doubles containing
        end
        
        function blockSize = getBlockSize(obj)
            % Return the current block size for this event set
            blockSize = obj.BlockSize;
        end % getBlockSize
        
        function endTimes = getEndTimes(obj)
            % Return event end times
            endTimes = obj.EndTimes;
        end % getEndTimes
        
        function event = getEvent(obj, k)
            % Return event k as a structure or empty
            event = [];
            try
                event.type = obj.Types{k};
                event.startTime = obj.StartTimes(k);
                event.endTime = obj.EndTimes(k);
                event.blocks = obj.Blocks{k};
            catch ME %#ok<NASGU>
            end
        end % getEvent
        
        function events = getEvents(obj, type)
            % Return the events of a particular type
            events = {obj.Events.type};
            eventIndices = strcmpi({obj.Events.type}, type);
            events = events(eventIndices);
        end % getEvents
        
        function maxTime = getMaxTime(obj)
            % Return the maximum time blocked for this event set
            maxTime = obj.MaxTime;
        end  % getMaxTime
        
        function samplingRate = getSamplingRate(obj)
            % Return the current sampling rate for this event set
            samplingRate = obj.SamplingRate;
        end   % getSamplingRate
        
        function startTimes = getStartTimes(obj)
            % Return event start times
            startTimes = obj.StartTimes;
        end % getStartTimes
         
        function version = getVersionID(obj)
            % Return version ID of this event set
            version = obj.VersionID;
        end % getVersionID
        
        function reblock(obj, blockSize, maxTime)
            % Reblock the event list to a new blocksize if not epoched
            %
            % Inputs:
            %    blockSize    size to make the windows
            %    maxTime      optional time in seconds of end range
            %
            % Notes:
            %  - no action is taken if data is epoched or blockSize <= 0
            %
            if isempty(blockSize) || blockSize <= 0 || obj.Epoched
                return;
            end
            if isempty(maxTime)
                maxTime = max(obj.EndTimes);
            end
            numBlocks = ceil(maxTime/blockSize);
            if ~isempty(obj.BlockSize) && ~isempty(obj.Blocks) && ...
                    numBlocks == size(obj.Blocks, 1) && ...
                    blockSize == obj.BlockSize
                return;    % no change so don't reblock
            end
            
            % Reblocking so the version changes
            c = viscore.counter.getInstance();
            obj.VersionID = num2str(c.getNext());  %
            obj.BlockSize = round(blockSize);
            obj.MaxTime = maxTime;
            
            obj.InitializeBlocks();
        end % reblock
        
    end % public methods
    
    
    methods(Access = private)
        
        function initializeBlocks(obj)
            % Initialize the Blocks cell array to hold the block numbers
            numBlocks = ceil(maxEnd/obj.BlockSize);
            obj.BlockList = cell(numBlocks, 1);
            for k = 1:length(BlockList)
                obj.BlockList{k} = {};
            end;
            obj.BlockEvents = cell(length(obj.Types), 1);
            for k = 1:length(obj.BlockEvents)
                obj.BlockEvents{k} = {};
            end;
            
            obj.BlockRange = zeros(length(obj.Types), 2);
            for k = 1:length(obj.Types)
                startBlock = floor(obj.StartTime/obj.BlockSize) + 1;
                if startBlock < numBlocks
                    continue;
                end
                endBlock = min(floor(obj.EndTime/obj.BlockSize) + 1, ...
                               numBlocks);
   
                obj.BlockRange(k, :) = [startBlock, endBlock];
                for j = startBlock:endBlock
                    obj.Blocks{j}{length(obj.Blocks{j}) + 1} = k;
                end
            end
        end % initializeBlocks
        
        function parseParameters(obj, types, startTimes, varargin)
            % Parse parameters provided by user in constructor
            parser = viscore.eventData.getParser();
            parser.parse(types, startTimes, varargin{:})
            % Get the parsed results
            pdata = parser.Results;
            
            % Handle the events
            obj.Types = pdata.Types;
            obj.StartTimes = double(pdata.StartTimes);
            if ~isempty(pdata.EndTimes) && ...
                    (size(pdata.EndTimes, 1) ~= size(pdata.StartTimes, 1))
                error('eventData:StartEndMatch', ...
                    'The event startTimes and endTimes must be same length\n');
            elseif isempty(pdata.EndTimes)
                obj.EndTimes = obj.StartTimes;
            else
                obj.EndTimes = double(pdata.EndTimes);
            end
            obj.Epoched = false;
            obj.BlockSize = pdata.BlockSize;
            obj.MaxTime = pdata.MaxTime;
            obj.SamplingRate = pdata.SamplingRate;
            if isempty(obj.MaxTime)
                obj.MaxTime = max(obj.EndTimes);
            end
            
            % Process the event order parameter
            obj.UniqueTypes = unique(obj.Types);
            if ~isempty(pdata.EventOrder)
                t = pdata.EventOrder;
                [iEvents, ia, ib] = intersect(obj.UniqueEvents, t); %#ok<ASGLU>
                t(ib) = [];
                obj.UniqueTypes = [iEvents(:); t(:)];
            end
            
        end % parseParameters
        
    end % private methods
    
    methods(Static = true)
        
        function parser = getParser()
            % Create a parser for eventData
            parser = inputParser;
            parser.addRequired('Types',  ...
                @(x) (~isempty(x) && iscolumn(x) && sum(~iscellstr(x)) == 0));
            parser.addRequired('StartTimes',  ...
                @(x) (~isempty(x) && iscolumn(x) && isnumeric(x)) && ...
                sum(isnan(x)) == 0);
            parser.addOptional('EndTimes', [], ...
                @(x) (isempty(x) || (iscolumn(x) && isnumeric(x)) && ...
                sum(isnan(x)) == 0));
            parser.addParamValue('BlockSize', 1, ...
                @(x) validateattributes(x, {'numeric'}, ...
                {'scalar', 'nonnegative'}));
            parser.addParamValue('EventOrder', {}, ...
                @(x) (isempty(x) || (iscolumn(x) && sum(~iscellstr(x)) == 0)));
            parser.addParamValue('MaxTime', [], ...
                @(x) (isempty(x) || (isnumeric(x) && isscalar(x) && x > 0)))
            parser.addParamValue('Probabilities', [], ...
                @(x) (isnumeric(x)));
            parser.addParamValue('SamplingRate', 1, ...
                @(x) validateattributes(x, {'numeric'}, ...
                {'scalar', 'nonnegative'}));
        end % getParser
        
    end % static methods
    
end % eventData
    
