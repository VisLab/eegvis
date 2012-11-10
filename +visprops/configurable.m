% visprops.configurable  base class for objects with configurable properties
%
% Usage:
%   >>  visprops.configurable(keyName);
%   >>  obj = visprops.configurable(keyName);
%
% Description:
%     visprops.visprops.configurable(keyName) is the base class for 
%         objects that have public properties that can be modified using a
%         property configuration GUI that is similar to the MATLAB property
%         manager. The keyName is a string used to look up this object in
%         the manager.
%
%         The public properties of a configurable object can be configured 
%         using a property manager. Implementors should over ride the
%         getDefaultProperties static method to designate which public 
%         properties of this object can be configured and type of configuration 
%         allowed.
%
%    obj = visprops.configurable(keyName) returns a handle to a newly 
%         created configurable object.
%
% Class documentation:
% Execute the following in the MATLAB command window to view the class 
% documentation for visprops.configurable:
%
%    doc visprops.configurable
%
% See also: visprops.configurableObj, visprops.property, and
%       visprops.propertyConfig
%

%
% Copyright (C) 2011  Kay Robbins, UTSA, krobbins@cs.utsa.edu
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

% $Log: configurable.m,v $
% Revision: 1.00  04-Dec-2011 09:11:20  krobbins $
% Initial version $
%

classdef configurable < hgsetget  
     
    properties (Access = private)
        ConfigObj    % ConfigurableObj managing this object's configuration
    end % public properties
    
    methods
        
        function obj = configurable(keyName)
            % Create a configurable object target
            obj.ConfigObj = visprops.configurableObj(keyName, [], obj);
        end % configurable constructor
        
        function conObj = getConfigObj(obj)
            % Return cell array of this object's configurable object
            conObj = obj.ConfigObj;
        end % getConfigurableObjs
        
        function ID = getInternalID(obj)
            if ~isempty(obj.ConfigObj) && isvalid(obj.ConfigObj)
                ID = obj.ConfigObj.getInternalID();
            else
                ID = [];
            end
        end % getInternalID
        
        function ID = getObjectID(obj)
            if ~isempty(obj.ConfigObj) && isvalid(obj.ConfigObj)
                ID = obj.ConfigObj.getObjectID();
            else
                ID = [];
            end
        end % getObjectID
        
        function updateProperties(obj, man)
            visprops.property.updateProperties(obj, man);
        end % updateProperties
        
    end % public methods
       
    methods (Static = true)
        
        function settings = getDefaultProperties()
            % Return a structure with the default properties
            settings = [];
        end % getDefaultProperties
        
    end % static methods
    
end % configurable

