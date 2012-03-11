%% visprops.vectorProperty
% Property representing a numeric vector
%
%% Syntax
%    visprops.vectorProperty(objectID, structure)
%    obj = visprops.vectorProperty(...)
%
%% Description
% |visprops.vectorProperty(objectID, structure)| create a new property
% representing a vector whose values are in a specified interval. 
% By default, the interval is |[-inf, inf]|. The |objectID| parameter
% is the hash key associated with configurable owner of the 
% property. The structure parameter is the structure specifying
% the vector property as described in |visprops.property|.
%
% |obj = visprops.vectorProperty(...)| returns a handle to a newly 
% created vector property.
%
% The |visprops.vectorProperty| extends |visprops.doubleProperty| and
% inherits its two public properties that specify
% the range for a valid value:
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
%% Example
% Create a vector property of non negative values.
   settings = struct( ...
                 'Enabled',       {true}, ...
                 'Category',      {'Summary'}, ...
                 'DisplayName',   {'My list'}, ...
                 'FieldName',     {'Values'}, ... 
                 'Value',         {[1, 2.5, 3, 4.23]}, ...
                 'Type',          {'visprops.vectorProperty'}, ...
                 'Editable',      {true}, ...
                 'Options',       {[0, inf]}, ...
                 'Description',   {'Block size for computation (must be non negative)'} ...
                                   );
   bm = visprops.vectorProperty([], settings);
   settings.Inclusive = [false, false];   % Lower interval endpoint is not included
 
%% Notes
% 
% * If the |Options| field of the settings structure for
% |visprops.vectorProperty| is non empty, it is used to set the 
% |Limits| property.
%
%% Class documentation
% Execute the following in the MATLAB command window to view the class 
% documentation for |visprops.vectorProperty|:
%
%    doc visprops.vectorProperty
%
%% See also
% <doubleProperty_help.html |visprops.doubleProperty|> and
% <property_help.html |visprops.property|>
%
%% 
% Copyright 2011 Kay A. Robbins, University of Texas at San Antonio