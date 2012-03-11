%% visprops.stringProperty
% Property representing a simple string
%
%% Syntax
%    visprops.stringProperty(objectID, structure)
%    obj = visprops.stringProperty(...)
%
%% Description
% |visprops.stringProperty(objectID, structure)| create a new property
% representing a simple string. The |objectID| parameter
% is the hash key associated with configurable owner of the 
% property. The structure parameter is the structure specifying
% the vector property as described in |visprops.property|.
%
% |obj = visprops.stringProperty(...)| returns a handle to a newly 
% created string property.
%
% The |visprops.stringProperty| extends |visprops.property|.
%
%% Example
% Create a string property of non negative values.
   settings = struct( ...
                 'Enabled',       {true}, ...
                 'Category',      {'Summary'}, ...
                 'DisplayName',   {'Window name'}, ...
                 'FieldName',     {'WindowName'}, ... 
                 'Value',         {'Epoch'}, ...
                 'Type',          {'visprops.stringProperty'}, ...
                 'Editable',      {true}, ...
                 'Options',       {''}, ...
                 'Description',   {'Axis label for window'} ...
                                   );
   bm = visprops.stringProperty([], settings);
  
%% Class documentation
% Execute the following in the MATLAB command window to view the class 
% documentation for |visprops.stringProperty|:
%
%    doc visprops.stringProperty
%
%% See also
% <property_help.html |visprops.property|>
%
%% 
% Copyright 2011 Kay A. Robbins, University of Texas at San Antonio