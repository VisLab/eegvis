%% viscore.dataManager
% Enhanced map for managing configuration objects
%
%% Syntax
%    viscore.dataManager()
%    obj =  viscore.dataManager()
%
%% Description
% |viscore.dataManager()| creates an enhanced map for managing various
% types of managed objects including plots, functions, and properties.
%
% The |viscore.managedObj| objects are stored in the map and indexed by
% a string key. 
%
% |obj = viscore.dataManager())| returns a handle to
%    the map for managing objects
%
%% Example
% Create a data manager and store a managed object under the name |'myKey'| 
   dm = viscore.dataManager();
   dm.putObject('myKey', viscore.managedObj([], []));
   
%% Class documentation
% Execute the following in the MATLAB command window to view the class 
% documentation for |viscore.dataManager|:
%
%    doc viscore.dataManager
%
%% See also
% <dataSelector_help.html |viscore.dataSelector|> and
% <managedObj_help.html |viscore.managedObj|> 
%

%% 
% Copyright 2011 Kay A. Robbins, University of Texas at San Antonio