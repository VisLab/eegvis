%% visprops.configurable
% Base class for objects with configurable properties
%
%% Syntax
%    visprops.visprops.configurable(keyName)
%    obj = visprops.configurable(keyName)
%
%% Description
% |visprops.visprops.configurable(keyName)| is the base class for 
% objects that have public properties that can be modified using a
% property configuration GUI that is similar to the MATLAB property
% manager. The |keyName| is a string used to look up this object in
% the manager.
%
% The public properties of a configurable object can be configured using a
% property manager. Implementors should over ride the
% |getDefaultProperties| static method to designate which public 
% properties of this object can be configured and type of configuration 
% allowed.
%
% |obj = visprops.configurable(keyName)| returns a handle to a newly 
% created configurable object.
%
%% Class documentation
% Execute the following in the MATLAB command window to view the class 
% documentation for |visprops.configurable|:
%
%    doc visprops.configurable
%
%% See also
% <configurableObj_help.html |visprops.configurableObj|>,
% <property_help.html |visprops.property|>, and
% <propertyConfig_help.html |visprops.propertyConfig|>
%
%% 
% Copyright 2011 Kay A. Robbins, University of Texas at San Antonio