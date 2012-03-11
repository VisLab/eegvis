% visprops.property  base class for a value managed by propertyConfig GUI
%
% Usage:
%   >>  visprops.property(objectID, structure);
%   >>  obj = visprops.property(objectID, structure);
%
% Description:
% visprops.property(objectID, structure) creates a configurable property
%        which provides holds a current MATLAB value, an original MATLAB
%        value and provides methods to map between MATLAB values and Java
%        JIDE values. The objectID parameter is the hash key associated 
%        with configurable owner of the property. The structure parameter 
%        is the structure specifying the vector property as described
%        in visprops.property.
%
% obj = visprops.property(objectID, structure) returns a handle to the
%        newly created property.
%
% An object allows some of its public properties to be configurable must
% provide a static getDefaultProperties method that returns a structure
% array with one entry for each configurable property. The fields of
% the structure array are:
%
%     Enabled          indicates whether property displays in GUI
%
%     Category         category for this property in the GUI
%
%     DisplayName      display name of property in the GUI
%
%     FieldName        name of the public property to be set in owner
%
%     Type             type of property object
%
%     Value            MATLAB property to be assigned
%
%     Editable         true if this property can be edited in the GUI
%
%     Options          optional parameters for type of property
%
%     Description      String appearing at bottom of property
%                       configuration window when item is selected
%
% Notes:
%  - This class is meant to be used as a base class and not called directly
%  - A property is a managedObj
%
% The JIDE properties mapped by property are components
% of the Java Grid Framework provided by JideSoft. This framework is
% distributed as part of MATLAB and used for its property manager.
% Further information about the framework can be found in the
% http://www.jidesoft.com/products/JIDE_Grids_Developer_Guide.pdf
% and in http://www.jidesoft.com/javadoc/.
%
% Class documentation:
% Execute the following in the MATLAB command window to view the class 
% documentation for visprops.property:
%
%    doc visprops.property
%
% See also: viscore.managedObj, visprops.propertyConfig,
%           visprops.configurable, and visprops.configurableObj

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

% $Log: property.m,v $
% Revision: 1.00  04-Dec-2011 09:11:20  krobbins $
% Initial version $
%

