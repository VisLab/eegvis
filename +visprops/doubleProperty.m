% visprops.doubleProperty() property representing a double in a specified interval
%
% Usage:
%   >>  visprops.doubleProperty(objectID, structure);
%   >>  obj = visprops.doubleProperty(objectID, structure);
%
% Description:
% visprops.doubleProperty(objectID, structure)   create a new property
%       representing a double in a specified interval. By default, 
%       the interval is [-inf, inf]. The objectID parameter
%       is the hash key associated with configurable owner of the 
%       property. The structure parameter is the structure specifying
%       the vector property as described in visprops.property.
%
% obj = visprops.doubleProperty(...) returns a handle to a newly 
%        created double property.
%
% The visprops.doubleProperty has two public properties that specify
% the interval for a valid value:
%
% Public property     Description
%
%    Limits           A two-element vector specifying the endpoints
%                     of the interval for a valid value. inf and -inf
%                     are valid values.
%
%    Inclusive        A two-element boolean vector specifying
%                     whether the endpoints of the interval specifyed by 
%                     Limits should be included as valid values.
%
% Example:
% Create a double property in the interval in the [0, inf) with initial
% value 1000.
%  settings = struct( ...
%                 'Enabled',       {true}, ...
%                 'Category',      {'Summary'}, ...
%                 'DisplayName',   {'Block size'}, ...
%                 'FieldName',     {'BlockSize'}, ... 
%                 'Value',         {1000.0}, ...
%                 'Type',          {'visprops.doubleProperty'}, ...
%                 'Editable',      {true}, ...
%                 'Options',       {[0, inf]}, ...
%                 'Description',   {'Block size for computation (must be non negative)'} ...
%                                   );
%   bm = visprops.doubleProperty([], settings);
%   settings.Inclusive = [true, false];   % Lower interval endpoint is valid
%
% Notes:
%  -  If the Options field of the settings structure for
%     visprops.doubleProperty is non empty, it is used to set the 
%     Limits| property.
%
% Class documentation:
% Execute the following in the MATLAB command window to view the class 
% documentation for visprops.doubleProperty:
%
%    doc visprops.doubleProperty
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

% $Log: doubleProperty.m,v $
% Revision: 1.00  04-Dec-2011 09:11:20  krobbins $
% Initial version $
%

classdef doubleProperty < visprops.property
 
    properties(Access = private)
        Inclusive = [false, false]   % true if valid includes endpoints
        Limits;                      % range of the value
    end % private properties
    
    methods
        
        function obj = doubleProperty(objectID, structure)
            % Create a new double property object
            obj = obj@visprops.property(objectID, structure);
        end % doubleProperty constructor
        
        function [jValue, isvalid, msg] = convertValueToJIDE(obj, mValue)
            % Convert a MATLAB value to a valid JIDE value within the limits
            try
                if isempty(mValue) || ~isnumeric(mValue) || ~isscalar(mValue)
                    throw(obj.getException('convertValueToJIDE', ...
                                          'Value isn''t numeric scalar'));
                elseif ~obj.testInLimits(mValue)
                    throw(obj.getException('convertValueToJIDE', ...
                                     'Value must be within interval'));
                end
                jValue = num2str(mValue);
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
                mValue = str2double(jValue);
                if isempty(mValue) || ~isnumeric(mValue) || isnan(mValue)
                    throw(obj.getException('convertValueToMATLAB', ...
                                           'Value isn''t numeric'));
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
              
        function inclusive = getInclusive(obj)
            % Return the vector indicating whether inclusive
            inclusive = obj.Inclusive;
        end % getInclusive
        
        function setting = getPropertyStructure(obj)
            % Return a structure extracted from JIDE properties
            setting = obj.getPropertyStructure@visprops.property();
            setting.Options = obj.Limits;
        end % getPropertyStructure
        
        function [isvalid, msg] = processOptions(obj)
            % Check the of the validity options and process as necessary
            isvalid = true;
            msg = '';
            obj.Limits = obj.ManStruct(1).Options;
            [defLimits, dinclusive] =  eval([class(obj) '.getDefaults()']);
            obj.Inclusive = dinclusive;
            if isempty(obj.Limits)
                obj.Limits = defLimits;
            elseif ~isnumeric(obj.Limits) || length(obj.Limits)~= 2 || ...
                    obj.Limits(1) > obj.Limits(2)
                isvalid = false;
                obj.Limits = defLimits;
                msg = 'Options must specify a numeric interval';
            end
            obj.ManStruct(1).Options = obj.Limits;
        end % processOptions
        
        function setInclusive(obj, inclusive)
            % Set the flags indicating whether limits are inclusive
            if isa(inclusive, 'logical') && length(inclusive) == 2
                obj.Inclusive = inclusive;
            end
        end % setInclusive
        
        function inLimits = testInLimits(obj, value)
            %Returns true if the value (scalar or vector) is within the limits
            inLimits = false;
            % If any values are strictly outside the limits, return false
            if sum(value < obj.Limits(1)) || sum(value > obj.Limits(2))
                return;
            end
            % Infinite left endpoint not included, but value is infinite
            if ~obj.Inclusive(1) && isinf(obj.Limits(1)) && sum(isinf(value))
                return;
            end
            % Finite left endpoint not included, but value equals endpoint
            if ~obj.Inclusive(1) && ...
               isfinite(obj.Limits(1)) && sum(value == obj.Limits(1))
               return;
            end 
            % Infinite right endpoint not included, but value is infinite
            if ~obj.Inclusive(2) && isinf(obj.Limits(2)) && sum(isinf(value))
                return;
            end
            % Finite right endpoint not included, but value equals endpoint
            if ~obj.Inclusive(2) && ...
               isfinite(obj.Limits(2)) && sum(value == obj.Limits(2))
               return;
            end           
            % Got through the tests, so must be okay
            inLimits = true;
        end % testInLimits
        
    end % public methods
    
    methods (Static = true)
        
        function [dLimits, dInclusive] = getDefaults()  
            % Return the default interval which must contain the value
            dLimits = [-inf, inf];
            dInclusive = [true, true];
        end % getDefaultLimits
        
        function javatype = getJavaType()
            % Return the Java type of this property
            javatype = visprops.javaclass('char', 1);
        end % getJavaType
        
        function pType = getPropertyType()
            % Return the class type of this property
            pType = 'visprops.doubleProperty';
        end % getPropertyType
        
    end % static methods
    
end % doubleProperty