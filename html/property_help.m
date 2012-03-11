%% visprops.property
% Base class for a configurable property
%
%% Syntax
%     visprops.property(objectID, structure)
%     obj = visprops.property(objectID, structure)
%
%% Description
% |visprops.property(objectID, structure)| creates a configurable property
%     which provides holds a current MATLAB value, an original MATLAB
%     value and provides methods to map between MATLAB values and Java
%     JIDE values. The |objectID| identifies the property in the
%     manager and the |structure| specifies the property details in the
%     structure described below.
%
% |obj = visprops.property(objectID, structure)| returns a handle to the
%      newly created property.
%
% An object allows some of its public properties to be configurable must
% provide a static |getDefaultProperties| method that returns a structure
% array with one entry for each configurable property. 
%
% The fields of the structure array are:
%
% <html>
% <table>
% <thead><tr><td>Field name</td><td>Description</td></tr></thead>
% <tr><td><tt>Enabled</tt></td><td>indicates whether property displays in GUI</td></tr>
% <tr><td><tt>Category</tt></td><td>category for this property in the GUI</td></tr>
% <tr><td><tt>DisplayName</tt></td><td>display name of property in the GUI</td></tr>
% <tr><td><tt>FieldName</tt></td><td>name of the public property to be set in owner</td></tr>
% <tr><td><tt>Type</tt></td><td>type of property object</td></tr>
% <tr><td><tt>Value</tt></td><td>MATLAB property to be assigned</td></tr>
% <tr><td><tt>Editable</tt></td><td>true if this property can be edited in the GUI</td></tr>
% <tr><td><tt>Options</tt></td><td>optional parameters for type of property</td></tr>
% <tr><td><tt>Description</tt></td><td>string appearing at bottom of property
%                       configuration window when item is selected</td></tr>
% </table>
% </html>
%
%% Notes
%
% * This class is meant to be used as a base class and not called directly
% * A property is a managedObj
%
% The JIDE properties mapped by property are components
% of the Java Grid Framework provided by JideSoft. This framework is
% distributed as part of MATLAB and used for its property manager.
% Further information about the framework can be found in the
% <http://www.jidesoft.com/products/JIDE_Grids_Developer_Guide.pdf 
%   JIDE Grids Developer Guide> and in 
% <http://www.jidesoft.com/javadoc/ JIDE 3.3.1 Javadoc>.
%
%% Class documentation
% Execute the following in the MATLAB command window to view the class 
% documentation for |visprops.property|:
%
%    doc visprops.property
%
%% See also
% <configurable_help.html |visprops.configurable|>,
% <configurableObj_help.html |visprops.configurableObj|>,
% <managedObj_help.html |viscore.managedObj|>, and
% <propertyConfig_help.html |visprops.propertyConfig|>
%% 
% Copyright 2011 Kay A. Robbins, University of Texas at San Antonio