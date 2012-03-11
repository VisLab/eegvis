% visprops.enumeratedProperty property representing a string selected from a list of valid values
%
% Usage:
%   >>  visprops.enumeratedProperty(objectID, structure);
%   >>  obj = visprops.enumeratedProperty(objectID, structure);
%
% Description:
% visprops.enumeratedProperty(objectID, structure) create a new property
%       representing a string from a list of valid values. The objectID
%       parameter is the hash key associated with configurable owner of the 
%       property. The structure parameter is the structure specifying
%       the vector property as described in visprops.property.
%
%
% obj = visprops.enumeratedProperty(...) returns a handle to a newly 
%       created enumerated property.
%
% The visprops.enumeratedProperty extends visprops.property.
%
% Example:
% Create an enumerated property
%   settings = struct( ...
%                 'Enabled',       {true}, ...
%                 'Category',      {'Summary'}, ...
%                 'DisplayName',   {'Window type'}, ...
%                 'FieldName',     {'WindowType'}, ... 
%                 'Value',         {'Blocked'}, ...
%                 'Type',          {'visprops.enumeratedProperty'}, ...
%                 'Editable',      {true}, ...
%                 'Options',       {{'Blocked', 'Epoched'}}, ...
%                 'Description',   {'Type of window used in computation'} ...
%                                   );
%   bm = visprops.enumeratedProperty([], settings);
%  
% Class documentation:
% Execute the following in the MATLAB command window to view the class 
% documentation for visprops.enumeratedProperty:
%
%    doc visprops.enumeratedProperty
%
% See also: visprops.property
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

% $Log: enumeratedProperty.m,v $
% Revision: 1.00  04-Dec-2011 09:11:20  krobbins $
% Initial version $
%

classdef enumeratedProperty < visprops.property
    
    properties (Access = private)
        EditorContext;           % context for combo box editor for property
        ValidNames;              % valid names in the combo box       
    end % private properties
    
    methods
        
        function obj = enumeratedProperty(objectID, structure)
            % Create a property for an enumerated type
            obj = obj@visprops.property(objectID, structure);
        end % enumeratedProperty constructor
        
        function [jValue, valid, msg] = convertValueToJIDE(obj, mValue)
            % Convert a matlab value to a JIDE value
            try 
                if ischar(mValue) && sum(strcmp(obj.ValidNames, mValue)) > 0
                    valid = true;
                    jValue = char(mValue);
                    msg = '';
                else
                    throw(MException( ...
                        obj.getException('convertValueToJIDE',  ...
                                         ' value not a valid name')));
                end
            catch ME
                jValue = '';
                valid = false;
                msg = ['[' ME.identifier '] ' ME.message];
            end
        end % convertValueToJIDE
        
        function prop = createJIDEProperty(obj, settings)
            % Create a JIDEProperty from a setting structure
            com.mathworks.mwswing.MJUtilities.initJIDE;
            name = obj.getStandardName(settings);
            value = settings.Value;
            [jValue, valid, msg] =  convertValueToJIDE(obj, value);
            if ~valid
                throw(obj.getException('createJIDEProperty', msg));
            end
            c = viscore.counter.getInstance();
            ID = ['comboboxeditor' num2str(c.getNext())];  % Get a unique ID
            editor = com.jidesoft.grid.ListComboBoxCellEditor(obj.ValidNames);
            obj.EditorContext = com.jidesoft.grid.EditorContext(ID);
            com.jidesoft.grid.CellEditorManager.registerEditor( ...
                       obj.getJavaType(), editor, obj.EditorContext);
            prop = com.jidesoft.grid.DefaultProperty();
            set(prop, 'Category', settings.Category, ...
                'Description', settings.Description, ...
                'DisplayName', settings.DisplayName, ...
                'Name', name, 'Value', jValue, ...
                'EditorContext', obj.EditorContext);
            prop.setType(obj.getJavaType());
            prop.setEditable(settings.Editable);
        end % createJIDEProperty
        
        function delete(obj)
            % Unregister editors when this object is deleted
            com.jidesoft.grid.CellEditorManager.unregisterEditor( ...
                obj.getJavaType(), obj.EditorContext);
        end % delete
                     
        function setting = getPropertyStructure(obj)
            % Return a structure extracted from JIDE properties
            setting = obj.getPropertyStructure@visprops.property();
            setting.Options = obj.ValidNames;
        end % getPropertyStructure
        
        function [isvalid, msg] = processOptions(obj)
            % Check the of the validity options and process as necessary
            isvalid = true;
            msg = '';
            if ~isfield(obj.ManStruct, 'Options') || ...
                    isempty(obj.ManStruct.Options) || ...
                    ~iscellstr(obj.ManStruct.Options)
                isvalid = false;
                msg = 'Options must be a cell array of valid strings';
            else
                obj.ValidNames = obj.ManStruct(1).Options;
            end
        end % processOptions
        
    end % public methods
    
    methods (Static = true)
        
        function javatype = getJavaType()
            % Return the Java type of this property
            javatype = visprops.javaclass('char', 1);
        end % getJavaType
        
        function pType = getPropertyType()
            % Return the class type of this property
            pType = 'visprops.enumeratedProperty';
        end % getPropertyType
    
    end % static methods
    
end % enumeratedProperty


