% visprops.vectorProperty property representing a numeric vector
%
% Usage:
%   >>  visprops.vectorProperty(objectID, structure);
%   >>  obj = visprops.vectorProperty(objectID, structure);
%
% Description:
% visprops.vectorProperty(objectID, structure) create a new property
%          representing a vector whose values are in a specified interval. 
%          By default, the interval is [-inf, inf]. The objectID parameter
%          is the hash key associated with configurable owner of the 
%          property. The structure parameter is the structure specifying
%          the vector property as described in visprops.property.
%
% obj = visprops.vectorProperty(...) returns a handle to a newly 
%          created vector property.
%
% The visprops.vectorProperty extends visprops.doubleProperty and
% inherits its two public properties that specify the range for a valid value:
%
% Public property      Description
%
%    Limits            A two-element vector specifying the endpoints
%                      of the interval for a valid value. 
%                      inf and -inf are valid values. 
%
%    Inclusive         A two-element boolean vector specifying
%                      whether the endpoints of the interval specifyed 
%                      by Limits should be included as valid values.
% 
% Example:
% Create a vector property of non negative values.
%   settings = struct( ...
%                 'Enabled',       {true}, ...
%                 'Category',      {'Summary'}, ...
%                 'DisplayName',   {'My list'}, ...
%                 'FieldName',     {'Values'}, ... 
%                 'Value',         {[1, 2.5, 3, 4.23]}, ...
%                 'Type',          {'visprops.vectorProperty'}, ...
%                 'Editable',      {true}, ...
%                 'Options',       {[0, inf]}, ...
%                 'Description',   {'Block size for computation (must be non negative)'} ...
%                                   );
%   bm = visprops.vectorProperty([], settings);
%   settings.Inclusive = [false, false];   % Lower interval endpoint is not included
% 
% Notes:
%   - If the Options field of the settings structure for
%     visprops.vectorProperty is non empty, it is used to set the 
%     Limits property.
%
% Class documentation:
% Execute the following in the MATLAB command window to view the class 
% documentation for visprops.vectorProperty:
%
%    doc visprops.vectorProperty
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

% $Log: vectorProperty.m,v $
% Revision: 1.00  04-Dec-2011 09:11:20  krobbins $
% Initial version $
%

classdef vectorProperty < visprops.doubleProperty
 
    methods
        
        function obj = vectorProperty(objectID, structure)
            % Create a configurable object representing a double in an interval
            obj = obj@visprops.doubleProperty(objectID, structure);
        end % vectorProperty constructor
        
        function [jValue, isvalid, msg] = convertValueToJIDE(obj, mValue)
            % Convert a MATLAB value to a valid JIDE value within the limits
            try
                if isempty(mValue) || ~isnumeric(mValue) || ~isvector(mValue)
                    throw(obj.getException('convertValueToJIDE', ...
                                           'Value isn''t a numeric vector'));
                elseif ~obj.testInLimits(mValue)
                    throw(obj.getException('convertValueToJIDE', ...
                                           'Value must be within interval'));
                end
                if size(mValue, 1) == 1
                   jValue = num2str(mValue);
                else
                   jValue = num2str(mValue');
                   jValue = strrep(jValue, ' ', ';');
                end
                isvalid = true;
                msg = '';
            catch ME
                jValue = [];
                isvalid = false;
                msg = ['[' ME.identifier '] ' ME.message];
            end
        end % convertValueToJIDE
        
        function [mValue, isvalid, msg] = convertValueToMATLAB(obj, jValue)
            % Convert a JIDE value to a valid Matlab value
            try
                jValue = char(jValue);
                if isempty(jValue)
                    throw(obj.getException('convertValueToMATLAB', ...
                                           'Can''t have an empty string'));
                end
                mValue = str2num(jValue);
                if isempty(mValue) || ~isnumeric(mValue) || ...
                    sum(isnan(mValue)) ~= 0 || ~isvector(mValue)
                    throw(obj.getException('convertValueToMATLAB', ...
                                           'Value isn''t numeric vector'));
                elseif ~testInLimits(obj, mValue)
                    throw(obj.getException('convertValueToMATLAB', ...
                                           'Value must be an interval'));
                end
                isvalid = true;
                msg = '';
            catch ME
                mValue = [];
                isvalid = false;
                msg = ['[' ME.identifier '] ' ME.message];
            end
        end % convertValueToMATLAB
        
    end % public methods
    
    methods (Static = true)
        
        function javatype = getJavaType()
            % Return the Java type of this property
            javatype = visprops.javaclass('char', 1);
        end % getJavaType
        
        function pType = getPropertyType()
            % Return the class type of this property
            pType = 'visprops.vectorProperty';
        end % getPropertyType
        
    end % static methods
    
end % vectorProperty