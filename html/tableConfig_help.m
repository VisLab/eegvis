%% viscore.tableConfig
% GUI base class for table-based configuration
%
%% Syntax
%    viscore.tableConfig(selector, title)
%    obj = viscore.tableConfig(selector, title)
%
%% Description
% |viscore.tableConfig(selector, title)| creates a table GUI for
% configuration by extending |viscore.dataConfig|. The |selector| must be a
% non-empty object of type |viscore.dataSelector|. The |title| string
% appears on the title bar of the figure window. 
%
% The table configuration class provides methods for creating a MATLAB
% |uitable| (as extended by |viscore.tablePanel|) in the central panel 
% of the GUI. The class also provides methods to update
% managed objects from the table and to set the table from managed objects.
% The |visviews.plotConfig| and |visfuncs.functionConfig| GUIs extend
% this class to provide specific configuration for plots and functions,
% respectively.
%
%
% |obj = viscore.dataConfig(selector, title)| returns a handle to
%    the GUI base class for configuration
%

%% Example
% Create a table configuration for a structure using the display name 
% as the unique field
    s = struct( ...
           'Enabled',        {true,              true}, ...
           'Category',       {'summary',        'detail'}, ...
           'DisplayName',    {'Block Image',    'Signal'}, ...
           'Definition',     {'visviews.blockImagePlot', ...
                              'visviews.stackedSignalPlot'}, ...
           'Description',    {'Displays an array as an image', ...
                              'Displays raw signal using a stacked view'});
   
    keyfun = @(x) x.('DisplayName');
    v = viscore.managedObj.createObjects('viscore.managedObj', s, keyfun);
    selector = viscore.dataSelector('viscore.tableConfig');
    selector.getManager().putObjects(v);
    tc = viscore.tableConfig(selector, 'test figure');

%% Class documentation
% Execute the following in the MATLAB command window to view the class 
% documentation for |viscore.tableConfig|:
%
%    doc viscore.tableConfig
%
%% See also
% <dataManager_help.html |viscore.dataManager|>,
% <dataSelector_help.html |viscore.dataSelector|>,
% <functionConfig_help.html |visfuncs.functionConfig|>,
% <managedObj_help.html |viscore.managedObj|>,
% <plotConfig_help.html |visviews.plotConfig|>,  
% <propertyConfig_help.html |visprops.propertyConfig|>, and
% <tablePanel_help.html |viscore.tablePanel|>

%% 
% Copyright 2011 Kay A. Robbins, University of Texas at San Antonio.