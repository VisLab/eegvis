% visprops.integerProperty property representing an integer in a specified interval
%
% Usage:
%   >>  visprops.integerProperty(objectID, structure);
%   >>  obj = visprops.integerProperty(objectID, structure);
%
% Description:
% visprops.integerProperty(objectID, structure) create a new property
%        representing an integer in a specified interval. By default, 
%        the interval is [-inf, inf]. The objectID parameter is
%        the hash key associated with configurable owner of the 
%        property. The structure parameter is the structure specifying
%        the vector property as described in visprops.property.
%
% obj = visprops.integerProperty(...) returns a handle to a newly 
%        created integer property.
%
% The visprops.integerProperty extends visprops.doubleProperty and
% inherits its two public properties that specify the interval for a valid value:
%
% Public property      Description 
%
%    Limits            A two-element vector specifying the endpoints
%                      of the interval for a valid value. 
%                      inf and -inf are validvalues.
%
%    Inclusive         A two-element boolean vector specifying
%                      whether the endpoints of the interval specifyed by     
%                      Limits should be included as valid values.
%
% Example:
% Create an integer property in the interval in the (-3, 5] with initial
% value -2.
%   settings = struct( ...
%                 'Enabled',       {true}, ...
%                 'Category',      {'Summary'}, ...
%                 'DisplayName',   {'Minimum limit'}, ...
%                 'FieldName',     {'MinimumLimit'}, ... 
%                 'Value',         {-2}, ...
%                 'Type',          {'visprops.integerProperty'}, ...
%                 'Editable',      {true}, ...
%                 'Options',       {[-3, 5]}, ...
%                 'Description',   {'Lower limit of axis'} ...
%                                   );
%   bm = visprops.integerProperty([], settings);
%   settings.Inclusive = [false, true];   % Upper interval endpoint is valid
% 
% Notes:
% - If the Options field of the settings structure for
%   visprops.integerProperty is non empty, it is used to set the 
%   Limits property.
% - This integer converts to a MATLAB int32.
%
% Class documentation:
% Execute the following in the MATLAB command window to view the class 
% documentation for visprops.integerProperty:
%
%    doc visprops.integerProperty
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

% $Log: integerProperty.m,v $
% Revision: 1.00  04-Dec-2011 09:11:20  krobbins $
% Initial version $
%

classdef integerProperty < visprops.doubleProperty
    
    properties(Access = private)
        CloseEnough = 1E-12;  % how close is a double to be int32
    end % private properties
    
    methods
        
        function obj = integerProperty(objectID, structure)
            % Create a configurable property for an integer
            obj = obj@visprops.doubleProperty(objectID, structure);
        end % integerProperty constructor
        
        function [jValue, isvalid, msg] = convertValueToJIDE(obj, mValue)
            % Convert a MATLAB value to a valid JIDE value within the limits
            try
                [jValue, isvalid, msg] = ...
                    convertValueToJIDE@visprops.doubleProperty(obj, mValue);
                if ~isvalid  % value not a valid double
                    return;
                end
                % See if close enough to an integer
                if abs(mValue - round(mValue)) > obj.CloseEnough
                    throw(obj.getException('convertValueToJIDE', ...
                                   'Value not close enough to an integer'));
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
                [mValue, isvalid, msg] = ...
                    convertValueToMATLAB@visprops.doubleProperty(obj, jValue);
                if ~isvalid  % value is not a valid double
                    return;
                end
                if abs(mValue - round(mValue)) > obj.CloseEnough
                    throw(obj.getException('convertValueToMATLAB', ...
                               'Value not close enough to an integer'));
                end
                mValue = int32(mValue);
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
            pType = 'visprops.integerProperty';
        end % getPropertyType
        
    end % static methods
    
end % integerProperty


