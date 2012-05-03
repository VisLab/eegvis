% viscore.eventData   manages an array of events for visualization
%
% Usage:
%   >>  viscore.eventData(types)
%   >>  viscore.eventData(types, startTimes)
%   >>  viscore.eventData(types, startTimes, endTimes)
%   >>  viscore.eventData(types, startTimes, endTimes, eventOrder)
%   >>  obj = viscore.eventData(...)
%
% Description:
% viscore.eventData(events, eventsID) creates an object to hold events for 
%    visualization. The events parameter is an array of structures, 
%    and the eventsID is a string identifying this set of events. 
%    This ID is used as part of visualization titles.
%
%
% viscore.eventData(events, eventsID, 'key1', 'value1', ...| specifies
%     optional name/value parameter pairs:
%   'EventOrder'        cell array specifying display order of event types
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
        EndTimes;            % double array of event end times
        StartTimes;          % double array of event start times
        Types;               % listing of events
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
        
        function event = getEvent(obj, k)
            % Return event k or empty
            event = [];
            try
               event = obj.Events(k);    
            catch ME %#ok<NASGU>
            end
        end % getEvent
        
        function events = getEvents(obj, type)
            % Return the events of a particular type
            events = {obj.Events.type};
            eventIndices = strcmpi({obj.Events.type}, type);
            events = events(eventIndices);
        end % getEvents
        
        
        function version = getVersionID(obj)
            % Return version ID of this event set
            version = obj.VersionID;
        end % getVersionID
        
    end % public methods
    
    methods(Access = private)
        
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
                    (size(pdata.EndTimes) ~= size(pdata.StartTimes))
               error('eventData:StartEndMatch', ...
                    'The event startTimes and endTimes must be same length\n'); 
            elseif isempty(pdata.EndTimes)
                obj.EndTimes = obj.StartTimes;
            else
                obj.EndTimes = double(pdata.EndTimes);
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
            parser.addOptional('EventOrder', {}, ...
                @(x) (isempty(x) || (iscolumn(x) && sum(~iscellstr(x)) == 0)));
        end % getParser
        
    end % static methods
    
end % eventData

