% visviews.eventImagePlot display event type vs block or clump as an image
%
% Usage:
%   >>   visviews.eventImagePlot(parent, manager, key)
%   >>   obj = visviews.eventImagePlot(parent, manager, key)
%
% Description:
% visviews.eventImagePlot(parent, manager, key) displays the 
%    counts of events as an image (event × clump), 
%    with pixel color representing the number of events. 
%    The y-axis corresponds to event types and 
%    the x-axis corresponds to time (e.g., window or clump number).
%
%    The parent is a graphics handle to the container for this plot. The
%    manager is an viscore.dataManager object containing managed objects
%    for the configurable properties of this object, and key is a string
%    identifying this object in the property manager GUI.
% 
% 
% obj = visviews.eventImagePlot(parent, manager, key) returns a handle to
%    the newly created object.
%
% visviews.eventImagePlot is configurable, resizable, clickable, and cursor explorable.
%
% Configurable properties:
% The visviews.eventImagePlot has eight configurable parameters: 
%
% Background specifies the color of the pixels that are below the
%   lowest threshold level.
%
% CertaintyThreshold is a number between 0 and 1 inclusively, specifying a
%    certainty threshold for displaying events. Events whose certainty is
%    below the threshold will be ignored in the display. This feature is
%    useful for displaying computed events such as classification labels
%    because the user can choose to display only those events that are
%    likely to have happened. By defaults, events have a certainty value
%    of 1, meaning that there is not doubt that they occurred, while a
%    certainty value of 0 means that there is no certainty that they
%    occurred. Set the certainty threshold to 0 to include all events,
%    regardless of certainty. 
%
% ClumpSize specifies the number of consecutive windows or epochs 
%    represented by each pixel column. When the ClumpSize is one (the default), 
%    each pixel column represents its own window. If ClumpSize is greater than 
%    one, each pixel column represents several consecutive blocks. 
%    Users can trade-off clump size versus block size to see different 
%    representations of the data.
%
% CombineMethod specifies how to combine multiple blocks into a 
%    single block to determine an overall block value. The value can be be
%   'max'  (default), 'min', 'mean', 'median' or 'sum'.
%
%    For example, with 32 channels, a clump size of 3, a block size of 
%    1000 samples, the eventImagePlot delivers a slice representing 
%    the events in 3 blocks. The detail plots use image plot's 
%    CombineMethod to combine the blocks to get appropriate 
%    colors for the slice.
%
% ColorLevels is a vector of threshold counts. Event counts below the
%    lowest level are displayed in the background color, while events
%    above the highest level are displayed at the highest color map color.
%    Intermediate counts are displayed by color k if:
%         ColorLevels(k) <= count < ColorLevels(k + 1)
%
% Colormap is the name of one of the built in MATLAB colormaps. The
%    color map used for the display is the background color, appended to
%    map(n), where n is the number of levels specified by ColorLevels.
%
% IsClickable is a boolean specifying whether this plot should respond to
%    user mouse clicks when incorporated into a linkable figure. The
%    default value is true.
%
% LinkDetails is a boolean specifying whether clicking this plot in a
%    linkable figure should cause detail views to display the clicked
%    slice. The default value is true.
%
% Example: 
% Create an event image plot for the sample EEG data
%
%    % Read in some EEG data
%    load('EEG.mat');  % Saved EEGLAB EEG data
%    events = viscore.blockedEvents.getEEGTimes(EEG);
%    testVD = viscore.blockedData(EEG.data, 'Sample EEG data', ...
%          'SampleRate', EEG.srate, 'Events', events);
%    funs = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
%               visfuncs.functionObj.getDefaultFunctions());
%
%    % Plot the block function, adjusting the margins
%    sfig = figure('Name', 'Kurtosis for EEG data');
%    ep = visviews.eventImagePlot(sfig, [], []);
%    ep.plot(testVD, funs{1}, []);
%    gaps = ep.getGaps();
%    ep.reposition(gaps);
%
% Notes:
%  - If the manager parameter is empty, the class defaults are used to
%    initialize.
%  - If the key parameter is empty, the class name is used to identify in
%    GUI configuration.
%  - Choose a neutral background color to emphasize important blocks.
%
% Class documentation:
% Execute the following in the MATLAB command window to view the class 
% documentation for visviews.eventImagePlot:
%
%    doc visviews.eventImagePlot
%
% See also: visviews.axesPanel, visviews.blockImagePlot, visviews.clickable,
%           visprops.configurable, visviews.cursorExplorable,
%           and visviews.resizable

% Copyright (C) 2012  Kay Robbins, UTSA, krobbins@cs.utsa.edu
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

% $Log: eventImagePlot.m,v $
% Revision: 1.00  25-Jun-2012 16:41:55  krobbins $
% Initial version $
%

