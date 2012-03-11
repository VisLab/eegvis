%% visprops.colorListProperty
% Property representing a list of colors
%
%% Syntax
%    visprops.colorListProperty(objectID, structure)
%    obj = visprops.colorListProperty(...)
%
%% Description
% |visprops.colorListProperty(objectID, structure)| create a new property
% representing a list of colors. The value should be an n x 3 
% array of values in the interval [0, 1]. The |objectID| parameter
% is the hash key associated with configurable owner of the 
% property. The structure parameter is the structure specifying
%  the vector property as described in |visprops.property|.
%
% |obj = visprops.colorlistProperty(...)| returns a handle to a newly 
% created color list property.
%
% The |visprops.colorListProperty| extends |visprops.property|.
%
%% Example
% Create a color property
   settings = struct( ...
                 'Enabled',       {true}, ...
                 'Category',      {'Summary'}, ...
                 'DisplayName',   {'Box colors'}, ...
                 'FieldName',     {'BoxColors'}, ... 
                 'Value',         {[0.7, 0.7, 0.7; 1, 0, 1]}, ...
                 'Type',          {'visprops.colorListProperty'}, ...
                 'Editable',      {true}, ...
                 'Options',       {''}, ...
                 'Description',   {'Alternating box colors for box plot'} ...
                                   );
   bm = visprops.colorListProperty([], settings);
  
%% Class documentation
% Execute the following in the MATLAB command window to view the class 
% documentation for |visprops.colorListProperty|:
%
%    doc visprops.colorListProperty
%
%% See also
% <colorProperty_help.html |visprops.colorProperty|> and
% <property_help.html |visprops.property|>
%
%% 
% Copyright 2011 Kay A. Robbins, University of Texas at San Antonio