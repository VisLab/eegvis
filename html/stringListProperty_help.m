%% visprops.stringListProperty
% Property representing a cell array of strings
%
%% Syntax
%    visprops.stringListProperty(objectID, structure)
%    obj = visprops.stringListProperty(...)
%
%% Description
% |visprops.stringListProperty(objectID, structure)| create a new property
% representing a cell array of strings. The |objectID| parameter
% is the hash key associated with configurable owner of the 
% property. The structure parameter is the structure specifying
% the vector property as described in |visprops.property|.
%
% |obj = visprops.stringlistProperty(...)| returns a handle to a newly 
% created string list property.
%
% The |visprops.stringListProperty| extends |visprops.property|.
%
%% Example
% Create a string list.
   settings = struct( ...
                 'Enabled',       {true}, ...
                 'Category',      {'Summary'}, ...
                 'DisplayName',   {'Body parts'}, ...
                 'FieldName',     {'NameList'}, ... 
                 'Value',         {{'Eyes', 'Ears', 'Nose', 'Throat'}}, ...
                 'Type',          {'visprops.stringListProperty'}, ...
                 'Editable',      {true}, ...
                 'Options',       {''}, ...
                 'Description',   {'List of parts'} ...
                                   );
   bm = visprops.stringListProperty([], settings);
  
%% Class documentation
% Execute the following in the MATLAB command window to view the class 
% documentation for |visprops.stringListProperty|:
%
%    doc visprops.stringListProperty
%
%% See also
% <property_help.html |visprops.property|> and
% <stringListProperty_help.html |visprops.stringListProperty|>
%
%% 
% Copyright 2011 Kay A. Robbins, University of Texas at San Antonio