%% visprops.colorProperty
% Property representing a single color
%
%% Syntax
%    visprops.colorProperty(objectID, structure)
%    obj = visprops.colorProperty(...)
%
%% Description
% |visprops.colorProperty(objectID, structure)| create a new property
% representing a single color. The value should be a 3-element row
% vector of values in the interval [0, 1]. The |objectID| parameter
% is the hash key associated with configurable owner of the 
% property. The structure parameter is the structure specifying
% the vector property as described in |visprops.property|.
%
% |obj = visprops.colorProperty(...)| returns a handle to a newly 
% created color property.
%
% The |visprops.colorProperty| extends |visprops.property|.
%
%% Example
% Create a color property
   settings = struct( ...
                 'Enabled',       {true}, ...
                 'Category',      {'Summary'}, ...
                 'DisplayName',   {'Background color'}, ...
                 'FieldName',     {'BackgroundColor'}, ... 
                 'Value',         {[0.7, 0.7, 0.7]}, ...
                 'Type',          {'visprops.colorProperty'}, ...
                 'Editable',      {true}, ...
                 'Options',       {''}, ...
                 'Description',   {'Background image color'} ...
                                   );
   bm = visprops.colorProperty([], settings);
  
%% Class documentation
% Execute the following in the MATLAB command window to view the class 
% documentation for |visprops.colorProperty|:
%
%    doc visprops.colorProperty
%
%% See also
% <colorListProperty_help.html |visprops.colorListProperty|> and
% <property_help.html |visprops.property|>
%
%% 
% Copyright 2011 Kay A. Robbins, University of Texas at San Antonio