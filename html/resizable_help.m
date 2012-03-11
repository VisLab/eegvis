%% visviews.resizable
% Base class that gives components fixed margins
%
%% Syntax
%     visviews.resizable()
%     obj = visviews.resizable()
%
%% Description
% |visviews.resizable()| is the base class for giving fixed margins
% to visualization components. 
%
%
% |obj = visviews.resizable()| returns a handle to the newly created
% resizable object.
%
%
% When multiple panels appear in a single figure, the figure can 
% appear misaligned when it uses the default MATLAB resizing. 
% The supervising visualization should adjust the panel margins to 
% eliminate the incongruities. Generally, viewing panels use the 
% box on option to display the axes bounding boxes. The box edges 
% forming the outside borders should align. Furthermore, panels 
% displayed in the same horizontal row should have top and bottom box 
% edges that align. 
%
% To provide this alignment, rsizable panels should override the 
% following methods:
%
%      gaps = getGaps(obj)
%
%      reposition(obj, margins)
%
% The |getGaps| method returns a vector containing the number of 
% pixels for [Left, Bottom, Right, Top] margins formed between the 
% axes box and the edge of the panel. Composite panels such as the 
% |visviews.tabPanel| and |visviews.horizontalPanel| report the 
% maximum for the outer margins over all of their child panels. 
%
% Supervising applications find the maximum required gaps and call the 
% |reposition| methods of their child resizable panels to perform 
% realignments. The individual resizable panels should always 
% preserve these margins on resizing, resulting in a more unified view. 
% The individual views in the |+visviews| package all use the 
% resizable |visviews.axesPanel| as a base class, eliminating the 
% need for individual visualizations to handle resizing explicitly.
%
%% Class documentation
% Execute the following in the MATLAB command window to view the class 
% documentation for |visviews.resizable|:
%
%    doc visviews.resizable
%
%% See also
% <axesPanel_help.html |visviews.axesPanel|>
%

%% 
% Copyright 2011 Kay A. Robbins, University of Texas at San Antonio