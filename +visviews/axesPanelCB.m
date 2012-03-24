% visviews.axesPanelCB base class for an axes and color bar with fixed margins
%             
% Usage:
%   >>   visviews.axesPanelCB(parent)
%   >>   obj = visviews.axesPanelCB(parent)
%
% Description:
% visviews.axesPanelCB(parent) create an axes panel and a color bar 
%     with a graphics handle parent. 
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

classdef axesPanelCB < visviews.axesPanel
 
    properties
        ColorbarAxes = [];         % axis for the color bar
    end % public properties
 
    methods
        
        function obj = axesPanelCB(parent)
            % Create the axes panel base class
            obj = obj@visviews.axesPanel(parent);
        end % axesPanel constructor
        
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
    
        function reset(obj)
            % Delete the children of the axes and ready for replotting
            obj.reset@visviews.axesPanel();
            % Delete the colorbar axes
            if ~isempty(obj.ColorbarAxes) && ishandle(obj.ColorbarAxes)
                delete(obj.ColorbarAxes);
            end
            obj.ColorbarAxes = [];
        end % reset
        
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