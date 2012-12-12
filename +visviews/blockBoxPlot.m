% visviews.blockBoxPlot display a boxplot of blocked function values by window
%
% Usage:
%   >>   visviews.blockBoxPlot(parent, manager, key)
%   >>   obj = visviews.blockBoxPlot(parent, manager, key)
%
% Description:
% visviews.blockBoxPlot(parent, manager, key) displays a series of
%    vertical box plots using a compressed style. The block box plot
%    displays the distribution of values of a summarizing function for
%    a clump of consecutive time windows or epochs for all channels.
%    Each window or epoch produces a single value for each element.
%
%    The parent is a graphics handle to the container for this plot. The
%    manager is an viscore.dataManager object containing managed objects
%    for the configurable properties of this object, and key is a string
%    identifying this object in the property manager GUI.
%
% obj = visviews.blockBoxPlot(parent, manager, key) returns a handle to
%    the newly created object.
%
% visviews.blockBoxPlot is configurable, resizable, clickable, and cursor explorable.
%
% Configurable properties:
% The visviews.blockBoxPlot has five configurable properties:
%
% BoxColors provides a list of colors used to alternate through in
%     displaying the boxes. For data with lots of clumps, the
%     boxes appear highly compressed due to limited viewing space and
%     alternating colors help users distinguish the individual boxes. The
%     default is [0.7, 0.7, 0.7; 1, 0, 1].
%
% ClumpSize specifies the number of consecutive windows or epochs
%    represented by each box. When the |ClumpSize| is one (the default),
%    each box represents a single window or element. If |ClumpSize| is greater than
%    one, each box represents several consecutive blocks.
%    Users can trade-off clump size versus block size to see different
%    representations of the data.
%
% CombineMethod specifies how to combine multiple blocks into a
%    single block to determine an overall block value. The value can be
%   'max' (default), 'min', 'mean', 'median', or 'sum'. Detail plots use the
%    combined block value to determine slice colors.
%
%    Suppose the plot has 128 channels, a clump size of 3, and a block size of
%    1000 samples, and 100 windows. A user click delivers a slice representing
%    3×1000 worth of data. A detail plot such as stackedSignalPlot
%    combines this data based on its own CombineMethod property,
%    say by taking the mean to plot 32×1000 data points on 32 line graphs.
%    However, we would like to use line colors for the signals based
%    on the block function values in the box plot. The detail plots use
%    box plot's CombineMethod to combine the blocks to get appropriate
%    colors for the slice.
%
%    Usually signal plots combine signals using mean or median, while
%    summary plots such as blockBoxPlot use the max, although users may
%    choose other combinations.
%
% IsClickable is a boolean specifying whether this plot should respond to
%    user mouse clicks when incorporated into a linkable figure. The
%    default value is true.
%
% LinkDetails is a boolean specifying whether clicking this plot in a
%    linkable figure should cause detail views to display the clicked
%    slice. The default value is true.
%
%
% Example:
% % Create a boxplot of kurtosis for EEG data
%
%    % Read some eeg data to display
%    load('EEG.mat');  % Saved EEGLAB EEG data
%    testVD = viscore.blockedData(EEG.data, 'Sample EEG data', ...
%         'SampleRate', EEG.srate);
%
%    % Create a kurtosis block function object
%    funs = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
%               visfuncs.functionObj.getDefaultFunctions());
%
%    % Plot the block function, adjusting margins for display
%    sfig = figure('Name', 'Kurtosis for EEG data');
%    bp = visviews.blockBoxPlot(sfig, [], []);
%    bp.plot(testVD, funs{1}, []);
%    gaps = bp.getGaps();
%    bp.reposition(gaps);
%
%
% Notes:
%   - If manager is empty, the class defaults are used to initialize.
%   - If key is empty, the class name is used to identify in GUI configuration.
%
% Class documentation:
% Execute the following in the MATLAB command window to view the class
% documentation for visviews.blockBoxPlot:
%
%    doc visviews.blockBoxPlot
%
%
% See also: visviews.axesPanel, visviews.blockImagePlot, visviews.clickable,
%           visprops.configurable, visviews.cursorExplorable,
%           visviews.elementBoxPlot, and visviews.resizable
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

