% visviews.axesPanel base class for an axes with fixed margins
%             
% Usage:
%   >>   visviews.axesPanel(parent)
%   >>   obj = visviews.axesPanel(parent)
%
% Description:
% visviews.axesPanel(parent) create an axes panel whose graphical parent
%     has graphics handle parent. 
%
%     The purpose of the axesPanel base class is to provide a resizable
%     panel containing a single axes (other axes may be overlaid). The 
%     margins around the axes are controlled so that they can be maintained
%     at a fixed size irrespective of size its container.
%
% obj = visviews.axesPanel(parent) returns a handle to the newly created
%      panel
%
%
% The visviews.axesPanel is resizable, clickable, and cursor explorable.
% Extending classes need over-ride the getClicked method of
% visviews.clickable and the updateString method of
% visviews.cursorExplorable to create a linked, resizable visualization.
%
% Example:
% Create an axis panel with minimal margins
%   sfig = figure('Name', 'AxesPanel testing repositioning after resetting gaps');
%   ap = visviews.axesPanel(sfig);
%   ap.YString = 'Apples';
%   ap.XString = 'Bananas';
%   gaps = getGaps(ap);
%   ap.reposition(gaps);
%
% Notes:
%  -  The visviews.axesPanel parent can be a figure or any other container.
%  -  When a point is clicked the labels change. Generally, these labels
%     consist of a base label and a portion derived from the data. 
%     Hence, the base axes labels are kept separate from the actual axis 
%     and regenerated as needed.
% 
% Class documentation:
% Execute the following in the MATLAB command window to view the class 
% documentation for visviews.axesPanel:
%
%    doc visviews.axesPanel
%
% See also: visviews.clickable, visviews.cursorExplorable,
% visviews.resizable, and visviews.blockImagePlot 
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

% $Log: axesPanel.m,v $
% Revision: 1.00  04-Dec-2011 09:11:20  krobbins $
% Initial version $
%

