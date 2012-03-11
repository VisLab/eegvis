% visprops.intervalProperty property representing a real interval
%
% Usage:
%   >>  visprops.intervalProperty(objectID, structure);
%   >>  obj = visprops.intervalProperty(objectID, structure);
%
% Description:
% visprops.intervalProperty(objectID, structure) create a new property
%        representing a real interval with endpoints included.
%
% obj = visprops.intervalProperty(...) returns a handle to a newly 
%       created an interval property.
%
% The visprops.intervalProperty extends visprops.property.
% 
% Example:
% Create a real interval representing [-3, 5].
%  settings = struct( ...
%                'Enabled',       {true}, ...
%                'Category',      {'Summary'}, ...
%                'DisplayName',   {'Box limits'}, ...
%                'FieldName',     {'BoxLimits'}, ... 
%                'Value',         {[-3, 5]}, ...
%                'Type',          {'visprops.intervalProperty'}, ...
%                'Editable',      {true}, ...
%                'Options',       {''}, ...
%                'Description',   {'Limits for the box plot'} ...
%                                  );
%  bm = visprops.intervalProperty([], settings);
% 
% Class documentation:
% Execute the following in the MATLAB command window to view the class 
% documentation for visprops.intervalProperty:
%
%    doc visprops.intervalProperty
%
% See also: visprops.doubleProperty and visprops.property
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

% $Log: intervalProperty.m,v $
% Revision: 1.00  04-Dec-2011 09:11:20  krobbins $
% Initial version $
%

classdef intervalProperty < visprops.property
    
    methods
        
        function obj = intervalProperty(objectID, structure)
            %
            obj = obj@visprops.property(objectID, structure);
        end % intervalProperty constructor
        
        function [jValue, isvalid, msg] = convertValueToJIDE(obj, mValue)  
            % Convert a MATLAB interval to a cell array of char 
            try
                if isempty(mValue) || ~isnumeric(mValue)
                    throw(obj.getException('convertValueToJIDE', ...
                                         'Value isn''t numeric'));
                elseif length(mValue) ~= 2 || mValue(1) > mValue(2)
                    throw(obj.getException('convertValueToJIDE', ...
                                           'Value must be an interval'));
                end
                jValue = {num2str(mValue(1));  num2str(mValue(2))}; 
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
            try
                if isempty(jValue)
                    throw(obj.getException('convertValueToMATLAB', ...
                                           'Can''t have an empty string'));
                end
                v1 = str2double(jValue{1});
                v2 = str2double(jValue{2});
                if isempty(v1) || ~isnumeric(v1) || isnan(v1) || ...
                   isempty(v2) || ~isnumeric(v2) || isnan(v2)  
                    throw(obj.getException('convertValueToMATLAB', ...
                                           'Value isn''t numeric'));
                elseif v1 > v2
                    throw(obj.getException('convertValueToMATLAB', ...
                                           'Value must be an interval'));
                end 
                mValue = [v1, v2];
                isvalid = true;
                msg = '';
            catch ME
                mValue = [];
                isvalid = false;
                msg = ['[' ME.identifier '] ' ME.message];
            end
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
            lowEnd = com.jidesoft.grid.DefaultProperty();
            set(lowEnd, 'Category', setting.Category, ...
                'Description', [setting.Description ': lower endpoint'], ...
                'DisplayName', 'Lower endpoint', ...
                'Name', 'LowEnd', 'Value', jValue{1});
            lowEnd.setType(obj.getJavaType());
            lowEnd.setEditable(setting.Editable);
            prop.addChild(lowEnd);           
            highEnd = com.jidesoft.grid.DefaultProperty();
            set(highEnd, 'Category', setting.Category, ...
                'Description', [setting.Description ': upper endpoint'], ...
                'DisplayName', 'Upper endpoint', ...
                'Name', 'HighEnd', 'Value', jValue{2});
            highEnd.setType(obj.getJavaType());
            highEnd.setEditable(setting.Editable);
            prop.addChild(highEnd);
        end % createJIDEProperty
        
        function [jProp, pos] = getJIDEPropertyByName(obj, name)
            % Return the correct child property based on its name
            baseName = obj.getFullName();
            children = obj.JIDEProperty.getChildren;
            if strcmp(baseName, name) == 1 
                jProp = obj.JIDEProperty;
                pos = 0;
            elseif strcmp([baseName '.LowEnd'], name) == 1 
                jProp = children.get(0);
                pos = 1;
             elseif strcmp([baseName '.HighEnd'], name) == 1 
                jProp = children.get(1);
                pos = 2;
            else
                jProp = [];
                pos = -1;
            end
        end % getJIDEPropertyByName
        
        function valid = setCurrentValue(obj, mValue)
            % Set CurrentValue JIDEValue to mValue if valid
            [jValue, valid] = convertValueToJIDE(obj, mValue);
            if valid
                children = obj.JIDEProperty.getChildren();
                low = children.get(0);
                low.setValue(jValue(1));
                high = children.get(1);
                high.setValue(jValue(2));
                obj.CurrentValue = mValue;
            end
        end % setCurrentValue
        
        function valid = validateAndSetFromJIDE(obj, name, newValue)
            % Set current value to newValue if newValue is valid
            try
                if isempty(newValue)
                    throw(obj.getException('validateAndSetFromJIDE',...
                                            'Interval cannot be empty'));
                end
                [jProp, pos] = obj.getJIDEPropertyByName(char(name));
                jValue = {num2str(obj.CurrentValue(1)); ...
                          num2str(obj.CurrentValue(2))};
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
            pType = 'visprops.intervalProperty';
        end % getPropertyType
        
    end % static methods
    
end % intervalProperty


