% visviews.clickable  base class for mouse click linkage among view panels
%
% Usage:
%   >>  visviews.clickable()
%   >>  obj = visviews.clickable()
%
% Description:
% visviews.clickable() is the base class for clickable panels in linked
%     visualizations. Most visualization panels extend visviews.axesPanel, 
%     which is a visviews.clickable class. Extending classes generally 
%     override the following methods:
%
%          [dSlice, bFunction] = getClicked(obj)
%
%          [cbHandles, hitHandles] = getHitObjects(obj)
%
%     When the user clicks on a clickable panel, the ButtonDownFcn callback 
%     calls its getClicked method. This method returns the data slice 
%     corresponding to the clicked region and a reference to the block 
%     function represented by this panel, if applicable. 
%
%     The getHitObjects method controls setting the ButtonDownFcn callback. 
%     The cbHandles cell array specifies the handles whose ButtonDownFcn
%     callback should be set. The hitHandles cell array specifies the 
%     handles whose HitTest property should be set 'on'. 
%
% Notes:
%  - The source map for a clickable object consists of an objectID string
%    as the key and a cell array of clickable objects that are linked to
%    this source.
%
% Class documentation:
% Execute the following in the MATLAB command window to view the class 
% documentation for visviews.clickable:
%
%    doc visviews.clickable
%
% See also: visviews.axesPanel
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

% $Log: clickable.m,v $
% Revision: 1.00  04-Dec-2011 09:11:20  krobbins $
% Initial version $
%

classdef navigator < handle
    
    properties
        IsClickable  = true;           % if true, this is clickable
        LinkDetails = true;            % if true, link to details
    end % public properties
    
    properties (Access = private)
        Master = [];                  % The master that has the toolbar
    end % private properties
    
    methods
        
        function obj = navigator(master)
            % Base class for clickable objects
            obj.Master = master;
        end % constructor
        
        function clearClickable(obj)
            % Clear the maps with IDs and relationships

        end % clear
    end % public methods
    
   methods (Static = true)
        function buttonDownCallback (src, eventdata, obj, increment) %#%#ok<MSNU> ok<INUSL>
            % Callback links master component to details
            fprintf('Here\n');
        end 
   end % static methods
end % navigator