%% visfuncs.functionObj
% Definition and current values of a summary function
%
%% Syntax
%    visfuncs.functionObj(objectID, structure)
%    obj = visfuncs.functionObj(objectID, structure)
%
%% Description
% |visfuncs.functionObj(objectID, structure)| creates a function object
% with specified ID from a function structure.
%
% |obj = visfuncs.functionObj(objectID, structure)| returns a handle
% to the newly created function object.
%
% The structure for specifying function objects has the following fields:
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
%                   over the entire data set..</td></tr>
% <tr><td><tt>ThresholdType</tt></td>
%     <td>String indicating criteria used for thresholding 
%                   function values. Currently the only valid choices
%                   are |'z score'| and |'value'|.</td></tr> 
% </table>
% </html>
%
%% Example 
% Create a function object for kurtosis and print the fields.

    fStruct = struct( ...
                'Enabled',        {true}, ...
                'Category',       {'block'}, ...
                'DisplayName',    {'Kurtosis'}, ...
                'ShortName',      {'K'}, ...
                'Definition',     {'@(x) (kurtosis(x, 1, 2))'}, ...
                'ThresholdType',  {'z score'}, ...
                'ThresholdLevels', {2, 3}, ...
                'ThresholdColors', {[1, 0, 1], [1, 0, 0]}, ...
                'BackgroundColor', {[0.7, 0.7, 0.7]}, ...
                'ThresholdScope', {'global'}, ...
                'Description',    {'Kurtosis computed for each (element, block)'});
      bf = visfuncs.functionObj([], fStruct);
      bf.printObject();
      
%% Notes
% * The function must operate on a 3D array by collapsing dimension 2,
% resulting in a 2D array.
% * Specify a function by providing its structure as indicated below.
% * The function object now keeps a reference to the data object and
% computes its values only if needed. It also has a unique ID so that
% the GUI can clear its values if there is a change in parameters.
% * Functions can have different categories.  Currently only |'block'|
% is supported, meaning that the data is blocked and a single value
% is computed for each block.
%
%% Class documentation
% Execute the following in the MATLAB command window to view the class 
% documentation for |visfuncs.functionObj|:
%
%    doc visfuncs.functionObj
%
%% See also
% <functionConfig_help.html |visfuncs.functionConfig|> and  
% <managedObj_help.html |viscore.managedObj|>

%% 
% Copyright 2011 Kay A. Robbins, University of Texas at San Antonio