%% visprops.propertyConfig
% GUI for configuration of public properties of configurable objects
%
%% Syntax
%     visprops.propertyConfig(selector, title)
%     obj = visprops.propertyConfig(selector, title)
%
%% Description
% |visprops.propertyConfig(selector, title)| creates a configuration
% GUI for specified public properties of configurable objects. 
% The |selector| must be a non-empty object of type 
% |viscore.dataSelector| and a configuration type of
% |'visprops.propertyConfig '|. The |title| string appears on the 
% title bar of the figure window.
%
% |obj = visprops.propertyConfig(selector, title)| returns a handle to
% a property configuration GUI
%
% The property configuration GUI is similar in format to the MATLAB
% property manager.
%
% The property configuration GUI is similar in format to the MATLAB
% property manager. 
%
% The property configuration GUI only processes configurable objects 
% in its object manager.
%
%% Example 1
% Create a property configuration GUI for a double property
%
     settings = struct( ...
                 'Enabled',       {true}, ...
                 'Category',      {'Summary'}, ...
                 'DisplayName',   {'Block size'}, ...
                 'FieldName',     {'BlockSize'}, ... 
                 'Value',         {1000.0}, ...
                 'Type',          {'visprops.doubleProperty'}, ...
                 'Editable',      {true}, ...
                 'Options',       {[0, inf]}, ...
                 'Description',   {'Block size for computation (must be non negative)'} ...
                                   );
                               
      selector = viscore.dataSelector('visprops.propertyConfig');
      settings.Category = [settings.Category ':' settings.DisplayName];
      theName = 'testing|A name';
      theProps = viscore.managedObj(theName, settings);
      selector.putObject(theName, theProps);
      bfc1 = visprops.propertyConfig(selector, 'Testing property config');  
  
%% Class documentation
% Execute the following in the MATLAB command window to view the class 
% documentation for |visprops.propertyConfig|:
%
%    doc visprops.propertyConfig
%

%% See also
% <configurationObj_help.html |visprops.configurationObj|>,
% <configurable_help.html |visprops.configurable|>,
% <dataConfig_help.html |viscore.dataConfig|>,  
% <dataManager_help.html |viscore.dataManager|>,
% <dataSelector_help.html |dataSelector|>, and
% <managedObj_help.html |viscore.managedObj|>,

%% 
% Copyright 2011 Kay A. Robbins, University of Texas at San Antonio