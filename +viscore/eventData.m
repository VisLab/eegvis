% viscore.eventData   manages an array of events for block visualizations
%
% Usage:
%   >>  viscore.eventData(event)
%   >>  obj = viscore.eventData(event)
%   >>  obj = viscore.eventData(..., 'Name1', 'Value1', ...)
%
% Description:
% viscore.eventData(event) creates an object to hold events for
%    visualization. The event parameter is an array of structures.
%    The visualization is assumed to be divided into (potentially
%    overlapping) fixed length blocks that are used for summaries.
%
%
% viscore.eventData(events, 'Name1', 'Value1', ...) specifies
%     optional name/value parameter pairs:
%
%   'BlockStartTimes'   optional vector of start times (in seconds) of blocks
%   'BlockTime'         length of block in seconds
%   'EventOrder'        cell array specifying display order of unique event types
%   'MaxTime'           maximum time in seconds to use
%
%
% The event order is alphabetical by default. The order is relevant for
% the order in which events occur in the visualization. The EventOrder
% parameter allows users to over-ride this behavior by specifying the
% types of events that should appear first (and hence are displayed more
% prominently). Any event types not mentioned are not displayed.
%
% obj = viscore.eventData(...) returns a handle to the newly created
% object.
%
% Example 1:
% Create a blocked data object for a random array
%   data = random('normal', 0, 1, [32, 1000, 20]);
%   bd = viscore.eventData(data);
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
%  - The events are sorted in increasing chronological order by start times
%
% The event structure array should contain the following fields fields:
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
        BlockList;           % cell array indexing events in block
        BlockStartTimes;     % start time of each block in seconds
        BlockTime;           % time in seconds for one block
        EventEndTimes;       % double array of event end times
        EventCounts;         % type x blocks array with event counts
        EventStartTimes;     % double array of event start times
        EventTypeNumbers;    % cell array of event type numbers
        EventUniqueTypes;    % cell array of unique in desired order
        MaxTime;             % maximum time in seconds for events
        VersionID            % version ID of this event set
    end % private properties
    
    methods
        
        function obj = eventData(event, varargin)
            % Constructor parses parameters and sets up initial data
            c = viscore.counter.getInstance();
            obj.VersionID = num2str(c.getNext());  % Get a unique ID
            obj.parseParameters(event, varargin{:});
        end % eventData constructor
        
        
        function events = getBlocks(obj, startBlock, endBlock)
            % Return the row vector of doubles containing event numbers
            bStart = max(startBlock, 1);
            bEnd = min(endBlock, length(obj.BlockList));
            numEvents = 0;
            for k = bStart:bEnd
                numEvents = numEvents + length(obj.BlockList{k});
            end
            events = zeros(numEvents, 1);
            s = 1;
            for k = bStart:bEnd
                e = s + length(obj.BlockList{k}) - 1;
                events(s:e) = obj.BlockList{k};
                s = e + 1;
            end
            events = unique(events);
        end % getBlocks
        
        function blocklist = getBlockList(obj)
            % Return the cell array of block event lists
            blocklist = obj.BlockList;
        end % getBlockList
        
        
        function range = getBlockRange(obj, k)
            % Returns the range of block numbers occupied by event k
            range = floor(obj.SampleRate.* ...
                [obj.EventStartTimes(k), obj.EventEndTimes(k)]./ ...
                obj.BlockSize) + 1;
            if range(1) > length(obj.BlockList)
                range = [];
            end
            range(2) = min(range(2), length(obj.BlockList));
        end % getBlockRange
        
        function blockTime = getBlockTime(obj)
            % Return the time in seconds of a block
            blockTime = obj.BlockTime;
        end % getBlockTime
        
        function endTimes = getEndTimes(obj, varargin)
            % Return event end times - all or those specified by varargin
            if nargin == 1
                endTimes = obj.EventEndTimes;
            else
                endTimes = obj.EventEndTimes(varargin{1});
            end
        end % getEndTimes
        
        function event = getEvent(obj, k)
            % Return event k as a structure or empty
            event = [];
            if k < 1 || k > length(obj.EventTypes)
                return;
            end
            event.type = obj.EventTypes{k};
            event.startTime = obj.EventStartTimes(k);
            event.endTime = obj.EventEndTimes(k);
        end % getEvent
        
        function counts = getEventCounts(obj, startBlock, endBlock) %#ok<MANU>
            % Return types x blocks array of counts
            counts = eval(['obj.EventCounts(:, ' ...
                num2str(startBlock) ':' num2str(endBlock) ')']);
        end % getEventCounts
        
        
