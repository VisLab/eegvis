%% visprops.intervalProperty
% Property representing a real interval (including endpoints)
%
%% Syntax
%    visprops.intervalProperty(objectID, structure)
%    obj = visprops.intervalProperty(...)
%
%% Description
% |visprops.intervalProperty(objectID, structure)| create a new property
% representing a real interval with endpoints included.
%
% |obj = visprops.intervalProperty(...)| returns a handle to a newly 
% created an interval property.
%
% The |visprops.intervalProperty| extends |visprops.property|.
% 
%% Example
% Create a real interval representing [-3, 5].
   settings = struct( ...
                 'Enabled',       {true}, ...
                 'Category',      {'Summary'}, ...
                 'DisplayName',   {'Box limits'}, ...
                 'FieldName',     {'BoxLimits'}, ... 
                 'Value',         {[-3, 5]}, ...
                 'Type',          {'visprops.intervalProperty'}, ...
                 'Editable',      {true}, ...
                 'Options',       {''}, ...
                 'Description',   {'Limits for the box plot'} ...
                                   );
   bm = visprops.intervalProperty([], settings);
  
%% Class documentation
% Execute the following in the MATLAB command window to view the class 
% documentation for |visprops.intervalProperty|:
%
%    doc visprops.intervalProperty
%
%% See also
% <property_help.html |visprops.doubleProperty|> and
% <property_help.html |visprops.property|>
%
%% 
% Copyright 2011 Kay A. Robbins, University of Texas at San Antonio