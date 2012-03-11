%% visviews.cursorExplorer
% Class that adds and supervises an exploratory data cursor
%
%% Syntax
%     visviews.cursorExplorer(visFig)
%     obj = visviews.cursorExplorer(visFig)
%
%% Description
% |visviews.cursorExplorer(visFig, objectList)| creates a class that
% provides data cursor that continuously updates as the user moves the 
% mouse over a figure. The |visFig| is a handle to the figure managed
% by this cursor explorer.
%
% |obj = visviews.cursorExplorer(visFig)| returns a handle to the
% newly created cursor explorer.
%
% MATLAB only supports a single type of window motion event and 
% uses this event for resizing, pan, and zoom. As a result, 
% cursor exploration must disable these other uses to work without 
% interference. The viewing supervisor application that contains
% the cursor explorer should provide a mechanism for the user to 
% enter and exit cursor exploration mode. The supervisor should call the
% |cursorOn| and |cursorOff| methods of |visviews.cursorExplorer| to 
% enter and exit cursor exploration mode. These methods disable or 
% enable zoom, pan, and some resizing in exploration mode as well 
% as saving and restoring state information.
%
% The supervising visualization should also call the |addExplorable|
% method of |visviews.cursorExplorer| to add |visviews.cursorExplorable|
% objects to this explorer.
%
%% Class documentation
% Execute the following in the MATLAB command window to view the class 
% documentation for |visviews.cursorExplorer|:
%
%    doc visviews.cursorExplorer
%
%% See also
% <axesPanel_help.html |visviews.axesPanel|> and
% <cursorExplorable_help.html |visviews.cursorExplorable|> 
%
%% 
% Copyright 2011 Kay A. Robbins, University of Texas at San Antonio