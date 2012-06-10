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
        CombineMethod = 'mean';      % method for combining dimensions for display
        EventScale = 3;              % event scale
    end % public properties 
    
    properties (Access = private)   
        Colors = [];                 % needed for clickable
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
        SelectedSignal = [];         % data in selected event or empty
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
            % Plot specified data slice of visData using bFunction's colors
            obj.reset();
            bFunction.setData(visData);
            obj.VisData = visData; % Keep data for cursor exploration
            if isempty(visData)
                return;
            end
            obj.Events = visData.getEvents();    
            if isempty(obj.Events)
                return;
            end
            % Figure out whether the slice is by window or by element
            if isempty(dSlice)
               obj.CurrentSlice = viscore.dataSlice(...
                                      'CombineMethod', obj.CombineMethod);
            else
                obj.CurrentSlice = dSlice;
            end
            
            [slices, names, cDims] = obj.CurrentSlice.getParameters(3);
            if ~isempty(cDims)  && isempty(intersect(cDims, 3))  % Plot all events for a window
                return;
            end
            sStart = [1, 1, 1];
            obj.StartBlock = sStart(3);
            obj.CurrentEvents = obj.Events.getBlock(1, 1);
            obj.UniqueEvents = obj.Events.getUniqueTypes();
            obj.XLimOffset = (sStart(3) - 1)* ...
                obj.Events.getBlockSize()/obj.Events.getSampleRate();
            obj.XStringBase = [names{1} ' '  ...
                viscore.dataSlice.rangeString(obj.StartBlock, obj.StartBlock) ')'];
            obj.YStringBase = 'Events';
            
            obj.XValues = obj.XLimOffset + ...
                (0:(obj.Events.getBlockSize() - 1))/obj.Events.getSampleRate();
            obj.XStringBase = 'Time (s)';
            obj.TimeUnits = 'sec';
            obj.SelectedHandle = [];
            obj.SelectedSignal = [];
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
                set(obj.SelectedHandle, 'LineWidth', obj.LineWidthUnselected);
            end
            obj.SelectedHandle = [];
            obj.SelectedSignal = [];
            obj.SelectedBlockOffset = 0;
            obj.YString = obj.YStringBase;
            srcTag = get(src, 'Tag');
            if ~isempty(srcTag) && strcmpi(get(src, 'Type'), 'line')
                set(src, 'LineWidth', obj.LineWidthSelected);
                obj.SelectedHandle = src;
                obj.SelectedSignal = obj.Signals(str2double(srcTag), :);
                if obj.PlotWindow
                    selected = str2double(srcTag) + obj.StartElement - 1;
                else
                    selected = str2double(srcTag) + obj.StartBlock - 1;
                end
                obj.YString = [obj.YStringBase ' ' '[' num2str(selected) ']'];
                obj.SelectedTagNumber = str2double(srcTag);
                if ~obj.PlotWindow && ~obj.VisData.isEpoched()
                    obj.SelectedBlockOffset = obj.VisData.getBlockSize() * ...
                        (selected - 1) /obj.VisData.SampleRate;
                 end
            end
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
            
            scale = obj.EventScale;
            if isempty(scale)
                scale = 1;
            end
            plotSpacing = double(scale);
            numPlots = length(obj.UniqueEvents);
            if numPlots == 0 || isnan(plotSpacing)
                warning('eventStackedPlot:NaNValues', 'No data to plot');
                return;
            elseif plotSpacing == 0;
                plotSpacing = 0.1;
            end
            %y-axis reversed, so must plot the negative of the events            
            obj.HitList = cell(1, numPlots + 1);
            obj.HitList{1} = obj.MainAxes;
            for k = 1:numPlots
                
                hp = plot(obj.MainAxes, obj.XValues, events, ...
                    'Color', obj.Colors(k, :), ...
                    'Clipping','on', 'LineWidth', obj.LineWidthUnselected);
                set(hp, 'Tag', num2str(k));
                obj.HitList{k + 1} = hp;
            end
            yTickLabels = cell(1, numPlots);
            yTickLabels{1} = '1';
            yTickLabels{numPlots} = num2str(numPlots);
%             obj.XString = sprintf('%s (Scale: %g %s)', ...
%                 obj.XString, plotSpacing, obj.SignalLabel);
            set(obj.MainAxes,  'YLimMode', 'manual', ...
                'YLim', [0, plotSpacing*(numPlots + 1)], ...
                'YTickMode', 'manual', 'YTickLabelMode', 'manual', ...
                'YTick', plotSpacing:plotSpacing:numPlots*plotSpacing, ...
                'YTickLabel', yTickLabels, ...
                'XTickMode', 'auto', ...
                'XLim', [obj.XValues(1), obj.XValues(end)], 'XLimMode', 'manual', ...
                'XTickMode', 'auto');
             obj.redraw();
        end % plot
        
    end % private methods
    
    methods(Static=true)
        
        function settings = getDefaultProperties()
            % Structure specifying how to set configurable public properties
            cName = 'visviews.eventStackedPlot';
            settings = struct( ...
                'Enabled',       {true,           true,               true,            true,            true,        true}, ...
                'Category',      {cName,          cName,              cName,           cName,           cName,       cName}, ...
                'DisplayName',   {'Clipping on',  'Combine method',   'Remove mean',  'Signal label',  'Signal scale', 'Trim percent'}, ...
                'FieldName',     {'ClippingOn',   'CombineMethod',    'RemoveMean',   'SignalLabel',    'SignalScale',  'TrimPercent'}, ...
                'Value',         {true,           'mean',             true,          '{\mu}V',        3.0,           0 }, ...
                'Type',          { ...
                'visprops.logicalProperty', ...
                'visprops.enumeratedProperty', ...
                'visprops.logicalProperty', ...
                'visprops.stringProperty', ...
                'visprops.doubleProperty', ...
                'visprops.doubleProperty'}, ...
                'Editable',      {true,              true,            true,           true,            true,         true}, ...
                'Options',       {'',         {'mean', 'median', 'max', 'min'},'',              '',              [0, inf],     [0, inf]}, ...
                'Description',   { ...
                ['If true, individual events are clipped ' ...
                'to fall within the plot window'], ...
                ['Specifies how to combine multiple windows ' ...
                 'into a single window for plotting'], ...
                'If true, remove mean before plotting', ...
                'Label indicating event units', ...
                ['Scale factor for plotting individual event plots ' ...
                '(must be positive)'], ...
                 ['Percentage of extreme points (half on each end ' ...
                'before calculating limits']} ...
                );
        end % getDefaultProperties
        
        
    end % static methods
    
end % eventStackedPlot