classdef eventImagePlot < visviews.axesPanel & visprops.configurable
    
    properties
        % configurable properties
        Background = [0.7, 0.7, 0.7]; % color of the image background 
        CertaintyThreshold = 0;       % display events at least this certain
        ClumpSize = 1.0;              % number of blocks in each group (clump)
        ColorLevels = [1, 2, 3, 4];   % vector of count thresholds for colors
        Colormap = 'jet';             % name of color map for display
        CombineMethod = 'sum';        % method for combining blocks when grouped
    end % public properties
    
    properties (Access = private)
        CurrentCounts = [];      % a events x clumps array of current counts
        CurrentFunction = [];    % block function that is currently displayed
        CurrentPointer = [];     % triangle marking current position on axes
        CurrentPosition = [];    % position of the last selected block or empty       
        CurrentSlice = [];       % current slice
        Events = [];             % events object with events 
        NumberBlocks = 0;        % number of blocks
        NumberClumps = 0;        % current number of clumps (boxplots)
        NumberElements = 0;      % number of elements in slice (for downstream)
        NumberEvents = 0;        % number of events being plotted
        StartBlock = 1;          % starting block of currently plotted slice
        StartElement = 1;        % starting element of currently plotted slice 
        UniqueTypes = {};        % cell array with unique event names
    end % private properties
    
    methods
        
        function obj = eventImagePlot(parent, manager, key)
            % Constructor must have parent for axesPanel
            obj = obj@visviews.axesPanel(parent);
            obj = obj@visprops.configurable(key);
            % Update properties if any are available
            if isa(manager, 'viscore.dataManager')
                visprops.property.updateProperties(obj, manager);
            end
            set(obj.MainAxes, 'Box', 'on',  'Tag', 'blockImageAxes', ...
                'ActivePositionProperty', 'position', ...
                'YDir', 'reverse');
        end % eventImagePlot constructor
        
        function [dSlice, bFunction, position] = getClicked(obj,  cposition)
            % Clicking on the boxplot always causes plot of group of blocks
            bFunction = obj.CurrentFunction;
            if isempty(cposition)
                point = get(obj.MainAxes, 'CurrentPoint');
                position = point(1, 1);
            else
                position = cposition;
            end
            dSlice = obj.calculateClumpSlice(position);
            obj.drawMarker(round(obj.CurrentPosition));
            position = obj.CurrentPosition;
        end % getClicked
        
        function position = getCurrentPosition(obj)
            % Return the current position
            position = obj.CurrentPosition;
        end % getCurrentPosition
        
         function name = getName(obj)
            % Return an identifying name for this object
            name = [num2str(obj.getObjectID()) '[' class(obj) ']'];
            if ~isempty(obj.CurrentFunction)
               name = [name ' ' obj.CurrentFunction.getValue(1, 'DisplayName')];
            end
        end % getName
        

        function plot(obj, visData, bFunction, dSlice)
            % Plot the blocked data using an image
            obj.reset();
            
            % Get needed information from the data and function objects
            if isempty(visData) || isempty(bFunction)
                warning('eventImagePlot:emptyFunctionOrData', ...
                    'Missing summary function or block data for this plot');
                return;
            end       
            bFunction.setData(visData);    % Make sure data is correct
            obj.CurrentFunction = bFunction; % Remember for data explorer
            if isempty(dSlice)
                obj.CurrentSlice = viscore.dataSlice();
            else
                obj.CurrentSlice = dSlice;
            end
            obj.Events = visData.getEvents();  
            if isempty(obj.Events);
                return;
            end
            obj.UniqueTypes = obj.Events.getUniqueTypes();
            obj.UniqueTypes{end + 1} = 'Uncertain';
             % Calculate sizes and number of clumps, adjust for uneven clumps
            [e, s, b] = visData.getDataSize();
            [slices, names] = obj.CurrentSlice.getParameters(3);  
            [dSlice, starts, sizes] = viscore.dataSlice.getSliceEvaluation(...
                [e, s, b], slices); %#ok<ASGLU>
            if isempty(starts) || isempty(sizes)
                return;
            end
            obj.StartBlock = starts(3);
            obj.StartElement = starts(1);
            obj.NumberBlocks = sizes(3);
            obj.NumberElements = sizes(1);
           
            obj.Events = visData.getEvents();  
            if isempty(obj.Events);
                return;
            end
            obj.UniqueTypes = obj.Events.getUniqueTypes();
            obj.NumberEvents = size(obj.UniqueTypes, 1) + 1;
            colors = obj.createColors();
            iMap = image(colors, 'Parent', obj.MainAxes, 'Tag', 'ImageMap');
            set(iMap, 'HitTest', 'off') %Get position from axes not image
            
            % Fix up the labels, limits and tick marks as needed
            obj.YStringBase = 'Event';
            obj.YString =  obj.YStringBase;
            yLimits = [0.5, double(obj.NumberEvents) + 0.5];
            yTickLabels = cell(1, obj.NumberEvents);
            yTickLabels{1} = '1';
            yTickLabels{obj.NumberEvents} = 'U';
            yTickLabels{obj.NumberEvents - 1} = num2str(obj.NumberEvents - 1);
            
            xLimits = [0.5, double(obj.NumberClumps) + 0.5];
            [xTickMarks, xTickLabels, obj.XStringBase] = ...
                obj.getClumpTicks(names{3});
            obj.XString = obj.XStringBase;
            
            % Fix the cursor string template
            if ~isempty(names{3})
                wString = names{3};
            else
                wString = 'Window';
            end
     
            obj.CursorString = {[wString ': ']; 'Ev-type: ';  ...
                'Count: ';};
            set(obj.MainAxes, ...
                'XLimMode', 'manual', 'XLim', xLimits, ...
                'XTickMode','manual', 'XTick', xTickMarks, ...
                'XTickLabelMode', 'manual', 'XTickLabel', xTickLabels, ...
                'YLimMode', 'manual', 'YLim', yLimits, ...
                'YTickMode','manual', 'YTick', 1:obj.NumberEvents, ...
                'YTickLabelMode', 'manual', 'YTickLabel', yTickLabels);
            obj.redraw();
        end % plot
        
        function s = updateString(obj, point)
            % Return [Block, Element, Function] value string for point
            s = '';   % String to be returned
            [x, y, xInside, yInside] = getDataCoordinates(obj, point);
            if ~xInside || ~yInside
                return;
            end
            
            cNum = round(x);
            if cNum < 1 || cNum > obj.NumberClumps
                return;
            end
            
            
            w = min(ceil((x - 0.5)*double(obj.ClumpSize)), obj.NumberBlocks) + obj.StartBlock - 1; 
            y = ceil(y - 0.5);
            x = ceil(x - 0.5);
            fprintf('%d %d\n', x, y);
            
            s = {[obj.CursorString{1} num2str(w)]; ...
                 [obj.CursorString{2} obj.UniqueTypes{y} '(' num2str(y) ')']; ...
                 [obj.CursorString{3} num2str(obj.CurrentCounts(y, x))]};
        end % updateString
        
    end % public methods
    
    methods (Access = 'private')
        
       function dSlice = calculateClumpSlice(obj, clump)
            % Calculate slice for clump and set CurrentPosition
            dSlice = [];
            if clump == -inf
                clump = 1;
            elseif clump == inf
                clump = obj.NumberClumps;
            elseif clump <= 0 || clump >= obj.NumberClumps + 1 || ...
                    obj.NumberClumps ~= ...      % needs to be recalculated
                    ceil(double(obj.NumberBlocks)/double(obj.ClumpSize));
                return;
            end
            clump = min(obj.NumberClumps, max(1, round(clump))); % include edges
            obj.CurrentPosition = clump;
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
           
        function colors = createColors(obj)
            % Return the the colors for the current clumps
            counts = obj.Events.getEventCounts(obj.StartBlock, ...
                obj.StartBlock + obj.NumberBlocks - 1, obj.CertaintyThreshold);
            
            % Calculate the number of clumps and adjust for uneven clumps
            obj.NumberClumps = ceil(double(obj.NumberBlocks)/double(obj.ClumpSize));
            if obj.ClumpSize > 1
                leftOvers = obj.NumberClumps*obj.ClumpSize - obj.NumberBlocks;
                if leftOvers > 0
                    counts = [counts, zeros(obj.NumberEvents, leftOvers)];
                end
                counts = reshape(counts', obj.ClumpSize, obj.NumberClumps*obj.NumberEvents);
                counts = viscore.dataSlice.combineDims(counts, 1, obj.CombineMethod);
                counts = reshape(counts, obj.NumberClumps, obj.NumberEvents)';
            end
            obj.CurrentCounts = counts;
            mask = zeros(1, obj.NumberEvents*obj.NumberClumps);
            for k = 2:length(obj.ColorLevels)
                mask(counts >= obj.ColorLevels(k - 1) & ...
                     counts < obj.ColorLevels(k)) = k - 1;
            end;
            mask(counts >= obj.ColorLevels(end)) = length(obj.ColorLevels);
            
            colors = eval([obj.Colormap '(' num2str(length(obj.ColorLevels)) ')']);
            colors = [obj.Background; colors];
            colors = colors(mask + 1, :);   
            colors = reshape(colors, [obj.NumberEvents, obj.NumberClumps, 3]);         
        end % createColors
        
        function drawMarker(obj, p)
            % Draw a triangle outside axes at position p
            if p < 0.5
                return;
            end    
            pos = getpixelposition(obj.MainAxes, false);
            x =  p + [-0.5; 0; 0.5];
            if isempty(obj.CurrentPointer) || ~ishandle(obj.CurrentPointer)
                obj.CurrentPointer = fill(x, [-0.5; 0.5; -0.5], ...
                    [1, 0, 0], 'Parent', obj.MainAxes);
            else
                set(obj.CurrentPointer, 'XData', x);
            end    
        end % drawMarker
      
        function [xTickMarks, xTickLabels, xStringBase] = getClumpTicks(obj, clumpName)
            % Calculate the x tick marks and labels based on clumps
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
            if obj.ClumpSize > 1
                if ~isempty(clumpName)
                    cName = [clumpName 's '];
                else
                    cName = '';
                end
                xStringBase = [cName ...
                    num2str(obj.StartBlock) ':' ...
                    num2str(obj.StartBlock + obj.NumberBlocks -1) ...
                    ' clumps of ' num2str(obj.ClumpSize)];
                
            else
                xStringBase = clumpName;
            end
        end % getClumpTicks

    end % private methods
    
    methods (Static = true)
        
        function settings = getDefaultProperties()
            % Structure specifying how to set configurable public properties
            cName = 'visviews.eventImagePlot';
            settings = struct( ...
                'Enabled',       { ... % display in property manager?
                 true,             ... %1 background color               
                 true,             ... %2 certainty threshold
                 true,             ... %3 blocks/clump
                 true,             ... %4 color levels
                 true,             ... %5 color map for image
                 true              ... %6 method for combining clumps
                 }, ...
                'Category',      {  ... % category for property
                 cName,             ... %1 background color                 
                 cName,             ... %2 certainty threshold
                 cName,             ... %3 blocks/clump
                 cName,             ... %4 color levels
                 cName,             ... %5 color map for image
                 cName              ... %6 method for combining clumps
                 }, ...
                'DisplayName',   {  ... % display name in property manager
                'Background color',    ... %1 background color              
                'Certainty threshold', ... %2 certainty threshold
                'Clump size',          ... %3 blocks/clump
                'Color levels',        ... %4 color levels
                'Color map',           ... %5 color map for image
                'Combine method'       ... %6 method for combining clumps
                },    ...
                'FieldName',     {  ... % name of public property
                'Background',         ... %1 background color              
                'CertaintyThreshold', ... %2 certainty threshold
                'ClumpSize',          ... %3 blocks/clump
                'ColorLevels',        ... %4 color levels
                'Colormap',           ... %5 color map for image
                'CombineMethod'       ... %6 method for combining clumps
                }, ...
                'Value',         {  ... % default or initial value
                 [0.7, 0.7, 0.7],     ... %1 background color                 
                 0,                   ... %2 certainty threshold
                 1,                   ... %3 blocks/clump
                 [1, 2, 3],           ... %4 color levels
                'jet',                ... %5 color map for image
                'sum'                 ... %6 method for combining clumps
                }, ...
                'Type',          { ... % type of property for validation
                'visprops.colorProperty',           ... %1 background color                
                'visprops.doubleProperty',          ... %2 certainty threshold
                'visprops.unsignedIntegerProperty', ... %3 blocks/clump
                'visprops.vectorProperty',          ... %4 color levels
                'visprops.enumeratedProperty',      ... %5 color map for image
                'visprops.enumeratedProperty'       ... %6 method for combining clumps
                }, ...
                'Editable',      { ... % grayed out if false
                 true,             ... %1 background color                
                 true,             ... %2 certainty threshold
                 true,             ... %3 blocks/clump
                 true,             ... %4 color levels
                 true,             ... %5 color map for image
                 true              ... %6 method for combining clumps
                 }, ...
                'Options',       { ... % restrictions on input values
                '',                ... %1 background color
                [0, 1],            ... %2 certainty threshold
                [1, inf],          ... %3 blocks/clump
                [1, inf],          ... %4 color levels
                {'jet', 'hsv', 'hot', 'cool', 'spring', 'summer', ...
                'autumn', 'winter', 'gray', 'bone', 'copper', ...
                'pink', 'lines'},  ... %5 color map for image
                {'max', 'min', 'mean', 'median', 'sum'} ...
                                   ... %6 method for combining clumps
                }, ...
                'Description',   {... % description of property
                'Color of pixels with no events',         ... %1  
                'Only display events that are at least this certain', ... %2 
                'Number of blocks grouped into a clump represented by one image pixel column', ... %3
                'Vector of count thresholds for choosing display colors', ... %4
                'Color map for the counts',               ... %5
                'Method for combining blocks in a clump'  ... %6
                } ...
                );
        end % getDefaultProperties
        
    end % static methods
    
end % eventImagePlot

