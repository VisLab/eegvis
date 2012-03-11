% visviews.verticalPanel() grid of vertically arranged resizable panels 
%
% Usage:
%   >>  visviews.verticalPanel(parent, manager, key)
%   >>  obj = visviews.verticalPanel(parent, manager, key)
%
% Description:
% visviews.verticalPanel(parent, manager, key) creates a grid of 
%      vertically arranged resizable panels. 
%
%      The parent is a graphics handle to the container for this plot. The
%      manager is an viscore.dataManager object containing managed objects
%      for the configurable properties of this object, and key is a string
%      identifying this object in the property manager GUI.
% 
% obj = verticalPanel(parent, manager, key) returns a
%      handle to a newly recreated vertical panel.
%
% visviews.verticalPanel is configurable, resizable, clickable, and 
% cursor explorable. 
%
% Example:
% Create a vertical panel that holds two detail views of random data
%   hf = figure('Name', 'Vertical panel example');
%   vp = visviews.verticalPanel(hf, [], []);
%   
%   % Set up the plots
%   plots = visviews.plotObj.createObjects( ...
%           'visviews.plotObj', visviews.dualView.getDefaultPlots(), []);
%   plots = plots(5:6);
%   man = viscore.dataManager();
%   vp.reset(man, plots);
%   
%   % Set up some data and plot
%   vdata = viscore.blockedData(random('exp', 2, [32, 1000, 20]), 'Random');
%   keyfun = @(x) x.('ShortName');
%   funs = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
%             visfuncs.functionObj.getDefaultFunctions(), keyfun);
%   slice1 = viscore.dataSlice('Slices', {':', ':', '3'}, ...
%    'DimNames', {'Channel', 'Sample', 'Window'});
%   vp.plot(vdata, funs{1}, slice1);
%   
%   % Reformat the margins
%   gaps = vp.getGaps();
%   vp.reposition(gaps);
%
% Notes:
% - If manager is empty, the class defaults are used to initialize.
% - If key| is empty, the class name is used to identify in GUI
%   configuration.
%
% Class documentation:
% Execute the following in the MATLAB command window to view the class 
% documentation for visviews.verticalPanel:
%
%    doc visviews.verticalPanel
%
% See also: visviews.axesPanel, visviews.clickable, 
%           visprops.configurable, visviews.cursorExplorable,
%           visviews.horizontalPanel, and visviews.resizable 

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

% $Log: verticalPanel.m,v $
% Revision: 1.00  04-Dec-2011 09:11:20  krobbins $
% Initial version $
%

classdef verticalPanel < uiextras.Panel & visprops.configurable ...
        & visviews.cursorExplorable & visviews.clickable & visviews.resizable
    
    properties (Access = private)
        PlotList = {};      % list of horizontal panels with plots 
    end % private properties
    
    methods
        
        function obj = verticalPanel(parent, manager, key)
            % Create a collection of vertically arranged panels
            obj = obj@uiextras.Panel('Parent', parent, ...
                   'BackgroundColor', [0.92, 0.92, 0.92]);   
            obj = obj@visprops.configurable(key); 
            % Update properties if any are available
            if isa(manager, 'viscore.dataManager')
                visprops.property.updateProperties(obj, manager);
            end    
        end % verticalPanel constructor
        
        function displayString = getCursorDisplay(obj, point)
            % Return the cursor string corresponding to point
            %
            % Parameters:
            %   point - a vector containing the (x, y) coordinates 
            %           of the point of interest (in pixels)
            %   displayString - (output) string associated with given point
            %
            % verticalPanel asks its children for the string. If point is
            % empty or none of its children have a non-empty display
            % string, displayString is empty
            selected = obj.get.SelectedChild();
            displayString = '';
            thisList = obj.PlotList{selected};
            for j = 1:length(thisList);
                displayString = getCursorDisplay(thisList{j}, point);
                if ~isempty(displayString)
                    break;
                end
            end
        end % getCursorDisplay
        
        function gap = getGaps(obj)
            % Find the overall maximum gap required for all subplots
            gap = [0 0 0 0];
            for k = 1:length(obj.PlotList)
                gap = max(gap, getGaps(obj.PlotList{k}));
            end
        end % getGaps

        function plot(obj, visData, bFunction, slice) %#ok<I)
            % Plot the specified data slice in each detail subpanel
            for k = 1:length(obj.PlotList);
                plotObj = obj.PlotList{k};
                plotObj.plot(visData, bFunction, slice);
            end
        end % plotSlice
        
        function registerCallbacks(obj, master)
            % Register the callbacks for the individual components
            for k = 1:length(obj.PlotList)
                registerCallbacks(obj.PlotList{k}, master);
            end 
        end % registerCallbacks
        
        function reposition(obj, margins)
            % Reposition internal plots with margins [top, right, bottom, left] 
            for k = 1:length(obj.PlotList)
                nextObj = obj.PlotList{k};
                nextObj.reposition(margins);
            end
            obj.redraw();
        end % reposition
    
        function reset(obj, propMan, plots)
            % Recreate vertical panels based on plots and propMan properties  
                   
            % Delete the children first
            children = get(obj, 'Children');  % Get the current panels
            for k = 1:length(children)
                delete(children(k));
            end            
            % Add a vertical flexible box
            pq = uiextras.VBoxFlex('Parent', obj, 'Spacing', 5,  ...
                    'Padding', 5, 'BackgroundColor', [0.92, 0.92, 0.92]);  
            obj.clearClickable();
            obj.PlotList = cell(length(plots), 1);
            for k = 1:length(plots)
                % Now create the individual horizontal plots
                obj.PlotList{k} = visviews.horizontalPanel(pq, [], []);
                reset(obj.PlotList{k}, propMan, plots(k));
                obj.mergeSource(obj.PlotList{k}, false);
            end
            obj.remapSources();  % See whether any sources are now available
        end % reset

        function updateProperties(obj, man)
           % Update detail panel properties as usual and store manager
           updateProperties@visprops.configurable(obj, man);
           obj.SMan = man;
           for k = 1:length(obj.PlotList)
                updateProperties(obj.PlotList{k}, man);
           end
       end % updateProperties
            
       function s = updateString(obj, point)
           % Return the string to be displayed for point. 
           % 
           % Parameters:
           %    point   a vector containing the (x, y) coordinates 
           %            of the point of interest (in pixels)
           %    s       (output) the first non empty string returned 
           %             by selected child panel plots.
           %
           % Implementation: Ask the plots in its list for the string.
           s = '';
           for j = 1:length(obj.PlotList)
               nextObj = obj.PlotList{j}; 
               s = nextObj.updateString(point);
               if ~isempty(s)
                   return
               end
           end
       end % updateString
                       
    end % public methods
    
end % verticalPanel


