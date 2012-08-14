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
        Background = [0.90, 0.90, 0.90]; % Background color
        CurrentClickable = [];         % set the current clickable
        CurrentPosition = [];          % set the current position
        Master = [];                   % master that has the panel
        NameBox = [];                  % text box displaying name of current
        NavigatorPanel = [];           % panel that holds navigation
        PositionBox = [];              % text box displaying current position
    end % private properties
    
    methods
        
        function obj = navigator(parent, master)
            % Base class for clickable objects
            obj.Master = master;
            obj.createLayout(parent);
        end % constructor
        
        
        function clear(obj)
            % Clear the settings of the navigator
            obj.CurrentClickable = [];
            obj.CurrentPosition = [];
            set(obj.PositionBox, 'String', 'unset')
            set(obj.NameBox, 'String', '');
        end % clear
        
        function [current, position] = getCurrent(obj)
            % Return the current object and position
            current = obj.CurrentClickable;
            position = obj.CurrentPosition;
        end % getCurrent
        
        function setCurrent(obj, current, position)
            % Set the current clickable object
            if isa(current, 'visviews.clickable')
                obj.CurrentClickable = current;
                obj.CurrentPosition = position;
                set(obj.PositionBox, 'String', num2str(position))
                set(obj.NameBox, 'String', [current.getName() ': ']);
            end
        end % setCurrent
        
        function buttonDownCallback (obj, src, eventdata, increment) %#ok<INUSL>
            % Callback links navigator to summary plots
            [current, position] = obj.getCurrent();
            if isempty(current)
                return;
            end
            position = position + increment;
            current.buttonDownCallback(obj, [], obj.Master, position);
            position = current.getCurrentPosition();
            obj.setCurrent(current, position);
        end
        
    end % public methods
    
    methods (Access = private)
        function createLayout(obj, parent)
            obj.NavigatorPanel =  uiextras.HBox('Parent', parent, ...
                'BackgroundColor', [0.8, 0.8, 0.8]);
            p = which('pop_eegvis.m');
            p = p(1:strfind(p, 'pop_eegvis.m') - 1);
            backwardIcon = imread([p 'icons/backwardIcon.png']);
            beginningIcon = imread([p 'icons/beginningIcon.png']);
            endIcon = imread([p 'icons/endIcon.png']);
            forwardIcon = imread([p 'icons/forwardIcon.png']);
            obj.NameBox = uicontrol('Parent', obj.NavigatorPanel, ...
                'Style', 'text', 'BackgroundColor', obj.Background, ...
                'String', '', 'HorizontalAlignment', 'right');
            uicontrol('Parent', obj.NavigatorPanel, ...
                'Style', 'pushbutton', 'CData', beginningIcon, ...
                'Callback', {@obj.buttonDownCallback, -inf});
            uicontrol('Parent', obj.NavigatorPanel, ...
                'Style', 'pushbutton', 'CData', backwardIcon, ...
                'Callback', {@obj.buttonDownCallback, -1});
            obj.PositionBox = uicontrol('Parent', obj.NavigatorPanel, ...
                'Style', 'edit', 'String', 'Unset');
            uicontrol('Parent', obj.NavigatorPanel, ...
                'Style', 'pushbutton', 'CData', forwardIcon, ...
                'Callback', {@obj.buttonDownCallback,  1});
            uicontrol('Parent', obj.NavigatorPanel, ...
                'Style', 'pushbutton', 'CData', endIcon, ...
                'Callback', {@obj.buttonDownCallback, inf});
            set(obj.NavigatorPanel, 'Sizes', [-1 30 30 60, 30, 30]);
        end % createLayout
    end % private methods
    
end % navigator