classdef axesPanel < uiextras.Panel & visviews.resizable ...
        & visviews.clickable & visviews.cursorExplorable
 
    properties(Constant = true)
        MaximumGaps = [50, 50, 30, 30];  % largest standard borders 
        MinimumGaps = [15, 10, 10, 15];  % smallest standard borders       
    end % constant properties 
    
    properties
        MainAxes;                  % handle for the main panel axes
        MinXLabelOffset = 5;       % minimum pixels from x label to axis
        MinYLabelOffset = 5;       % minimum pixels from y label to axis  
        XLabelOffset = 0;          % actual x label offset from axis
        XLimOffset = 0;            % actual offset of label to x axis scale
        XOffsetFromAxis = false;    % if true adjust x label offset on resize      
        XString = '';              % actual x-axis label
        XStringBase = '';          % x label without clicked point info
        YLabelOffset = 0;          % actual y label offset from axis
        YLimOffset = 0;            % actual offset of label to y axis scale
        YOffsetFromAxis = true;    % if true adjust y label offset on resize      
        YString = '';              % actual y-axis label
        YStringBase = '';          % y label without clicked point info
    end % public properties
 
    properties(Access = protected)
        InnerPanel = [];           % handle to inner panel for resizing
        MarginBottom = 10;         % pixels on bottom panel border
        MarginLeft = 10;           % pixels on left panel border
        MarginRight = 10;          % pixels on right panel border 
        MarginTop = 10;            % pixels on top panel border 
    end % protected properties
    
    methods
        
        function obj = axesPanel(parent)
            % Create the axes panel base class
            obj = obj@uiextras.Panel( 'Parent', parent);
            obj.InnerPanel = uipanel('Parent', obj, 'BorderType', 'none');
            set(obj, 'Units', 'normalized', 'Padding', 2, ...
                 'BorderType', 'none');
            obj.MainAxes = axes('Parent', obj.InnerPanel, ...
                'Box', 'on',  'ActivePositionProperty', 'Position', ...
                'Units', 'normalized', 'Tag', 'MainAxes');
        end % axesPanel constructor
        
        function c = getBackgroundColor(obj)
            % Return the background color of the inner panel
            c = get(obj.InnerPanel, 'BackgroundColor');
        end % get BackgroundColor
        
        function [x, y, xInside, yInside] = getDataCoordinates(obj, point)
            % Return (x, y) data coordinates of point and whether inside axes
            %
            % Inputs:
            %    point     pixel coordinates of a point wrt parent figure
            %
            % Outputs:
            %    x         x coordinate of point in data units
            %    y         y coordinate of point in data units
            %    xInside   true if x is inside main axis of this panel
            %    yInside   true if y is inside main axis of this panel
            % 
            % Required for the visviews.cursorExplorable interface
             p = getpixelposition(obj.MainAxes, true);
             a = get(obj.MainAxes,  'XLim');
             xDir = get(obj.MainAxes, 'XDir');
             if strcmpi(xDir, 'reverse')
                 a = [a(2), a(1)];
             end
             x = (a(2) - a(1))*(point(1) - p(1))/p(3) + a(1);
             b = get(obj.MainAxes,  'YLim');
             yDir = get(obj.MainAxes, 'YDir');
             if strcmpi(yDir, 'reverse')
                 b = [b(2), b(1)];
             end
             y = (b(2) - b(1))*(point(2) - p(2))/p(4) + b(1); 
             xInside = (p(1) <= point(1)) && ( point(1) < p(1) + p(3));
             yInside = (p(2) <= point(2)) && ( point(2) < p(2) + p(4));
        end % getDataCoordinates
        
        function gap = getGaps(obj) 
        % Return the gaps around the axes box for repositioning (resizable)
            oldUnits = get(obj.MainAxes, 'Units');  % Work in pixels
            set(obj.MainAxes, 'Units', 'Pixels');    
            % Calculate the gap position after repositioning labels
            gap = get(obj.MainAxes, 'TightInset');             
            % Create the labels
            yLab = get(obj.MainAxes, 'YLabel');
            set(yLab, 'Units', 'Pixels', 'String', obj.YString, ...
                    'HorizontalAlignment',  'Center', ...
                    'VerticalAlignment', 'Baseline');
            xLab = get(obj.MainAxes, 'XLabel');
            set(xLab, 'Units', 'Pixels',  'String', obj.XString, ...
                    'HorizontalAlignment', 'Center', ...
                    'VerticalAlignment', 'Top');
            % Adjust the gap for the labels
            if ~isempty(get(yLab, 'String'))
                yExtent = get(yLab, 'Extent');
                if obj.YOffsetFromAxis
                   obj.YLabelOffset = obj.MinYLabelOffset;
                else
                   obj.YLabelOffset = max(gap(1), obj.MinYLabelOffset);
                end 
                gap(1) = obj.YLabelOffset + yExtent(3);
            end
            if ~isempty(get(xLab, 'String'))
                xExtent = get(xLab, 'Extent');
                if obj.XOffsetFromAxis
                   obj.XLabelOffset = obj.MinXLabelOffset;
                else
                   obj.XLabelOffset = max(obj.MinXLabelOffset, gap(2));
                end 
                gap(2) = obj.XLabelOffset + xExtent(4);
            end 
            set(obj.MainAxes, 'Units', oldUnits);
        end % getGaps
        
        function [cbHandles, hitHandles] = getHitObjects(obj)
            % Return handles to register as callbacks and hit handles
            % Required for the visviews.clickable interface
            cbHandles = {obj.MainAxes};
            hitHandles = {obj.MainAxes};
        end % getHitObjects
          
        function hPosition = getPixelHitPosition(obj)
            % Return the pixel position of the axes (a utility function)
            t = get(obj.MainAxes, 'ActivePositionProperty');
            set(obj.MainAxes, 'ActivePositionProperty', 'Position');
            hPosition = getpixelposition(obj.MainAxes, true);
            set(obj.MainAxes, 'ActivePositionProperty', t);
        end % getPixelHitPosition

        function reposition(obj, newMargins)
            % Set margins and redraw object (required for visviews.resizable) 
            obj.MarginLeft = newMargins(1);
            obj.MarginBottom = newMargins(2);
            obj.MarginRight = newMargins(3);
            obj.MarginTop = newMargins(4);
            obj.redraw();
        end % reposition
    
        function reset(obj)
            % Delete the children of the axes and ready for replotting
            set(get(obj, 'MainAxes'), 'NextPlot', 'replace');
            childPlots = get(obj.MainAxes, 'Children');
            if ~isempty(childPlots) % remove any previous plots without clearing
                for c = 1:length(childPlots)
                    delete(childPlots(c));
                end
            end
            hold(obj.MainAxes, 'off');  % Make sure that hold is off to start
            set(get(obj, 'MainAxes'), 'NextPlot', 'add'); % Set for adding
        end % reset
        
        function setBackgroundColor(obj, c)
            % Set the background color to c
            set(obj, 'BackgroundColor', c);
            set(obj.InnerPanel, 'BackgroundColor', c);
            set(obj.MainAxes, 'Color', c);
        end % setBackgroundColor
        
    end % public methods
    
    methods( Access = protected )
        
        function redraw( obj )
            % Redraw the layout, positioning the children  
            if isempty( obj.UIContainer ) || ~ishandle( obj.UIContainer )
                return
            end            
            % Selected one inherits visibility of layout and
            % fills the available space
            pos = getpixelposition( obj );
            border = obj.BorderWidth + 1 + obj.Padding;
            x0 = obj.Padding + 1;
            y0 = obj.Padding + 1;
            w = pos(3) - 2*border;
            h = pos(4) - 2*border;
            if ~isempty( obj.Title )
                % Work out how much extra space to leave for the title
                oldunits = get( obj.UIContainer, 'FontUnits' );
                set( obj.UIContainer, 'FontUnits', 'Pixels' );
                % Get the height of the title (in pixels)
                titleSize = get( obj.UIContainer, 'FontSize' );
                % Put the old units back
                set( obj.UIContainer, 'FontUnits', oldunits );                
                % Whether to move top or bottom depends on title
                % position
                if isempty( strfind( get( obj.UIContainer, 'TitlePosition' ), 'top' ) )
                    % Title at the bottom
                    h = h - titleSize;
                    y0 = y0 + titleSize;
                else
                    % Title at the top
                    h = h - titleSize;
                end                
            end          
            % Use the CardLayout function to put the right child onscreen
            obj.showSelectedChild( [x0 y0 w h] )
            % Reposition the axes first
            %set(obj.InnerPanel, 'Position', [x0, y0, w, h]);
            set(obj.MainAxes, 'Units', 'Pixels')
            x0 = obj.MarginLeft;
            y0 = obj.MarginBottom;
            % Height and width of the axes must be at least 1 pixel
            w = max(1, w - obj.MarginLeft - obj.MarginRight);
            h = max(1, h - obj.MarginBottom - obj.MarginTop);           
            set(obj.MainAxes, 'Position', [x0, y0, w, h]);            
            % Reposition labels if necessary
            yLab = get(obj.MainAxes, 'YLabel');
            
            set(yLab, 'String', obj.YString, 'Units', 'pixels', ...
                     'Position', [-obj.YLabelOffset, round(h/2)]);     
            xLab = get(obj.MainAxes, 'XLabel');
            set(xLab, 'String', obj.XString, 'Units', 'pixels', ...
                'Position', [round(w/2), -obj.XLabelOffset]);
        end % redraw    
        
    end % protected methods
    
end % axesPanel 