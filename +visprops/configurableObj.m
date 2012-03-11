% visprops.configurableObj() component class for objects with configurable properties
%
% Usage:
%   >>  visprops.configurableObj(objectID, structure, target);
%   >>  obj = visprops.Configurable(objectID, structure, target);
%
% Description:
% visprops.configurableObj(objectID, structure, target) connector to property
%        configuration for an object that extends visprops.configurable. 
%        This design keeps the configuration code out of the configurable 
%        object. The objectID identifies this object in the manager. 
%        The structure parameter is a structure array that specifies 
%        the configurable public properties of the configurable object 
%        and how these properties should appear in the configuratin GUI. 
%        A description of the fields of the structure appears below. 
%        The target is an object reference or a class name specifying 
%        the object to be configured. If the objectID is empty, the 
%        object ID is taken to be the class name of the target. 
%        If both the objectID parameter and the target parameter are 
%        empty the object ID is the ID generated for the underlying 
%        managedObj class.
%
%        The public properties of a configurable object can be configured 
%        using a property manager. Implementors should over ride the
%        getDefaultProperties static method to designate which public 
%        properties of this object can be configured and type of 
%        configuration allowed. The getDefaultProperties method returns 
%        a structure array with the following fields:
%
% Field name       Description
%   Enabled        indicates whether property displays in GUI
%   Category       category for this property in the GUI
%   DisplayName    display name of property in the GUI
%   FieldName      name of the public property to be set in owner
%   Type           type of property object
%   Value          MATLAB property to be assigned
%   Editable       true if this property can be edited in the GUI
%   Options        optional parameters for type of property
%   Description    string appearing at bottom of property
%                  configuration window when item is selected
%
% obj = visprops.configurable(keyName) returns a handle to a newly 
%                  created configurable object.
%
% The visprops.configurableObj class extends viscore.managedObj.
%
% Class documentation:
% Execute the following in the MATLAB command window to view the class 
% documentation for visprops.configurableObj:
%
%    doc visprops.configurableObj
%
% See also: visprops.configurable, visprops.property, and
%           visprops.propertyConfig
%
%       configuration window when item is selected
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

% $Log: Configurable.m,v $
% Revision: 1.00  04-Dec-2011 09:11:20  krobbins $
% Initial version $
%

