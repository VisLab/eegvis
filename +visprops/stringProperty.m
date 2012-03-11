% visprops.stringProperty property representing a simple string 
%
% Usage:
%   >>  visprops.stringProperty(objectID, structure)
%   >>  obj = visprops.stringProperty(objectID, structure)
%
% Description:
% visprops.stringProperty(objectID, structure) create a new property
%        representing a simple string. The objectID parameter is 
%        the hash key associated with configurable owner of the property. 
%        The structure parameter is the structure specifying the vector 
%        property as described in visprops.property.
%
%   obj = visprops.stringProperty(...) returns a handle to a newly 
%                created string property.
%
% The visprops.stringProperty extends visprops.property.
%
% Example:
% Create a vector property of non negative values.
%   settings = struct( ...
%                 'Enabled',       {true}, ...
%                 'Category',      {'Summary'}, ...
%                 'DisplayName',   {'Window name'}, ...
%                 'FieldName',     {'WindowName'}, ... 
%                 'Value',         {'Epoch'}, ...
%                 'Type',          {'visprops.stringProperty'}, ...
%                 'Editable',      {true}, ...
%                 'Options',       {''}, ...
%                 'Description',   {'Axis label for window'} ...
%                                   );
%   bm = visprops.stringProperty([], settings);
%  
% Class documentation:
% Execute the following in the MATLAB command window to view the class 
% documentation for visprops.stringProperty:
%
%    doc visprops.stringProperty
%
% See also: visprops.property



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

% $Log: stringProperty.m,v $
% Revision: 1.00  04-Dec-2011 09:11:20  krobbins $
% Initial version $
%

classdef stringProperty < visprops.property
    
    methods
        
        function obj = stringProperty(objectID, structure)
            % Create a configurable object corresponding to a string
            obj = obj@visprops.property(objectID, structure);
        end % stringProperty constructor
        
        function [jValue, isvalid, msg] = convertValueToJIDE(obj, mValue)   %#ok<MANU>
            % Convert Matlab value of this property into its Java equivalent
            try
                if ~ischar(mValue)
                    throw(MException('', ...
                        'Value not of class char'));
                else
                    jValue = char(mValue);
                    isvalid = true;
                    msg = '';
                end
            catch ME
                jValue = '';
                isvalid = false;
                msg = ['Value is not a valid character string: ' ...
                    ME.message];
            end
        end % convertValueToJIDE
        
    end % public methods
    
    methods (Static = true)
 
        function javatype = getJavaType() 
            % Return the Java type of this property
            javatype = visprops.javaclass('char', 1);
        end % getJavaType
        
        function pType = getPropertyType() 
            % Return the class type of this property
            pType = 'visprops.stringProperty';
        end % getPropertyType
        
    end % static methods
    
end % stringProperty


