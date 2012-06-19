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
        BlockList = {};      % cell array indexing events in block
        BlockStartTimes;     % start time of each block in seconds
        BlockTime;           % time in seconds for one block
        EpochList;           % cell array with the epoch numbers
        EventEndTimes;       % double array of event end times
        EventCounts;         % type x blocks array with event counts
        EventStartTimes;     % double array of event start times
        EventTypeNumbers;    % cell array of event type numbers
        EventUniqueTypes;    % cell array of unique in desired order
        MaxTime;             % maximum time in seconds for events
        Preblocked;          % true if block start times are fixed (no reblocking)
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
        
        function blockStartTimes = getBlockStartTimes(obj)
            % Return a vector of the block or epoch start times
            blockStartTimes = obj.BlockStartTimes;
        end % getBlockStartTimes
        
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
        
        function eList = getEpochs(obj, k)
            % Return the time in seconds of a block
            eList = obj.EpochList{k};
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
        
        function numBlocks = getNumberBlocks(obj)
            % Returns the current number of blocks
            numBlocks = length(obj.BlockList);
        end % getNumberBlocks
        
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
            % Reblock the event list to a new blocksize
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
            elseif nargin > 2 && ~isempty(maxTime)
                obj.MaxTime = maxTime;
            end
            if ~obj.Preblocked
                obj.BlockStartTimes = ...
                    (0:(ceil(obj.MaxTime/blockTime)-1)).*obj.BlockTime;
            end
            
            % Reblocking so the version changes
            c = viscore.counter.getInstance();
            obj.VersionID = num2str(c.getNext());  %
            obj.BlockTime = blockTime;
            obj.calculateBlockList();
        end % reblock
        
        
        
        function calculateBlockList(obj)
            % Return the starting block numbers of each event
            numBlocks = length(obj.BlockStartTimes);
            blockEnds = obj.BlockStartTimes + obj.BlockTime;
            obj.EventCounts = zeros(length(obj.EventUniqueTypes), numBlocks);
            obj.BlockList = cell(numBlocks, 1);
            for k = 1:length(obj.BlockList)
                obj.BlockList{k} = {};
            end;
            startBlocks = calculateStartBlocks(obj);
            for k = 1:length(obj.EventStartTimes)
                for j = 1:length(startBlocks{k});
                    s = startBlocks{k}(j);
                    for n = s:numBlocks
                        obj.BlockList{n}{length(obj.BlockList{n}) + 1} = k;
                        obj.EventCounts(obj.EventTypeNumbers(k), n) = ...
                            obj.EventCounts(obj.EventTypeNumbers(k), n) + 1;
                        if blockEnds(n) >= obj.EventEndTimes(k)
                            break;
                        end
                    end
                end
            end
            % Now fix BlockList elements to be arrays
            for k = 1:length(obj.BlockList)
                obj.BlockList{k} = cell2mat(obj.BlockList{k});
            end
        end % calculateStartBlocks
        
        function startBlocks = calculateStartBlocks(obj)
            startBlocks = cell(length(obj.EventStartTimes), 1);
            for k = 1:length(obj.EventStartTimes)
                if ~obj.Preblocked  % calculate events based on position
                    startBlocks{k} = floor(obj.EventStartTimes(k)/obj.BlockTime) + 1;
                elseif  ~isempty(obj.EpochList)  % Calculate based on explicit list
                    startBlocks{k} = obj.EpochList{k};
                else
                    startBlocks{k} = find( ...
                        obj.BlockStartTimes <= obj.EventStartTimes(k) && ...
                        obj.EventStartTimes(k) < blockEnds(s));
                end
            end
        end % calculateStartBlocks
    end % public methods
    
    methods(Access = private)
        function parseParameters(obj, event, varargin)
            % Parse parameters provided by user in constructor
            parser = viscore.eventData.getParser();
            parser.parse(event, varargin{:})
            % Get the parsed results
            p = parser.Results;
            
            % Set the events
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
            
            %              % Events must be sorted by increasing start times
            %             [obj.EventStartTimes, iorder] = sort(obj.EventStartTimes);
            %             obj.EventEndTimes = obj.EventEndTimes(iorder);
            %             types = types(iorder);
            %
            % Process the event types
            [obj.EventUniqueTypes, ia, obj.EventTypeNumbers] = ...
                unique(types);        %#ok<ASGLU>
            if isempty(obj.EventUniqueTypes{1})
                error('eventData:NonemptyType', ...
                    'Event types must be non empty\n');
            end
            
            % Figure out the maximum time
            obj.MaxTime = p.MaxTime;
            obj.BlockTime = p.BlockTime;
            if ~isempty(p.BlockStartTimes)
                obj.Preblocked = true;
                obj.BlockStartTimes = ...
                    reshape(p.BlockStartTimes, length(p.BlockStartTimes), 1);
                if isempty(obj.MaxTime)
                    obj.MaxTime = max(obj.BlockStartTimes) + obj.BlockTime;
                end
                if isfield(p.event, 'epochs')
                    obj.EpochList = {p.event.epochs}';
                end
            else
                obj.Preblocked = false;
                if isempty(obj.MaxTime)
                    obj.MaxTime = max(obj.EventEndTimes);
                end
                
            end
            
            obj.reblock(obj.BlockTime, obj.MaxTime);
        end % parseParameters
        
    end % private methods
    
    methods(Static = true)
        
        function [event, epochStarts, epochScale] = getEEGTimes(EEG)
            % Return epoch start times in seconds and time scale in ms
            event = [];
            epochStarts = [];
            epochScale = [];
            if ~isstruct(EEG) ||~isfield(EEG, 'event') || isempty(EEG.event)
                return;
            end
            
            % Construct the events
            types = {EEG.event.type}';
            uEvents = cell2mat({EEG.event.urevent}');
            eLatencies = double(cell2mat({EEG.urevent(uEvents).latency}'));
            startTimes = (round(eLatencies) - 1)./EEG.srate;
            endTimes = startTimes + 1/EEG.srate;
            
            
            % Now look at the epochs
            if ~isfield(EEG,'epoch') ||  isempty(EEG.epoch) % not epoched
                event = struct('type', types, 'startTime', num2cell(startTimes), ...
                    'endTime', num2cell(endTimes));
                return;
            end
            epochList = {EEG.event.epoch}';
            event = struct('type', types, 'startTime', num2cell(startTimes), ...
                'endTime', num2cell(endTimes), 'epochs', epochList);
            if ~isstruct(EEG) ||~isfield(EEG, 'times')
                epochScale = (0:(length(EEG.epoch) - 1))'/EEG.srate;
            else
                epochScale = reshape(EEG.times, length(EEG.times), 1)./1000;
            end
            epochBase = epochScale(1);
            
            epochStarts = zeros(length(EEG.epoch), 1);
            for k = 1:length(EEG.epoch)
                u = EEG.event(EEG.epoch(k).event(1)).urevent;
                epochStarts(k) = epochBase + ...
                    (EEG.urevent(u).latency - 1)./EEG.srate - ...
                    EEG.epoch(k).eventlatency{1}./1000;
                epochStarts(k) = round(epochStarts(k)*EEG.srate)./EEG.srate;
            end
        end  % getEpochTimes
        
        function parser = getParser()
            % Create a parser for eventData
            parser = inputParser;
            parser.StructExpand = true;
            parser.addRequired('event', ...
                @(x) (~isempty(x) && isstruct(x)) && ...
                sum(isfield(x, {'type', 'startTime', 'endTime'})) == 3);
            parser.addParamValue('BlockStartTimes', [], ...
                @(x)(isempty(x) || isnumeric(x)));
            parser.addParamValue('BlockTime', 1, ...
                @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));
            %             parser.addParamValue('Epoched', false, ...
            %                 @(x) validateattributes(x, {'logical'}, {}));
            parser.addParamValue('MaxTime', [], ...
                @(x) (isempty(x) || (isnumeric(x) && isscalar(x) && x > 0)));
        end % getParser
        
        
        
    end % static methods
    
end % eventData

