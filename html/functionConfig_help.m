%% visfuncs.functionConfig
% GUI for function configuration
%
%% Syntax
%    visfuncs.functionConfig(selector, title)
%    obj = visfuncs.functionConfig(selector, title)
%
%% Description
% |visfuncs.functionConfig(selector, title)| creates a configuration
% GUI for functions. The |selector| must be a non-empty object of 
% type |viscore.dataSelector| and a configuration type of
% |'visfuncs.functionConfig'|. The |title| string appears on the 
% title bar of the figure window.
%
% |obj = visfuncs.dataConfig(selector, title)| returns a handle to
% a function configuration GUI
%
% The function configuration GUI presents a table view of the functions
% with the following columns:
%
% <html>
% <table>
% <thead><tr><td>Name</td><td>Value</td></tr></thead>
% <tr><td><tt>BackgroundColor</tt></td>
%     <td>Numeric color vector (1 × 3) giving background color 
%                   for visualizations.</td></tr>
% <tr><td><tt>Enabled</tt></td>
%     <td>Logical indicating whether the object should be 
%                   enabled in the visualization.</td></tr>
% <tr><td><tt>Category</tt>
%     <td>String indicating the type of function (now only |'Block'|).</td></tr> 
% <tr><td><tt>DisplayName</tt></td>
%     <td>String identifying the object in the visualization.</td></tr>
% <tr><td><tt>Definition</tt></td>
%     <td>String representation of function for evaluation with <tt>eval</tt>.</td></tr>
% <tr><td><tt>Description</tt></td>
%     <td>String description used in tooltips in the visualization.</td></tr>
% <tr><td><tt>ShortName</tt></td>
%     <td>String giving a brief identification of object 
%                   (used as a key in configuration and must be unique).</td></tr>
% <tr><td><tt>ThresholdColors</tt></td>
%     <td>Numeric color vector (n × 3) where n is the 
%                   number of threshold levels.</td></tr>
% <tr><td><tt>ThresholdLevels</tt></td>
%     <td>Numeric vector of cutoff levels.</td></tr>
% <tr><td><tt>ThresholdScope</tt></td>
%     <td>String indicating whether thresholds are computed 
%                   globally or by element. Currently only |'global'| is
%                   implemented, indicating that thresholds are computed
%                   over the entire data set.</td></tr>
% <tr><td><tt>ThresholdType</tt></td>
%     <td>String indicating criteria used for thresholding 
%                   function values. Currently the only valid choices
%                   are |'z score'| and |'value'|.</td></tr> 
% </table>
% </html>
%
%% Example 1
% Create a function configuration GUI
%
    keyfun = @(x) x.('ShortName');  % Functions uniquely identified by short name
    defaults = visfuncs.functionObj.createObjects( 'visfuncs.functionObj', ...
          visfuncs.functionObj.getDefaultFunctions(), keyfun);
    selector = viscore.dataSelector('visfuncs.functionConfig');
    selector.getManager().putObjects(defaults);
    fc = visfuncs.functionConfig(selector, 'Example function configuration');


%%
% The structure specifies that a kurtosis value with a z score greater than 3
% will be displayed in red (color value [1, 0, 0]), a kurtosis value
% with a z-score between 2 and 3 will be displayed in magenta (color
% value [1, 0, 1]), and a kurtosis value less than 2 will be displayed
% using the gray background color ([0.7, 0.7, 0.7]).
% 
%% Notes
% * |visfuncs.functionConfig| uses the |ShortName| field as the unique key.
% * The |ShortName| should be no more than 4 characters
%
%% Class documentation
% Execute the following in the MATLAB command window to view the class 
% documentation for |visfuncs.functionConfig|:
%
%    doc visfuncs.functionConfig
%
%% See also
% <dataConfig_help.html |viscore.dataConfig|>,  
% <dataManager_help.html |viscore.dataManager|>,
% <dataSelector_help.html |viscore.dataSelector|>,
% <functionObj_help.html |visfuncs.functionObj|>, and
% <managedObj_help.html |viscore.managedObj|>,

%% 
% Copyright 2011 Kay A. Robbins, University of Texas at San Antonio