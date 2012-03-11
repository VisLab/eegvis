% visprops.colorProperty() property representing a single color 
%
% Usage:
%   >>  visprops.colorProperty(objectID, structure);
%   >>  obj = visprops.colorProperty(objectID, structure);
%
%
% Description:
% visprops.colorProperty(objectID, structure) create a new property
%         representing a single color. The value should be a 3-element row
%         vector of values in the interval [0, 1]. The objectID parameter
%          is the hash key associated with configurable owner of the 
%          property. The structure parameter is the structure specifying
%          the vector property as described in visprops.property.
%
%
% obj = visprops.colorProperty(...) returns a handle to a newly 
%         created color property.
%
% The visprops.colorProperty extends visprops.property.
%
% Example:
% Create a color property
%   settings = struct( ...
%                 'Enabled',       {true}, ...
%                 'Category',      {'Summary'}, ...
%                 'DisplayName',   {'Background color'}, ...
%                 'FieldName',     {'BackgroundColor'}, ... 
%                 'Value',         {[0.7, 0.7, 0.7]}, ...
%                 'Type',          {'visprops.colorProperty'}, ...
%                 'Editable',      {true}, ...
%                 'Options',       {''}, ...
%                 'Description',   {'Background image color'} ...
%                                   );
%   bm = visprops.colorProperty([], settings);
%  
% Class documentation:
% Execute the following in the MATLAB command window to view the class 
% documentation for visprops.colorProperty:
%
%    doc visprops.colorProperty
%
% See also:  visprops.property and visprops.colorListProperty
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

% $Log: colorProperty.m,v $
% Revision: 1.00  04-Dec-2011 09:11:20  krobbins $
% Initial version $
%

classdef colorProperty < visprops.property
    
    properties (Access = private)
        EditorContext;           % context for color editor for property
    end % private properties
    
    methods
        
        function obj = colorProperty(objectID, structure)
            % Create a color property
            obj = obj@visprops.property(objectID, structure);
        end % colorProperty constructor
        
        function [jValue, valid, msg] =  convertValueToJIDE(obj, mValue)   
            % Convert Matlab value of this property into its Java equivalent
            try
                if isempty(mValue) || ~isnumeric(mValue) ||  ...
                        size(mValue, 1) ~= 1 || size(mValue, 2) ~= 3 || ...
                        sum(mValue < 0) ~= 0 || sum(mValue > 1) ~= 0
                    throw(obj.getException('convertValueToMATLAB', ...
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
            [jvalue, valid, msg] =  convertValueToJIDE(obj, value);
            if ~valid
                throw(obj.getException('createJIDEProperty', msg));
            end
              c = viscore.counter.getInstance();
            ID = ['colorcelleditor' num2str(c.getNext())];  % Get a unique ID
            editor = com.jidesoft.grid.ColorCellEditor();
            obj.EditorContext = com.jidesoft.grid.EditorContext(ID);
            com.jidesoft.grid.CellEditorManager.registerEditor( ...
                obj.getJavaType(), editor, obj.EditorContext);
            prop = com.jidesoft.grid.DefaultProperty();
            set(prop, 'Category', setting.Category, ...
                'Description', setting.Description, ...
                'DisplayName', setting.DisplayName, ...
                'Name', name, 'Value', jvalue, ...
                'EditorContext', obj.EditorContext);
            prop.setType(obj.getJavaType());
            prop.setEditable(setting.Editable);
        end % createJIDEProperty
        
        function delete(obj)
            % Unregister editors when this object is deleted
            com.jidesoft.grid.CellEditorManager.unregisterEditor( ...
                obj.getJavaType(), obj.EditorContext);
        end % delete
        
    end % public methods
        
    methods (Static = true)  

        function javatype = getJavaType() 
            % Return the Java type of this property
            javatype = visprops.javaclass('colormap');
        end % getJavaType
        
        function pType = getPropertyType() 
            % Return the class type of this property
            pType = 'visprops.colorProperty';
        end % getPropertyType

    end % static methods
    
end % colorProperty




