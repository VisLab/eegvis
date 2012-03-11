% viscore.counter singleton class that returns a unique ID value
%
% Usage:
%   >>  viscore.counter();
%   >>  obj = viscore.counter();
%
% Description:
% viscore.counter creates a singleton counter object used to generate
%     IDs for managed objects.
%
% obj = viscore.counter returns a handle to the singleton counter for IDs.
%
% Example:
% Generate a new ID from the counter
%   counter = viscore.counter.getInstance();
%   newID = counter.getNext();
%   
% Class documentation:
% Execute the following in the MATLAB command window to view the class 
% documentation for |viscore.counter|:
%
%    doc viscore.counter
%
% See also: viscore.dataManager and viscore.managedObj  

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

% $Log: counter.m,v $
% Revision: 1.00  04-Dec-2011 09:11:20  krobbins $
% Initial version $
%

classdef  (Sealed) counter < handle
    
    properties (Access = private)
        Count       % counter indicating how many ID's objects have been created
    end
    
    methods (Access = private)
        
        function obj = counter()
            % Initialize the counter
            obj.Count = 0;
        end % counter constructor
        
    end % private methods
    
    methods
        
        function nextCount = getNext(obj)
            % Return the next unique object ID
            obj.Count = obj.Count + 1;
            nextCount = obj.Count;
        end % getNext
        
        function thisCount = getCount(obj)
            % Return the current object ID
            thisCount = obj.Count;
        end % getCount
        
    end % public methods
    
   methods (Static = true)
       
       function singleObj = getInstance()
           % Return a handle to the singleton counter factory object
           persistent localObj
           if isempty(localObj) || ~isvalid(localObj)
               localObj = viscore.counter();
           end
           singleObj = localObj;
       end % getInstance
       
   end % static methods
    
end % SelectorCount

