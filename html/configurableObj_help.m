%% visprops.configurableObj
% Component class for objects with configurable properties
%
%% Syntax
%    visprops.configurableObj(objectID, structure, target)
%    obj = visprops.Configurable(objectID, structure, target)
%
%% Description
% |visprops.configurableObj(objectID, structure, target)| connector to property
% configuration for an object that extends |visprops.configurable|. 
% This design keeps the configuration code out of the configurable object.
% The |objectID| identifies this object in the manager. The |structure|
% parameter is a structure array that specifies the configurable public   
% properties of the configurable object and how these properties 
% should appear in the configuratin GUI. A description of the fields of 
% the structure appears below. The |target| is an object reference
% or a class name specifying the object to be configured. If the 
% |objectID| is empty, the object ID is taken to be the class name of 
% the |target|. If both the |objectID| parameter and the |target| 
% parameter are empty the object ID is the ID generated for the 
% underlying |managedObj| class.
%
% The public properties of a configurable object can be configured using a
% property manager. Implementors should over ride the
% |getDefaultProperties| static method to designate which public 
% properties of this object can be configured and type of configuration 
% allowed. The |getDefaultProperties| method returns a structure array
% with the following fields:
%
% <html>
% <table>
% <thead><tr><td>Field name</td><td>Description</td></tr></thead>
% <tr><td>|Enabled|</td><td>indicates whether property displays in GUI</td></tr>
% <tr><td>|Category|</td><td>category for this property in the GUI</td></tr>
% <tr><td>|DisplayName|</td><td>display name of property in the GUI</td></tr>
% <tr><td>|FieldName|</td><td>name of the public property to be set in owner</td></tr>
% <tr><td>|Type|</td><td>type of property object</td></tr>
% <tr><td>|Value|</td><td>MATLAB property to be assigned</td></tr>
% <tr><td>|Editable|</td><td>true if this property can be edited in the GUI</td></tr>
% <tr><td>|Options|</td><td>optional parameters for type of property</td></tr>
% <tr><td>|Description|</td><td>string appearing at bottom of property
%                       configuration window when item is selected</td></tr>
% </table>
% </html>
%
%
% |obj = visprops.configurable(keyName)| returns a handle to a newly 
% created configurable object.
%
% The |visprops.configurableObj| class extends |viscore.managedObj|.
%
%% Class documentation
% Execute the following in the MATLAB command window to view the class 
% documentation for |visprops.configurableObj|:
%
%    doc visprops.configurableObj
%
%% See also
% configurable_help.html |visprops.configurable|>,
% property_help.html |visprops.property|>, and
% propertyConfig_help.html |visprops.propertyConfig|>
%
%% 
% Copyright 2011 Kay A. Robbins, University of Texas at San Antonio