%% viscore.counter
% Singleton class that returns a unique ID value 
%
%% Syntax
%    viscore.counter()
%    obj = viscore.counter()
%
%% Description
% |viscore.counter| creates a singleton counter object used to generate
% IDs for managed objects.
%
% |obj = viscore.counter| returns a handle to the singleton counter for
% IDs.
%
%% Example
% Generate a new ID from the counter
   counter = viscore.counter.getInstance();
   newID = counter.getNext();
   
%% Class documentation
% Execute the following in the MATLAB command window to view the class 
% documentation for |viscore.counter|:
%
%    doc viscore.counter
%
%% See also
% <dataManager_help.html |viscore.dataManager|>  and
% <managedObj_help.html |viscore.managedObj|> 
%% 
% Copyright 2011 Kay A. Robbins, University of Texas at San Antonio