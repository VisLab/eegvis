% visprops.colorListProperty property representing a list of colors 
%
% Usage:
%   >>  visprops.colorListProperty(objectID, structure);
%   >>  obj = visprops.colorListProperty(objectID, structure);
%
% Description:
% visprops.colorListProperty(objectID, structure) create a new property
%      representing a list of colors. The value should be an n x 3 
%      array of values in the interval [0, 1]. The objectID parameter
%      is the hash key associated with configurable owner of the 
%      property. The structure parameter is the structure specifying
%      the vector property as described in visprops.property.
%
%
% obj = visprops.colorlistProperty(...) returns a handle to a newly 
%        created color list property.
%
% The visprops.colorListProperty extends visprops.property.
%
% Example:
% Create a color property
%   settings = struct( ...
%                 'Enabled',       {true}, ...
%                 'Category',      {'Summary'}, ...
%                 'DisplayName',   {'Box colors'}, ...
%                 'FieldName',     {'BoxColors'}, ... 
%                 'Value',         {[0.7, 0.7, 0.7; 1, 0, 1]}, ...
%                 'Type',          {'visprops.colorListProperty'}, ...
%                 'Editable',      {true}, ...
%                 'Options',       {''}, ...                 
%                 'Description',   {'Alternating box colors for box plot'} ...
%                                   );
%   bm = visprops.colorListProperty([], settings);
%  
% Class documentation:
% Execute the following in the MATLAB command window to view the class 
% documentation for visprops.colorListProperty:
%
%    doc visprops.colorListProperty
%
% See also: visprops.colorProperty and visprops.property
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

% $Log: colorListProperty.m,v $
% Revision: 1.00  04-Dec-2011 09:11:20  krobbins $
% Initial version $
%

classdef colorListProperty < visprops.property
    
    properties (Access = private)
        EditorContext;           % context for color editor for property
    end % private properties
    
    methods
        
        function obj = colorListProperty(objectID, structure)
            % Create a color list property
            obj = obj@visprops.property(objectID, structure);
        end % colorListProperty constructor
        
        function [jValue, valid, msg] =  convertValueToJIDE(obj, mValue)   
           % Convert Matlab value of this property into its Java equivalent
            try
                if isempty(mValue) || ~isnumeric(mValue) ||  ...
                        size(mValue, 2) ~= 3 || ...
                        sum(mValue(:) < 0) ~= 0 || sum(mValue(:) > 1) ~= 0
                    throw(obj.getException('convertValueToJIDE', ...
                                           'Invalid MATLAB color'));
                end
                jValue = java.awt.Color(mValue(1), mValue(2), mValue(3));
                valid = true;
                msg = '';
            catch ME
                jValue = '';
                valid = false;
                msg = ['[' ME.identifier '] ' ME.message];
            end
        end % convertValueToJIDE
        
        function [mValue, valid, msg] = convertValueToMATLAB(obj, jValue) %#ok<MANU>
            % Convert a JIDE value to MATLAB
            try
                mValue = [jValue.getRed(), jValue.getGreen(), jValue.getBlue()]/255;
                valid = true;
                msg = '';
            catch ME
                mValue = [];
                valid = false;
                msg = ['[' ME.identifier ': ' ME.message ']: attempt to convert invalid java.awt color'];
            end
        end % convertValueToMATLAB
        
        function prop = createJIDEProperty(obj, setting)
            % Create a JIDEProperty from a setting structure 
            com.mathworks.mwswing.MJUtilities.initJIDE;
            name = obj.getStandardName(setting);
            value = setting.Value;  
            prop = com.jidesoft.grid.DefaultProperty();
            set(prop, 'Category', setting.Category, ...
                'Description', setting.Description, ...
                'DisplayName', setting.DisplayName, ...
                'Name', name);
            prop.setEditable(false);            
            c = viscore.counter.getInstance();
            ID = ['colorcelleditor' num2str(c.getNext())];  % Get a unique ID
            editor = com.jidesoft.grid.ColorCellEditor();
            obj.EditorContext = com.jidesoft.grid.EditorContext(ID);
            com.jidesoft.grid.CellEditorManager.registerEditor( ...
                obj.getJavaType(), editor, obj.EditorContext);
            numColors = size(value, 1);
            for k = 1:numColors
                 [jvalue, valid, msg] =  convertValueToJIDE(obj, value(k, :));
                 if ~valid
                     throw(obj.getException(msg));
                 end
                propColor = com.jidesoft.grid.DefaultProperty();
                set(propColor, 'Category', setting.Category, ...
                    'Description', setting.Description, ...
                    'DisplayName', [setting.DisplayName ':' num2str(k)], ...
                    'Name', num2str(k), 'Value', jvalue, ...
                    'EditorContext', obj.EditorContext);
                propColor.setType(obj.getJavaType());
                propColor.setEditable(setting.Editable);
                prop.addChild(propColor);
            end
        end % createJIDEProperty
        
        function delete(obj)
            % Cleanup registered editors when this object is deleted
            com.jidesoft.grid.CellEditorManager.unregisterEditor( ...
                obj.getJavaType(), obj.EditorContext);
        end % delete
        
        function [jProp, pos] = getJIDEPropertyByName(obj, name)
            % Return a JIDE child property based on its full name
            if strcmp(obj.JIDEProperty.getFullName(), name)
                jProp = obj.JIDEProperty;
                pos = 0;
                return;
            end
            children = obj.JIDEProperty.getChildren;
            for k = 1:children.size();
                jProp = children.get(k-1);
                if strcmp(jProp.getFullName(), name) == 1 
                    pos = k;
                    return;
                end
            end
            pos = -1;
        end % getJIDEPropertyByName
        
        function valid = setCurrentValue(obj, mValue)
            % Set CurrentValue and JIDEValue to mValue if valid
            [jvalue, valid] = convertValueToJIDE(obj, mValue);
            if valid
                children = obj.JIDEProperty.getChildren();
                set(children.get(0), 'Value', jvalue(1));
                set(children.get(1), 'Value', jvalue(2));
                obj.CurrentValue = mValue;
            end
        end % setCurrentValue
        
        function valid = validateAndSetFromJIDE(obj, name, jValue)
            % Set current value to jValue if its valid  
            [jProp, pos] = obj.getJIDEPropertyByName(name); 
            [mValue, valid, msg] = obj.convertValueToMATLAB(jValue); %#ok<NASGU>
            if valid && ~isempty(pos)
                obj.CurrentValue(pos, :) = mValue;
                return;
            end
            
            % Current the value the other way for checking             
            [jValue, valid, msg] = obj.convertValueToJIDE(...
                                    obj.CurrentValue(pos, :)); %#ok<NASGU>
            if valid
                set(jProp, 'Value', jValue);
            end
        end % validateAndSetFromJIDE
        
    end % public methods
    
    methods (Static = true)
        
        function javatype = getJavaType()
            % Return the Java type of this property
            javatype = visprops.javaclass('colormap');
        end % getJavaType
        
        function pType = getPropertyType()
            % Return the class type of this property
            pType = 'visprops.colorListProperty';
        end % getPropertyType
        
    end % static methods
    
end % ColorProperty
    
    
