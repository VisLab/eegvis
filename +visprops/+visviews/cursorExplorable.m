% visviews.cursorExplorable base class for objects that respond to a cursor explorer
%
% Usage: 
%   >>   visviews.cursorExplorable()
%   >>   obj = visviews.cursorExplorable()
%
% Description:
% visviews.cursorExplorable() allow the continuous display of data
%     coordinates as the user moves the cursor over the viewing area.
%
% obj = visviews.cursorExplorable() return a newly created cursor
%     explorable object.
%
% Panels or other components that are available for cursor exploration 
% must extend the visviews.cursorExplorable class, which has two methods: 
%
%    [x, y, xInside, yInside] = getDataCoordinates(obj, point)
%
%    s = updateString(obj, point) 
%
% Both methods take a point in pixel coordinates relative to the 
% enclosing figure. The getDataCoordinates method returns the 
% x and y data coordinates of the point and indicators of whether 
% these coordinates are inside the axes in the x and y directions, 
% respectively. The updateString method returns the string displayed 
% when the user moves the mouse over the designated point. 
% This string should be empty if the point is not within this 
% object's panel area.
%
% Class documentation:
% Execute the following in the MATLAB command window to view the class 
% documentation for visviews.cursorExplorable:
%
%    doc visviews.cursorExplorable
%
% See also: visviews.axesPanel and visviews.cursorExplorer
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

% $Log: cursorExplorable.m,v $
% Revision: 1.00  04-Dec-2011 09:11:20  krobbins $
% Initial version $
%

classdef cursorExplorable < handle

    properties(Access = protected)
        CursorString = '';  % default string to be displayed
    end % protected properties
    
    methods 
        
        function [x, y, xInside, yInside] = getDataCoordinates(obj, point) %#ok<INUSD,MANU>
            % Return (x, y) data coordinates of point and whether inside axes
            %
            % Inputs:
            %    point     pixel coordinates of a point in the figure
            %
            % Outputs:
            %    x         x coordinate of point in data units
            %    y         y coordinate of point in data units
            %    xInside   true if x is inside main axis of this panel
            %    yInside   true if y is inside main axis of this panel
            %
            x = [];
            y = [];
            xInside = false;
            yInside = false;
        end % getDataCoordinates
            
        function s = updateString(obj, point) %#ok<INUSD,MANU>
            s = '';
        end
        
    end % public methods
   
end % cursorExplorable

