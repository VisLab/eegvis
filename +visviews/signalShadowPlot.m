% visviews.shadowSignalPlot  display element or window signals using shadow outline
%
% Usage:
%   >>  visviews.shadowSignalPlot(parent, manager, key)
%   >>  obj = visviews.shadowSignalPlot(parent, manager, key)
%
% Description:
% obj = visviews.shadowSignalPlot(parent, manager, key) presents a 
%     compact summary of multiple signals over a fixed period. The 
%     shadow signal plot shows an envelope of the signals as a gray shadow. 
%     All signals fall within this shadow. The plot only displays individual 
%     signals designated as outliers for some time points. The shadow 
%     signal plot uses the signal z score at each time point to determine 
%     outliers. By default, outliers are those signals whose amplitude 
%     has a z score of at least three at some point in time. 
%
%     The parent is a graphics handle to the container for this plot. The
%     manager is an viscore.dataManager object containing managed objects
%     for the configurable properties of this object, and key is a string
%     identifying this object in the property manager GUI.
% 
% 
% obj = visviews.shadowSignalPlot(parent, manager, key) returns a handle to
%     the newly created object.
%
% visviews.shadowSignalPlot is configurable, resizable, and cursor explorable.
%
% The shadow signal plot changes the labeling of the horizontal axis 
% depending on whether the display is for epoched data or not. For window 
% slices of non-epoched data, the plot uses the sampling rate to 
% calculate the actual time in seconds corresponding to the data. 
% For channel slices of non-epoched data, the plot labels the horizontal 
% axis with the duration of the slice in seconds starting from zero. 
% For window or channel slices of epoched data, the plot labels the 
% horizontal axis using the epoch times in ms of the samples within 
% the epoch. The plot always labels the horizontal axis with the window 
% number (or range of windows numbers) of the corresponding slice.
%
% Clicking one of the signals causes it to become the selected signal. 
% The object displays the selected signal using a wider line and 
% adds an indicator identifying the selected line to the label on the 
% vertical axis. Selecting a signal causes dependent views to update 
% their values. Unselect a signal by clicking in an empty part of 
% the plot area.

% Configurable properties:
% The visviews.shadowSignalPlot has five configurable parameters: 
%
% CombineMethod       specifies how to combine multiple blocks 
%                     when displaying a clumped slice.  The value can be 
%                     'max', 'min', 'mean', 'median', or 
%                     'none' (the default). 
%
% CutoffScore         specifies the size of the z-score cutoff for outliers. 
%
% RangeType           specifies the direction of outliers from the mean. A
%                     value of 'both' (the default) indicates that 
%                     outliers can occur in either direction 
%                     from the mean, while 'upper' and 'lower' indicate outliers 
%                     occur only above or below the mean, respectively.
%
% RemoveMean          is a boolean flag specifiying whether to remove the 
%                     the individual channel means for the data before 
%                     trimming or plotting.
%
% ShowMean            is a boolean flag indicating whether to show the mean signal
%                     on the graph. If true (the default), the plot 
%                     displays the signal mean as a thick gray line.
%
% ShowStd             is a boolean flag indicating whether to show the standard
%                     deviation of the signal on the graph. If true (the default), 
%                     the plot displays the signal standard deviation 
%                     using thin gray lines to mark the distance above 
%                     and below the mean at each time point.
%
% SignalLabel         is a string specifying the units for the y-axis.
%
% TrimPercent         is a numerical value specifying the percentage of 
%                     extreme points to remove from the window before 
%                     plotting. If the percentage is t, the largest
%                     t/2 percentage and the smallest t/2 percentage of the
%                     data points are removed (over all elements or channels).
%                     The signal scale is calculated relative to the trimmed 
%                     signal and all of the signals are clipped at the
%                     trim cutoff before plotting.
%
%
%% Example  
% Create a shadow signal plot for random sinusoidal signals
%
%   % Create a sinusoidal data set with random amplitude and phase 
%   nSamples = 1000;
%   nChans = 32;
%   a = repmat(10*rand(nChans, 1), 1, nSamples);
%   p = repmat(pi*rand(nChans, 1), 1, nSamples);
%   x = repmat(linspace(0, 1, nSamples), nChans, 1);
%   data = 0.01*random('normal', 0, 1, [nChans, nSamples]) + ...
%           a.*cos(2*pi*x + p);
%   data(1, :) = 2*data(1, :);  % Make first signal bigber
%   testVD = viscore.blockedData(data, 'Cosine');
%
%   % Create a block function and a slice
%   defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
%              visfuncs.functionObj.getDefaultFunctions());
%   thisFunc = defaults{1};
%   thisSlice = viscore.dataSlice('Slices', {':', ':', '1'}, ...
%   'DimNames', {'Channel', 'Sample', 'Window'});
%
%   % Create the figure and plot the data
%   sfig = figure('Name', 'Plot with smoothed signals');
%   sp = visviews.shadowSignalPlot(sfig, [], []);
%   sp.CutoffScore = 2.0;
%   sp.plot(testVD, thisFunc, thisSlice);
%  
%   % Adjust the margins
%   gaps = sp.getGaps();
%   sp.reposition(gaps);
%
% Notes:
%
% -  If manager is empty, the class defaults are used to initialize
% -  If key is empty, the class name is used to identify in GUI configuration
% -  Mean removal is done before trimming
%
% Class documentation:
% Execute the following in the MATLAB command window to view the class 
% documentation for visviews.shadowSignalPlot:
%
%    doc visviews.shadowSignalPlot
%