classdef configurableObj < hgsetget & viscore.managedObj 
    
    properties
       CategoryModifier = '';  % modification of category used for organizing properties
    end % public properties
    
    properties (Access = private)
       ClassName               % class name of target object
       TargetObj = [];         % target object to be configured
    end % private properties
    
    methods
        
        function obj = configurableObj(objectID, structure, target)
            % Create a configurableObj for target
            obj = obj@viscore.managedObj(objectID, structure);
            if isa(target, 'visprops.configurable')
                defProps = target.getDefaultProperties();
                obj.TargetObj = target;
                obj.ClassName = class(target);
            elseif ischar(target)
                defProps = eval([target '.getDefaultProperties()']);
                obj.TargetObj = target;
                obj.ClassName = target;
            else
                defProps = [];
                obj.TargetObj = [];
                obj.ClassName = '';
            end
            if isempty(objectID) && ~isempty(obj.ClassName)
                obj.ObjectID = obj.ClassName;
            end
            % Create the structure for this configurable object
            s = viscore.managedObj.mergeStructures(defProps, structure, 'FieldName');
            obj.setProperties(s)    
        end % configurableObj constructor
        
        function clonedObj = clone(obj)
            % Make a clean copy of the object retaining the same ID
            clonedObj = eval([class(obj) '(obj.ObjectID, obj.ManStruct,' ...
                'obj.TargetObj);']);
            clonedObj.CategoryModifier = obj.CategoryModifier;
        end % clone
        
        function className = getClassName(obj)
            % Returns the class name of the target object
            className = obj.ClassName;
        end % getClassName
        
       function c = getConfiguration(obj)
            % Return the configuration structure for this object
            c.key = obj.getObjectID();
            c.class = class(obj);
            c.properties = obj.getStructure();
            c.categoryModifier = obj.CategoryModifier;
            c.targetClass = obj.getClassName();
            c.properties = obj.getStructure();
        end % getConfiguration
                
        function s = getProperties(obj)
            % Get structure containing configurable properties of target object
            s = obj.getStructure(); 
            if isempty(s) || ~isa(obj.TargetObj, 'visprops.configurable')  % Static configuration
                return;
            end
            % This is an actual configurable object, so update by its values
            p = properties(obj.TargetObj);  % Find the names of the public properties
            for k = 1:length(s)
                fieldName = s(k).FieldName;
                inx = find(strcmp(p, fieldName), 1, 'first');
                if inx == 0
                    continue;
                end
                s(k).Value = obj.(fieldName);
            end
        end % getProperties
        
        function target = getTargetObj(obj)
            % Return the target for this configurable object
            target = obj.TargetObj;
        end % getTargetObj
        
        function setProperties(obj, s)
            % Set target object's public fields from structure s
            if ~isa(s, 'struct') || ... % Verify s is a property structure
                ~isfield(s, 'FieldName') || ~isfield(s, 'Value')
                return;
            end
            obj.setStructure(s);  % Set the underlying structure            
            % If have an actual configurable object
            if isa(obj.TargetObj, 'visprops.configurable') 
                visprops.property.setProperties(obj.TargetObj, s);
            end
        end % setProperties
        
        function setTargetObj(obj, target)
            % Set a new target object and update is public properties
            if ~isa(target, 'visprops.configurable')
                warning('configurableObj:setTargetObj', [target ...
                    ' must be a configurable obj']);
            end
            obj.TargetObj = target;
            obj.TargetObj.updateProperties(obj.getStructure());
        end % setTargetObj
               
    end % public methods
    
    methods (Static = true)
        
       function obj = createFromConfig(config)
            % Return managed object of appropriate class from configuration
            if isempty(config)
                obj = '';
            else
                evalStr = char([config.class '(''' config.key ''' ,' ...
                    '[], ''' config.targetClass ''')']);
                obj = eval(evalStr);
                obj.setProperties(config.properties);
                obj.CategoryModifier = config.categoryModifier;
            end
        end % createFromConfig(config)
        
        function newMan = createManager(cMan, cList)
            % Update the manager cMan with new configurable objects
            %
            % If objectID of an item in cList doesn't match
            % an object in cMan, a new object is added.
            % If objectID of an item in CList matches an item in cMan
            % but class names don't match, cList item replaces one in cMan.
            % If objectID of an item in cList matches an item in cMan and
            % the class names also match, the item structures are merged,
            % with the one in cMan being the replace.
            newMan = viscore.BaseManager();
            for k = 1:length(cList)
                tObj = cList{k};
                if ~isa(cList{k}, 'visprops.configurableObj')
                    continue;
                end
                mObj = cMan.getObject(tObj.getObjectID());
                if ~isempty(mObj) && ...
                        strcmp(mObj.getClassName(), cList{k}.getClassName()) == 1
                    pStruct = viscore.ManagedObj.mergeStructures(...
                        mObj.getStructure(), tObj.getStructure());
                    tObj.setStructure(pStruct);
                end
                newMan.putObject(tObj.getObjectID(), tObj);
               
            end
        end % createManager
        
        function bfs = createObjects(s)
            % Create objects for
            bfs = {};
            if isempty(s)  % Nothing to create
                return;
            end            
            if isa(s, 'struct') % Just create a single structure, new ID
                c = viscore.CountObj.getInstance();
                ns = visprops.configurableObj(num2str(c.getNext()), s, []);
                if ~isempty(ns)  % Created successfully
                    bfs{1} = ns;
                    return;
                end
            elseif ~isa(s, 'cell') % Only valid alternative is a cell array
                return;
            end            
            bfs = cell(length(s), 1);
            count = 0;
            for k = 1:length(s)
                if isa(s{k}, 'visprops.configurableObj')
                    count = count + 1;
                    bfs{count} = s{k}.clone();
                elseif isa(s{k}, 'char')
                    try
                        settings = eval([s{k} '.getDefaultProperties']);
                        count = count + 1;
                        bfs{count} = visprops.configurableObj(s{k}, settings, s{k});
                    catch ME
                        warning('configurableObj:CreateObjects', ...
                            '%s: %s is not a valid configurable object', ...
                            ME.message, s{k});
                    end
                end
            end
            bfs = bfs(1:count);  
        end % createObjects
     
        function fields = getDefaultFields()
            % Default fields are the ones that  are configured.
            fields = viscore.managedObj.getDefaultFields();
            fields = [fields{:},   ...
                {'FieldName', 'Value', 'Type', 'Editable', 'Options'}]; 
        end % getDefaultFields
             
        function updateManager(cMan, cList)
            % Update the manager cMan with new configurable objects,
            % retaining values of old if matching
            %
            % If objectID of an item in cList doesn't match
            % an object in cMan, a new object is added.
            % If objectID of an item in CList matches an item in cMan
            % but class names don't match, cList item replaces one in cMan.
            % If objectID of an item in cList matches an item in cMan and
            % the class names also match, the item structures are merged,
            % with the one in cMan being the replace so existing values are
            % retained.           
            keys = cMan.getKeys();  % Keep list of original keys for removal  
            for k = 1:length(cList)
                tObj = cList{k};   % incoming configurable object
                if ~isa(cList{k}, 'visprops.configurableObj')
                    continue;
                end              
                % Remove this key from the list of keys if it is there
                tKeys = strcmp(keys, tObj.getObjectID());
                keys(tKeys) = '';                 
                % Patch up the
                mObj = cMan.getObject(tObj.getObjectID()); 
                if ~isempty(mObj) && ...
                    strcmp(mObj.getClassName(), cList{k}.getClassName()) == 1
                    pStruct = viscore.managedObj.mergeStructures(...
                        tObj.getStructure(), mObj.getStructure(), 'FieldName');
                    tObj.setStructure(pStruct);
                end
                cMan.putObject(tObj.getObjectID(), tObj);       
            end
            % Remove the keys for which there are no
            for k = 1:length(keys)
                cMan.remove(keys{k});
            end
        end % updateManager

    end % static methods
    
end % configurableObj

