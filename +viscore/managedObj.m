% viscore.managedObj()   base class for keyed configuration objects
%
% Usage:
%    >>  viscore.managedObj(objectID, structure)
%    >>  obj = viscore.managedObj(objectID, structure)
%
% Description:
% viscore.managedObj(objectID, structure) creates an object that 
%     holds a structure and an ID. The objectID identifies this managed 
%     object. If objectID is empty, the internal unique ID is used. The 
%     structure holds the function, plot, and public property specifications. 
%
% obj = viscore.managedObj(objectID, structure) returns a handle to
%     the managed object.
%
% Example:
% Create a managed object with the default structure and empty values
%    m = viscore.managedObj([], []);
%
% Notes:  
% - managed objects have a unique integer InternalID that cannot be changed.
% - managed objects also have a user-settable ObjectID. If the user
%   does not set the ObjectID in the constructor, the managed object uses 
%    the string representation of the InternalID as the ObjectID.
%
% Class documentation:
% Execute the following in the MATLAB command window to view the class 
% documentation for viscore.managedObj:
%
%    doc viscore.managedObj
%
% See also: viscore.dataManager and viscore.dataSelector
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

% $Log: managedObj.m,v $
% Revision: 1.00  04-Dec-2011 09:11:20  krobbins $
% Initial version $
%

