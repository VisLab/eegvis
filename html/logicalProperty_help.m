%% visprops.logicalProperty
% Property representing a logical (boolean) value
%
%% Syntax
%    visprops.logicalProperty(objectID, structure)
%    obj = visprops.logicalProperty(...)
%
%% Description
% |visprops.logicalProperty(objectID, structure)| create a new property
% representing a logical value (|true| or |false|). The |objectID| parameter
% is the hash key associated with configurable owner of the 
% property. The structure parameter is the structure specifying
% the vector property as described in |visprops.property|.
%
% |obj = visprops.logicalProperty(...)| returns a handle to a newly 
% created logical property.
%
% The |visprops.logicalProperty| extends |visprops.property|.
%
%% Example
% Create a logical property
   settings = struct( ...
                 'Enabled',       {true}, ...
                 'Category',      {'Summary'}, ...
                 'DisplayName',   {'Show mean'}, ...
                 'FieldName',     {'ShowMean'}, ... 
                 'Value',         {true}, ...
                 'Type',          {'visprops.logicalProperty'}, ...
                 'Editable',      {true}, ...
                 'Options',       {''}, ...
                 'Description',   {'Flag indicate whether mean should be displayed'} ...
                                   );
   bm = visprops.logicalProperty([], settings);
  
%% Class documentation
% Execute the following in the MATLAB command window to view the class 
% documentation for |visprops.logicalProperty|:
%
%    doc visprops.logicalProperty
%
%% See also
% <property_help.html |visprops.property|>
%
%% 
% Copyright 2011 Kay A. Robbins, University of Texas at San Antonio