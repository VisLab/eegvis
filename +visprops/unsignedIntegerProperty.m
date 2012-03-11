% visprops.unsignedIntegerProperty property representing an unsigned integer in a specified interval
%
% Usage:
%   >>  visprops.unsignedIntegerProperty(objectID, structure)
%   >>  obj = visprops.unsignedIntegerProperty(objectID, structure)
%
% Description:
% visprops.unsignedIntegerProperty(objectID, structure) create a new property
%        representing an integer in a specified interval. By default, the interval
%        is [0, inf]. The objectID parameter is the hash key associated with 
%        configurable owner of the property. The structure parameter is 
%        the structure specifying the vector property as described in 
%        visprops.property.
%        
% obj = visprops.unsignedIntegerProperty(...) returns a handle to a newly 
%        created integer property.
%
% The visprops.unsignedIntegerProperty extends visprops.integerProperty and
% inherits its two public properties that specify the interval for a valid value:
%
% Public property      Description
%
%   Limits             A two-element vector specifying the endpoints
%                      of the interval for a valid value. inf is a valid
%                      value.
%
%   Inclusive          A two-element boolean vector specifying
%                      whether the endpoints of the interval specifyed by 
%                      Limits should be included as valid values.
%
% Example:
% Create an unsigned integer property in the interval in the (0, 5] with initial
% value 1.
%   settings = struct( ...
%                 'Enabled',       {true}, ...
%                 'Category',      {'Summary'}, ...
%                 'DisplayName',   {'Count'}, ...
%                 'FieldName',     {'Count'}, ... 
%                 'Value',         {1}, ...
%                 'Type',          {'visprops.unsignedIntegerProperty'}, ...
%                 'Editable',      {true}, ...
%                 'Options',       {[0, 5]}, ...
%                 'Description',   {'Object counter'} ...
%                                   );
%   bm = visprops.integerProperty([], settings);
%   settings.Inclusive = [false, true];   % Upper interval endpoint is valid
% 
% Notes:
%   - If the Options field of the settings structure for
%     visprops.unsignedIntegerProperty is non empty, it is used to set the 
%     Limits property.
%   - This integer converts to a MATLAB uint32.
%
%
% Class documentation:
% Execute the following in the MATLAB command window to view the class 
% documentation for visprops.unsignedIntegerProperty:
%
%    doc visprops.unsignedIntegerProperty
%
% See also: visprops.doubleProperty, visprops.integerProperty, and
%     visprops.property
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

% $Log: unsignedIntegerProperty.m,v $
% Revision: 1.00  04-Dec-2011 09:11:20  krobbins $
% Initial version $
%

classdef unsignedIntegerProperty < visprops.integerProperty
    % Model property for an unsigned integer (converts to uint32)
  
    methods
        
        function obj = unsignedIntegerProperty(objectID, structure)
            % Creates configurable object for integer in specified interval
            obj = obj@visprops.integerProperty(objectID, structure);
        end % unsignedIntegerProperty constructor
            
        function [mValue, isvalid, msg] = convertValueToMATLAB(obj, jValue)
            % Convert a JIDE value to a valid Matlab value
            try
                [mValue, isvalid, msg] = ...
                    convertValueToMATLAB@visprops.integerProperty(obj, jValue);
                if ~isvalid  % value is not a valid integer
                    return;
                end
                mValue = uint32(mValue);
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
        
        function [dLimits, dInclusive] = getDefaults()  
            % Return the default interval and endpoint characteristics 
            dLimits = [0, inf];
            dInclusive = [true, true];
        end % getDefaultLimits
        
        function javatype = getJavaType()
            % Return the Java type of this property
            javatype = visprops.javaclass('char', 1);
        end % getJavaType
        
        function pType = getPropertyType()
            % Return the class type of this property
            pType = 'visprops.unsignedIntegerProperty';
        end % getPropertyType
        
    end % static methods
    
end % unsignedIntegerProperty