%% visviews.plotConfig  
% GUI for configuring list of plots
%
%% Syntax
%     visviews.plotConfig(selector, title)
%     obj = visviews.plotConfig(selector, title)
%
%% Description
% |visviews.plotConfig(selector, title)| creates a configuration
% GUI for functions. The |selector| must be a non-empty object of 
% type |viscore.dataSelector|. The |title| string appears on the 
% title bar of the figure window.
%
% |obj = visviews.plotConfig(selector, title)| returns a handle to
% a plot configuration GUI.
%
% The plot configuration GUI presents a table view of the plots
% with the following columns:
%
% <html>
% <table>
% <thead><tr><td>Name</td><td>Value</td></tr></thead>
% <tr><td><tt>Enabled</tt></td>
%     <td>Logical indicating whether the object should be 
%                   enabled in the visualization.</td></tr>
% <tr><td><tt>Category</tt></td>
%     <td>String indicating the type of plot (either 
%        <tt>'summary'</tt> or <tt>'detail'</tt>).</td></tr> 
% <tr><td><tt>DisplayName</tt></td>
%     <td>String identifying the plot in the visualization 
%        (must be unique).</td></tr>
% <tr><td><tt>Definition</tt></td>
%     <td>String containing the full class name.</td></tr>
% <tr><td><tt>Description</tt></td>
%     <td>String description used in tooltips in the visualization.</td></tr>
% <tr><td><tt>Sources</tt></td>
%     <td>String or cell array of strings specifying linkage.
%     Values <tt>'none'</tt> and <tt>'master'</tt> indicate top-level 
%     summary and details, respectively. If the <tt>DisplayName</tt>
%     of another plot is given, the named plot is considered a source
%     and this plot displays slices of the named plot, when that plot is clicked.</td></tr>
% </table>
% </html>
%
%% Notes
% * |visviews.plotConfig| uses the |DisplayName| field as the unique key.
%
%% Example 1
% Create a plot configuration GUI
    defaults = visviews.plotObj.createObjects(...
             'visviews.plotObj',  visviews.dualView.getDefaultPlots());
    selector = viscore.dataSelector('visviews.plotConfig');
    selector.getManager().putObjects(defaults);
    pc  = visviews.plotConfig(selector, 'Testing plotConfig');

%% Example 2
% Create a specification of a top-level block image summary visualization
    pStruct = struct( ...
                'Enabled',     {true}, ...
                'Category',    {'summary'}, ...
                'DisplayName', {'Block image'}, ...
                'Definition',  {'visviews.blockImagePlot'}, ...
                'Sources',     {'None'}, ...
                'Description', {'Image of blocked value array'});
     defaults = visviews.plotObj.createObjects('visviews.plotObj', pStruct);
     selector = viscore.dataSelector('visviews.plotConfig');
     selector.getManager().putObjects(defaults);
     pc  = visviews.plotConfig(selector, 'Testing plotConfig');

%%
% The structure specifies that a |visviews.blockImagePlot| should be
% created with the unique display name |'Block image'|. 
% 
%% Class documentation
% Execute the following in the MATLAB command window to view the class 
% documentation for |visviews.plotConfig|:
%
%    doc visviews.plotConfig
%
%% See also
% <dataConfig_help.html |viscore.dataConfig|>,  
% <dataManager_help.html |viscore.dataManager|>,
% <dataSelector_help.html |viscore.dataSelector|>,
% <managedObj_help.html |viscore.managedObj|>, and
% <plotObj_help.html |viscore.plotObj|>
