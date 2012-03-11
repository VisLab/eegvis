%% visprops.doubleProperty
% Property representing a double in a specified interval
%
%% Syntax
%    visprops.doubleProperty(objectID, structure)
%    obj = visprops.doubleProperty(...)
%
%% Description
% |visprops.doubleProperty(objectID, structure)| create a new property
% representing a double in a specified interval. By default, the interval
% is |[-inf, inf]|. The |objectID| parameter
% is the hash key associated with configurable owner of the 
% property. The structure parameter is the structure specifying
% the vector property as described in |visprops.property|.
%
% |obj = visprops.doubleProperty(...)| returns a handle to a newly 
% created double property.
%
% The |visprops.doubleProperty| has two public properties that specify
% the interval for a valid value:
%
% <html>
% <table>
% <thead><tr><td>Public property</td><td>Description</td></tr></thead>
% <tr><td><tt>Limits</tt></td><td>A two-element vector specifying the endpoints
% of the interval for a valid value. <tt>inf</tt> and <tt>-inf</tt> are valid
% values.</td></tr>
% <tr><td><tt>Inclusive</tt></td><td>A two-element boolean vector specifying
% whether the endpoints of the interval specifyed by <tt>Limits</tt> should
% be included as valid values.</td></tr>
% </table>
% </html>
% 
%% Notes
% 
% * If the |Options| field of the settings structure for
% |visprops.doubleProperty| is non empty, it is used to set the 
% |Limits| property.
%
%% Example
% Create a double property in the interval in the [0, inf) with initial
% value 1000.
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
   bm = visprops.doubleProperty([], settings);
   settings.Inclusive = [true, false];   % Lower interval endpoint is valid
 
%% Class documentation
% Execute the following in the MATLAB command window to view the class 
% documentation for |visprops.doubleProperty|:
%
%    doc visprops.doubleProperty
%
%% See also
% <property_help.html |visprops.property|>
%
%% 
% Copyright 2011 Kay A. Robbins, University of Texas at San Antonio