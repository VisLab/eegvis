%% visviews.axisPanel
% Base class for an axes with fixed margins
%
%% Syntax
%     visviews.axesPanel(parent)
%     obj = visviews.axesPanel(parent)
%
%% Description
% |visviews.axesPanel(parent)| create an axes panel whose graphical parent
% has graphics handle |parent|. 
%
% The purpose of the axesPanel base class is to provide a resizable
% panel containing a single axes (other axes may be overlaid). The 
% margins around the axes are controlled so that they can be maintained
% at a fixed size irrespective of size its container.
%
% |obj = visviews.axesPanel(parent)| returns a handle to the newly created
%      panel
%
%
% The |visviews.axesPanel| is resizable, clickable, and cursor explorable.
% Extending classes need over-ride the getClicked method of
% |visviews.clickable| and the updateString method of
% |visviews.cursorExplorable| to create a linked, resizable visualization.
%
%% Example
% Create an axis panel with minimal margins
   sfig = figure('Name', 'AxesPanel testing repositioning after resetting gaps');
   ap = visviews.axesPanel(sfig);
   ap.YString = 'Apples';
   ap.XString = 'Bananas';
   gaps = getGaps(ap);
   ap.reposition(gaps);

%% Notes
% * The |visviews.axesPanel| parent can be a figure or any other container.
% * When a point is clicked the labels change. Generally, these labels
%   consist of a base label and a portion derived from the data. 
%   Hence, the base axes labels are kept separate from the actual axis 
%   and regenerated as needed.
% 
%% Class documentation
% Execute the following in the MATLAB command window to view the class 
% documentation for |visviews.axesPanel|:
%
%    doc visviews.axesPanel
%
%% See also
% <clickable_help.html |visviews.clickable|>, 
% <cursorExplorable_help.html |visviews.cursorExplorable|>,
% <resizable_help.html |visviews.resizable|>, and 
% <blockImagePlot_help.html |visviews.blockImagePlot|> 
%% 
% Copyright 2011 Kay A. Robbins, University of Texas at San Antonio