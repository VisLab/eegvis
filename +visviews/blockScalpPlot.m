% visviews.blockScalpPlot display a scalp map of blocked function values by window
%
% Usage:
%   >>   visviews.blockScalpPlot(parent, manager, key)
%   >>   obj = visviews.blockScalpPlot(parent, manager, key)
%
% Description:
% obj = visviews.blockScalpPlot(parent, manager, key) displays a scalp map
%    of combined block function values for a specified slice of time.
%    The display includes a contour map of the combined values over the
%    time and either points, labels, or numbers identifying the positions
%    of the elements. The block scalp plot assumes that the elements
%    correspond to eeg channels positioned on a scalp. If no channel
%    locations are provided, the scalp map arrays the elements in a circle
%    and does not draw a contour map.
%
%    The parent is a graphics handle to the container for this plot. The
%    manager is an viscore.dataManager object containing managed objects
%    for the configurable properties of this object, and key is a string
%    identifying this object in the property manager GUI.
%
% obj = visviews.blockScalpPlot(parent, manager, key) returns a handle to
%    the newly created object.
%
% visviews.blockScalpPlot is configurable, resizable, clickable, and cursor explorable.
%
% Configurable properties:
% The visviews.blockScalpPlot has five configurable properties:
%
% CombineMethod specifies how to combine multiple blocks into a
%    single block to determine an overall block value. The value can be
%   'max'  (default), 'min', 'mean', or  'median'. Detail plots use the
%    combined block value to determine slice colors.
%
%    Suppose the plot has 128 elements and 100 windows. The block scalp
%    map requires a single value for each element and must combine the
%    block values over the 100 windows to obtain a single value for each
%    element. Possible combination methods include max, min, mean, or
%    median. The default is the max.
%
% ElementColor specifies the color used for an element and its
%     corresponding label when the electrode is in the current slice. The
%     default is |[0, 0, 0]|.
%
% HeadColor specifies the color for the head outline. The plot function
%     uses the same color for electrodes and their corresponding labels
%     when the electrodes are not in the current slice. The
%     default is |[0.75, 0.75, 0.75]|.
%
% InterpolationMethod specifies the method used to produce the shaded
%     map of block values on the scalp. The default value is 'square' which
%     specifies that the block values be interpolated on a grid that is
%     2 x the HeadRadius. After interpolation, the plot masks values
%     the values that fall outside the inscribed circle with radius
%     HeadRadius. This method is the default method used by EEGLAB
%     topolot. Since some of the outer grid points on the square are
%     outside the convex hull of the elements, values along the edges
%     are extrapolated rather than interpolated. This can result in
%     contours maps that are visually pleasing but can be misleading.
%
%     An alternative interpolation method 'convex', only creates the
%     map within the convex hull. All map values are then interpolated.
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
% % Create a boxplot of kurtosis of 32 exponentially distributed channels
%
%    % Create a block box plot
%    sfig = figure('Name', 'Kurtosis for 32 exponentially distributed channels');
%    bp = visviews.blockScalpPlot(sfig, [], []);
%
%    % Generate some data to plot
%    data = random('exp', 1, [32, 1000, 20]);
%    testVD = viscore.blockedData(data, 'Exponenitally distributed');
%
%    % Create a kurtosis block function object
%    defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
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
%
% Notes:
%   - If manager is empty, the class defaults are used to initialize.
%   - If key is empty, the class name is used to identify in GUI configuration.
%
% Class documentation:
% Execute the following in the MATLAB command window to view the class
% documentation for visviews.blockScalpPlot:
%
%    doc visviews.blockScalpPlot
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

% $Log: blockScalpPlot.m,v $
% Revision: 1.00  04-Dec-2011 09:11:20  krobbins $
% Initial version $
%

