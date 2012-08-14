% visviews.cursorExplorer class that adds and supervises an exploratory data cursor
%
% Usage:
%   >>  visviews.cursorExplorer(visFig)
%   >>  obj = visviews.cursorExplorer(visFig)
%
% Description:
% visviews.cursorExplorer(visFig, objectList) creates a class that
%    provides data cursor that continuously updates as the user moves the 
%    mouse over a figure. The |visFig| is a handle to the figure managed
%    by this cursor explorer.
%
% obj = visviews.cursorExplorer(visFig) returns a handle to the
%    newly created cursor explorer.
%
% This class provides a data cursor that continuously updates as the
% user moves the mouse over a figure.
%
% MATLAB only supports a single type of window motion event and 
% uses this event for resizing, pan, and zoom. As a result, 
% cursor exploration must disable these other uses to work without 
% interference. The viewing supervisor application that contains
% the cursor explorer should provide a mechanism for the user to 
% enter and exit cursor exploration mode. The supervisor should call the
% cursorOn and cursorOff methods of visviews.cursorExplorer to 
% enter and exit cursor exploration mode. These methods disable or 
% enable zoom, pan, and some resizing in exploration mode as well 
% as saving and restoring state information.
%
% The supervising visualization should also call the addExplorable
% method of visviews.cursorExplorer to add visviews.cursorExplorable
% objects to this explorer.
%
% Class documentation:
% Execute the following in the MATLAB command window to view the class 
% documentation for visviews.cursorExplorer:
%
%    doc visviews.cursorExplorer
%
% See also: visviews.axesPanel and visviews.cursorExplorable 
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

% $Log: cursorExplorer.m,v $
% Revision: 1.00  04-Dec-2011 09:11:20  krobbins $
% Initial version $
%

