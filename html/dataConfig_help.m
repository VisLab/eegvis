%% viscore.dataConfig
% GUI base class for configuration
%
%% Syntax
%    viscore.dataConfig(selector, title)
%    obj = viscore.dataConfig(selector, title)
%
%% Description
% |viscore.dataConfig(selector, title)| creates a basic figure shell for
% configuration, including New, Edit, Delete, Apply,
% Reset, Load, Save, and Close buttons. The |selector| must be a
% non-empty object of type |viscore.dataSelector|. The |title| string
% appears on the title bar of the figure window.
%
% |obj = viscore.dataConfig(selector, title)| returns a handle to
%    the GUI base class for configuration
%
%
%% Example
% Create an empty dataConfig GUI
   sel = viscore.dataSelector('viscore.dataConfig');
   dc = viscore.dataConfig(sel, 'Example of viscore.dataConfig'); 

%% Notes
% * This class is not meant to be called directly, but rather provides
% base class infrastructure for extending classes.
%
%% See also
% <dataManager_help.html |dataManager|>,
% <dataSelector_help.html |dataSelector|>,
% <functionConfig_help.html |functionConfig|>,
% <managedObj_help.html |manageObj|>,
% <plotConfig_help.html |plotConfig|>, and
% <propertyConfig_help.html |propertyConfig|>

%% 
% Copyright 2011 Kay A. Robbins, University of Texas at San Antonio