%         function events = getEvents(obj, type)
%             % Return the events of a particular type
%             events = {obj.Events.type};
%             eventIndices = strcmpi({obj.Events.type}, type);
%             events = events(eventIndices);
%         end % getEvents
%         
%         function [selected, limits] = getEventSlice(obj, dSlice)
%             % Return the event positions of the events in the slice
%             slices = dSlice.getParameters(3);
%             
%             slicePoints = eval(slices{2});
%             if isempty(slicePoints)
%                 selected = [];
%                 limits = [];
%                 return;
%             end
%             
%             firstTime = (min(slicePoints(:)) - 1)/obj.SampleRate;
%             lastTime = (max(slicePoints(:)) - 1)/obj.SampleRate;
%             selected = (firstTime <= obj.StartTimes &&  ...
%                 obj.StartTimes <= lastTime) || ...
%                 (firstTime <= obj.EndTimes &&  ...
%                 obj.EndTimes <= lastTime);
%             limits = [firstTime, lastTime];
%         end % getEventSlice
%         
        
        function numBlocks = getNumberBlocks(obj)
            % Returns the current number of blocks
            numBlocks = length(obj.BlockList);
        end % getNumberBlocks
        
%         function sampleRate = getSampleRate(obj)
%             % Return the current sample rate for this event set
%             sampleRate = obj.SampleRate;
%         end   % getSampleRate
%         
        function startTimes = getStartTimes(obj, varargin)
            % Return event start times - all or those specified by varargin
            if nargin == 1
                startTimes = obj.EventStartTimes;
            else
                startTimes = obj.EventStartTimes(varargin{1});
            end
        end % getStartTimes
        
        function types = getTypes(obj, varargin)
            % Return a cell array of event types in event order
            if nargin == 1
                types = obj.EventTypeNumbers;
            else
                types = obj.EventTypeNumbers(varargin{1});
            end
            types = obj.EventUniqueTypes(types);  % not correct
        end % getUniqueTypes
        
        
        function typeNumbers = getTypeNumbers(obj, varargin)
            % Return event type numbers - all or those specified by varargin
            if nargin == 1
                typeNumbers = obj.EventTypeNumbers;
            else
                typeNumbers = obj.EventTypeNumbers(varargin{1});
            end
        end % getTypeNumbers
        
        function uniqueTypes = getUniqueTypes(obj)
            % Return the unique event types
            uniqueTypes = obj.EventUniqueTypes;
        end % getUniqueTypes
        
        function version = getVersionID(obj)
            % Return version ID of this event set
            version = obj.VersionID;
        end % getVersionID
        
        function reblock(obj, blockTime, maxTime)
            % Reblock the event list to a new blocksize if not epoched
            %
            % Inputs:
            %    blockSize    size to make the windows
            %    maxTime      optional time in seconds of end range
            %
            % Notes:
            %  - no action is taken if data is epoched or blockSize <= 0
            %
            if isempty(blockTime) || blockTime <= 0
                return;
            end
            if nargin == 2 || isempty(maxTime)
                maxTime = max(obj.EventEndTimes);
            end
            if isempty(obj.BlockStartTimes)
               numBlocks = ceil(maxTime/blockTime);
            else
               numBlocks = length(obj.BlockStartTimes);
            end
            
            % Reblocking so the version changes
            c = viscore.counter.getInstance();
            obj.VersionID = num2str(c.getNext());  %
            obj.BlockTime = blockTime;
            
            obj.EventCounts = zeros(length(obj.EventUniqueTypes), numBlocks);
            obj.BlockList = cell(numBlocks, 1);
            for k = 1:length(obj.BlockList)
                obj.BlockList{k} = {};
            end;
            
            for k = 1:length(obj.EventStartTimes)
                startBlock = floor(obj.EventStartTimes(k)/blockTime) + 1;
                if startBlock > numBlocks
                    continue;
                end
                endBlock = min(floor(obj.EventEndTimes(k)/blockTime) + 1, ...
                    numBlocks);
                
                for j = startBlock:endBlock
                    obj.BlockList{j}{length(obj.BlockList{j}) + 1} = k;
                    obj.EventCounts(obj.EventTypeNumbers(k), j) = ...
                        obj.EventCounts(obj.EventTypeNumbers(k), j) + 1;
                end
            end
            
            % Now fix BlockList  elements to be arrays
            for k = 1:length(obj.BlockList)
                obj.BlockList{k} = cell2mat(obj.BlockList{k});
            end
            
        end % reblock  
        
    end % public methods
    
    methods(Access = private)
        
        function parseParameters(obj, event, varargin)
            % Parse parameters provided by user in constructor
            parser = viscore.eventData.getParser();
            parser.parse(event, varargin{:})
            % Get the parsed results
            p = parser.Results;
            
            % Handle the events
            obj.BlockTime = p.BlockTime;
            obj.BlockStartTimes = p.BlockStartTimes;
            obj.MaxTime = p.MaxTime;
            types = {p.event.type}';
            obj.EventStartTimes = cell2mat({p.event.startTime})';
            obj.EventEndTimes = cell2mat({p.event.endTime})';
            if sum(isnan(obj.EventStartTimes)) > 0 || sum(obj.EventStartTimes) < 0 > 0
                error('eventData:NonNegativeStart', ...
                    'Event start times must be non negative\n')
            elseif sum(isnan(obj.EventEndTimes)) > 0 || ...
                    sum(obj.EventStartTimes > obj.EventEndTimes) > 0
                error('eventData:StartEndMatch', ...
                    'Event end times must be greater than or equal to the endTimes\n');
            end
            
            % Process the event order parameter         
            obj.EventUniqueTypes = unique(types);       
            if isempty(obj.EventUniqueTypes{1})
                error('eventData:NonemptyType', ...
                    'Event types must be non empty\n');
            end
            if ~isempty(p.EventOrder)
                t = p.EventOrder;
                [iEvents, ia, ib] = intersect(obj.EventUniqueEvents, t); %#ok<ASGLU>
                t(ib) = [];
                obj.EventUniqueTypes = [iEvents(:); t(:)];
            end
            obj.EventTypeNumbers = zeros(length(types), 1);
            for k = 1:length(obj.EventUniqueTypes)
                obj.EventTypeNumbers(strcmpi(obj.EventUniqueTypes{k}, types)) = k;
            end
            
            obj.reblock(obj.BlockTime, obj.MaxTime);
        end % parseParameters
        
    end % private methods
    
    methods(Static = true)
        
        function parser = getParser()
            % Create a parser for eventData
            parser = inputParser;
            parser.StructExpand = true;
            parser.addRequired('event', ...
                @(x) (~isempty(x) && isstruct(x)) && ...
                sum(isfield(x, {'type', 'startTime', 'endTime'})) == 3);
            parser.addParamValue('BlockStartTimes', [], ...
                @(x)(isempty(x) || (iscolumn(x) && isnumeric(x))));
            parser.addParamValue('BlockTime', 1, ...
                @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));
            parser.addParamValue('EventOrder', {}, ...
                @(x) (isempty(x) || (iscolumn(x) && sum(~iscellstr(x)) == 0)));
            parser.addParamValue('MaxTime', [], ...
               @(x) (isempty(x) || (isnumeric(x) && isscalar(x) && x > 0)));
        end % getParser
        
        function event = getEventStructure(EEG)
            % Returns a structure for an EEG type structure
            if ~isstruct(EEG) ||~isfield(EEG, 'event') || isempty(EEG.event)
                event = [];
                return;
            end
            types = {EEG.event.type}';
            startTimes = (round(double(cell2mat({EEG.event.latency}))') - 1)./EEG.srate;
            endTimes = startTimes + 1/EEG.srate;
            event = struct('type', types, 'startTime', num2cell(startTimes), ...
                'endTime', num2cell(endTimes));
        end % getEventStructure
   
    end % static methods
    
end % eventData

