%% visprops.enumeratedProperty
% Property representing a string selected from a list of valid values
%
%% Syntax
%    visprops.enumeratedProperty(objectID, structure)
%    obj = visprops.enumeratedProperty(...)
%
%% Description
% |visprops.enumeratedProperty(objectID, structure)| create a new property
% representing a string from a list of valid values. The |objectID| parameter
% is the hash key associated with configurable owner of the 
% property. The structure parameter is the structure specifying
%  the vector property as described in |visprops.property|.
%
% |obj = visprops.enumeratedProperty(...)| returns a handle to a newly 
% created enumerated property.
%
% The |visprops.enumeratedProperty| extends |visprops.property|.
%
%% Example
% Create an enumerated property
   settings = struct( ...
                 'Enabled',       {true}, ...
                 'Category',      {'Summary'}, ...
                 'DisplayName',   {'Window type'}, ...
                 'FieldName',     {'WindowType'}, ... 
                 'Value',         {'Blocked'}, ...
                 'Type',          {'visprops.enumeratedProperty'}, ...
                 'Editable',      {true}, ...
                 'Options',       {{'Blocked', 'Epoched'}}, ...
                 'Description',   {'Type of window used in computation'} ...
                                   );
   bm = visprops.enumeratedProperty([], settings);
  
%% Class documentation
% Execute the following in the MATLAB command window to view the class 
% documentation for |visprops.enumeratedProperty|:
%
%    doc visprops.enumeratedProperty
%
%% See also
% <property_help.html |visprops.property|>
%
%% 
% Copyright 2011 Kay A. Robbins, University of Texas at San Antonio