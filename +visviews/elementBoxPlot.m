% visviews.elementBoxPlot display a boxplot of block function values by element
%
% Usage:
%   >>   visviews.elementBoxPlot(parent, manager)
%   >>   obj = visviews.elementBoxPlot(parent, manager)
%
% Description:
% obj = visviews.elementBoxPlot(parent, manager, key) displays a series of 
%     horizontal box plots using a compressed style. The element box plot 
%     displays the distribution of values of a summarizing function for 
%     each element (e.g., channel)  as a horizontal box plot. 
% 
%    The parent is a graphics handle to the container for this plot. The
%    manager is an viscore.dataManager object containing managed objects
%    for the configurable properties of this object, and key is a string
%    identifying this object in the property manager GUI.
% 
% obj = visviews.elementBoxPlot(parent, manager, key) returns a handle to
%     the newly created object.
%
% visviews.elementBoxPlot is configurable, resizable, clickable, and cursor explorable.
%
% Configurable properties:
% The visviews.elementBoxPlot has four configurable parameters: 
%
% ClumpFactor specifies the number of consecutive elements 
%    represented by each box. When the ClumpFactor is one (the default), 
%    each box represents a single window or epoch. If ClumpFactor is greater than 
%    one, each box represents several consecutive elements. 
%
% CombineMethod specifies how to combine multiple elements into a 
%    single group to determine an overall block value. The value can be 
%   'max'  (default), 'min', 'mean', or  'median'. Detail plots use this 
%    block value to determine slice colors. 
%
%    For example, with 128 channels, a clump size of 3, and a block size of 
%    1000 samples, and 20 windows, the elementBoxPlot delivers a slice representing 
%    3×1000×20 worth of data. A detail plot such as stackedSignalPlot 
%    combines this data based on its own CombineMethod property, 
%    say by taking the mean to plot 20×1000 data points on 20 line graphs. 
%    However, we would like to use line colors for the signals based 
%    on the block function values in the box plot. The detail plots use 
%    box plot's CombineMethod to combine the blocks to get appropriate 
%    colors for the slice. 
%
%    Usually signal plots combine signals using mean or median, while 
%    summary plots such as elementBoxPlot use the max, although users may 
%    choose other combinations.
%
% IsClickable boolean specifying whether this plot should respond to
%    user mouse clicks when incorporated into a linkable figure. The
%    default value is true.
%
% LinkDetails boolean specifying whether clicking this plot in a
%    linkable figure should cause detail views to display the clicked
%    slice. The default value is true.
%
% Example: 
% Create a boxplot of kurtosis of 32 exponentially distributed channels
%
%    % Create a block box plot
%    sfig = figure('Name', 'Kurtosis for 32 exponentially distributed channels');
%    bp = visviews.elementBoxPlot(sfig, [], []);
%
%    % Generate some data to plot
%    data = random('exp', 1, [32, 1000, 20]);
%    testVD = viscore.blockedData(data, 'Exponenitally distributed');
%    
%    % Create a kurtosis block function object
%   defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
%               visfuncs.functionObj.getDefaultFunctions());
%    thisFunc = defaults{1};
%    thisFunc.setData(testVD);
%   
%    % Plot the block function
%    bp.plot(testVD, thisFunc, []);
%   
%    % Adjust the margins
%    gaps = bp.getGaps();
%    bp.reposition(gaps);
%   
% Notes:
%  - If manager is empty, the class defaults are used to initialize
%  - If key is empty, the class name is used to identify in GUI configuration
%  - Uses MATLAB's boxplot and requires the statistics toolbox
%
% See also: visviews.blockBoxPlot, visviews.blockImagePlot, 
%           visviews.clickable, visprops.configurable, 
%           visviews.cursorExplorable, and visviews.resizable
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

% $Log: elementBoxPlot.m,v $
% Revision: 1.00  04-Dec-2011 09:11:20  krobbins $
% Initial version $
%