classdef blockScalpPlot < visviews.axesPanel & visprops.configurable
    
    properties
        % configurable properties
        CombineMethod = 'max';         % method of combining blocks
        ElementColor = [0, 0, 0];    % electrode color
        HeadColor = [0.75, 0.75, 0.75];   % color for plotting the head
        InterpolationType = 'square';  % method
    end % public properties
    
    properties (Access = private)
        ColorbarAxes = [];       % axis for the color bar
        CurrentElement = [];     % last valid clicked element
        CurrentFunction = [];    % handle to block function for this
        CurrentSlice = [];       % current data slice
        HeadAxes = []            % axis for the 
        InterpolationRadius = 0.5; % radius for extent of interpolation
        NumberBlocks = 0;        % number of blocks being plotted
        NumberElements = 0;      % number of blocks being plotted
        PlotRadius = 0.5  ;      % radius for plotting electrodes
        SliceElectrodes = {};    % electrodes that should produce a slice
        StartBlock = 1;          % starting block of currently plotted slice
        StartElement = 1;        % starting element of currently plotted slice
        SqueezeFactor = 1;       % radial squeeze factor for rescaling
        TextLabel = [];          % handle to label at bottom of head
        ValidElements = [];      % list of the valid elements
    end % private properties
    
    properties (Constant)
        HeadRadius = 0.5;              % head radius (do not change)
    end % constant properties
    
    methods
        
        function obj = blockScalpPlot(parent, manager, key)
            % Parent is non-empty handle to container for axes panel but manager can be empty
            obj = obj@visviews.axesPanel(parent);
            obj = obj@visprops.configurable(key);
            % Update properties if any are available
            if isa(manager, 'viscore.dataManager')
                visprops.property.updateProperties(obj, manager);
            end
            set(obj.MainAxes, 'Tag', 'blockScalpAxes');
        end % blockScalpPlot constructor
        
        function buttonDownPreCallback (obj, src, eventdata)  %#ok<INUSD>
            % Set the current element based on the tag
            obj.CurrentElement = str2double(get(src, 'Tag'));
            if isempty(intersect(obj.CurrentElement, obj.ValidElements))
                obj.CurrentElement = [];
            end
        end % buttonDownPreCallback
        
        function [dSlice, bFunction] = getClicked(obj)
            % Clicking on the electrodes always causes plot of an element
            bFunction = obj.CurrentFunction;
            blockSlice = 'none';
            if isempty(obj.CurrentElement)
                dSlice = [];
            else
                blockSlice = viscore.dataSlice.rangeString( ...
                    obj.StartBlock, obj.NumberBlocks);
                [slices, names] = obj.CurrentSlice.getParameters(3); %#ok<ASGLU>
                dSlice = viscore.dataSlice('Slices', ...
                    {num2str(obj.CurrentElement), ':', blockSlice}, ...
                    'CombineMethod', obj.CombineMethod, 'CombineDim', 1, ...
                    'DimNames', names);
            end
            fprintf('To here %s\n', blockSlice);
        end % getClicked
        
        function [cbHandles, hitHandles] = getHitObjects(obj)
            % Return handles that should register callbacks as well has hit handles
            cbHandles = [{obj.MainAxes, obj.HeadAxes}, obj.SliceElectrodes];
            hitHandles = [{obj.MainAxes, obj.HeadAxes}, obj.SliceElectrodes];
        end % getHitObjects
        
        function plot(obj, visData, bFunction, dSlice)
            % Plots the scalp map with color bar and electrodes
            obj.reset();
            
            % Get needed information from the data and function objects
            bFunction.setData(visData);
            obj.CurrentFunction = bFunction;
            
            if isempty(dSlice)
                obj.CurrentSlice = viscore.dataSlice();
            else
                obj.CurrentSlice = dSlice;
            end
            
            [slices, names] = obj.CurrentSlice.getParameters(3);
            
            % Get values for unsliced elements first (for interpolation)
            [bValues, sStarts, sSizes] =  viscore.dataSlice.getDataSlice(...
                obj.CurrentFunction.getBlockValues(), {':', slices{3}}, ...
                2, obj.CombineMethod);
            obj.StartBlock = sStarts(2);
            obj.NumberBlocks = sSizes(2);
            
            % Now get values sliced for elements
            [sValues, sStarts, sSizes] =  viscore.dataSlice.getDataSlice(...
                bValues, slices(1), [], []);
            obj.StartElement = sStarts(1);
            obj.NumberElements = sSizes(1);
            
            [x, y, labels, values] = ...
                obj.findLocations(visData.getElementLocations(), bValues);
            
            x = x*obj.SqueezeFactor;
            y = y*obj.SqueezeFactor;
            myFigure = ancestor(obj.MainAxes, 'figure');
            set(0, 'CurrentFigure', myFigure);
            set(gcf, 'CurrentAxes', obj.MainAxes);
            
            % Create the label at the bottom
            if obj.NumberBlocks ~= size(sValues, 2)
                combineString = [obj.CombineMethod ' '];
            else
                combineString = '';
            end
            obj.XStringBase = [obj.CurrentFunction.getValue(1, 'DisplayName'), ...
                ' (' combineString names{3} ' ' num2str(obj.StartBlock) ':' ...
                num2str(obj.StartBlock + obj.NumberBlocks - 1) ')' ...
                ' [' names{1} ' ' num2str(obj.StartElement) ':' ...
                num2str(obj.StartElement + obj.NumberElements - 1) ']'];
            obj.XString = obj.XStringBase;
            hold on
            %obj.setBackgroundColor([1, 1, 1]);
            obj.plotMap(x, y, values)
            obj.plotHead();
            obj.plotElements(x, y, labels);
            obj.CursorString = {'y:'; 'x:'};
            hold off
            obj.redraw();
        end % plot
        
       function reset(obj)
            % Delete the children of the axes and ready for replotting
            obj.reset@visviews.axesPanel();
            % Delete the colorbar axes
            if ~isempty(obj.ColorbarAxes) && ishandle(obj.ColorbarAxes)
                delete(obj.ColorbarAxes);
            end
            obj.ColorbarAxes = [];
            % Delete the head axes
            if ~isempty(obj.HeadAxes) && ishandle(obj.HeadAxes)
                delete(obj.HeadAxes);
            end
            obj.HeadAxes = [];
        end % reset
        
        function s = updateString(obj, point)
            % Return a cursor string corresponding to point
            s = '';   % String to be returned
            [x, y, xInside, yInside] = getDataCoordinates(obj, point);
            if ~xInside || ~yInside
                return;
            end
            
            s = {[obj.CursorString{1} num2str(y/obj.SqueezeFactor)]; ...
                [obj.CursorString{2} num2str(x/obj.SqueezeFactor)]}; ...
                
        end % updateString
        
    end % public methods
    
    methods( Access = protected )
        
        function redraw( obj )
            obj.redraw@visviews.axesPanel();
        end % redraw
        
    end % protected methods
    
    methods (Access = private)
        
        function [x, y, labels, values] = ...
                findLocations(obj, elementLocs, bValues)
            % Find channels with valid locations and set locations
            x = []; y = []; labels = {}; values = [];
            if isempty(elementLocs)   % element locations not defined
                return;
            end
            obj.ValidElements = find(~cellfun('isempty', {elementLocs.theta}));
            validElements = intersect(find(~cellfun('isempty', {elementLocs.X})), ...
                obj.ValidElements);
            badElements = union(find(isnan(bValues)), find(isinf(bValues))); % NaN and Inf values
            if ~isempty(badElements)
                obj.ValidElements = setdiff(obj.ValidElements, ...
                    badElements + obj.StartElement - 1);
            end
            if isempty(obj.ValidElements)
                return;
            end
            validElements = sort(validElements);
            theta = {elementLocs.theta};
            theta = pi/180*cell2mat(theta(validElements));
            radius = {elementLocs.radius};
            radius = cell2mat(radius(validElements));
            
            % Transform electrode locations from polar to cartesian coordinates
            [x, y] = pol2cart(theta, radius);
            labels = {elementLocs.labels};
            labels = char(labels(validElements));
            values = bValues(validElements);
            obj.InterpolationRadius = min(1.0, max(radius)*1.02); % just outside outermost electrode location
            obj.PlotRadius = max(obj.InterpolationRadius, 0.5);   % plot to 0.5 head boundary
            obj.SqueezeFactor = obj.HeadRadius/obj.PlotRadius;
            obj.ValidElements = validElements;
        end % findLocations
        
        function markerSize = getMarkerSize(obj, ylen)   %#ok<MANU>
            % Determine the marker size based on the number of electrodes
            mSizes = [10, 3, 4, 5, 6, 8];
            mCutoffs = [100, 80, 64, 48, 32];
            markerSize = mSizes(1);
            for k = 1:length(mCutoffs)
                if ylen > mCutoffs(k)
                    markerSize = mSizes(k + 1);
                    break;
                end
            end
        end % getMarkerSize
        
        function labelCallback (obj, src, eventdata, textobj, labels) %#ok<INUSL,MANU>
            % Callback for switching string of textobj among labels on click
            labelNum = get(src, 'userdata');
            labelNum = mod(labelNum, length(labels)) + 1;
            set(textobj, 'String', labels{labelNum});
            set(src, 'userdata', labelNum);
        end % labelCallback
        
        function plotElements(obj, x, y, labels)
            % Plot elements points and positions, setting callbacks
            if isempty(x)  % don't plot anything if no elements
                return;
            end
            mSize = obj.getMarkerSize(length(x));
            elements = intersect(obj.ValidElements, ...
                obj.StartElement:(obj.StartElement + obj.NumberElements - 1));
            elementMask = false(length(x), 1);
            elementMask(elements) = true;
            obj.SliceElectrodes = cell(1, length(elements));
            sPos = 1;   % indexing variable
            for k = 1:length(x)
                if elementMask(k)    % Element in the slice
                    obj.SliceElectrodes{sPos} = ...
                        plot3(y(k), x(k), 2.1, '.', 'Color', obj.ElementColor, ...
                        'markersize', mSize, 'Tag', num2str(k));
                    % Element labels switch
                    h = text(double(y(k)+0.01),double(x(k)),...
                        2.1, num2str(k),'HorizontalAlignment','left',...
                        'VerticalAlignment','middle','Color', obj.ElementColor, ...
                        'userdata', 1 , ...
                        'FontSize', get(0,'DefaultAxesFontSize'));
                    set(h, 'ButtonDownFcn', {@obj.labelCallback, h, ...
                        {labels(k,:), num2str(obj.ValidElements(k))}});
                    sPos = sPos + 1;
                else
                    h = text(double(y(k)+0.01),double(x(k)),...
                        2.1, '','HorizontalAlignment','left',...
                        'VerticalAlignment','middle','Color', obj.HeadColor, ...
                        'FontSize', get(0,'DefaultAxesFontSize'));
                    plot3(y(k), x(k), 2.1, '.', 'Color', obj.HeadColor, ...
                        'markersize', mSize, 'userdata', 1, 'Tag', num2str(k), ...
                        'ButtonDownFcn', {@obj.labelCallback, h, ...
                        {'', labels(k,:), num2str(obj.ValidElements(k))}});
                end
            end
            
        end % plotElements
        
        function plotHead(obj)
            % Plot head outline and label the graph
            
            % Plot filled ring to mask jagged grid boundary
            hwidth = 0.007;                         % cartoon head ring width
            hin  = obj.SqueezeFactor*obj.HeadRadius*(1 - hwidth/2); % inner head ring radius
            rwidth = 0.035;                         % blanking ring width
            rin = max(hin, obj.HeadRadius*(1 - rwidth/2));   % inner ring radius
            
            % Mask the outer circle
            circ = linspace(0, 2*pi, 201);         % create a circular grid
            rx = sin(circ);
            ry = cos(circ);
            ringx = [[rx(:)' rx(1) ]*(rin + rwidth)  [rx(:)' rx(1)]*rin];
            ringy = [[ry(:)' ry(1) ]*(rin + rwidth)  [ry(:)' ry(1)]*rin];
            patch(ringx, ringy, 0.01*ones(size(ringx)), ...
                obj.getBackgroundColor(), 'edgecolor', 'none'); hold on
            
            % Plot head outline
            headx = [[rx(:)' rx(1) ]*(hin + hwidth)  [rx(:)' rx(1)]*hin];
            heady = [[ry(:)' ry(1) ]*(hin + hwidth)  [ry(:)' ry(1)]*hin];
            patch(headx, heady, ones(size(headx)), ...
                obj.HeadColor, 'edgecolor', obj.HeadColor); hold on
            
            % Plot ears and nose
            base  = obj.HeadRadius - 0.0046;
            basex = 0.18*obj.HeadRadius;              % nose width
            tip   = 1.15*obj.HeadRadius;
            tiphw = 0.04*obj.HeadRadius;              % nose tip half width
            tipr  = 0.01*obj.HeadRadius;              % nose tip rounding
            earX = [0.492, 0.510, 0.518, 0.5299, 0.5419, 0.54, 0.547, ...
                0.532, 0.510, 0.484];                % head radius = 0.5
            earY = [0.0955, 0.1175, 0.1183, 0.1146, 0.0955, -0.0055, ...
                -0.0932, -0.1313, -0.1384, -0.1199];
            
            plot3([basex; tiphw; 0; -tiphw; -basex]*obj.SqueezeFactor, ... % nose
                [base; tip - tipr; tip; tip - tipr; base]*obj.SqueezeFactor,...
                2*ones(size([basex; tiphw; 0; -tiphw; -basex])),...
                'Color', obj.HeadColor, 'LineWidth', 1.7);
            plot3(earX*obj.SqueezeFactor, earY*obj.SqueezeFactor, ... % left ear
                2*ones(size(earX)), 'Color', obj.HeadColor, 'LineWidth', 1.7)
            plot3(-earX*obj.SqueezeFactor, earY*obj.SqueezeFactor,  ... % right ear
                2*ones(size(earY)), 'Color', obj.HeadColor, 'LineWidth', 1.7)
            
            axis square
            axis off
            axis equal;
            set(gca, 'xlim', [-0.51 0.51]);
            set(gca, 'ylim', [-0.51 0.51]);
            obj.TextLabel = text(0.0, -0.51, 2.1, ...   % set the bottom label
                obj.XStringBase, 'HorizontalAlignment','center',...
                'VerticalAlignment','middle','Color', [0, 0, 0]);
        end % plotHead
        
        function plotMap(obj, x, y, values)
            % Plot contour map image for interpolation electrodes
            if isempty(values)  % Nothing to plot
                return;
            end
            
            % Find the elements to interpolate
            intElements = find(x <= obj.InterpolationRadius & y <= obj.InterpolationRadius); % interpolate and plot channels inside interpolation square
            intElements = intersect(obj.ValidElements, intElements);
            intx  = x(intElements);
            inty  = y(intElements);
            intValues = values(intElements);
            xmin = min(-obj.HeadRadius, min(intx));
            xmax = max(obj.HeadRadius, max(intx));
            ymin = min(-obj.HeadRadius, min(inty));
            ymax = max(obj.HeadRadius, max(inty));
            
            xi = linspace(xmin, xmax, 67);   % x-axis description (row vector)
            yi = linspace(ymin, ymax, 67);   % y-axis description (row vector)
            [Xi, Yi ,Zi] = griddata(inty, intx, intValues, yi', xi, 'invdist'); % interpolate
            mask = (sqrt(Xi.^2 + Yi.^2) > obj.HeadRadius); % mask outside the plotting circle
            Zi(mask)  = NaN;                 % mask non-plotting areas
            delta = xi(2) - xi(1); % length of grid entry
            
            % instead of default larger AXHEADFAC
            AXHEADFAC = 1.3;        % head to axes scaling factor
            if obj.SqueezeFactor < 0.92 && obj.PlotRadius-obj.HeadRadius > 0.05  % (size of head in axes)
                AXHEADFAC = 1.05;     % do not leave room for external ears if head cartoon
            end
            set(gca, ...
                'Xlim', [-obj.HeadRadius obj.HeadRadius]*AXHEADFAC, ...
                'Ylim', [-obj.HeadRadius obj.HeadRadius]*AXHEADFAC);
            surface(Xi - delta/2, Yi - delta/2, zeros(size(Zi)), ...
                Zi, 'EdgeColor', 'none', 'FaceColor', 'flat');
            caxis([min(Zi(:)) max(Zi(:))]); % set coloraxis
            %obj.ColorbarAxes = colorbar;
        end % plotMap
        
    end % private methods
    
    methods (Static = true)
        
        function settings = getDefaultProperties()
            % Structure specifying how to set configurable public properties
            cName = 'visviews.elementBoxPlot';
            settings = struct( ...
                'Enabled',       {true, true, true, true}, ...
                'Category',      {cName, cName, cName, cName}, ...
                'DisplayName',   {...
                'Combination method', ...
                'Element color', ...
                'Head color', ...
                'Interpolation method'}, ...
                'FieldName',     {'CombineMethod', 'ElementColor', 'HeadColor',         'InterpolationMethod'}, ...
                'Value',         {'max',            [0, 0, 0],     [0.75, 0.75, 0.75],  'square'}, ...
                'Type',          {...
                'visprops.enumeratedProperty', ...
                'visprops.colorProperty', ...
                'visprops.colorProperty', ...
                'visprops.enumeratedProperty'}, ...
                'Editable',      {true, true, true, true}, ...
                'Options',       {{'max', 'min', 'mean', 'median'}, '', '', {'square', 'convex'}}, ...
                'Description',   {...
                'Method for combining windows to produce single value for each element', ...
                'Color for plotting elements in current slice', ...
                'Color for plotting head outline and elements not in current slice', ...
                'Method for interpolating block data onto the head map'} ...
                );
            
        end % getDefaultProperties
        
    end % static methods
    
end % blockScalpPlot