% $Log: blockBoxPlot.m,v $
% Revision: 1.00  04-Dec-2011 09:11:20  krobbins $
% Initial version $
%

classdef blockBoxPlot < visviews.axesPanel  & visprops.configurable
    
    properties
        % configurable properties
        BoxColors = [0.7, 0.7, 0.7; 1, 0, 1];     % alternating box colors
        ClumpSize = 1.0;       % number of blocks in each box plot (clump)
        CombineMethod = 'max';   % method of combining blocks in a clump
    end % public properties
    
    properties (Access = private)
        Boxplot = [];            % handle to boxplot for setting callbacks
        CurrentFunction = [];    % handle to block function for this
        CurrentPointer = [];     % triangle marking current position on axes
        CurrentPosition = [];    % position of the last selected block or empty
        CurrentSlice = [];       % current data slice
        NumberBlocks = 0;        % number of blocks being plotted
        NumberClumps = 0;        % current number of clumps (boxplots)
        NumberElements = 0;      % number of elements being plotted
        StartBlock = 1;          % starting block of currently plotted slice
        StartElement = 1;        % starting element of currently plotted slice
    end % private properties
    
    methods
        
        function obj = blockBoxPlot(parent, manager, key)
            % Parent is non-empty handle to container for axes panel but manager can be empty
            obj = obj@visviews.axesPanel(parent);
            obj = obj@visprops.configurable(key);
            % Update properties if any are available
            if isa(manager, 'viscore.dataManager')
                visprops.property.updateProperties(obj, manager);
            end
            set(obj.MainAxes, 'Tag', 'blockBoxAxes');
        end % blockBoxPlot constructor
        
        
        function [dSlice, bFunction, position] = getClicked(obj, cposition)
            % Clicking on the boxplot always causes plot of group of blocks
            bFunction = obj.CurrentFunction;
            if ~isempty(cposition)
                position = cposition;
            else
                point = get(obj.MainAxes, 'CurrentPoint');
                position = point(1, 1);
            end
            [dSlice, position] = obj.calculateClickedSlice(position);
            if ~isempty(position)
               obj.drawMarker(position);
               obj.CurrentPosition = position;
            end
        end % getClicked
        
        function position = getCurrentPosition(obj)
            % Return the current position
            position = obj.CurrentPosition;
        end % getCurrentPosition
        
        function [cbHandles, hitHandles] = getHitObjects(obj)
            % Return handles that should register callbacks as well has hit handles
            cbHandles = {obj.MainAxes, obj.Boxplot};
            hitHandles = {obj.MainAxes, obj.Boxplot};
        end % getHitObjects
        
        function [dSlice, bFunction] = getInitialSourceInfo(obj)
            bFunction = obj.CurrentFunction;
            dSlice = obj.calculateClickedSlice(1);
        end % getInitialSourceInfo
        
        function name = getName(obj)
            % Return an identifying name for this object
            name = [num2str(obj.getObjectID()) ' [' class(obj) ']'];
            if ~isempty(obj.CurrentFunction)
               name = [name ' ' obj.CurrentFunction.getValue(1, 'DisplayName')];
            end
        end % getName
        
        function plot(obj, visData, bFunction, dSlice)
            % Sets up the plot hierarchy but may not display plot
            obj.reset();
            % Get needed information from the data and function objects
            if isempty(visData) || isempty(bFunction)
                warning('blockBoxPlot:emptyFunctionOrData', ...
                    'Missing summary function or block data for this plot');
                return;
            end
            bFunction.setData(visData);
            obj.CurrentFunction = bFunction;
            if isempty(dSlice)
                obj.CurrentSlice = viscore.dataSlice();
            else
                obj.CurrentSlice = dSlice;
            end
            
            [slices, names] = obj.CurrentSlice.getParameters(3); %#ok<ASGLU>
            [data, s] = bFunction.getBlockSlice(obj.CurrentSlice);
            if isempty(data)
                warning('blockBoxPlot:emptyData', 'No data for this plot');
                return;
            end
            obj.StartBlock = s(2);
            obj.StartElement = s(1);
            [obj.NumberElements, obj.NumberBlocks] = size(data);
            limits = bFunction.getBlockLimits();
            
            % Calculate the number of clumps and adjust for uneven clumps
            obj.NumberClumps = ceil(double(obj.NumberBlocks)/double(obj.ClumpSize));
            data = data(:);
            groups = repmat(1:obj.NumberClumps, obj.NumberElements*obj.ClumpSize, 1);
            groups = groups(:);
            
            % Draw the box plot
            limits = [max(limits(1), min(data(:))), min(limits(2), max(data(:)))];
            if sum(isnan(limits)) > 0
                warning('blockBoxPlot:NaNValues', 'Block values were entirely NaN\n');
                limits = [-0.1, 0.1];
            elseif sum(abs(limits)) <= 10e-8 % limits were both zero
                limits = [-0.1, 0.1];
            elseif length(data) == 1 || limits(1) == limits(2) %constant
                limits = [limits(1)*0.9, limits(1)*1.1];
            end
            
            try  % boxplot fails if it doesn't have enough room
                obj.Boxplot = boxplot(obj.MainAxes, ...
                    data, num2cell(groups(1:length(data))), ...
                    'orientation', 'Vertical', ...
                    'plotstyle', 'compact',...
                    'Colors', obj.BoxColors, ...
                    'Jitter', 0.1, 'datalim', limits, ...
                    'extrememode', 'compress');
            catch ME
                warning('blockBoxPlot:plot', ...
                    ['boxplot ' obj.getObjectID() ' for function ' ...
                    obj.CurrentFunction.getDisplayName(1) ...
                    ' doesn''t have enough room to plot: (' ME.message ...
                    ')\nPossible fixes:\n' ...
                    ' - Expand the figure window\n' ...
                    ' - Consider using a hierarchy and clumping to show this data\n' ...
                    ' - Shorten function and window display names\n' ...
                    ' - Use fewer summary plots']);
                return;
            end
            
            % Fix up the labels, limits and tick marks as needed
            xLimits = [0, obj.NumberClumps + 1];
            [xTickMarks, xTickLabels, obj.XStringBase] = ...
                obj.getClumpTicks(names{3}, names{1});
            obj.XString = obj.XStringBase;
            obj.YStringBase = bFunction.getValue(1, 'DisplayName');
            obj.YString = obj.YStringBase;
            
            if ~isempty(names{3})
                wString = names{3};
            else
                wString = 'Window';
            end
            
            yTickLabels = cellstr(get(obj.MainAxes, 'YTickLabel'));
            yTickMarks = get(obj.MainAxes, 'YTick');
            yLimits = get(obj.MainAxes, 'YLim');
            if length(yTickLabels) > 2
                for k = 2:length(yTickLabels) - 1
                    yTickLabels(k) =  {' '};
                end
            end
            
            set(obj.MainAxes, 'ActivePositionProperty', 'Position', ...
                'XLimMode', 'manual', 'XLim', xLimits, ...
                'XTickMode','manual', 'XTick', xTickMarks, ...
                'XTickLabelMode', 'manual', 'XTickLabel', xTickLabels, ...
                'YLimMode', 'manual', 'YLim', yLimits, ...
                'YTickMode','manual', 'YTick', yTickMarks, ...
                'YTickLabelMode', 'manual', 'YTickLabel', yTickLabels);
            
            % Set the cursor string for exploration mode
            obj.CursorString = {[wString ': ']; ...
                [bFunction.getValue(1, 'ShortName') ': ']; };
            obj.redraw();
        end % plot
        
        function setBackgroundColor(obj, c)
            % Set the background color to c
            obj.setBackgroundColor@visviews.axesPanel(c);
            set(obj.MainAxes, 'Color', 'none', 'Box', 'off', ...
                'XColor', c, 'YColor', c, 'ZColor', c);
            if ~isempty(obj.HeadAxes)
                set(obj.HeadAxes, 'Color', c);
            end
        end % setBackgroundColor
        
        function s = updateString(obj, point)
            % Return a cursor string corresponding to point
            s = '';   % String to be returned
            [x, y, xInside, yInside] = getDataCoordinates(obj, point);
            if ~xInside || ~yInside
                return;
            end
            cNum = round(x);
            if cNum < 1 || cNum > obj.NumberClumps
                return;
            end
            
            w = min(ceil((x - 0.5)*double(obj.ClumpSize)), obj.NumberBlocks) ...
                + obj.StartBlock - 1;
            s = {[obj.CursorString{1} num2str(w)]; ...
                [obj.CursorString{2} num2str(ceil(y - 0.5))]};
            
        end % updateString
        
    end % public methods
    
    methods (Access = 'private')
        
        function [dSlice, position] = calculateClickedSlice(obj, clump)
            % Calculate slice for clump and set CurrentPosition
            dSlice = [];
            position = [];
            if clump == -inf
                clump = 1;
            elseif clump == inf
                clump = obj.NumberClumps;
            elseif clump <= 0 || clump >= obj.NumberClumps + 1 || ...
                    obj.NumberClumps ~= ...  % needs to be recalculated
                    ceil(double(obj.NumberBlocks)/double(obj.ClumpSize));
                return;
            end
            clump = min(obj.NumberClumps, max(1, round(clump))); % include edges
            position = round(clump);
            if obj.ClumpSize == 1
                s = num2str(clump + obj.StartBlock - 1);
            else
                startBlock = (clump - 1)* obj.ClumpSize + obj.StartBlock; % adjust to win num
                endBlock = min(obj.StartBlock + obj.NumberBlocks - 1, ...
                    startBlock + obj.ClumpSize - 1);
                s = [num2str(startBlock) ':' num2str(endBlock)];
            end
            [slices, names] = obj.CurrentSlice.getParameters(3); %#ok<ASGLU>
            elementSlice = viscore.dataSlice.rangeString( ...
                obj.StartElement, obj.NumberElements);
            dSlice = viscore.dataSlice('Slices', {elementSlice, ':', s}, ...
                'CombineMethod', obj.CombineMethod, 'CombineDim', 3, ...
                'DimNames', names);
        end % calculateClumpSlice
        
        function drawMarker(obj, p)
            % Draw a triangle outside axes at position p
            pos = getpixelposition(obj.MainAxes, false);
            lims = get(obj.MainAxes, {'XLim'; 'YLim'});
            deltaX = 10*(lims{1}(2) - lims{1}(1))./pos(3);
            deltaY = 10*(lims{2}(2) - lims{2}(1))./pos(4);
            x = p + deltaX*[-0.5; 0; 0.5];
            y = lims{2}(2) + deltaY.* [1; 0; 1];
            if isempty(obj.CurrentPointer) || ~ishandle(obj.CurrentPointer)
                obj.CurrentPointer = fill3(x, y, [0.1; 0.1; 0.1], ...
                    [1, 0, 0], 'Parent', obj.MainAxes);
            else
                set(obj.CurrentPointer, 'XData', x, 'YData', y);
            end
        end % drawMarker
        
        function [xTickMarks, xTickLabels, xStringBase] = ...
                getClumpTicks(obj, blockName, elementName)
            % Calculate the tick marks and labels based on clumps
            if obj.NumberClumps <= 1 && obj.ClumpSize == 1
                xTickMarks = 1;
                xTickLabels = {num2str(obj.StartBlock)};
            elseif obj.NumberClumps <= 1
                xTickMarks = 1;
                xTickLabels = {'1'};
            elseif obj.ClumpSize == 1;
                xTickMarks = [1, obj.NumberClumps];
                xTickLabels = {num2str(obj.StartBlock), ...
                    num2str(obj.StartBlock + obj.NumberClumps - 1)};
            else
                xTickMarks = [1, obj.NumberClumps];
                xTickLabels = {'1', num2str(obj.NumberClumps)};
            end
            if obj.ClumpSize == 1 || obj.NumberBlocks == 1
                xStringBase = blockName;
            else
                xStringBase = [blockName 's' ...
                    num2str(obj.StartBlock) ':' ...
                    num2str(obj.StartBlock + obj.NumberBlocks -1) ...
                    ' clumps of ' num2str(obj.ClumpSize)];
            end
            
            % Add an indicator of which elements being plotted
            if obj.NumberElements > 1
                xStringBase = [xStringBase ' [' elementName 's ' ...
                    num2str(obj.StartElement) ':' ...
                    num2str(obj.NumberElements + obj.StartElement - 1) ']'];
            else
                xStringBase = [xStringBase ' [' elementName ' ' ...
                    num2str(obj.StartElement) ']'];
            end
        end % getClumpTicks
        
    end % private methods
    
    methods (Static = true)
        
        function settings = getDefaultProperties()
            % Structure specifying how to set configurable public properties
            cName = 'visviews.blockBoxPlot';
            settings = struct( ...
                'Enabled',       { ... % display in property manager?
                true,             ... %1 box plot colors
                true,             ... %2 blocks/clump
                true,             ... %3 method for combining clumps
                true              ... %4 link to details on click
                }, ...
                'Category',      {  ... % category for property
                cName,             ... %1 box plot colors
                cName,             ... %2 blocks/clump
                cName,             ... %3 method for combining clumps
                cName              ... %4 link to details on click
                }, ...
                'DisplayName',   {  ... % display name in property manager
                'Box plot colors',    ... %1 alternating box plot colors
                'Clump size',         ... %2 blocks/clump
                'Combine method',     ... %3 method for combining clumps
                'Link to details'     ... %4 link to details on click
                }, ...
                'FieldName',     {  ... % name of public property
                'BoxColors',        ... %1 alternating box plot colors
                'ClumpSize',        ... %2 blocks/clump
                'CombineMethod',    ... %3 method for combining clumps
                'LinkDetails'       ... %4 link to details on click
                }, ...
                'Value',         {  ... % default or initial value
                [0.7, 0.7, 0.7; 0, 0, 1], ... %1 alternating box plot colors
                1,                  ... %2 blocks/clump
                'max',              ... %3 method for combining clumps
                true,               ... %4 link to details on click
                }, ...
                'Type',          {  ... % type of property for validation
                'visprops.colorListProperty', ... %1 alternating box plot colors
                'visprops.unsignedIntegerProperty', ... %2 blocks/clump
                'visprops.enumeratedProperty', ... %3 method for combining clumps
                'visprops.logicalProperty' ... %4 link to details on click
                }, ...
                'Editable',      {  ... % grayed out if false
                true,               ... %1 alternating box plot colors
                true,               ... %2 blocks/clump
                true,               ... %3 method for combining clumps
                true                ... %4 link to details on click
                }, ...
                'Options',       {  ... % restrictions on input values
                '',                 ... %1 alternating box plot colors
                [1, inf],           ... %2 blocks/clump
                {'max', 'min', 'mean', 'median', 'sum'}, ... %3 method for combining clumps
                ''                  ... %4 link to details on click
                }, ...
                'Description',   {  ... % description for property manager
                'blockBoxPlot alternating box colors (cannot be empty)', ... %1
                'Number of blocks grouped into a clump represented by one box plot', ... %2
                'Method for combining blocks in a clump',      ... %3
                'If true, click causes detail plot redisplay'} ... %4
                );
        end % getDefaultProperties
        
    end % static methods
    
end  % blockBoxPlot

