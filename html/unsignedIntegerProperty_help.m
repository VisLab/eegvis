%% visprops.unsignedIntegerProperty
% Property representing an unsigned integer in a specified interval
%
%% Syntax
%    visprops.unsignedIntegerProperty(objectID, structure)
%    obj = visprops.unsignedIntegerProperty(...)
%
%% Description
% |visprops.unsignedIntegerProperty(objectID, structure)| create a new property
% representing an integer in a specified interval. By default, the interval
% is |[0, inf]|. The |objectID| parameter
% is the hash key associated with configurable owner of the 
% property. The structure parameter is the structure specifying
% the vector property as described in |visprops.property|.
%
% |obj = visprops.unsignedIntegerProperty(...)| returns a handle to a newly 
% created integer property.
%
% The |visprops.unsignedIntegerProperty| extends |visprops.integerProperty| and
% inherits its two public properties that specify the interval for a valid value:
%
% <html>
% <table>
% <thead><tr><td>Public property</td><td>Description</td></tr></thead>
% <tr><td><tt>Limits</tt></td><td>A two-element vector specifying the endpoints
% of the interval for a valid value. <tt>inf</tt> is a valid value.</td></tr>
% <tr><td><tt>Inclusive</tt></td><td>A two-element boolean vector specifying
% whether the endpoints of the interval specifyed by <tt>Limits</tt> should
% be included as valid values.</td></tr>
% </table>
% </html>
% 
%% Example
% Create an unsigned integer property in the interval in the (0, 5] with initial
% value 1.
   settings = struct( ...
                 'Enabled',       {true}, ...
                 'Category',      {'Summary'}, ...
                 'DisplayName',   {'Count'}, ...
                 'FieldName',     {'Count'}, ... 
                 'Value',         {1}, ...
                 'Type',          {'visprops.unsignedIntegerProperty'}, ...
                 'Editable',      {true}, ...
                 'Options',       {[0, 5]}, ...
                 'Description',   {'Object counter'} ...
                                   );
   bm = visprops.integerProperty([], settings);
   settings.Inclusive = [false, true];   % Upper interval endpoint is valid

%% Notes
% 
% * If the |Options| field of the settings structure for
% |visprops.unsignedIntegerProperty| is non empty, it is used to set the 
% |Limits| property.
% * This integer converts to a MATLAB |uint32|.
%
%% Class documentation
% Execute the following in the MATLAB command window to view the class 
% documentation for |visprops.unsignedIntegerProperty|:
%
%    doc visprops.unsignedIntegerProperty
%
%% See also
% <doubleProperty_help.html |visprops.doubleProperty|>,
% <integerProperty_help.html |visprops.integerProperty|>, and
% <property_help.html |visprops.property|>
%
%% 
% Copyright 2011 Kay A. Robbins, University of Texas at San Antonio