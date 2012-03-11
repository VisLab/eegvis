%% visprops.integerProperty
% Property representing an integer in a specified interval
%
%% Syntax
%    visprops.integerProperty(objectID, structure)
%    obj = visprops.integerProperty(...)
%
%% Description
% |visprops.integerProperty(objectID, structure)| create a new property
% representing an integer in a specified interval. By default, the interval
% is |[-inf, inf]|. The |objectID| parameter
% is the hash key associated with configurable owner of the 
% property. The structure parameter is the structure specifying
% the vector property as described in |visprops.property|.
%
% |obj = visprops.integerProperty(...)| returns a handle to a newly 
% created integer property.
%
% The |visprops.integerProperty| extends |visprops.doubleProperty| and
% inherits its two public properties that specify the interval for a valid value:
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
% Create an integer property in the interval in the (-3, 5] with initial
% value -2.
   settings = struct( ...
                 'Enabled',       {true}, ...
                 'Category',      {'Summary'}, ...
                 'DisplayName',   {'Minimum limit'}, ...
                 'FieldName',     {'MinimumLimit'}, ... 
                 'Value',         {-2}, ...
                 'Type',          {'visprops.integerProperty'}, ...
                 'Editable',      {true}, ...
                 'Options',       {[-3, 5]}, ...
                 'Description',   {'Lower limit of axis'} ...
                                   );
   bm = visprops.integerProperty([], settings);
   settings.Inclusive = [false, true];   % Upper interval endpoint is valid
   
%% Notes
% 
% * If the |Options| field of the settings structure for
% |visprops.integerProperty| is non empty, it is used to set the 
% |Limits| property.
% * This integer converts to a MATLAB |int32|.
%
% 
%% Class documentation
% Execute the following in the MATLAB command window to view the class 
% documentation for |visprops.integerProperty|:
%
%    doc visprops.integerProperty
%
%% See also
% <doubleProperty_help.html |visprops.doubleProperty|> and
% <property_help.html |visprops.property|>
%
%% 
% Copyright 2011 Kay A. Robbins, University of Texas at San Antonio