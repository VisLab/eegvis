%% viscore.managedObj
% Base class for keyed configuration objects
%
%% Syntax
%    viscore.managedObj(objectID, structure)
%    obj = viscore.managedObj(selector, title)
%
%% Description
% |viscore.managedObj(objectID, structure)| creates an object that 
% holds a structure and an ID. The |objectID| identifies this managed 
% object. If |objectID| is empty, the internal unique ID is used. The |structure| 
% holds the function, plot, and public property specifications. 
%
% |obj = viscore.managedObj(objectID, structure)| returns a handle to
%    the managed object.
%
%% Example
% Create a managed object with the default structure and empty values
    m = viscore.managedObj([], []);

%% Notes 
% 
% * managed objects have a unique integer |InternalID| that cannot be changed.
% * managed objects also have a user-settable |ObjectID|. If the user
% does not set the |ObjectID| in the constructor, the managed object uses 
% the string representation of the |InternalID| as the |ObjectID|.
%
%% Class documentation
% Execute the following in the MATLAB command window to view the class 
% documentation for |viscore.managedObj|:
%
%    doc viscore.managedObj
%
%% See also
% <dataManager_help.html |viscore.dataManager|> and
% <dataSelector_help.html |viscore.dataSelector|>

%% 
% Copyright 2011 Kay A. Robbins, University of Texas at San Antonio