classdef property < handle & viscore.managedObj
    
    properties
        CurrentValue        % current MATLAB value of property
        Field               % field name for this property
        Key                 % hash key to find property's configurable object
        OriginalValue       % original MATLAB value of the property                
    end % public properties 
    
    properties (Constant = true)
        Tolerance = 1E-12;  % tolerance for testing equality of doubles
    end % constant properties
    
    properties(Access = protected)
        JIDEProperty        % cell with one(JIDEprop, name, MATLAB value) structure
    end % protected properties 
    
    methods      
        
        function obj = property(objectID, structure)
            % Create a property from a property structure for objectID
            obj = obj@viscore.managedObj(objectID, structure);
            [valid, msg] = obj.processOptions();
            if ~valid
                throw(getException(obj, 'property', msg));
            end  
            [jValue, valid, msg] = obj.convertValueToJIDE(structure.Value); %#ok<ASGLU>
            if ~valid
                throw(getException(obj, 'property', msg));
            end
            obj.CurrentValue = structure.Value;
            obj.OriginalValue = structure.Value;
            obj.Field = structure.FieldName;
            com.mathworks.mwswing.MJUtilities.initJIDE;
            obj.JIDEProperty = obj.createJIDEProperty(structure);
        end % property constructor
        
        function [jValue, valid, msg] = convertValueToJIDE(obj, mValue) %#ok<MANU>
            % Convert a MATLAB value to a valid JIDE value
            jValue = mValue;
            if isempty(mValue)
               valid = false;
               msg = 'Value cannot be empty';
            else
               valid = true;
               msg = '';
            end
        end % convertValueToJIDE
        
        function [mValue, valid, msg] = convertValueToMATLAB(obj, jValue) %#ok<MANU>
            % Convert a JIDE value to MATLAB
            mValue = jValue;
            if isempty(mValue)
               valid = false;
               msg = 'Value cannot be empty';
            else
               valid = true;
               msg = '';
            end
        end % convertValueToMATLAB

        function prop = createJIDEProperty(obj, setting)
            % Create a JIDEProperty from a setting structure
            name = obj.getStandardName(setting);
            value = setting.Value;
            [jvalue, valid, msg] =  convertValueToJIDE(obj, value);
            if ~valid
                throw(obj.getException('createJIDEProperty', msg));
            end
            prop = com.jidesoft.grid.DefaultProperty();
            set(prop, 'Category', setting.Category, ...
                'Description', setting.Description, ...
                'DisplayName', setting.DisplayName, ...
                'Name', name, 'Value', jvalue);
            prop.setType(obj.getJavaType());
            prop.setEditable(setting.Editable);
        end % createJIDEProperty
        
        function me = getException(obj, fName, msg)
            % Return an informative exception based on msg
            classNames = regexp(class(obj), '\.', 'split');
            me = MException(char([classNames{end} ':' fName]), msg);
        end % getException
        
        function name = getFullName(obj)
            % Return the JIDE full name of the property
            name = char(obj.JIDEProperty.getFullName());
        end % getFullName  
        
        function names = getFullNames(obj)
            % Return full JIDE names of this property and its children
            numChildren = obj.JIDEProperty.getChildrenCount();
            names = cell(numChildren + 1, 1);
            names{1} = char(obj.JIDEProperty.getFullName());
            children = obj.JIDEProperty.getChildren();
            if numChildren > 0
                for k = 1:numChildren
                    child = children.get(k-1);
                    names{k + 1} = char(child.getFullName());
                end
            end
        end % getFullNames
        
        function jProp = getJIDEProperty(obj)
            % Return the JIDE property
            jProp = obj.JIDEProperty;
        end % getJIDEProperty
        
        function [jProp, pos] = getJIDEPropertyByName(obj, name)
            % Return the JIDE property and position based on its name
            if strcmp(obj.JIDEProperty.getFullName(), name) == 1 
                jProp = obj.JIDEProperty;
                pos = 0;
            else
                jProp = [];
                pos = -1;
            end
        end % getJIDEPropertyByName
              
        function setting = getPropertyStructure(obj)
            % Return a structure reflecting this JIDE property
            sfields = regexp(char(obj.JIDEProperty.getFullName()), '/', 'split');
            setting = visprops.property.getDefaults();
            setting.FieldName = sfields{3};
            setting.Category = get(obj.JIDEProperty, 'Category');
            setting.DisplayName = get(obj.JIDEProperty, 'DisplayName');
            setting.Type = obj.getPropertyType();
            setting.Value = obj.CurrentValue;
            setting.Editable = obj.JIDEProperty.isEditable();
            setting.Options = '';
            setting.Description = get(obj.JIDEProperty, 'Description');
        end % getPropertyStructure
        
        function name = getStandardName(obj, setting)
            % Return name of the object as used in the map
            name = [setting.Category '/' obj.getObjectID() '/' ...
                setting.FieldName '/'];
        end % getStandardName
        
        function [valid, msg] = processOptions(obj)  %#ok<MANU>
            % Process Options field, indicating validity public to override
            valid = true;
            msg = '';
        end % processOptions
        
        function valid = setCurrentValue(obj, mValue)
            % Set CurrentValue and JIDEValue to mValue if valid
            [jvalue, valid] = convertValueToJIDE(obj, mValue);
            if valid
                set(obj.JIDEProperty, 'Value', jvalue);
                obj.CurrentValue = mValue;
            end
        end % setCurrentValue
        
        function valid = validateAndSetFromJIDE(obj, name, jValue) %#ok<INUSL>
            % Set current value to newValue if newValue is valid JIDE value
            [mValue, valid, msg] = obj.convertValueToMATLAB(jValue); %#ok<NASGU>
            if valid
                obj.CurrentValue = mValue;
                return;
            end
            [jValue, valid, msg] = obj.convertValueToJIDE(obj.CurrentValue); %#ok<NASGU>
            if valid
                set(obj.JIDEProperty, 'Value', jValue);
            end
        end % validateAndSetFromJIDE
        
    end % public methods
    
    methods(Static = true)
        
        function bfs = createObjects(s)
            % Return property cell array corresponding to structure s
            if isempty(s)
                s = visprops.property.getDefaults();
            end
            bfs = cell(length(s));
            for k = 1:length(s)
                bfs{k} = visprops.property([], s(k) );
            end
        end % createObjects 
        
        function pStruct = getDefaults()
            % Field name, class name, class modifier, display name, type, default, options,
            % descriptions
            pStruct = struct( ...
                'Enabled',        {true}, ...
                'Category',       {'Class'}, ...
                'DisplayName',    {'Example setting'}, ...
                'FieldName',      {'Example'}, ...
                'Value',          {'Set me to something'}, ...
                'Type',           {'visprops.stringProperty'}, ...
                'Editable',       {true}, ...
                'Options',        {''}, ...
                'Description',    {'Example setting -- make Example a property' ...
                });
        end % getDefaults
        
        function fields = getDefaultFields()
            % Default fields are the ones that  are configured.
            fields = viscore.managedObj.getDefaultFields();
            fields = [fields{:}, ...
                {'FieldName', 'Value', 'Type', 'Editable', 'Options'}];
        end % getDefaultFields
        
        function javatype = getJavaType()
            % Return the Java type of this property
            javatype = visprops.javaclass('char');
        end % getJavaType
        
        function pType = getPropertyType()
            % Return the type of this property
            pType = 'visprops.property';
        end % getPropertyType
        
        function s = getProperties(obj)
            % Get a structure containing configurable properties
            s = eval([class(obj) '.getDefaultProperties()']); 
            if isempty(s)
                return;
            end
            p = properties(obj);  % Find the names of the public properties
            for k = 1:length(s)
                fieldName = s(k).FieldName;
                inx = find(strcmp(p, fieldName), 1, 'first');
                if inx == 0
                    continue;
                end
                s(k).Value = obj.(fieldName);
            end
        end % getProperties
        
        function obj = loadobj(obj)
            % Load this object from a file
            if isstruct(obj) && isfield(obj, 'structure') && ...
                    isfield(obj, 'objectID') && isfield(obj, 'className')
                newObj = eval([obj.className '(' obj.objectID ',' obj.structure ')']);
                obj = newObj;
            end
        end %loadobj
        
        function obj = saveobj(obj)
            % Save this property object for a file
            s.structure = obj.getStructure();
            s.objectID = obj.getObjectID();
            s.className = class(obj);
            obj = s;
        end % saveobj
        
        function setProperties(obj, s)
            % Set object's public fields from structure s
            if ~isa(s, 'struct') || ...
                ~isfield(s, 'FieldName') || ~isfield(s, 'Value')
                return;
            end
            p = properties(obj);  % Find the names of the public properties
            for k = 1:length(s)
                fieldName = s(k).FieldName;
                inx = find(strcmp(p, fieldName), 1, 'first');
                if isempty(inx) || inx == 0
                    continue;
                end
                obj.(fieldName) = s(k).Value; 
            end
        end % setProperties
        
        function updateProperties(obj, man)
            % Update an object's public fields from property manager man
            if ~isa(man, 'viscore.dataManager') || ...
                               ~isa(obj, 'visprops.configurable')
                return;
            end
            % Get the object settings based on the object ID
            mySettings = man.getObject(getObjectID(obj));
            if ~isempty(mySettings)
                s = mySettings.getStructure();
                visprops.property.setProperties(obj, s);
            end
        end % updateProperties
        
    end % static methods
    
end % property


