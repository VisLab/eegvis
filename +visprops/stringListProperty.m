% visprops.stringListProperty  property representing a cell array of strings
%
% Usage:
%   >>  visprops.stringListProperty(objectID, structure);
%   >>  obj = visprops.stringListProperty(objectID, structure);
%
% Description:
% visprops.stringListProperty(objectID, structure) create a new property
%        representing a cell array of strings. The objectID parameter is 
%        the hash key associated with configurable owner of the property. 
%        The structure parameter is the structure specifying the vector 
%        property as described in visprops.property.
%
% obj = visprops.stringlistProperty(...) returns a handle to a newly 
%        created string list property.
%
% The visprops.stringListProperty extends visprops.property.
%
% Example:
% Create a string list.
%   settings = struct( ...
%                 'Enabled',       {true}, ...
%                 'Category',      {'Summary'}, ...
%                 'DisplayName',   {'Body parts'}, ...
%                 'FieldName',     {'NameList'}, ... 
%                 'Value',         {{'Eyes', 'Ears', 'Nose', 'Throat'}}, ...
%                 'Type',          {'visprops.stringListProperty'}, ...
%                 'Editable',      {true}, ...
%                 'Options',       {''}, ...
%                 'Description',   {'List of parts'} ...
%                                   );
%   bm = visprops.stringListProperty([], settings);
%  
% Class documentation:
% Execute the following in the MATLAB command window to view the class 
% documentation for visprops.stringListProperty:
%
%    doc visprops.stringListProperty
%
% See also: visprops.property and visprops.stringProperty
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

% $Log: stringListProperty.m,v $
% Revision: 1.00  04-Dec-2011 09:11:20  krobbins $
% Initial version $
%

classdef stringListProperty < visprops.property
    
    methods
        
        function obj = stringListProperty(objectID, structure)
            % Create configurable object representing cell array of strings
            obj = obj@visprops.property(objectID, structure);
        end % stringListProperty constructor
        
        function [jValue, isvalid, msg] = convertValueToJIDE(obj, mValue)  
            % Convert a MATLAB value to a JIDE value
            try
                if isempty(mValue) || ~isa(mValue, 'cell')
                    throw(obj.getException('convertValueToJIDE', ...
                                           'Value isn''t numeric'));
                else
                    for k = 1:length(mValue)
                        if ~isa(mValue{k}, 'char')
                            throw(obj.getException('convertValueToJIDE', ...
                            ['Value ' num2str(k) ' must be an interval']));
                        end
                    end
                end
                jValue = mValue; 
                isvalid = true;
                msg = '';
            catch ME
                jValue = [];
                isvalid = false;
                msg = ['[' ME.identifier '] ' ME.message];
            end
        end % convertValueToJIDE
        
        function [mValue, isvalid, msg] = convertValueToMATLAB(obj, jValue) 
            % Converts a JIDE value to single MATLAB value
            [mValue, isvalid, msg] = convertValueToJIDE(obj, jValue);
        end % convertValueToMATLAB
        
        function prop = createJIDEProperty(obj, setting)
            % Create a JIDEProperty from a setting structure
            com.mathworks.mwswing.MJUtilities.initJIDE;
            name = obj.getStandardName(setting);
            value = setting.Value;
            [jValue, valid, msg] =  convertValueToJIDE(obj, value);
            if ~valid
                throw(obj.getException('createJIDEProperty', msg));
            end
            prop = com.jidesoft.grid.DefaultProperty();
            set(prop, 'Category', setting.Category, ...
                'Description', setting.Description, ...
                'DisplayName', setting.DisplayName, ...
                'Name', name);
            prop.setEditable(false);            
            % Add each item as an element in the list
            for k = 1:length(jValue)
               next = com.jidesoft.grid.DefaultProperty();
               set(next, 'Category', setting.Category, ...
                'Description', [setting.Description ': element ' num2str(k)], ...
                'DisplayName', ['Element ' num2str(k)], ...
                'Name', num2str(k), 'Value', jValue{k});
                next.setType(obj.getJavaType());
                next.setEditable(setting.Editable);
                prop.addChild(next);
            end
        end % createJIDEProperty
        
        function [jProp, pos] = getJIDEPropertyByName(obj, name)
            % Return the correct child property based on its name
            try
                baseName = obj.getFullName();
                children = obj.JIDEProperty.getChildren;
                if strcmp(baseName, name) == 1 
                    jProp = obj.JIDEProperty;
                    pos = 0;
                else
                   childName = name(length(baseName) + 2:end);
                   pos = uint32(str2double(childName));
                   jProp = children.get(pos);
                end
            catch  %#ok<CTCH>
               jProp = [];
               pos = -1;
            end
        end % getJIDEPropertyByName
        
        function valid = setCurrentValue(obj, mValue)
            % Set CurrentValue JIDEValue to mValue if valid
            [jValue, valid] = convertValueToJIDE(obj, mValue);
            if ~valid
                return;
            end
            children = obj.JIDEProperty.getChildren();
            if children.size() ~= length(jValue)
                valid = false;
                return;
            end
            for k = 1:length(jValue)
              next = children.get(k-1);
              next.setValue(jValue{k});
            end
            obj.CurrentValue = mValue;
        end % setCurrentValue
                  
        function valid = validateAndSetFromJIDE(obj, name, newValue)
            % Set current value to newValue if newValue is valid
            try
                if isempty(newValue)
                    throw(MException('List cannot be empty'));
                end
                [jProp, pos] = obj.getJIDEPropertyByName(char(name));
                jValue = obj.CurrentValue();
                jValue{pos} = newValue;                
                [mValue, valid, msg] = obj.convertValueToMATLAB(jValue); %#ok<NASGU>
                if valid
                    obj.CurrentValue = mValue;
                    return;
                end
                [jValue, valid, msg] = obj.convertValueToJIDE(obj.CurrentValue); %#ok<NASGU>
                if valid
                    set(jProp, 'Value', jValue{pos});
                end
            catch ME %#ok<NASGU>
                valid = false;
            end
        end % validateAndSetFromJIDE
        
    end % public methods
    
    methods (Static = true)
        
        function javatype = getJavaType()
            % Return the Java type of this property
            javatype = visprops.javaclass('char', 1);
        end % getJavaType
        
        function pType = getPropertyType()
            % Return the class type of this property
            pType = 'visprops.stringListProperty';
        end % getPropertyType
    
    end % static methods
    
end % stringListProperty


