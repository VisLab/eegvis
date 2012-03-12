% visviews.horizontalPanel create a grid of horizontally arranged resizable panels 
%
% Usage:
%   >>  visviews.horizontalPanel(parent, manager, key)
%   >>  obj = visviews.horizontalPanel(parent, manager, key)
%
% Description:
% visviews.horizontalPanel(parent, manager, key) creates a grid of 
%    horizontally arranged resizable panels. 
%
%    The parent is a graphics handle to the container for this plot. The
%    manager is an viscore.dataManager object containing managed objects
%    for the configurable properties of this object, and key is a string
%    identifying this object in the property manager GUI.
% 
% obj = horizontalPanel(parent, manager, key) returns a
%    handle to a newly recreated horizontal panel.
%
% 
% visviews.horizontalPanel is configurable, resizable, clickable, and 
% cursor explorable. 
%
% Example:
% Create a horizontal panel containing 3 summary visualizations
%   hf = figure('Name', 'Repositions the panel');
%   tp = visviews.horizontalPanel(hf, [], []);
%   
%   % Set up the plots
%   plots = visviews.plotObj.createObjects( ...
%           'visviews.plotObj', visviews.dualView.getDefaultPlots(), []);
%   plots = plots(1:3);
%   man = viscore.dataManager();
%   tp.reset(man, plots);
%   
%   % Set up some data and plot
%   vdata = viscore.blockedData(random('exp', 2, [32, 1000, 20]), 'Random');
%   funs = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
%                           visfuncs.functionObj.getDefaultFunctions());
%   slice1 = viscore.dataSlice('Slices', {':', ':', ':'}, ...
%    'DimNames', {'Channel', 'Sample', 'Window'});
%   tp.plot(vdata, funs{1}, slice1);
%   
%   % Reformat the margins
%   gaps = tp.getGaps();
%   tp.reposition(gaps);
%
% Notes:
%  - If manager is empty, the class defaults are used to initialize.
%  - If key is empty, the class name is used to identify in GUI
%    configuration.
%
% Class documentation:
% Execute the following in the MATLAB command window to view the class 
% documentation for visviews.horizontalPanel:
%
%    doc visviews.horizontalPanel
%
% See also: visviews.axesPanel, visviews.clickable, visprops.configurable,
%           visviews.cursorExplorable, visviews.resizable, 
%           visviews.tabPanel, and visviews.verticalPanel 
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

% $Log: horizontalPanel.m,v $
% Revision: 1.00  04-Dec-2011 09:11:20  krobbins $
% Initial version $
%

classdef horizontalPanel < uiextras.Panel & visprops.configurable & ...
                  visviews.cursorExplorable & visviews.clickable & ...
                  visviews.resizable
 
    properties (Access = private)
        PlotList = {};      % list of axes panels 
    end % private properties
    
    methods
        
        function obj = horizontalPanel(parent, manager, key)
            % Create a horizontal array of plots passing in the parent object
            obj = obj@uiextras.Panel('Parent', parent, ...
                               'BackgroundColor', [0.92, 0.92, 0.92], ...
                           'Units', 'normalized', 'Position', [0, 0, 1, 1]);
            obj = obj@visprops.configurable(key);
            if isa(manager, 'viscore.dataManager')
                visprops.property.updateProperties(obj, manager);
            end
        end % horizontalPanel constructor
       
       function gap = getGaps(obj)
            % Find the overall maximum gap required for all subplots
            gap = [0 0 0 0];
            for k = 1:length(obj.PlotList)
                gap = max(gap, getGaps(obj.PlotList{k}));
            end
        end % getGaps
        
        function plot(obj, visData, bFunction, dslice)
            % Plot the individual items in the panel
            
            % Make sure the units are set for resizing
            set(obj, 'Units', 'normalized', 'Position', [0, 0, 1, 1]);
            % Plot each panel 
            for k = 1:length(obj.PlotList);
                   plotObj = obj.PlotList{k};
                   plotObj.plot(visData, bFunction, dslice);
            end
        end % plot
        
        function registerCallbacks(obj, master)
            % Register the callbacks for the individual components
            for k = 1:length(obj.PlotList)
                registerCallbacks(obj.PlotList{k}, master);
            end 
        end % registerCallbacks
        
        function reposition(obj, margins)
            % Reposition internal plots with margins [top, right, bottom, left] 
            for k = 1:length(obj.PlotList)
                reposition(obj.PlotList{k}, margins);
            end
            obj.redraw();
        end % reposition
        
        function reset(obj, propMan, plots)
            % Recreate horizontal panels based on plots and propMan properties  
            
            % First delete existing children of the panel
            children = get(obj, 'Children');  % Get the current panels
            for k = 1:length(children)
                delete(children(k));
            end
            % Now create the flexible horizontal box
            hb = uiextras.HBoxFlex('Parent', obj, ...
                'Spacing', 5, 'Padding', 5, ...
            'BackgroundColor', [0.92, 0.92, 0.92]);
            
            % Populate the box with the required plots
            obj.clearClickable();
            obj.PlotList = cell(length(plots), 1);
            for k = 1:length(plots)
                pCon = plots{k};
                obj.PlotList{k} = obj.createPlot(pCon, hb, propMan);
                obj.processSource(obj.PlotList{k}, pCon);
            end
            obj.remapSources();
        end % reset
        
        function updateProperties(obj, man)
            % Update horizontal panel properties as usual 
            updateProperties@visprops.configurable(obj, man);
            for k = 1:length(obj.PlotList)
                updateProperties(obj.PlotList{k}, man);
            end
        end % updateProperties 
        
        function s = updateString(obj, point)
           % Return the string to be displayed for point, ignoring non explorable objects 
           % 
           % Inputs:
           %    point   a vector containing the (x, y) coordinates 
           %            of the point of interest (in pixels)
           %
           % Outputs:
           %    s       (output) the first non empty string returned 
           %             by selected child panel plots.
           %
           % Implementation: Ask the children who are cursorExplorable
           % if they can identify the point
           s = '';
           for k = 1:length(obj.PlotList)
               if isa(obj.PlotList{k}, 'visviews.cursorExplorable')
                    s = updateString(obj.PlotList{k}, point);
               end
               if ~isempty(s)
                   return
               end
           end
       end % updateString
       
    end % public methods
    
    methods (Access = private)
        
        function p = createPlot(obj, pCon, parent, propMan)  %#ok<INUSL,MANU>
            % Create an actual graphics object corresponding to pCon plotObj
            p = [];
            s = 'empty';
            try
                s = [pCon.getDefinition() '(parent, propMan, ''' ...
                          pCon.getDisplayName() ''')'];
                p = eval(s);
                if isempty(propMan)
                    return;
                end
                cProps = propMan.getObject(pCon.getObjectID());
                if ~isempty(cProps)
                   p.updateProperties(cProps.getStructure());
                end
            catch ME 
                warning ('horizontalPanel:CreatePlot', ...
                         [ME.message ' Bad: definition [' s ']']);
            end
        end % createPlot
        
    end % private methods
    
end % horizontalPanel

