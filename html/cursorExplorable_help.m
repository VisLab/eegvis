%% visviews.cursorExplorable
% Base class for objects that respond to a cursor explorer
%
%% Syntax
%     visviews.cursorExplorable()
%     obj = visviews.cursorExplorable()
%
%% Description
% |visviews.cursorExplorable()| allow the continuous display of data
% coordinates as the user moves the cursor over the viewing area.
%
% |obj = visviews.cursorExplorable()| return a newly created cursor
% explorable object.
%
% Panels or other components that are available for cursor exploration 
% must extend the |visviews.cursorExplorable| class, which has two methods: 
%
%    [x, y, xInside, yInside] = getDataCoordinates(obj, point)
%
%    s = updateString(obj, point) 
%
% Both methods take a point in pixel coordinates relative to the 
% enclosing figure. The |getDataCoordinates| method returns the 
% x and y data coordinates of the point and indicators of whether 
% these coordinates are inside the axes in the x and y directions, 
% respectively. The |updateString| method returns the string displayed 
% when the user moves the mouse over the designated point. 
% This string should be empty if the point is not within this 
% object's panel area.
%
%% Class documentation
% Execute the following in the MATLAB command window to view the class 
% documentation for |visviews.cursorExplorable|:
%
%    doc visviews.cursorExplorable
%
%% See also
% <axesPanel_help.html |visviews.axesPanel|> and
% <cursorExplorer_help.html |visviews.cursorExplorer|> 
%
%% 
% Copyright 2011 Kay A. Robbins, University of Texas at San Antonio