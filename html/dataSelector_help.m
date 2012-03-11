%% viscore.dataSelector  
% Container connecting a configuration GUI and an object manager
%
%% Syntax
%     viscore.dataSelector(conType)
%     obj = viscore.dataSelector(conType)
%
%% Description
% |viscore.dataSelector(conType)| creates a data selector object to hold a 
% specified type of configuration. The |conType| variable should be the 
% class name of the configuration GUI. The default |conType| is 
% |viscore.dataConfig|. Other configuration GUIs include 
% |visfuncs.functionConfig| for configuring block functions, 
% |visprops.propertyConfig| for configuring object public properties,
% and |visviews.plotConfig| for specifying the views to include 
% in a visualization. 
%
% The data selector automatically creates its
% own data manager, but this manager can be replaced by using the
% |setManager| method of |viscore.dataSelector|.
%
% The |viscore.dataSelector| provides a convenient way of manipulating
% configurations for objects such as |visviews.dualView|, which manages
% three different configurations.
%
% |obj = viscore.dataSelector(conType)| returns a handle to a newly
% created |viscore.dataSelector| object.
%
%% Example
% Create a data selector for a data configuration GUI
   vs =  viscore.dataSelector('viscore.dataConfig');

%% Class documentation
% Execute the following in the MATLAB command window to view the class 
% documentation for |viscore.dataSelector|:
%
%    doc viscore.dataSelector
%
%% See also
% <dataConfig_help.html |viscore.dataConfig|>,
% <functionConfig_help.html |visfuncs.functionConfig|>,
% <dataManager_help.html |viscore.dataManager|>,
% <plotConfig_help.html |visviews.plotConfig|>, and
% <propertyConfig_help.html |visprops.propertyConfig|>


%% 
% Copyright 2011 Kay A. Robbins, University of Texas at San Antonio