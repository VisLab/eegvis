%% visviews.clickable
% Base class for panels that are clickable in linked visualizations
%
%% Syntax
%     visviews.clickable()
%     obj = visviews.clickable()
%
%% Description
% |visviews.clickable()| is the base class for clickable panels in linked
% visualizations. Most visualization panels extend visviews.axesPanel, 
% which is a |visviews.clickable| class. Extending classes generally 
% override the following methods:
%
%      [dSlice, bFunction] = getClicked(obj)
%
%      [cbHandles, hitHandles] = getHitObjects(obj)
%
% When the user clicks on a clickable panel, the |ButtonDownFcn| callback 
% calls its |getClicked method|. This method returns the data slice 
% corresponding to the clicked region and a reference to the block 
% function represented by this panel, if applicable. 
%
% The |getHitObjects| method controls setting the |ButtonDownFcn| callback. 
% The |cbHandles| cell array specifies the handles whose |ButtonDownFcn|
% callback should be set. The |hitHandles| cell array specifies the 
% handles whose |HitTest| property should be set |'on'|. 
%
% |obj = visviews.clickable()| returns a handle to the newly created
% clickable object.
%
%
% The |visviews.clickable| base class defines a |buttonDownCallback| 
% function that performs the linkage and a |registerCallbacks| function 
% that sets the |ButtonDownFcn| property of the handles returned by 
% |getHitObjects|. Extending classes should not override these functions 
% to perform additional actions in the callback. Instead, individual 
% classes should override the following two functions:
%
%      buttonDownPreCallback (obj, src, eventdata)
%
%      buttonDownPostCallback (obj, src, eventdata)
%
% The |buttonDownCallback| function calls the |buttonDownPreCallback|
% at the beginning of |buttonDownCallback| and the |buttonDownPostCallback|
% after processing the linkage.
%
%% Configurable properties
% The |visviews.clickable| has two configurable parameters: 
%
% |IsClickable| is a boolean specifying whether this plot should respond to
%    user mouse clicks when incorporated into a linkable figure. The
%    default value is |true|.
%
% |LinkDetails| is a boolean specifying whether clicking this plot in a
%    linkable figure should cause detail views to display the clicked
%    slice. The default value is |true|.
%
%% Notes
% * The source map for a clickable object consists of an objectID string
% as the key and a cell array of clickable objects that are linked to
% this source.
%
%% Class documentation
% Execute the following in the MATLAB command window to view the class 
% documentation for |visviews.clickable|:
%
%    doc visviews.clickable
%
%% See also
% <axesPanel_help.html |visviews.axesPanel|>
%

%% 
% Copyright 2011 Kay A. Robbins, University of Texas at San Antonio