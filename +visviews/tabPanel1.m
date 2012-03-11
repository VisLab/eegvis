% visviews.tabPanel   create a tabbed panel for holding multiple summary views
%
% Usage:
%   >>  visviews.tabPanel(parent, manager, key)
%   >>  obj = visviews.tabPanel(parent, manager, key)
%
% Description:
% visviews.tabPanel(parent, manager, key) creates a tabbed panel in which 
%      each tab contains horizontally arranged resizable panels. 
%
%      The parent is a graphics handle to the container for this plot. The
%      manager is an viscore.dataManager object containing managed objects
%      for the configurable properties of this object, and key is a string
%      identifying this object in the property manager GUI.
% 
% obj = tabPanel(parent, manager, key) returns a
%      handle to a newly recreated tab panel.
%
% 
% visviews.tabPanel is configurable, resizable, clickable, and 
% cursor explorable. 
%
% Example:
% Create a tab panel holding 3 summary views
%   hf = figure('Name', 'Repositions the panel');
%   tp = visviews.tabPanel(hf, [], []);
%   
%  % Set up the plots
%   plots = visviews.plotObj.createObjects( ...
%           'visviews.plotObj', visviews.dualView.getDefaultPlots(), []);
%   plots = plots(1:3);
%   man = viscore.dataManager();
%   
%   % Set up some data and plot
%   vdata = viscore.blockedData(random('exp', 2, [32, 1000, 20]), 'Random');
%   funs = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
%                           visfuncs.functionObj.getDefaultFunctions(), []);
%   slice1 = viscore.dataSlice('Slices', {':', ':', ':'}, ...
%                              'DimNames', {'Channel', 'Sample', 'Window'});
%   tp.setFunctions(funs);
%   
%   tp.reset(man, plots);
%   tp.plot(vdata, slice1);
%   
%   % Reformat the margins
%   gaps = tp.getGaps();
%   tp.reposition(gaps);
%
% Notes:
%  -  If manager is empty, the class defaults are used to initialize.
%  -  If key is empty, the class name is used to identify in GUI
%     configuration.
%
% Class documentation:
% Execute the following in the MATLAB command window to view the class 
% documentation for visviews.tabPanel:
%
%    doc visviews.tabPanel
%
% See also: visviews.axesPanel, visviews.clickable, 
%           visprops.configurable, visviews.cursorExplorable, 
%           visviews.horizontalPanel, visviews.resizable, and 
%           visviews.verticalPanel 
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

% $Log: tabPanel.m,v $
% Revision: 1.00  04-Dec-2011 09:11:20  krobbins $
% Initial version $
%

classdef tabPanel1 < uiextras.TabPanel & visprops.configurable & ...
                  visviews.cursorExplorable  & visviews.clickable & ...
                  visviews.resizable

    properties (Access = private)
        Functions = {};     % cell array of currently enabled function objects
        PlotList = {};      % list of horizontal panels (one for each tab panel)        
    end % private properties
    
    methods     
        
        function obj = tabPanel1(parent, manager, key)
            % Create the tab panel pass in the parent object
            obj = obj@uiextras.TabPanel('Parent', parent, ...
                'Units','Normalized', 'Position', [0, 0, 1, 1]);    
            obj = obj@visprops.configurable(key);
            set(obj, 'Callback', @obj.changeTabCallback);
             % Update properties if any are available
            if isa(manager, 'viscore.dataManager')
                visprops.property.updateProperties(obj, manager);
            end
        end % tabPanel constructor
        
       function gap = getGaps(obj)
            % Return the overall maximum gap required for all subplots
            gap = [0 0 0 0];
            for k = 1:length(obj.PlotList)
                gap = max(gap, getGaps(obj.PlotList{k}));
            end
        end % getGaps
        
        function bFunction = getSelectedFunction(obj)
            % Return a handle to the functionObj plotted in selected child
            bFunction = obj.Functions{obj.SelectedChild};
        end % getSelectedFunction
       
        function plot(obj, visData, dslice)
            % Plot the axes within each tab but do not necessarily display
            for k = 1:length(obj.Functions);
                   plotObj = obj.PlotList{k};
                   plotObj.plot(visData, obj.Functions{k}, dslice);
            end
        end % plotBlocks
                
        function registerCallbacks(obj, master)
            % Register the callback 
            for k = 1:length(obj.PlotList)
                registerCallbacks(obj.PlotList{k}, master);
            end
        end % registerCallbacks
        
        function reposition(obj, margins)
            % Reposition internal plots with margins [top, right, bottom, left] 
            % obj.Margins = margins;
            for k = 1:length(obj.PlotList)
                reposition(obj.PlotList{k}, margins);
            end
            obj.redraw();
        end % reposition
             
        function reset(obj, propMan, plots)
            % Recreate panels based on list of currently enabled functions and plots  
            numFunctions = length(obj.Functions);
            if numFunctions == 0
                warning('tabPanel:Empty', ...
                    'Cannot have an empty list of functions to plot');
                return;
            end                 
            % Delete the tabpanels we don't need  
            tabpanels = get(obj, 'Children');  % Get the current panels
            for k = (numFunctions + 1):length(tabpanels)
                delete(tabpanels(k));
            end           
            % Add some additional tabpanels if we need more
            for k = (length(tabpanels) + 1):numFunctions
                tabpanels(k) = uipanel('Parent', obj, 'BorderType', 'none', ...
                            'Units','Normalized', 'Position', [0, 0, 1, 1]);
                setappdata(tabpanels(k), 'ChildPlot', ...
                     visviews.horizontalPanel(tabpanels(k), [], []));
            end
            obj.clearClickable();
            for k = 1:numFunctions
                obj.PlotList{k} = getappdata(tabpanels(k), 'ChildPlot');
                reset(obj.PlotList{k}, propMan, plots);
                obj.mergeSource(obj.PlotList{k}, true);
            end           
            % Fix the tab names
            tNames = get(obj, 'TabNames');
            for k = 1:length(tNames)
                tNames{k} = obj.Functions{k}.getValue(1, 'ShortName');  
            end
            set(obj, 'TabNames', tNames);
            set(obj, 'SelectedChild', 1);
            drawnow
        end % reset
        
        function setFunctions(obj, functions)
            % Set the functions and clear the graphics objects
            obj.Functions = functions;
            obj.PlotList = {};
        end % setFunctions
        
        function updateProperties(obj, man)
            % Update tab panel properties as usual and store manager
            updateProperties@visprops.configurable(obj, man);
            for k = 1:length(obj.PlotList)
                updateProperties(obj.PlotList{k}, man);
            end
        end % updateProperties
        
        function s = updateString(obj, point)
           % Return the string to be displayed for point. 
           % 
           % Inputs:
           %    point   a vector containing the (x, y) coordinates 
           %            of the point of interest (in pixels)
           %
           % Outputs:
           %    s       (output) the first non empty string returned 
           %             by selected child panel plots.
           %
           % Implementation: Ask the plots in its list for the string.
           s = obj.PlotList{obj.SelectedChild}.updateString(point);
       end % updateString 
        
    end % public methods
    
    methods(Access = private)
        function changeTabCallback(obj, src, eventdata) %#ok<MANU,INUSD>
            pChild = eventdata.SelectedChild;
            obj.SelectedChild = pChild;
            set(obj.PlotList{pChild}, 'Units', 'normalized', 'Position', [0, 0, 1, 1]);
            obj.PlotList{pChild}.redraw()
        end % changeRequestCallback
   end
    
end % tabPanel

