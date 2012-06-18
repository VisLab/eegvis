% visviews.eventStackedPlot()  display stacked view of individual element or window events
%
% Usage:
%   >>  visviews.eventStackedPlot(parent, manager, key)
%   >>  obj = visviews.eventStackedPlot(parent, manager, key)
%
% Description:
% obj = visviews.eventStackedPlot(parent, manager, key) shows each 
%     member of a slice of events offset vertically, with the lowest numbered 
%     member at the top and the highest number slice at the bottom. 
%     The stacked event plot can show three possible slices: by channel, 
%     by sample, or by window. Plotting by window is the most traditional display. 
% 
%     The parent is a graphics handle to the container for this plot. The
%     manager is an viscore.dataManager object containing managed objects
%     for the configurable properties of this object, and |key| is a string
%     identifying this object in the property manager GUI.
% 
%
% obj = visviews.eventStackedPlot(parent, manager, key) returns a handle to
%     the newly created object.
%
% visviews.eventStackedPlot is configurable, resizable, and cursor explorable.
%
%
% Configurable properties:
% The visviews.eventStackedPlot has five configurable parameters: 
%
% ClippingOn    is a boolean, which if true causes the individual events
%               to be truncated so that they appear inside the axes. 
%
% CombineMethod specifies how to combine multiple blocks 
%               when displaying a clumped slice.  The value can be 
%               'max', 'min', 'mean', 'median', or 
%               'none' (the default). 
%
% RemoveMean    is a boolean flag specifiying whether to remove the 
%               the individual channel means for the data before 
%               trimming or plotting.
%
% SignalLabel   is a string identifying the units of the event. 
%
% SignalScale   is a numerical factor specifying the vertical spacing 
%               of the individual line plots. The spacing is SignalScale 
%               times the 10% trimmed mean of the standard deviation 
%               of the data.
%
% TrimPercent   is a numerical value specifying the percentage of 
%               extreme points to remove from the window before 
%               plotting. If the percentage is t, the largest
%               t/2 percentage and the smallest t/2 percentage of the
%               data points are removed (over all elements or channels).
%               The event scale is calculated relative to the trimmed 
%               event and all of the events are clipped at the
%               trim cutoff before plotting.
%
% Example: 
% Create a stacked event plot for random events
%
%   % Create a sinusoidal data set with random amplitude and phase 
%   data = random('normal', 0, 1, [32, 1000, 20]);
%   testVD = viscore.blockedData(data, 'Rand1');
%
%   % Create a block function and a slice
%   defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
%              visfuncs.functionObj.getDefaultFunctions());
%   thisFunc = defaults{1};
%   thisSlice = viscore.dataSlice('Slices', {':', ':', '1'}, ...
%               'DimNames', {'Channel', 'Sample', 'Window'});
%
%   % Create the figure and plot the data
%   sfig  = figure('Name', 'Stacked event plot with random data');
%   sp = visviews.eventStackedPlot(sfig3, [], []);
%   sp.SignalScale = 2.0;
%   sp.plot(testVD3, thisFunc, thisSlice);
%  
%   % Adjust the margins
%   gaps = sp.getGaps();
%   sp.reposition(gaps);
%
% Notes:
% -  If manager is empty, the class defaults are used to initialize
% -  If key is empty, the class name is used to identify in GUI configuration
% -  The plot calculates the spacing as the event scale times the
%    10% trimmed mean of the standard deviations of the event. That is,
%    the standard deviation of each plot is calculated. Then the lower
%    and upper 5% of the values are removed and the mean standard
%    deviation is computed. This value is multiplied by the event scale
%    to determine the plot spacing.
%
% Class documentation:
% Execute the following in the MATLAB command window to view the class 
% documentation for visviews.eventStackedPlot:
%
%    doc visviews.eventStackedPlot
%
% See also: visviews.clickable, visviews.configurable, visviews.resizable, and
%           visviews.shadowSignalPlot
%