classdef cursorExplorer < hgsetget    
 
    properties (Access = private)
        CursorAnnotation = [];   % text object holding cursor display
        CursorImage = [];    % cursor tool icon installed on cursor figure
        FigHitPosition = []; % figure hit position during exploration
        GapSize = 10;        % size in pixels of gap between cursor and text
        HitList = {};        % list of objects within figure that can be hit
        LastHit = 1;         % last object in HitList to be hit by cursor
        oldProps = [];       % save zoom and other properties during explore       
        ValueToggleButton;   % toggle button indicating whether cursor is on
        VisualFig;           % handle of figure to which this cursor is attached
    end % private properites 
    
    methods
        
        function obj = cursorExplorer(visFig, objectList) %#ok<INUSD>
            % Create a cursor explorer figure (objectList is list of cursorExplorable objects)
            obj.VisualFig = visFig;
            initialize(obj);
        end % cursorExplorer constructor
        
        function addExplorable(obj, eObjects)
            % Add one or more cursorExplorable objects to HitList
            % If any of the eObjects are on the list already don't add again
            if isa(eObjects, 'cell')
                for k = 1:length(eObjects)
                    obj.addOneExplorable(eObjects{k});
                end
            else
                obj.addOneExplorable(eObjects);
            end
        end % addExplorable
        
        function clear(obj)
            % Clear hit list on creation and when hittable object list changes
            obj.HitList = {};
        end % clear
        
        function flag = ison(obj)
            % Return true if figure is in exploration mode
            flag = strcmpi(get(obj.ValueToggleButton, 'State'), 'on');
        end % ison
        
        function removeExplorable(obj, eObjects)
            % Remove one or more cursorExplorable objects from hit list 
            if isa(eObjects, 'cell')
                for k = 1:length(eObjects)
                    obj.removeOneExplorable(eObjects{k});
                end
            else
                obj.removeOneExplorable(eObjects);
            end
        end % removeExplorable     
        
    end % public methods
    
    methods (Access = private)
        
        function addOneExplorable(obj, eObject)
            % Add a cursor explorable object to the hit list
            if isempty(eObject) || ~isa(eObject, 'visviews.cursorExplorable') 
                return;
            end
            for k = 1:length(obj.HitList)
                if eq(obj.HitList{k}, eObject)
                    return;
                end
            end
            obj.HitList{length(obj.HitList) + 1} = eObject;
        end % addOneExplorable
        
        function initialize(obj)
            % Create  the cursor object tool on toolbar, and adds and icon
            % to the figure toolbar and sets up the calbacks            
            % Set the toolbar widget for the window cursor
            hToolbar = findall(obj.VisualFig, 'Type', 'uitoolbar');
            p = which('pop_visviews.m');
            p = p(1:strfind(p, 'pop_visviews.m') - 1);
            ptIcon = imread([p 'icons/explorerIcon.png']);
            obj.ValueToggleButton = ...
            uitoggletool(hToolbar, 'CData', ptIcon,...
                'Separator', 'on', 'HandleVisibility','off', 'TooltipString', ...
                'Enable/disable display of data values under cursor', ...
                'Tag', 'CursorToggle', 'State', 'off', ...
                'OnCallback', {@obj.valueCursorOnFcn}, ...
                'OffCallback', {@obj.valueCursorOffFcn});
            obj.CursorImage = NaN(16, 16);
            obj.CursorImage(:, 9) = 1;
            obj.CursorImage(9, :) = 1;
        end % initialize
        
        function removeOneExplorable(obj, eObject)
            % Remove a cursor explorable object from the hit list
            if isempty(eObject) 
                return;
            end
            for k = 1:length(obj.HitList)
                if eq(obj.HitList{k}, eObject)
                    obj.HitList(k) = [];
                    return;
                end
            end
        end % removeOneExplorable
        
        function valueCursorOffFcn (obj, source, eventdata) %#ok<INUSD>
            % Callback to restore figure state when cursor tool is deactivated
            % (e.g., user has clicked the value cursor toggle button off)
            
            % Restore figure properties and turn off cursor text
            if ~isempty(obj.CursorAnnotation)
                delete(obj.CursorAnnotation);
            end
            
            obj.FigHitPosition = [];
            if isempty(obj.oldProps)
                return;
            end
            figh = ancestor( source, 'figure');
            set(figh, ...
                'WindowButtonMotionFcn', obj.oldProps.figProps{1}, ...
                'WindowButtonUpFcn', obj.oldProps.figProps{2}, ...
                'Units', obj.oldProps.figProps{3}, ...
                'Resize', obj.oldProps.figProps{4}, ...
                'Pointer', obj.oldProps.figProps{5}, ...
                'PointerShapeCData', obj.oldProps.figProps{6}, ...
                'PointerShapeHotSpot', obj.oldProps.figProps{7}, ...
                'Interruptible', obj.oldProps.figProps{8}, ...
                'BusyAction', obj.oldProps.figProps{9});
            set(obj.oldProps.actions, {'Enable'}, obj.oldProps.states(:));
            set(obj.oldProps.toggleButtons, {'Enable'}, obj.oldProps.toggleEnable(:));
            obj.oldProps = [];
            set(obj.ValueToggleButton, 'State', 'off');
            drawnow expose update;
        end % valueCursorOffFcn
        
        function valueCursorOnFcn (obj, source, eventdata) %#ok<INUSD>
            % Callback for activation of the cursor tool 
            % (e.g., user has clicked the value cursor toggle button on)
            
            figh = ancestor( source, 'figure' );
            % Store existing motion callback and toggle button states
            obj.oldProps = struct();
            
            % Make sure all interaction modes are off to prevent our
            % callbacks being clobbered
            obj.oldProps.actions = ...
                [zoom(figh), rotate3d(figh), pan(figh), datacursormode(figh)];
            obj.oldProps.states = get(obj.oldProps.actions, 'Enable');
            set(obj.oldProps.actions, 'Enable', 'off');
            obj.oldProps.figProps = get(figh, ...
                {'WindowButtonMotionFcn', 'WindowButtonUpFcn', 'Units', 'Resize', ...
                'Pointer', 'PointerShapeCData', 'PointerShapeHotSpot', ...
                'Interruptible', 'BusyAction'});
            obj.oldProps.toggleButtons = ...
                findall(figh, 'Type', 'uitoggletool');
            obj.oldProps.toggleStates = ...
                get(obj.oldProps.toggleButtons, 'State');
            obj.oldProps.toggleEnable = ...
                get(obj.oldProps.toggleButtons, 'Enable');
            set(obj.oldProps.toggleButtons, 'Enable', 'off');
            % Set the window motion callback
            set(figh, 'WindowButtonMotionFcn', @obj.windowButtonMotionFcn, ...
                'WindowButtonUpFcn', '', ...
                'Resize', 'off', 'Units', 'pixels', ...
                'Pointer', 'custom', 'PointerShapeCData', obj.CursorImage,...
                'PointerShapeHotSpot', [9 9], ...
                'Interruptible', 'off', 'BusyAction', 'cancel');
            obj.FigHitPosition = get(figh, 'Position');
            obj.CursorAnnotation = annotation(figh, 'textbox', ...
                'Units', 'pixels', ...
                'FitBoxToText', 'on', 'LineStyle', 'none', 'String', '', ...
                'FontName', 'monospaced', 'FontSize', 8, ...
                'HorizontalAlignment', 'left', ...
                'VerticalAlignment', 'bottom', 'Visible', 'off');
            set(source, 'Enable', 'on');
            drawnow expose update;
        end % valueCursorOnFcn
        
        function windowButtonMotionFcn(obj, src, eventdata) %#ok<INUSD>
            % Callback for displaying moving cursor
            try
                % Find the object that was hit
                point = get(obj.VisualFig, 'CurrentPoint');
                pos = obj.LastHit; 
                lenList = length(obj.HitList);
                for k = 1:lenList
                    s = obj.HitList{pos}.updateString(point);
                    if ~isempty(s)
                        % Place the cursor text so as not to roll off the edges
                        set(obj.CursorAnnotation, 'String', s);
                        aPos = get(obj.CursorAnnotation, 'Position');
                        if point(1) + obj.GapSize + aPos(3) > obj.FigHitPosition(3)
                            aPos(1) = point(1) - obj.GapSize() - aPos(3);
                        else
                            aPos(1) = point(1) + obj.GapSize();
                        end;
                        aPos(2) = min( point(2), obj.FigHitPosition(4) - aPos(4));
                        set(obj.CursorAnnotation, 'Position', aPos, 'Visible', 'on');
                        obj.LastHit = pos;
                        return     % return as soon as you have a cursor
                    end
                    pos = mod(pos, lenList) + 1;
                end
                set(obj.CursorAnnotation, 'Visible', 'off');
            catch exception
                exception    %#ok<NOPRT> % should be removed or replaced
            end
        end % windowButtonMotionFcn  
    
    end % private methods 
    
end % cursorExplorer 

