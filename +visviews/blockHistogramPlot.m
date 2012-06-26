% visviews.blockHistogramPlot() display histogram and boxplot of block function values
%
% Usage:
%   >>  visviews.blockHistogramPlot(parent, manager, key)
%   >>  obj = visviews.blockHistogramPlot(parent, manager, key)
%
% Description:
% obj = visviews.blockHistogramPlot(parent, manager, key) displays a 
%     histogram of the summary values along with an aligned horizontal box
%     plot to give two views of the data.
%
%     The parent is a graphics handle to the container for this plot. The
%     manager is an viscore.dataManager object containing managed objects
%     for the configurable properties of this object, and key is a string
%     identifying this object in the property manager GUI.
% 
% obj = visviews.blockHistogramPlot(parent, manager, key) returns a handle to
%     the newly created object.
%
% visviews.blockHistogramPlot is configurable, resizable, clickable, and 
% cursor explorable.
%
% Configurable properties:
% The visviews.blockHistogramPlot has two configurable properties: 
%
% HistogramColor is a 1 x 3 color vector giving the color of the 
%                histogram bars. The default color is light gray.
%
% NumberBins     specifies the number of bins in the histogram. The
%                default number of bins is 20.
%
% The visualization is not linkable or clickable.
%
% Example:
% Create a histogram summary of kurtosis of 32 exponentially distributed channels
%
%   % Create a block histogram plot
%   sfig = figure('Name', 'Kurtosis for 32 exponentially distributed channels');
%    bp = visviews.blockHistogramPlot(sfig, [], []);
%
%   % Generate some data to plot
%   data = random('exp', 1, [32, 1000, 20]);
%   testVD = viscore.blockedData(data, 'Exponenitally distributed');
%    
%   % Create a kurtosis block function object
%   funs = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
%              visfuncs.functionObj.getDefaultFunctions());
%    
%   % Plot the block function histogram
%   bp.plot(testVD, funs{1}, []);
%   
%   % Adjust the margins
%   gaps = bp.getGaps();
%   bp.reposition(gaps);
%
% Notes:
% - If manager is empty, the class defaults are used to initialize.
% - If key is empty, the class name is used to identify in GUI
%   configuration.
%
% Class documentation:
% Execute the following in the MATLAB command window to view the class 
% documentation for visviews.blockHistogramPlot:
%
%    doc visviews.blockHistogramPlot
%
% See also: visviews.axesPanel, visviews.blockBoxPlot, visviews.clickable, 
%           visprops.configurable, visviews.elementBoxPlot, and 
%           visviews.resizable 
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

% $Log: blockHistogramPlot.m,v $
% Revision: 1.00  04-Dec-2011 09:11:20  krobbins $
% Initial version $
%