% Copyright (C) 2011  Kay Robbins, UTSA, krobbins@cs.utsa.edu
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
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

% $Log: eventStackedPlot.m,v $
% Revision: 1.00  04-Dec-2011 09:11:20  krobbins $
% Initial version $
%

classdef eventStackedPlot < visviews.axesPanel  & visprops.configurable 
    %Panel that plots window events
    %
    % Inputs:
    %    parent    handle of parent container for this panel
    %    settings  structure or ModelSettings object containing this
    
    properties
        ColorSelected = [1, 0, 0];   % face color of selected event
        ColorUnselected = [0, 1, 0]; % face color of unselected events
    end % public properties 
    
    properties (Access = private)   
        ColorLines = [0.8, 0.8, 0.8]; % color of grid lines

        CurrentSlice = [];           % current data slice
        CurrentEvents = [];          % array with current event numbers
        Events = [];                 % events currently plotted in this panel
        HitList = {};                % list of hithandles
        LineWidthSelected = 2.0;     % width of selected event line  
        LineWidthUnselected = 0.5;   % width of unselected event line    
        PlotSpacing = [];            % spacing between plot axes
        PlotWindow = true;           % if true, a window is being plotted
        SelectedBlockOffset = 0;     % start of selected block in seconds
        SelectedHandle = [];         % handle of selected event or empty
        SelectedEvent = [];          % data in selected event or empty
        SelectedTagNumber = [];      % number of selected event within events
        
        StartBlock = 1;              % starting block of currently plotted slice
        StartEvent = 1;              % starting event of currently plotted slice 
        TotalBlocks = 0;             % total number of blocks in the data
        UniqueEvents = 0;            % cell array of unique events
        VisData = [];                % original data for interrogation
        TimeUnits = 'sec';           % time units of the access
        XValues = [];                % x values of current plot
    end % private properties
    
    methods
        
        function obj = eventStackedPlot(parent, manager, key)
            % Create a stacked event plot, updating properties from  manager
            obj = obj@visviews.axesPanel(parent);
            obj = obj@visprops.configurable(key);
            % Update properties if any are available
            if isa(manager, 'viscore.dataManager')
                visprops.property.updateProperties(obj, manager);
            end
            set(obj.MainAxes, 'Box', 'on', 'YDir', 'reverse', ...
                'Tag', 'stackedSignalAxes', 'HitTest', 'on');
        end % eventStackedPlot constructor
        
        function [cbHandles, hitHandles] = getHitObjects(obj)
            % Return handles to register as callbacks and hit handles
            % Required for the visviews.clickable interface
            cbHandles = obj.HitList;
            hitHandles = obj.HitList;
        end % getHitObjects
        
        function plot(obj, visData, bFunction, dSlice)
            % Plot the events for the specified data slice
            obj.reset();
            if isempty(visData)
                return;
            end
            bFunction.setData(visData);
            obj.VisData = visData; % Keep data for cursor exploration

            obj.Events = visData.getEvents();    
            if isempty(obj.Events)
                return;
            end
            % Figure out whether the slice is by window or by element
            if isempty(dSlice)
               obj.CurrentSlice = viscore.dataSlice();
            else
                obj.CurrentSlice = dSlice;
            end
            
            % Calculate sizes and number of clumps, adjust for uneven clumps
            [e, s, b] = visData.getDataSize();
            [slices, names, cDims] = obj.CurrentSlice.getParameters(3);
 
            if isempty(cDims) || ~isempty(intersect(cDims, 3))  % Plot all elements for a window
                obj.PlotWindow = true; 
            elseif ~isempty(intersect(cDims, 1))  % Plot all windows for an element    
                obj.PlotWindow = false;
            else
                warning('eventStackedPlot:plotSlice', ...
                        'array slice is empty and cannot be plotted');
                return;
            end
            
            % Extract the signal based on the slice (May not need this)       

            [dSlice, starts, sizes] = viscore.dataSlice.getSliceEvaluation(...
                                       [e, s, b], slices); %#ok<ASGLU>
            obj.StartBlock = starts(3);
            obj.TotalBlocks = sizes(3);
            
                       % Adjust signals to account for blocking
            if obj.PlotWindow  % Plot all elements for a window           
                % If continguous windows are plotted reshape to align
                obj.XLimOffset = (starts(3) - 1)*obj.Events.getBlockTime();
                obj.XStringBase = [names{3} ' ' ...
                  viscore.dataSlice.rangeString(obj.StartBlock, obj.TotalBlocks)];

            else % Plot all windows for an element
                obj.XLimOffset = 0;
                obj.XStringBase = [names{3} ' ' ...
                  viscore.dataSlice.rangeString(obj.StartBlock, obj.TotalBlocks)];
            end
          
           % Adjust the labels
            if visData.isEpoched() % add time scale to x label
                obj.XValues =  1000*visData.getEpochTimeScale();
                obj.XValues = [obj.XValues(1), obj.XValues(end)];
                obj.XStringBase = ['Time(ms) [' obj.XStringBase ']'];
                obj.TimeUnits = 'ms';
            else    
                obj.XValues = [obj.XLimOffset, ...
                         obj.XLimOffset + obj.Events.getBlockTime()];
                obj.XStringBase = ['Time(s) [' obj.XStringBase ']'];
                obj.TimeUnits = 'sec';
            end
           
            obj.CurrentEvents = obj.Events.getBlocks(obj.StartBlock, ...
                obj.StartBlock + obj.TotalBlocks - 1);
            obj.UniqueEvents = obj.Events.getUniqueTypes();
            obj.YStringBase = 'Events';
            obj.SelectedHandle = [];
            obj.SelectedEvent = [];
            obj.YString = obj.YStringBase;
            obj.XString = obj.XStringBase;
            obj.displayPlot();
        end % plot
        
        function reset(obj)
            obj.reset@visviews.axesPanel();
            obj.HitList = {};
        end % reset

        function s = updateString(obj, point)
            % Return [Block, Element, Function] value string for point
            s = '';   % String to be returned
            try   % Use exception handling for small round-off errors
                [x, y, xInside, yInside] = obj.getDataCoordinates(point); %#ok<ASGLU>
                if ~xInside || ~yInside
                    return;
                end
                
                if ~obj.VisData.isEpoched()
                    t = x + obj.SelectedBlockOffset;
                    sample = floor(obj.VisData.SampleRate*(t)) + 1;
                    s = {['t: ' num2str(t) ' ' obj.TimeUnits]; ...
                        ['s: ' num2str(sample)]};
                    if ~isempty(obj.SelectedHandle)
                        rs = floor(obj.VisData.SampleRate*(x - obj.XLimOffset)) + 1;
                        s{3} = ['raw: '  num2str(obj.SelectedSignal(rs)) ...
                            ' ' obj.SignalLabel];
                    end
                else
                    a = (x - obj.VisData.EpochTimes(1))./1000;
                    a = floor(obj.VisData.SampleRate*a) + 1;
                    s = {['et: ' num2str(x) ' ' obj.TimeUnits]; ...
                        ['es: ' num2str(a)]};
                    if ~isempty(obj.SelectedHandle)
                        z = {['v: '  num2str(obj.SelectedSignal(a)) ...
                            ' ' obj.SignalLabel]};
                        s = [s; z];
                    end;
                end
            catch  ME  %#ok<NASGU>   ignore errors on cursor sweep
            end
        end % updateString
        
        function buttonDownPreCallback(obj, src, eventdata, master)  %#ok<INUSD>
            % Callback when user clicks on the plot to select a event
            if ~isempty(obj.SelectedHandle) && ishandle(obj.SelectedHandle)
                set(obj.SelectedHandle, ...
                    'MarkerFaceColor', obj.ColorUnselected, ...
                    'Color', obj.ColorUnselected);
            end

            if ~strcmpi(get(src, 'Type'), 'line')
                obj.SelectedHandle = [];
                obj.SelectedEvent = []; 
                obj.XString = obj.XStringBase;
                return;
            end 
            set(src, 'MarkerFaceColor', obj.ColorSelected, ...
                     'Color', obj.ColorSelected);
            obj.SelectedHandle = src;
            event = get(src, 'Tag');
            obj.SelectedEvent = str2double(event); 
            type = obj.Events.getTypes(obj.SelectedEvent); 
            obj.XString = [obj.XStringBase ' {Event('  event '): ' ...
                  type{1} ' [' ...
                  num2str(obj.Events.getStartTimes(obj.SelectedEvent)) ...
                  ', '  num2str(obj.Events.getEndTimes(obj.SelectedEvent)) ']}' ];
            obj.redraw();
        end % buttonDownPreCallback
        
    end % public methods
    
    methods (Access = private)
        
        function displayPlot(obj)
            % Plot the events stacked one on top of another
            obj.reset();
            % Go no further if events is empty
            if isempty(obj.Events)
                return;
            end        
              
            numPlots = length(obj.UniqueEvents);
            if numPlots == 0 
                warning('eventStackedPlot:NaNValues', 'No events');
                return;
            end
            %y-axis reversed, so must plot the negative of the events            
            sTimes = obj.Events.getStartTimes(obj.CurrentEvents);
            eTimes = obj.Events.getEndTimes(obj.CurrentEvents);
            tNums = obj.Events.getTypeNumbers(obj.CurrentEvents);
            obj.HitList = cell(1, length(obj.CurrentEvents) + 1);
            obj.HitList{1} = obj.MainAxes;
            for k = 1:length(obj.CurrentEvents);
                h =  plot(obj.MainAxes, [sTimes(k); eTimes(k)], ...
                          [tNums(k); tNums(k)], '-s', ...
                         'Tag', num2str(obj.CurrentEvents(k)), ...
                          'LineWidth', 4,...
                          'Color', obj.ColorUnselected, ...
                          'MarkerEdgeColor', 'k',...
                          'MarkerFaceColor', obj.ColorUnselected,...
                          'MarkerSize', 10);
                obj.HitList{k + 1} = h;
            end
           
            yTickLabels = cell(1, numPlots);
            yTickLabels{1} = '1';
            yTickLabels{numPlots} = num2str(numPlots);
            set(obj.MainAxes,  'YLimMode', 'manual', ...
                'YLim', [0, numPlots + 1], ...
                'YTickMode', 'manual', 'YTickLabelMode', 'manual', ...
                'YTick', 1:numPlots, 'YTickLabel', yTickLabels, ...
                'XLim', obj.XValues, ...
                'XLimMode', 'manual', 'XTickMode', 'auto');
             obj.redraw();
        end % plot
        
    end % private methods
    
    methods(Static=true)
        
        function settings = getDefaultProperties()
            % Structure specifying how to set configurable public properties
            cName = 'visviews.eventStackedPlot';
            settings = struct( ...
                'Enabled',       {true,           true}, ...
                'Category',      {cName,          cName}, ...
                'DisplayName',   {'Color selected',  'Color unselected'}, ...
                'FieldName',     {'ColorSelected',   'ColorUnselected'}, ...
                'Value',         {[1, 0, 0],         [0, 1, 0]}, ...
                'Type',          { ...
                'visprops.colorProperty', ...
                'visprops.colorProperty'}, ...
                'Editable',      {true,              true}, ...
                'Options',       {'',         ''}, ...
                'Description',   { ...
                'Color of selected event', ...
                'Color of unselected event'} ...
                );
        end % getDefaultProperties
        
        
    end % static methods
    
end % eventStackedPlot