classdef elementBoxPlot < visviews.axesPanel & visprops.configurable
    
    properties
        % configurable properties
        BoxColors = [0.7, 0.7, 0.7; 1, 0, 1];  % alternating box colors
        ClumpFactor = 1.0;      % number of elements in each box plot (clump)
        CombineMethod = 'max';   % method of combining blocks in a clump
    end % public properties
    
    properties (Access = private)
        Boxplot = [];           % handle to boxplot for setting callbacks
        CurrentFunction = [];   % block function that is currently displayed
        CurrentSlice = [];      % current data slice
        NumberBlocks = 1;       % number of blocks being plotted
        NumberClumps = 0;       % current number of clumps (boxplots)
        NumberElements = 1;     % number of elements being plotted
        StartBlock = 1;         % starting block of currently plotted slice
        StartElement = 1;       % starting block of currently plotted slice
    end % private properties
    
    methods
        
        function obj = elementBoxPlot(parent, manager, key)
            % Constructor must have parent for axesPanel
            obj = obj@visviews.axesPanel(parent);
            obj = obj@visprops.configurable(key);
            % Update properties if any are available
            if isa(manager, 'viscore.dataManager')
                visprops.property.updateProperties(obj, manager);
            end
            set(obj.MainAxes, 'YDir', 'reverse', 'Tag', 'elementBoxAxes');
        end % elementBoxPlot constructor
        
        function [dSlice, bFunction] = getClicked(obj)
            % Clicking on the boxplot always causes plot of an element
            point = get(obj.MainAxes, 'CurrentPoint');
            bFunction = obj.CurrentFunction;
            dSlice = obj.getClumpSlice(point(1, 2));
        end % getClicked
        
        function dSlice = getClumpSlice(obj, clump)
            % Returns the slice corresponding to elements in clump
            dSlice = [];
            
            if clump <= 0 || clump >= obj.NumberClumps + 1 || ...
                    obj.NumberClumps ~= ...  % needs to be recalculated
                    ceil(double(obj.NumberElements)/double(obj.ClumpFactor));
                return;
            end
            clump = min(obj.NumberClumps, max(1, round(clump))); % include edges
            if obj.ClumpFactor == 1
                s = num2str(clump + obj.StartElement - 1);
            else
                startElement = (clump - 1)* obj.ClumpFactor + obj.StartElement; % adjust to win num
                endElement = min(obj.StartElement + obj.NumberElements - 1, ...
                               startElement + obj.ClumpFactor - 1);
                s = [num2str(startElement) ':' num2str(endElement)];
            end
            [slices, names] = obj.CurrentSlice.getParameters(3); %#ok<ASGLU>
            blockSlice = viscore.dataSlice.rangeString( ...
                                         obj.StartBlock, obj.NumberBlocks);
            dSlice = viscore.dataSlice('Slices', {s, ':', blockSlice}, ...
                'CombineMethod', obj.CombineMethod, 'CombineDim', 1, ...
                'DimNames', names);
        end % getClumpSlice
        
        function [cbHandles, hitHandles] = getHitObjects(obj)
            % Return handles that should register callbacks as well has hit handles
            cbHandles = {obj.MainAxes, obj.Boxplot};
            hitHandles = {obj.MainAxes, obj.Boxplot};
        end % getHitObjects
        
        function plot(obj, visData, bFunction, dSlice)
            % Sets up the plot hierarchy but may not display plot
            obj.reset();
            
            % Get needed information from the data and function objects
            bFunction.setData(visData);
            obj.CurrentFunction = bFunction;
           
            if isempty(dSlice)
                obj.CurrentSlice = viscore.dataSlice();
            else
                obj.CurrentSlice = dSlice;
            end
            
            [slices, names] = obj.CurrentSlice.getParameters(3); %#ok<ASGLU>
            [data, s] = bFunction.getBlockSlice(obj.CurrentSlice);
            obj.StartBlock = s(2);
            obj.StartElement = s(1);
            [obj.NumberElements, obj.NumberBlocks] = size(data);
            limits = bFunction.getBlockLimits();
            
            % Calculate the number of clumps and adjust for uneven clumps
            obj.NumberClumps = ceil(double(obj.NumberElements)/double(obj.ClumpFactor));
            leftOvers = obj.NumberClumps*obj.ClumpFactor - obj.NumberElements ;
            if leftOvers > 0
                data = [data; zeros(leftOvers, obj.NumberBlocks)];
            end
            data = reshape(data', obj.NumberBlocks*obj.ClumpFactor, obj.NumberClumps);
            groups = repmat((1:obj.NumberClumps)', 1, obj.NumberBlocks*obj.ClumpFactor)';
            
            dRange = 1:(obj.NumberElements *obj.NumberBlocks);
            limits = [max(limits(1), min(data(:))), min(limits(2), max(data(:)))];
            try % boxplot fails if it doesn't have enough room
                obj.Boxplot = boxplot(obj.MainAxes, ...
                    data(dRange),  num2cell(groups(dRange)), ...
                    'plotstyle', 'compact', 'Orientation', 'horizontal', ...
                    'Colors', obj.BoxColors, 'factordirection', 'list', ...
                    'Jitter', 0.1, 'datalim', limits, ...
                    'extrememode', 'compress');
            catch ME
                warning('elementBoxPlot:plot', ...
                    ['boxplot ' obj.getObjectID() ' for function ' ...
                    obj.CurrentFunction.getDisplayName(1) ...
                    ' doesn''t have enough room to plot: (' ME.message ...
                    ')\nPossible fixes:\n' ...
                    ' - Expand the figure window\n' ...
                    ' - Consider using a hierarchy and clumping to show this data\n' ...
                    ' - Shorten function and window display names\n' ...
                    ' - Expand the summary plot space vertically']);
                return;
            end
            
            % Fix up the labels, limits, and tick marks as needed
            yLimits = [0, obj.NumberClumps + 1];
            [yTickMarks, yTickLabels, obj.YStringBase, xBase] = ...
                obj.getClumpTicks(names{3}, names{1});
            
            obj.XStringBase = [bFunction.getValue(1, 'DisplayName') ...
                ' ' xBase];
            obj.YString = obj.YStringBase;
            obj.XString = obj.XStringBase;
            
            if ~isempty(names{1})
                eString = names{1}(1);
            else
                eString = 'e';
            end
 
            xTickLabels = cellstr(get(obj.MainAxes, 'XTickLabel'));
            xTickMarks = get(obj.MainAxes, 'XTick');
            xLimits = get(obj.MainAxes, 'XLim');
            if length(xTickLabels) > 2
                for k = 2:length(xTickLabels) - 1
                    xTickLabels(k) =  {' '};
                end
            end

            set(obj.MainAxes, 'ActivePositionProperty', 'Position', ...
                'XLimMode', 'manual', 'XLim', xLimits, ...
                'XTickMode','manual', 'XTick', xTickMarks, ...
                'XTickLabelMode', 'manual', 'XTickLabel', xTickLabels, ...
                'YLimMode', 'manual', 'YLim', yLimits, ...
                'YTickMode','manual', 'YTick', yTickMarks, ...
                'YTickLabelMode', 'manual', 'YTickLabel', ...
                yTickLabels);
            
            % Set the cursor string for exploration mode
            obj.CursorString = {[eString ': '];  ...
                [bFunction.getValue(1, 'ShortName') ': ']};
            
            obj.redraw();     
        end % plot
        
        function s = updateString(obj, point)
            % Return a cursor string corresponding to point
            s = '';   % String to be returned
            [x, y, xInside, yInside] = getDataCoordinates(obj, point);
            if ~xInside || ~yInside
                return;
            end
            cNum = round(y);
            if cNum < 1 || cNum > obj.NumberClumps
                return;
            end
            
            e = min(ceil((y - 0.5)*double(obj.ClumpFactor)), obj.NumberElements);
            s = {[obj.CursorString{1} num2str(e)]; ...
                [obj.CursorString{2} num2str(x)]}; ...
                
        end % updateString
        
    end % public methods
    
    methods (Access = private)
           
        function [yTickMarks, yTickLabels, yStringBase, xStringBase] = ...
                getClumpTicks(obj, blockName, elementName)
            % Calculate the tick marks and labels based on clumps
            if obj.NumberClumps <= 1 && obj.ClumpFactor == 1
                yTickMarks = 1;
                yTickLabels = {num2str(obj.StartElement)};
            elseif obj.NumberClumps <= 1
                yTickMarks = 1;
                yTickLabels = {'1'};
            elseif obj.ClumpFactor == 1;
                yTickMarks = [1, obj.NumberClumps];
                yTickLabels = {num2str(obj.StartElement), ...
                    num2str(obj.StartElement + obj.NumberClumps - 1)};
            else
                yTickMarks = [1, obj.NumberClumps];
                yTickLabels = {'1', num2str(obj.NumberClumps)};
            end
            if obj.ClumpFactor == 1 || obj.NumberElements == 1
                yStringBase = elementName;
            else
                yStringBase = [elementName 's ' ...
                    num2str(obj.StartElement) ':' ...
                    num2str(obj.StartElement + obj.NumberElements -1) ...
                    ' in clumps of ' num2str(obj.ClumpFactor)];
            end
            
            % Add an indicator of which elements being plotted
            if obj.NumberBlocks > 1
                xStringBase = ['[' blockName 's ' ...
                    num2str(obj.StartBlock) ':' ...
                    num2str(obj.NumberBlocks + obj.StartBlock - 1) ']'];
            else
                xStringBase = ['[' blockName ' ' ...
                    num2str(obj.StartBlock) ']'];
            end
        end % getClumpTicks
    end
    
    methods (Static = true)
        
        function settings = getDefaultProperties()
            % Structure specifying how to set configurable public properties
            cName = 'visviews.elementBoxPlot';
            settings = struct( ...
                'Enabled',       {true, true, true}, ...
                'Category',      {cName, cName, cName}, ...
                'DisplayName',   {...
                'Box plot colors', ...
                'Elements per clump (boxplot)', ...
                'Combination method'}, ...
                'FieldName',     {'BoxColors', 'ClumpFactor', 'CombineMethod'}, ...
                'Value',         { ...
                [0.7, 0.7, 0.7; 0, 0, 1], ...
                1, ...
                'max'}, ...
                'Type',          {...
                'visprops.colorListProperty', ...
                'visprops.unsignedIntegerProperty', ...
                'visprops.enumeratedProperty'}, ...
                'Editable',      {true, true, true}, ...
                'Options',       {'', [1, inf], {'max', 'min', 'mean', 'median'}}, ...
                'Description',   {...
                'elementBoxPlot alternating box colors (cannot be empty)', ...
                'Number of elements grouped into a clump represented by one box plot', ...
                'Method for combining elements in a clump'} ...
                );
            
        end % getDefaultProperties
        
    end % static methods
    
end % elementBoxPlot

