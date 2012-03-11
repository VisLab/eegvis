% visprops.logicalProperty  property representing a logical (boolean) value
%
% Usage:
%   >>  visprops.LogicalPProperty(objectID, structure);
%   >>  obj = visprops.logicalProperty(objectID, structure);
%
% Description:
% visprops.logicalProperty(objectID, structure)  create a new property
%        representing a logical value (true or false). The objectID 
%        parameter is the hash key associated with configurable owner of the 
%        property. The structure parameter is the structure specifying
%        the vector property as described in visprops.property.
%
%   obj = visprops.logicalProperty(...) returns a handle to a newly 
%        created logical property.
%
% The visprops.logicalProperty extends visprops.property.
%
% Example:
% Create a logical property
%   settings = struct( ...
%                 'Enabled',       {true}, ...
%                 'Category',      {'Summary'}, ...
%                 'DisplayName',   {'Show mean'}, ...
%                 'FieldName',     {'ShowMean'}, ... 
%                 'Value',         {true}, ...
%                 'Type',          {'visprops.logicalProperty'}, ...
%                 'Editable',      {true}, ...
%                 'Options',       {''}, ...
%                 'Description',   {'Flag indicate whether mean should be displayed'} ...
%                                   );
%   bm = visprops.logicalProperty([], settings);
%  
% Class documentation:
% Execute the following in the MATLAB command window to view the class 
% documentation for visprops.logicalProperty:
%
%    doc visprops.logicalProperty
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

% $Log: logicalProperty.m,v $
% Revision: 1.00  04-Dec-2011 09:11:20  krobbins $
% Initial version $
%

classdef logicalProperty < visprops.property
    
    properties (Access = private)
        EditorContext;           % context for logical values for property
        ValidNames = {'true', 'false'};  % names for underlying enumerated type
    end % private properties
    
    methods
        
        function obj = logicalProperty(objectID, structure)
            % Create a configurable property corresponding to a boolean value
            obj = obj@visprops.property(objectID, structure);
        end % logicalProperty constructor
        
        function [jValue, valid, msg] = convertValueToJIDE(obj, mValue) 
            % Convert a matlab value to a JIDE value
            try
                if isempty(mValue)
                    throw(obj.getException('convertValueToJIDE', ...
                                          'logical value can''t be empty'));
                end
                if ~isa(mValue, 'logical')
                    throw(obj.getException('convertValueToJIDE', ...
                                           'value must be logical'));
                elseif mValue == true;
                    jValue = 'true';
                elseif mValue == false;
                    jValue = 'false';
                else
                    throw(obj.getException('convertValueToJIDE', ...
                                          'invalid logical value'));
                end
                valid = true;
                msg = '';
            catch ME
                jValue = '';
                valid = false;
                msg = ['[' ME.identifier '] ' ME.message];
            end
        end % convertValueToJIDE
        
        function [mValue, valid, msg] = convertValueToMATLAB(obj, jValue) 
            % Convert a JIDE value to a matlab value
            try
                if isempty(jValue) || ~ischar(jValue)
                    throw(obj.getException('convertValueToMATLAB', ...
                                           'logical value can''t be empty'));
                end
                if strcmpi(jValue, 'true') == 1
                    mValue = true;
                elseif strcmpi(jValue, 'false') == 1
                    mValue = false;
                else
                    throw(obj.getException('convertValueToMATLAB', ...
                                           'invalid logical value'));
                end
                valid = true;
                msg = '';
            catch ME
                mValue = '';
                valid = false;
                msg = ['[' ME.identifier '] ' ME.message];
            end
        end % convertValueToMATLAB
        
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
            ID = ['colorcelleditor' num2str(c.getNext())];  % Get a unique ID
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
        
        function setting = getPropertyStructure(obj)
            % Return a structure extracted from JIDE properties
            setting = obj.getPropertyStructure@visprops.property();
            setting.Options = obj.ValidNames;
        end % getPropertyStructure
        
    end % public methods
    
    methods (Static = true)
        
        function javatype = getJavaType()
            % Return the Java type of this property
            javatype = visprops.javaclass('char', 1);
        end % getJavaType
        
        function pType = getPropertyType()
            % Return the class type of this property
            pType = 'visprops.logicalProperty';
        end % getPropertyType
    
    end % static methods
    
end % logicalProperty


