%% visviews.plotObj 
% Holds definition and and settings for a plot
%
%% Syntax
%     visviews.plotObj(objectID, structure))
%     obj = visviews.plotObj(objectID, structure)
%
%% Description
% |visviews.plotObj(objectID, structure)| creates a plot object
% with specified ID from a plot structure. The structure has the following
% fields:
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
% |visviews.plotObj(objectID, structure)| returns a handle to
% a newly created plot object.
%
%% Example 
% Create a specification of a top-level block image summary visualization
    pStruct = struct( ...
                'Enabled',     {true}, ...
                'Category',    {'summary'}, ...
                'DisplayName', {'Block image'}, ...
                'Definition',  {'visviews.blockImagePlot'}, ...
                'Sources',     {'None'}, ...
                'Description', {'Image of blocked value array'});
     defaults = visviews.plotObj.createObjects('visviews.plotObj', pStruct);
     selector.getManager().putObjects(defaults);
     pc  = visviews.plotConfig(selector, 'Testing plotConfig');

%%
% The structure specifies that a |visviews.blockImagePlot| should be
% created with the unique display name |'Block image'|. 
% 
%% Notes
% * |visviews.plotObj| structure uses the |DisplayName| field as the unique key.
%
%% Class documentation
% Execute the following in the MATLAB command window to view the class 
% documentation for |visviews.plotObj|:
%
%    doc visviews.plotObj
%
%% See also
% <dataConfig_help.html |viscore.dataConfig|>,  
% <dataManager_help.html |viscore.dataManager|>,
% <dataSelector_help.html |viscore.dataSelector|>,
% <managedObj_help.html |viscore.managedObj|>, and
% <plotConfig_help.html |viscore.plotConfig|>
%% 
% Copyright 2011 Kay A. Robbins, University of Texas at San Antonio