classdef blockHistogramPlot < visviews.axesPanel & visprops.configurable 
    
    properties
        BoxColor = [0, 0, 0];                % color used for the box plot
        DefaultColor = [0.7, 0.7, 0.7];      % color used in various places
        HistogramColor = [0.85, 0.85, 0.85]; % color used for histogram faces
        NumberBins = 20;                     % number of bins used
    end % public properties 
    
    properties (Access = private)
        BoxPlot                 % handle to boxplot for display purposes
        CurrentFunction = [];   % block function that is currently displayed
        CurrentSlice = [];      % current slice of data
        NumberBlocks = 1;       % number of blocks being plotted
        NumberElements = 1;     % number of elements being plotted
        StartBlock = 1;         % starting block of currently plotted slice
        StartElement = 1;       % starting block of currently plotted slice
    end % private properties 
    
    methods
        
        function obj = blockHistogramPlot(parent, manager, key)
            % Constructor must have parent for axesPanel
            obj = obj@visviews.axesPanel(parent);
            obj = obj@visprops.configurable(key);
            % Update properties if any are available
            if isa(manager, 'viscore.dataManager')
                visprops.property.updateProperties(obj, manager);
            end
            set(obj.MainAxes, 'Box', 'on',  'Tag', 'blockHistogramAxes', ...
                'ActivePositionProperty', 'position');
        end % blockHistogramPlot constructor
        
        function plot(obj, visData, bFunction, dSlice) 
            % Plot the blocks
            obj.reset();
            set(obj.MainAxes, 'Box', 'on',  'Tag', 'blockHistogramPlot', ...
                'ActivePositionProperty', 'position');
            hold(obj.MainAxes, 'on');
            
            if isempty(visData) || isempty(bFunction)
                warning('blockHistogramPlot:emptyFunctionOrData', ...
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
            
            [slices, names] = obj.CurrentSlice.getParameters(3); %#ok<ASGLU>
 
            [data, s] = bFunction.getBlockSlice(obj.CurrentSlice);
            if isempty(data)
                warning('blockHistogramPlot:emptyData', 'No data for this plot');
                return;
            end
            obj.StartBlock = s(2);
            obj.StartElement = s(1);
            [obj.NumberElements, obj.NumberBlocks] = size(data);

            [hHeight, xout] = hist(data(:), obj.NumberBins);
            xout = double(xout);
            hHeight = hHeight/length(data(:));  % Probability
            hFact = floor(1./max(hHeight));
            hTop = ceil(max(hHeight)*hFact)/hFact;      % Top scale of histogram
            if isnan(hTop) || hTop < 0.05 || hTop > 1
                warning('blockHistogramPlot:NaNData', ...
                    'Data histogram appears to be out of range');
                hTop = 1;
            end
            obj.BoxPlot = boxplot(obj.MainAxes, data(:), 'Notch', 'on', ...
                'Positions', 1.5*hTop, 'Widths', 0.25*hTop, ...
                'Color', obj.BoxColor, ...
                'Orientation', 'horizontal', 'Labels', {});
            bar(obj.MainAxes, xout, hHeight, 1.0, ...
                'Facecolor', obj.HistogramColor);
            set(obj.MainAxes, 'YLimMode', 'manual', 'YLim', [0, 2*hTop], ...
                'YTickMode', 'manual', 'YTick', [0, hTop/2, hTop], ...
                'YTickLabelMode', 'manual', ...
                'YTickLabel', {'0', '', ''}); %{'0', '', num2str(hTop)});
            obj.XString = bFunction.getValue(1, 'DisplayName');
            obj.XStringBase = [obj.XString ' ' getAxesLabels(obj, names{3}, names{1})];
            obj.XString = obj.XStringBase;
            obj.CursorString = {[bFunction.getValue(1, 'ShortName') ': ']};
            xLims = get(obj.MainAxes, 'XLim');            
            % Label the probability over the maximum bar
            [mValue, pos] = max(hHeight); %#ok<ASGLU>
            line(xLims, [hTop, hTop], 'Parent', obj.MainAxes, ...
                'Color', obj.DefaultColor);
            textString = strtrim(sprintf('%5.2g', hTop));
            text(xout(pos(1)), hTop, textString, 'Parent', obj.MainAxes, ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
            hold(obj.MainAxes, 'off');
            obj.YString =  '';
            obj.YStringBase = obj.YString;
            if ~isempty(names{1})
                obj.CursorString{2} = [names{1}(1) ': '];
            end
            obj.redraw();
        end % plot
        
        function s = updateString(obj, point)
            % Return [Block, Element, Function] value string for point
            s = '';   % String to be returned
            try   % Use exception handling for small round-off errors
                p = getpixelposition(obj.MainAxes, true);
                if point(1) < p(1) || point(2) < p(2) || ...
                        point(1) >= p(1) + p(3) || point(2) >= p(2) + p(4)
                    return    % not on this graph so return an empty string
                end
                % Translate point to data units and make a string
                a = get(obj.MainAxes,  'XLim');
                x = (a(2) - a(1))*(point(1) - p(1))/p(3) + a(1);
                s = {[obj.CursorString{1} num2str(x)]};
            catch  %#ok<CTCH>
            end
        end % updateString
        
    end % public methods
    
    methods (Access = private)
           
        function xStringBase = getAxesLabels(obj, blockName, elementName)
            % Calculate the string for the xaxis label
            if  obj.NumberElements == 1
                xStringBase = [elementName ' ' num2str(obj.StartElement)];
            else
                xStringBase = [elementName 's ' ...
                    num2str(obj.StartElement) ':' ...
                    num2str(obj.StartElement + obj.NumberElements -1)];
            end
            
            % Add an indicator of which elements being plotted
            if obj.NumberBlocks > 1
                xStringBase = [ '[' xStringBase '] [' blockName 's ' ...
                    num2str(obj.StartBlock) ':' ...
                    num2str(obj.NumberBlocks + obj.StartBlock - 1) ']'];
            else
                xStringBase = [ '[' xStringBase '] [' blockName ' ' ...
                    num2str(obj.StartBlock) ']'];
            end
        end % getAxesLabels
    end
    
    methods (Static = true)
        
       function settings = getDefaultProperties()
            % Structure specifying how to set configurable public properties
            cName = 'visviews.blockHistogramPlot';
            settings = struct( ...
                'Enabled',       {true,                     true}, ...
                'Category',      {cName,                    cName}, ...
                'DisplayName',   {'Histogram bar color',    'Number of bins'}, ...
                'FieldName',     {'HistogramColor',         'NumberBins'}, ...
                'Value',         {[0.8, 0.8, 0.8],          20}, ...
                'Type',          { ...
                'visprops.colorProperty', ...
                'visprops.unsignedIntegerProperty'}, ...
                'Editable',      {true,                     true}, ...
                'Options',       {'',                       ''}, ...
                'Description',   { ...
                'Color of the histogram bars', ...
                'Number of bins in the histogram'} ...
                );
        end % getDefaultProperties
        
    end % static methods
    
end % blockHistogramPlot

