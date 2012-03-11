% viscore.dataManager  enhanced map for managing configuration objects
%
% Usage:
%   >>  viscore.dataManager()
%   >>  obj = viscore.dataManager()
%
% Description:
% viscore.dataManager() creates an enhanced map for managing various
%     types of managed objects including plots, functions, and properties.
%
%     The viscore.managedObj objects are stored in the map and indexed by
%     a string key. 
%
% obj = viscore.dataManager()) returns a handle to
%     the map for managing objects
%
% Example:
% Create a data manager and store a managed object under the name 'myKey' 
%   dm = viscore.dataManager();
%   dm.putObject('myKey', viscore.managedObj([], []));
%   
% Class documentation:
% Execute the following in the MATLAB command window to view the class 
% documentation for viscore.dataManager:
%
%    doc viscore.dataManager
%
% See also: viscore.dataSelector and viscore.managedObj
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

% $Log: dataManager.m,v $
% Revision: 1.00  04-Dec-2011 09:11:20  krobbins $
% Initial version $
%

classdef dataManager < hgsetget
    
    properties  (Access = private)
        Map;          % map of managedObjs for lookup by key
    end % private properties
    
    methods
        
        function obj = dataManager()
            % Create the map
            obj.clear();
        end % dataManager constructor
        
        function clear(obj)
            % Make the object empty or initialize if in constructor
            obj.Map = containers.Map('KeyType', 'char', 'ValueType', 'any');
            %obj.List = {};
        end % clear
        
        function man = clone(obj)
            % Clone this dataManager keeping IDs and keys
            man = eval([class(obj) '();']); % Get correct type of manager
            keys = obj.Map.keys;
            for k = 1:length(keys)
                cObj = obj.Map(keys{k});
                if isempty(cObj) || ~isa(cObj, 'viscore.managedObj')
                    continue;
                end
                clonedObj = cObj.clone();
                man.putObject(keys{k}, clonedObj);
            end
        end % clone
        
        function enabled = getEnabledObjects(obj, category)
            % Return cell array of enabled managedObj objects in category
            enabled = obj.Map.values();
            if isempty(enabled)
                return;
            end
            eFlags = true(length(enabled), 1);
            for k = 1:length(enabled)
                nEnabled = enabled{k}.getNumberEnabled();
                categories = enabled{k}.getCategories();
                if nEnabled == 0 || (~isempty(category) && ...
                        sum(strcmp(category, categories)) == 0)
                    eFlags(k) = false;
                end
            end
            enabled = enabled(eFlags);
        end % getEnabledObjects
        
        function keys = getKeys(obj)
            % Return the keys
            keys = obj.Map.keys;
        end % getKeys
        
        function numEnabled = getNumberEnabled(obj)
            % Return number of managed objects with any enabled substructures
            numEnabled = 0;
            objs = obj.Map.values();
            if isempty(objs)
                return;
            end
            for k = 1:length(objs)
                if objs{k}.getNumberEnabled() > 0
                    numEnabled = numEnabled + 1;
                end
            end
        end % getNumberEnabled
        
        function numObjects = getNumberObjects(obj)
            % Return the number of objects managed by this
            numObjects = length(obj.Map);
        end % getNumberObjects
        
        function s = getObject(obj, key)
            % Return the object associated with key
            %
            % Inputs:
            %     key      string identifying object associated with key
            %
            % Outpus:
            %     s         retrieved object or empty
            %
            s = [];
            if obj.Map.isKey(key)
                s = obj.Map(key);
            end
        end % getObject
        
        function [sObjs, keys] = getObjects(obj)
            % Return cell array of objects and corresponding keys managed by this manager
            %
            % Outputs:
            %     sObjs         retrieved cell array of objects
            %     keys          the keys corresponding to the objects
            %
            keys = obj.Map.keys;
            sObjs = obj.Map.values(keys);
        end % getObjects
        
        function value = getValue(obj, key, fieldName)
            % Return the value of the field associated with key or empty
            %
            % Inputs:
            %    key     string under which object was stored
            %    field   identifier within object of value to be retrieved
            %
            % Outputs:
            %    value   retrieved value for (key, field) or empty if none
            value = [];
            if obj.Map.isKey(key)
                pSettings = obj.Map(key);
                value = pSettings.getValue(position, fieldName);
            end
        end % getValue
        
        function ikey = isKey(obj, key)
            % Return true if key is in this manager
            ikey = obj.Map.isKey(key);
        end % isKey
        
        function printObjects(obj, msg)
            % Print objects managed by this manager with identifying msg
            fprintf('\n%s:\n', msg);
            keys = obj.Map.keys;
            for k = 1:length(keys)
                if obj.Map.isKey(keys{k})
                    printObject(obj.Map(keys{k}));
                    fprintf('\n');
                end
            end
        end % printObjects
        
        function putObject(obj, key, s)
            % Store the object s under key in this manager
            %
            % Inputs:
            %     key    string under which object is stored
            %     s      object to be stored
            %
            % Notes: empty objects are not stored and duplicate keys
            %        are overwritten
            if isempty(key) || isempty(s)  % Don't store empty ones
                return;
            elseif obj.Map.isKey(key)
                obj.Map.remove(key);
            end
            obj.Map(key) =  s;
        end % putObject
        
        function putObjects(obj, objList)
            % Store cell array of managedObj in this Manager under their ObjectID
            %
            % Inputs:
            %     objList    a managedObj or a cell array of managedObj
            %
            % Notes: empty objects are not stored and duplicate keys
            %        are overwritten
            if isempty(objList)
                return;
            elseif isa(objList, 'viscore.managedObj')
                obj.putObject(objList.getObjectID(), objList);
            elseif isa(objList, 'cell')
                for k = 1:length(objList)
                    if ~isa(objList{k}, 'viscore.managedObj')
                        continue
                    end
                    obj.putObject(objList{k}.getObjectID(), objList{k});
                end
            end
        end % putObjects
        
        function putValue(obj, key, position, fieldName, value)
            % Store the value for fieldName of object stored under key
            %
            % Inputs:
            %    key            string key for object in the Manager
            %    position       position within structure array
            %    fieldName      field name within structure array of object
            %    value          value to be stored in object
            %
            if obj.Map.isKey(key)
                p = obj.Map(key);
                p.setValue(position, fieldName, value);
            end
        end % putValue
        
        function putValueByField(obj, key, fieldName, value)
            % Insert a value of a field in the object corresponding to key
            if obj.Map.isKey(key)
                p = obj.Map(key);
                s = p.getStructure();
                fNames = {s.('FieldName')};
                pos = find(strcmpi(fNames, fieldName), 1, 'first');
                if ~isempty(pos)
                    p.setValue(pos, 'Value', value);
                end
            end
        end % putValueByField
        
        function refresh(obj, rMan, keyField) %#ok<INUSD>
            % Reset this manager but retain old values if they are there
            oldMap = obj.Map;
            newList = rMan.getObjects();
            obj.clear();
            for k = 1:length(newList)
                key = newList{k}.getObjectID();
                if oldMap.isKey(key)   % merge structures retaining old values
                    oldStructure = oldMap(key).getStructure();
                    s = viscore.managedObj.mergeStructures( ...
                        newList{k}.getStructure(), oldStructure);
                    newList{k}.putStructure(s);
                end
                obj.putObject(key, newList{k});
            end
        end % refresh
        
        function removed = remove(obj, key)
            % Remove object stored under key if any and return true if removed   
            if obj.Map.isKey(key)
                obj.Map.remove(key);
                removed = true;
            else
                removed = false;
            end
        end % remove
        
    end % public methods
    
    methods (Static = true)
        function config = createConfig(objList, keys)
            % Return a configuration structure for these managed objects
            if isempty(objList) || (~isempty(keys) && (length(keys)~= length(objList)))
                config = '';
            else
                config(length(objList)) = ...
                    objList{length(objList)}.getConfiguration();
                for k = 1:length(objList) - 1
                    config(k) = objList{k}.getConfiguration();
                end
                if ~isempty(keys)
                    for k = 1:length(objList)
                        config(k).key = keys{k};
                    end
                end
            end
        end % createConfigur
        
        function [objList, keys] = createManagedObjs(config)
            if isempty(config)
                objList = '';
            else
                objList = cell(length(config), 1);
                keys = cell(length(config), 1);
                for k = 1:length(config)
                    className = config(k).class;
                    objList{k} = eval([className '.createFromConfig(config(k))']);
                end
            end
        end % createManagedObjs
        
    end % static methods
    
end % dataManager