% See also: visviews.axesPanel, visviews.clickable, visprops.configurable,
%           visviews.cursorExplorable, visviews.resizable, and 
%           visviews.stackedSignalPlot
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

% $Log: shadowSignalPlot.m,v $
% Revision: 1.00  04-Dec-2011 09:11:20  krobbins $
% Initial version $
%

classdef signalShadowPlot < visviews.axesPanel  & visprops.configurable
    
    properties
        CombineMethod = 'mean';     % method for combining dimensions for display
        CutoffScore = 3.0;          % z score for an outlier
        RangeType = 'both';         % specifies directions for outliers (upper, lower, both)
        RemoveMean = true;          % remove the mean prior to plotting
        ShowMean = true;            % if true, display the mean line
        ShowStd = true;             % if true, display the std ranges
        SignalLabel = '{\mu}V';     % y label for plot
        TrimPercent = 0;            % percentage of extreme points to trim 
    end % public properties
    
    properties (Access = private)
        CurrentSlice = [];          % current data slice
        HitList = {};               % list of hithandles
        LineWidthSelected = 2.0;    % width of a selected signal
        LineWidthUnselected = 0.5;  % width of unselected signal
        PlotWindow = true;          % if true, a window is being plotted
        Outliers = [];              % [Element, Window] indices of outliers
        ScaleGap = 0.1              % gap for setting the y axis limits
        SelectedBlock = [];         % block number of selected signal
        SelectedBlockOffset = 0;    % start of selected block in seconds
        SelectedElement = [];       % block number of selected signal
        SelectedHandle = [];        % handle of selected signal or empty
        SelectedSignal = [];        % data in selected signal or empty
        SignalElementMean = [];     % signal mean by element
        SignalMean = [];            % signal mean by sample
        Signals = [];               % data to be plotted in this panel
        SignalStd = []              % signal standard deviation by sample
        StartBlock = 1;             % starting block of currently plotted slice
        StartElement = 1;           % starting element of currently plotted slice
        VisData = [];               % original data for interrogation
        TimeUnits = 'sec';          % time units of the access
        XValues = [];               % x values of current plot
    end % private properties
    
    methods
        
        function obj = signalShadowPlot(parent, manager, key)
            % Create a signalShadowPlot
            obj = obj@visviews.axesPanel(parent);
            obj = obj@visprops.configurable(key);
            % Update properties if any are available
            if isa(manager, 'viscore.dataManager')
                visprops.property.updateProperties(obj, manager);
            end
            set(obj.MainAxes, 'Box', 'on', 'Tag', 'shadowSignalAxes');
        end % signalShadowPlot constructor
        
        function [cbHandles, hitHandles] = getHitObjects(obj)
            % Return handles to register as callbacks and hit handles
            % Required for the visviews.clickable interface
            cbHandles = obj.HitList;
            hitHandles = obj.HitList;
        end % getHitObjects
        
        function outliers = getOutliers(obj)
            outliers = obj.Outliers;
        end % getOutliers
        
        function plot(obj, visData, bFunction, dSlice)
            % Plot the specified slice of visData
            obj.reset();
            if isempty(visData)
                return;
            end
            bFunction.setData(visData);
            obj.VisData = visData; % Keep data for cursor exploration
  
            % Figure out whether the slice is by window or by element
            if isempty(dSlice)
               obj.CurrentSlice = viscore.dataSlice();
            else
                obj.CurrentSlice = dSlice;
            end
         
            [slices, names, cDims] = obj.CurrentSlice.getParameters([]);
            if isempty(cDims) || ~isempty(intersect(cDims, 3))  % Plot all elements for a window
                obj.PlotWindow = true; 
            elseif ~isempty(intersect(cDims, 1))  % Plot all windows for an element    
                obj.PlotWindow = false;
            else
                warning('signalShadowPlot:plotSlice', ...
                        'array slice is empty and cannot be plotted');
                return;
            end
             
            % Extract the signal based on the slice        
            if obj.PlotWindow || obj.VisData.isEpoched()
                cDims = [];
            end
            [obj.Signals, sStart] = viscore.dataSlice.getDataSlice(visData.getData(), ...
                slices, cDims, []);
            if isempty(obj.Signals)
                warning('signalShadowPlot:plotSlice', ...
                    'must have at least 2 samples to plot');
                return;
            end
            [nElements, nSamples, nBlocks] = size(obj.Signals);
            obj.Signals = squeeze(obj.Signals);
            obj.StartElement = sStart(1);
            obj.StartBlock = sStart(3);
   
            % Adjust signals to account for blocking
            if obj.PlotWindow  % Plot all elements for a window           
                % If continguous windows are plotted reshape to align
                if ~obj.VisData.isEpoched() && nBlocks > 1 % windows displayed consecutively
                    obj.Signals = permute(obj.Signals, [2, 3, 1]);
                    obj.Signals = reshape(obj.Signals, [nSamples*nBlocks, nElements]);
                    obj.Signals = squeeze(obj.Signals');
                end
                obj.XLimOffset = (sStart(3) - 1)*nSamples/visData.getSampleRate();
                obj.XStringBase = [names{1} ' '  ...
                    viscore.dataSlice.rangeString(obj.StartElement, nElements) ...
                                  ' ('  names{3} ' ' ...
                    viscore.dataSlice.rangeString(obj.StartBlock, nBlocks) ')'];
            else % Plot all windows for an element
                if nElements > 1  % windows for multiple elements individually displayed
                    obj.Signals = permute(obj.Signals, [3, 2, 1]);
                else
                    obj.Signals = (obj.Signals)';
                end     
                obj.XLimOffset = 0;
                obj.XStringBase  = [names{3} ' ' ...
                    viscore.dataSlice.rangeString(obj.StartBlock, nBlocks) ...
                    ' (' names{1} ' ' ...
                    viscore.dataSlice.rangeString(obj.StartElement, nElements) ')'];
            end

            % Adjust the labels
            if visData.isEpoched() % add time scale to x label
                obj.XValues = visData.getEpochTimeScale();
                obj.XStringBase = ['Time(ms) [' obj.XStringBase ']'];
                obj.TimeUnits = 'ms';
            else
                obj.XValues = obj.XLimOffset + ...
                    (0:(size(obj.Signals, 2) - 1))./visData.getSampleRate();
                obj.XStringBase = ['Time(s) [' obj.XStringBase ']'];
                obj.TimeUnits = 'sec';
            end
            obj.SelectedHandle = [];
           % obj.SelectedSignal = [];
            obj.YStringBase = obj.SignalLabel;
            obj.YString = obj.YStringBase;
            obj.XString = obj.XStringBase;
            obj.displayPlot();
        end % plotSlice
        
        function s = updateString(obj, point)
            % Return value string if pixel point within plot, otherwise empty
            % 
            % Parameters:
            %    point   pixel position of point with respect to parent figure
            %    s       (out)  string value of point or empty if outside axes
            %
            % Form of the string is:
            %      t: time in seconds if continuous or in ms if epoched
            %      s: 
            %      
            s = '';   % String to be returned
            try   % Use exception handling for small round-off errors
                [x, y, xInside, yInside] = obj.getDataCoordinates(point);
                if ~xInside || ~yInside
                    return;
                end
                
                if ~obj.VisData.isEpoched()
                    t = x + obj.SelectedBlockOffset;
                    sample = floor(obj.VisData.SampleRate*(t)) + 1;
                    s = {['t: ' num2str(t) ' ' obj.TimeUnits]; ...
                         ['s: ' num2str(sample)]; ...
                         ['v: ' num2str(y) ' ' obj.SignalLabel]};  
                    if ~isempty(obj.SelectedHandle)
                       rs = floor(obj.VisData.SampleRate*(x - obj.XLimOffset)) + 1;
                       s{4} = ['raw: '  num2str(obj.SelectedSignal(rs)) ...
                               ' ' obj.SignalLabel];
                    end
                else
                    a = (x - obj.VisData.EpochTimes(1))./1000;
                    a = floor(obj.VisData.SampleRate*a) + 1;
                    s = {['et: ' num2str(x) ' ' obj.TimeUnits]; ...
                          ['es: ' num2str(a)]; ...
                          ['v: ' num2str(y) ' ' obj.SignalLabel]};  
                    if ~isempty(obj.SelectedHandle) 
                        % Currently EpochStartTimes are not set in
                        % eegBrowse so this is not implemented yet.
%                       t = obj.VisData.EpochStartTimes(obj.SelectedBlock) + a;
%                       sample = floor(obj.VisData.SampleRate*t) + 1;
                      z = { ... ['t: ' num2str(t) ' secs']; ... 
                            ... ['s: ' num2str(sample)]; ...
                           ['raw: '  num2str(obj.SelectedSignal(a)) ...
                               ' ' obj.SignalLabel]};
                      s = [s; z];
                    end;
                end
            catch  ME  %#ok<NASGU>   ignore errors on cursor sweep
                %fprintf('*');   % debugging
            end
        end % updateString
        
        function buttonDownPreCallback(obj, src, eventdata, master)  %#ok<INUSD>
            % Callback when user clicks on the plot to select a signal
            if ~isempty(obj.SelectedHandle) && ishandle(obj.SelectedHandle)
                set(obj.SelectedHandle, 'LineWidth', obj.LineWidthUnselected);
            end
            
            % Clear the selected signal
            obj.SelectedHandle = [];
            obj.SelectedBlock = [];
            obj.SelectedElement = [];
            obj.SelectedSignal = [];
            obj.SelectedBlockOffset = 0;
            obj.YString = obj.YStringBase;
            srcTag = get(src, 'Tag');
            if ~isempty(srcTag) && strcmpi(get(src, 'Type'), 'line')
                set(src, 'LineWidth', obj.LineWidthSelected);
                obj.SelectedHandle = src;
                [tag1, tag2] = strtok(srcTag, '.');
                relativeElement = str2double(tag1);
                relativeBlock = str2double(tag2(2:end));
                obj.SelectedElement = relativeElement + obj.StartElement - 1;
                obj.SelectedBlock = relativeBlock + obj.StartBlock - 1;
                if obj.PlotWindow && obj.VisData.isEpoched() && size(obj.Signals, 3) > 1
                   obj.YString = [obj.YStringBase ' [' ...
                                  num2str(obj.SelectedElement) ...
                                  '(' num2str(obj.SelectedBlock) ')]'];       
                elseif obj.PlotWindow
                    obj.YString = [obj.YStringBase ' [' ...
                                   num2str(obj.SelectedElement) ']'];
                elseif size(obj.Signals, 3) > 1
                   obj.YString = [obj.YStringBase ' [' num2str(obj.SelectedBlock) ...
                              '(' num2str(obj.SelectedElement) ')]'];
                else
                   obj.YString = [obj.YStringBase ' [' ...
                                 num2str(obj.SelectedBlock) ']'];
                end
                
                % Set the selected signal for exploration
                if obj.PlotWindow
                    obj.SelectedSignal = ...
                        obj.Signals(relativeElement, :, relativeBlock);
                else
                    obj.SelectedSignal = ...
                        obj.Signals(relativeBlock, :, relativeElement);
                end
                if ~obj.PlotWindow && ~obj.VisData.isEpoched()
                    obj.SelectedBlockOffset = obj.VisData.getBlockSize() * ...
                        (obj.SelectedBlock - 1) /obj.VisData.getSampleRate();
                end
            end
            obj.redraw();
        end % buttonDownPreCallback
        
    end % public methods
    
    methods (Access = private)
        
        function displayPlot(obj)
            % Plot obj.Signals using the visData object for settings
            obj.reset();  % Clear out the previous plot
            % Go no further if signals is empty
            if isempty(obj.Signals)
                return;
            end
            
            data = obj.Signals;
            % Remove the mean if necessary
            obj.SignalElementMean = [];
            if obj.RemoveMean
                obj.SignalElementMean = mean(data, 2);
                data = data - repmat(obj.SignalElementMean, 1, size(data, 2));
            end
               
            % Trim up the signals if necessary
            if 0 < obj.TrimPercent && obj.TrimPercent < 100
                tValues = prctile(data(:), ...
                    [obj.TrimPercent/2, 100-obj.TrimPercent/2]);
                data(data < tValues(1)) = tValues(1);
                data(data > tValues(2)) = tValues(2);
            end
            
            % Calculate the signal mean and std
            [rows, cols, depth] = size(data);
            if depth > 1
                dTemp = reshape(permute(data, [1, 3, 2]), [rows*depth, cols]);
                obj.SignalMean = squeeze(mean(dTemp));
                obj.SignalStd = squeeze(std(dTemp));
            else
                obj.SignalMean = squeeze(mean(data));
                obj.SignalStd = squeeze(std(data));
            end
                
            % Scale the y axes so that it is ScaleGap bigger than extremes
            maxData = squeeze(max(max(data, [], 3)));
            minData = squeeze(min(min(data, [], 3)));
            y = [min(minData), max(maxData)];
            yLims = [y(1) - obj.ScaleGap*abs(y(1)), y(2) + obj.ScaleGap*abs(y(2))];
            if sum(isnan(yLims)) > 0  % Check the bad cases before scaling
                warning('signalShadowPlot:NaNValues', 'Values were entirely NaN\n');
                yLims = [-0.1, 0.1];
            elseif sum(abs(yLims)) <= 10e-8 % limits were both zero 
                yLims = [-0.1, 0.1];
            elseif length(data) == 1 || yLims(1) == yLims(2) %constant
                yLims = [yLims(1)*0.9, yLims(1)*1.1];
            end
            
            % Draw the shaded areas
            mlColor = [0.6, 0.6, 0.6];
            slColor = [0.8, 0.8, 0.8];
            areaColor = [0.93, 0.93, 0.93];
            chanColors = jet(size(data, 1));
            hold(obj.MainAxes, 'on');
            hArea = area(obj.MainAxes, obj.XValues, maxData);
            set(hArea, 'FaceColor', areaColor, 'BaseValue', yLims(1), ...
                'EdgeColor', areaColor);
            hArea2 = area(obj.MainAxes, obj.XValues, minData);
            set(hArea2, 'FaceColor', [1, 1, 1], 'BaseValue', yLims(1), ...
                'EdgeColor', areaColor);
            
            % Set the outliers
            [nElements, nSamples, nWindows] = size(obj.Signals); %#ok<ASGLU>
            upperRange = obj.SignalMean + obj.CutoffScore*obj.SignalStd;
            lowerRange = obj.SignalMean - obj.CutoffScore*obj.SignalStd;
            if strcmpi(obj.RangeType, 'upper')
                rangeIndex = obj.Signals > repmat(upperRange, [nElements, 1, nWindows]);
            elseif strcmpi(obj.RangeType, 'lower')
                rangeIndex = obj.Signals <repmat(lowerRange, [nElements, 1, nWindows]);
            else
                rangeIndex = (obj.Signals < repmat(lowerRange, [nElements, 1, nWindows])) | ...
                    (obj.Signals > repmat(upperRange, [nElements, 1, nWindows]));
            end
            [index1, index2] = find(sum(rangeIndex > 0, 2));
            obj.Outliers = [index1, index2]; % Indices relative to start of slice
        
            numPlots = size(obj.Outliers, 1);
            obj.HitList = cell(1, numPlots + 3);
            obj.HitList{1} = obj.MainAxes;
            obj.HitList{2} = hArea;
            obj.HitList{3} = hArea2;
            
            for k = 1:numPlots
                set(obj.MainAxes,'Layer','top')
                c1 = obj.Outliers(k, 1);
                c2 = obj.Outliers(k, 2);
                if obj.PlotWindow  % Tag as element.block
                    tag = [num2str(c1) '.' num2str(c2)];
                else
                    tag = [num2str(c2) '.' num2str(c1)];
                end
                hp = plot(obj.MainAxes, obj.XValues, data(c1, :, c2), ...
                    'Tag', tag, 'Color', chanColors(c1, :));
                obj.HitList{k + 3} = hp;
            end
            % Draw the mean and standard deviation range lines if requested
            set(obj.MainAxes,'Layer','top')
            if obj.ShowMean
                plot(obj.MainAxes, obj.XValues, obj.SignalMean, 'Tag', 'Average', ...
                    'Color', mlColor, 'LineWidth', 1)
            end
            if obj.ShowStd
                plot(obj.MainAxes, obj.XValues, obj.SignalMean + obj.SignalStd, ...
                    'Tag', 'AveragePlusStd', 'Color', slColor, 'LineWidth', 1)
                plot(obj.MainAxes, obj.XValues, obj.SignalMean - obj.SignalStd, ...
                    'Tag', 'AverageMinusStd', 'Color', slColor, 'LineWidth', 1)
            end
            hold(obj.MainAxes, 'off');
            % Fix up various tick marks and other features as needed
            set(obj.MainAxes, 'YLim', yLims);
            yTicks = linspace(yLims(1), yLims(2), 5);
            set(obj.MainAxes, 'YLimMode', 'manual', 'YLim', yLims, ...
                'YTickMode','manual', 'YTick', yTicks);
            yTickLabels = cellstr(get(obj.MainAxes, 'YTickLabel'));
            if length(yTickLabels{1}) > 3 || length(yTickLabels{end}) > 3
                yTickLabels{1} = ' ';
                yTickLabels{end} = ' ';
            end
            yTickLabels(2:end-1) = {' '};
            % Append the vertical range to x label to give context
            obj.XString = sprintf('%s (Scale: %g to %g %s)', ...
                obj.XString, yLims(1), yLims(2), obj.SignalLabel);
            set(obj.MainAxes, ...
                'YTickLabelMode', 'manual', 'YTickLabel', yTickLabels, ...
                'HitTest', 'on', 'ButtonDownFcn', ...
                {@visviews.signalShadowPlot.signalButtonDownFcn, obj}, ...
                'box', 'on', ...
                'XLim', [obj.XValues(1), obj.XValues(end)], 'XLimMode', 'manual', ...
                'XTickMode', 'auto');
            obj.redraw();
        end % displayPlot
        
    end % private methods
    
    methods(Static=true)
        
        function settings = getDefaultProperties()
            % Structure specifying how to set configurable public properties
            cName = 'visviews.signalShadowPlot';
            settings = struct( ...
                'Enabled',       {true,                true,          true,          true,           true,           true,       true,    true}, ...
                'Category',      {cName,               cName,         cName,         cName,          cName,          cName,      cName,   cName},...
                'DisplayName',   {'Combine method',   'Cutoff score', 'Range type',  'Remove mean',  'Show mean',    'Show std', 'Signal label', 'Trim percent'}, ...
                'FieldName',     {'CombineMethod',    'CutoffScore',  'RangeType',   'RemoveMean',   'ShowMean',     'ShowStd',  'SignalLabel', 'TrimPercent'}, ...
                'Value',         {'mean',             3.0,            'both',        true,            true,          false,     '{\mu}V',      0}, ...
                'Type',          { ...
                'visprops.enumeratedProperty', ...
                'visprops.doubleProperty', ...
                'visprops.enumeratedProperty', ...
                'visprops.logicalProperty', ...
                'visprops.logicalProperty', ...
                'visprops.logicalProperty', ...
                'visprops.stringProperty', ...         
                'visprops.doubleProperty'}, ...
                'Editable',      {true,                              true,       true,                        true,   true,     true,      true,       true}, ...
                'Options',       {{'mean', 'median', 'max', 'min'},  [0, 100],   {'both', 'lower', 'upper'},  '',     '',       '',        '',       [0, inf]}, ...
                'Description',   { ...
                ['Specifies how to combine multiple windows ' ...
                 'into a single window for plotting'], ...
                ['Threshold (zscore) for determining whether ' ...
                'a signal is an outlier'], ...
                ['Indicates whether an outlying signal ' ...
                'is one that falls below the shadow ' ...
                '(lower), one that falls above the ' ...
                'shadow (upper), or one that falls ' ...
                'either above or below the shadow ' ...
                '(both)'], ...
                'If true, remove signal mean before plotting', ...
                'If true, display the mean line', ...
                'If true, display the std limits', ...
                'Y axis label', ...
                ['Percentage of extreme points (half on each end ' ...
                'before calculating limits']} ...
                );
        end % getDefaultProperties
        
    end % static methods
    
end % signalShadowPlot