classdef managedObj < handle
    
    properties (Access = protected)
        ManStruct               % managed structure array with properties
        ObjectID                % string ID for identifying this object
    end % protected properties
    
    properties (Access = private)
        InternalID              % unique internal ID number for this object
    end
    
    methods
        
        function obj = managedObj(objectID, structure)
            % Create a managed object
            c = viscore.counter.getInstance();
            obj.InternalID = c.getNext();
            if isempty(objectID)
                obj.ObjectID = num2str(obj.InternalID);  % get a unique ID
            else
                obj.ObjectID = objectID;
            end
            requiredFields = eval([class(obj) '.getDefaultFields()']);
            obj.ManStruct = viscore.managedObj.createStruct( ...
                obj.ObjectID, requiredFields, structure);
        end % managedObj constructor
        
        function clonedObj = clone(obj)
            % Make clean copy of object keeping same ID and hash modifier
            clonedObj = eval([class(obj) '(obj.ObjectID, obj.ManStruct);']);
        end % clone

        function categories = getCategories(obj)
            % Get a cell array listing the Categories for this object
            categories =  {obj.ManStruct.Category};
        end % getCategories
        
        function c = getConfiguration(obj)
            % Return the configuration structure
            c.key = obj.getObjectID();
            c.class = class(obj);
            c.properties = obj.getStructure();
        end % getConfiguration
        
        function def = getDefinition(obj, k)
            % Return the definition in the kth structure of this object
            def = obj.ManStruct(k).Definition;
        end % getDefinition
        
        function definitions = getDefinitions(obj)
            % Get a cell array listing the definitions for this object
            definitions =  {obj.ManStruct.Definition};
        end % getDefinitions

        function displayNames = getDisplayNames(obj)
            % Get a cell array listing the display names for this object
            displayNames =  {obj.ManStruct.DisplayName};
        end % getDisplayNames
        
        function displayName = getDisplayName(obj, k)
            % Return the display name in the kth structure of this object
            displayName = obj.ManStruct(k).DisplayName;
        end % getDisplayName
        
        function fValues = getFieldValues(obj, fName)
            % Return a cell array of the values of the field fName
            if isempty(obj.ManStruct) || ~isfield(obj.ManStruct, fName)
                fValues = {};
            else
                fValues =  {obj.ManStruct.(fName)};
            end
        end % getFieldValues
        
        function internalID = getInternalID(obj)
            internalID = obj.InternalID;
        end 
        
        function nEnabled = getNumberEnabled(obj)
            % Returns the number substructures enabled
            enabled = {obj.ManStruct.Enabled};
            nEnabled = sum(cell2mat(enabled));
        end % getNumberEnabled
        
        function ID = getObjectID(obj)
            % Return the ID of this object
            ID = obj.ObjectID;
        end % getObjectID
        
        function pos = getPositionByFieldID(obj, fieldID)
            % Return positions of structures identified by fieldID
            IDs = {obj.ManStruct.ID};
            pos = find(strcmpi(IDs, fieldID));
        end % getPositionByFieldID
        
        function s = getStructure(obj)
            % Return the structure of this managed object
            s = obj.ManStruct;
        end % getStructure
        

        function value = getValue(obj, position, fieldName)
            % Return the value of a field in the structure at position pos
            if ~isempty(position)
                value = obj.ManStruct(position).(fieldName);
            else
                value = [];
            end
        end % getValue
        
        function value = getValueByFieldID(obj, fieldID, fieldName)
            % Return values of fieldName for structures identified by ID
            pos = obj.getPositionByFieldID(fieldID);
            value = obj.getValue(pos, fieldName);
        end % getValuesByField
               
        function printObject(obj)
            % Output the contents of this managed object in readable form
            fprintf('ObjectID: %s\n', obj.ObjectID);
            fieldNames = fieldnames(obj.ManStruct);
            numStrucs = length(obj.ManStruct);
            for k = 1:length(numStrucs)
                fprintf('[%d]: \n', k);
                viscore.managedObj.printStructure( ...
                    obj.ManStruct(k), fieldNames);
            end
        end % printObject

        function setObjectID(obj, ID)
            % Set the object ID to ID
            obj.ObjectID = ID;
        end % setObjectID
        
        function setStructure(obj, s)
            % Set the managed structure to s
            obj.ManStruct = s;
        end % setStructure
        
        function setValue(obj, position, fieldName, value)
            % Set the field of the structure in position to value
            if ~isempty(position)
                obj.ManStruct(position).(fieldName) = value;
            end
        end % setValue
        
        function value = setValueByFieldID(obj, fieldID, fieldName, value)
            % Set values of fieldName to value for structures named name
            pos = obj.getPositionByFieldID(fieldID);
            obj.setValue(pos, fieldName, value);
        end % setValuesByFieldID
        
    end % public methods
        
    methods (Static = true)
        
        function pls = cloneCellArray(s)
            % Clone the managed objects from cell array s,
            pls = [];
            if ~isa(s, 'cell')
                return;
            end
            tpls = cell(length(s), 1);
            pos = 0;
            for k = 1:length(s)
                if isa(s{k}, 'viscore.managedObj')
                    pos = pos + 1;
                    tpls{pos} = s{k}.clone();
                end
            end
            if pos > 0
                pls = tpls(1:pos);
            end
        end % cloneCellArray
     
        function s = createEmptyStruct(ID, fields)
            % Create empty managed structure with specified fields and ID
            s = struct();
            for k = 1:length(fields)
                s.(fields{k}) = [];
            end
            if ~isempty(ID)
                s.ID = ID;
            end
        end % createEmptyStruct
        
        function obj = createFromConfig(config)
            % Return managed object of appropriate class from configuration
            if isempty(config)
                obj = '';
            else
               key = config.key;
               className = config.class;
               properties = config.properties; %#ok<NASGU>
               obj = eval([className '(''' key ''', properties)']);
            end
        end % createFromConfig(config)
        
        function bfs = createObjects(className, s, keyfun)
            % Create cell array of managed objects from structure array or cell array
            %
            % Inputs:
            %    className       Class name of type of managed objet to create
            %    s               Input values (structure, cell array or empty)
            %
            % Outputs:
            %    bfs             Cell array of managed objects
            %
            % Notes:  
            %    -  If a cell array is passed in, only valid className
            %       objects are cloned
            %    -  The input should be a 1 dimensional array
            if isa(s, 'cell')   % See if cell array valid className objects
                bfs = cell(length(s), 1);
                count = 0;
                for k = 1:length(s)
                    if ~isa(s{k}, className)
                        continue;
                    end
                    count = count + 1;
                    bfs{count} = s{k}.clone();
                end
                if count > 0  % The input cell array contained valid objects
                    bfs = bfs(1:count);
                    return;
                end
                s = [];  % Force generation of defaults since invalid       
            end
            if isempty(s) || ~isa(s, 'struct')
                s = eval([className '.createEmptyStruct([], ' ...
                    className '.getDefaultFields());']);
            end
            bfs = cell(length(s), 1);
            for k = 1:length(s)        
                if ~isempty(keyfun)
                    key = keyfun(s(k)); %#ok<NASGU>
                else
                    key = []; %#ok<NASGU>
                end
                bfs{k} = eval([className '(key, s(k));']);
            end
        end % createObjects
        
        function bfs = createStruct(ID, fields, properties)
            % Create managed structure with specified fields, merging with property names
            if isempty(ID)
                c = viscore.counter.getInstance();
                ID = num2str(c.getNext());
            end
            if isempty(properties) || ~isa(properties, 'struct')
                bfs = viscore.managedObj.createEmptyStruct(ID, fields);
                return;
            end
            requiredFields = union(fields, fieldnames(properties));
            bfs(length(properties)) = ...
                viscore.managedObj.createEmptyStruct(ID, requiredFields);
            pFields = fieldnames(bfs);
            c = viscore.counter.getInstance();
            for k = 1:length(properties)
                for m = 1:length(pFields)
                    if isfield(properties(k), pFields{m})
                        bfs(k).(pFields{m}) = properties(k).(pFields{m});
                    end
                end
                if isempty(bfs(k).ID)
                    bfs(k).ID = num2str(c.getNext());
                end
            end
        end % createStruct
        
        function fields = getDefaultFields()
            % Return the default fields for the object
            fields = {'ID', 'Enabled', 'Category', 'DisplayName', ...
                'Definition', 'Description'};
        end % getDefaultFields
        
        function merged = mergeStructures(primary, replace, keyField)
            % Replace the primary structure with replace for items whose
            % fieldName value
            %
            % Inputs:
            %    primary     a structure
            %    replace     a structure
            %
            % Outputs:
            %    primary     original structure augmented by primary
            %
            % Notes:
            %   - All of the fields of both structures are included
            %   - If the two structures have a field in common, use replace
            merged = primary;
            if isempty(primary)
                merged = replace;
            elseif ~isempty(replace) % must actually merge
                primaryNames = {primary.(keyField)};
                replaceNames = {replace.(keyField)};
                pNames = unique(primaryNames);
                rNames = unique(replaceNames);
                if length(pNames)~= length(primaryNames) || ...
                        length(rNames) ~= length(replaceNames)
                    warning('managedObj:mergeStructures', ...
                        [keyField ' structure values must be unique']);
                    return;
                end
                for k = 1:length(replaceNames)
                    pos = find(strcmp(replaceNames{k}, primaryNames));
                    if isempty(pos)
                        pos = length(merged) + 1;
                    end
                    merged(pos) = replace(k);
                end
            end
        end % mergeStructures
        
        function printStructure(s, fieldNames)
            % Output values of fields of s to command window
            for k = 1:length(fieldNames)
                nextValue = s.(fieldNames{k});
                fprintf('\t%s:', fieldNames{k});
                if ischar(nextValue)
                    fprintf('\t%s\n', nextValue);
                elseif isnumeric(nextValue) || islogical(nextValue)
                    fprintf('\t%g', nextValue);
                    fprintf('\n');
                end
            end
        end % printStructure
        
    end % static methods
    
end % managedObj

