% visviews.dualView  two level-viewer with upper panel summaries and lower panel details
%
% Usage:
%   >>  visviews.dualView()
%   >>  visviews.dualView('key1', 'value1', ....)
%   >>  obj = visviews.dualView(...)
%
% Description:
% visviews.dualView() creates a summary/detail viewer divided into two
%    levels. The top portion contains multiple summary views organized 
%    by tabs. The bottom portion contains various detail panels, which 
%    display relatively small portions of the data. A user selects detail 
%    views by clicking a summary view. The user can configure the 
%    arrangement of viewing panels and how summary and detail panels link.
%
% visviews.dualView('key1', 'value1', ....) specifies optional parameter
%    name/value pairs.
%
%    'VisData'        blockedData object or a 3D array of data
%
%    'Functions'      dataManager, structure, or cell array of 
%                     initial functions
%
%    'Plots'          dataManager, structure, or cell array of 
%                     initial plots
%
%    'Properties'     dataManager, structure, or cell array of 
%                     initial properties
%
% visviews.dualView is configurable, resizable, and clickable. It
% is also a container for a cursor explorer.
%
% Configurable properties
% The visviews.dualView has five configurable parameters: 
%
% BlockName specifies base name of the windows in the block summaries
%    for non-epoched data.
%
% BlockSize specifies the number of frames in a block for non-epoched
%    data (e.g., 'Window').
%
% ElementName specifies the base name of an element (e.g., 'Channel').
%
% EpochName specifies the base name of the windows in block summaries
%    for epoched data.
%
% VisName specifies the prefix used for the name on the figure window 
%    title bar.
%
% Example:
% Create a viewer to show some data
%   data = random('exp', 2, [32, 1000, 20]); % Create some random data
%   visviews.dualView('VisData', data); % View the data
%
% Notes:
%   - Many summaries supported by this viewer are window or epoch oriented.
%   - Some displays treat epoched data differently than non-epoched data.
%   - Epoched data may not be continuous and cannot be reblocked by
%     changing the block size.
%
% Class documentation:
% Execute the following in the MATLAB command window to view the class 
% documentation for visviews.dualView:
%
%    doc visviews.dualView
%
% See also: eegbrowse, eegplugin_eegvis,and eegvis
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

% $Log: dualView.m,v $
% Revision: 1.00  04-Dec-2011 09:11:20  krobbins $
% Initial version $
%

classdef dualView < hgsetget & visprops.configurable & visviews.clickable
    
    properties
        % Configurable properties
        BlockName = 'Window';     % name designating a block or window
        BlockSize = 1000;         % size of windows (blocks if unepoched)     
        ElementItemNames = {};    % element item names (not supported)
        ElementName = 'Channel';  % general element name (e.g., channel)
        EpochName = 'Epoch';      % name designating an epoch
        VisName = 'eegvis';       % name on visualization figure title bar
        
        % Other public properties
        VisFig = [];              % visualization figure handle
        VisSource;                % string identifier of visualization origin        
    end % public properties
    
    properties (Access = private)
        DetailNumber = 1;         % number of the block or element in details
        DetailPanel = [];         % detail panel
        ElementDetails = false    % when true, plot all windows for an element
        ExploratoryCursor = [];   % cursorExplorer object
        GUIClosing = false;       % indicates whether GUI in process of closing
        SummaryPanel = [];        % summary tab panel        
        VisData = [];             % blockedData object containing data        
        WindowName = 'Window';    % name actually used for block dimension name
                
        % Selectors for managing configurable resources
        FunSelect;                % selector managing function configuration
        PlotSelect;               % selector managing plot configuration
        PropSelect;               % selector managing property configuration
    end % private properties
    
    methods
        
        function obj = dualView(varargin)
            % Create visualization and initialize displays
            obj = obj@visprops.configurable([]);
            obj.FunSelect = viscore.dataSelector('visfuncs.functionConfig');
            addlistener(obj.FunSelect, 'StateChanged', @obj.updateOnFunctionChange);
            obj.PlotSelect = viscore.dataSelector('visviews.plotConfig');
            addlistener(obj.PlotSelect, 'StateChanged', @obj.updateOnPlotChange);
            obj.PropSelect = viscore.dataSelector('visprops.propertyConfig');
            addlistener(obj.PropSelect, 'StateChanged', @obj.updateOnPropertyChange);
            obj.parseParameters(varargin{:});            
            % Create the figure
            obj.VisFig = figure('Name', obj.VisName, ...
                'NumberTitle','off', 'Color', [1, 1, 1], ...
                'Units', 'normalized', 'UserData', obj, ...
                'Visible', 'on', 'Tag', 'VisFig', ...
                'DeleteFcn', {@obj.closeRequestCallback});
            obj.createLayout();
            obj.reset(true, true, true);
        end % dualView constructor
        
        function delete(obj)
            % Delete associated figures when this object is deleted
            obj.GUIClosing = true;
            obj.deleteDependentViews();
            x = obj.VisFig;
            obj.VisFig = [];
            if isempty(x) || ~ishandle(x) || ...
                    strcmpi('on', get(x, 'BeingDeleted'))
                return;
            end
            delete(x);
        end % delete
        
        function conObjs = getConfigurableObjs(obj)
            % Return cell array of this object's configurable objects
            vConf = visprops.configurableObj('visviews.dualView', [], 'visviews.dualView');
            vConf.CategoryModifier = '';
            pConf = obj.PlotSelect.getObjects();
            pConf = visviews.plotObj.createConfigurableObjs(pConf);
            conObjs = [{vConf}, pConf(:)'];
        end % getConfigurableObjs
        
        function names = getDimensionNames(obj)
            % Return current dimension names for the visualization 
            names = {obj.ElementName, 'Sample', obj.WindowName};
        end % getDimensionNames
        
        function clickable = getIsClickable(obj)
            % Return true if visualization in state to process mouse clicks
            clickable = isempty(obj.ExploratoryCursor) || ...
                ~obj.ExploratoryCursor.ison();
            clickable = clickable && ...
                ~strcmpi(get(zoom(obj.VisFig), 'Enable'), 'on');
        end % getIsClickable
        
        function plotDetails(obj, bFunction, slice)
            % Plot target based on slice
            %
            % Inputs:
            % currentElement  number of the current element
            obj.DetailPanel.plot(obj.VisData, bFunction, slice);
        end % plotSlice

        function registerCallbacks(obj)
            % Add the button down callbacks for component visualizations
            registerCallbacks(obj.SummaryPanel, obj);
            registerCallbacks(obj.DetailPanel, obj);
        end % registerCallbacks
        
        function reset(obj, functionChange, plotChange, propertyChange) 
            % Redraw all panels with current values of plots, functions, settings
            if isempty(obj.VisData)  % If no data can't reset
                return;
            end    
            
            % Get the property manager for this visualization
            sMan = obj.PropSelect.getManager();
            
            % If the plots have changed we have to update property GUI
            if plotChange   
                pConf = obj.getConfigurableObjs();     % get new plots
                propMan = obj.PropSelect.getManager(); % get current configurable objects                
                % Update the property manager based on the plots
                visprops.configurableObj.updateManager(propMan, pConf);                
                % Update the property view GUI if it is open
                obj.PropSelect.setManager(propMan);
            end        
            
            % Make sure new properties have been processed at top level
            if propertyChange || plotChange      
                obj.updateProperties(sMan);                
            end  
            
            % Title figure window appropriately, taking into account source
            name = obj.VisData.DataID;
            namePrefix = obj.VisName;
            if ~isempty(obj.VisSource)
                namePrefix = [namePrefix ' (' obj.VisSource ')'];
            end
            if ~isempty(namePrefix)
                name = [namePrefix ': ' name];
            end
            set(obj.VisFig, 'Name', name);
            obj.getConfigObj().CategoryModifier = obj.VisName;    
            
            % Set window name and reblock the data if necessary
            if (obj.VisData.isEpoched())
                obj.WindowName = obj.EpochName;
            else
                obj.WindowName = obj.BlockName;
            end
            if obj.VisData.getBlockSize() ~= obj.BlockSize
                obj.VisData.reblock(obj.BlockSize);
            end            
            
            % Update the function values and update functions onsummary panel
            if functionChange   % if functions have changed, update properties 
                funMan = obj.FunSelect.getManager();
                obj.SummaryPanel.setFunctions(funMan.getEnabledObjects(''));
            end
            
            % Reset the subpanels
            obj.clearClickable();
            plotMan = obj.PlotSelect.getManager();
            obj.SummaryPanel.reset(sMan, plotMan.getEnabledObjects('summary'));
            obj.mergeSource(obj.SummaryPanel, true);
            obj.DetailPanel.reset(sMan, plotMan.getEnabledObjects('detail'));
            obj.mergeSource(obj.DetailPanel, false);
            obj.remapSources();
            
            % Plot the visualizations and adjust cursor and callbacks
            initializePlots(obj);
            obj.adjustMargins();
            obj.ExploratoryCursor.clear();
            obj.ExploratoryCursor.addExplorable({obj.SummaryPanel, obj.DetailPanel});
            obj.registerCallbacks();
            obj.initializeFromSources();
        end % reset
        
        function setDataSource(obj, visData)
            % Set the data source to visData
            obj.VisData = visData;
        end % setDataSource
        
        function setFunctionManager(obj, fMan)
            % Set the function manager to fMan
            obj.FunSelect.setManager(fMan);
        end % setFunctionManager
        
        function setPlotManager(obj, pMan)
            % Set the plot manager to pMan
            obj.PlotSelect.setManager(pMan);
        end % setPlotManager
        
        function setPropertyManager(obj, sMan)
            % Set the property manager to sMan
            obj.PropSelect.setManager(sMan);
        end % setPropertyManager
        
        function updateOnFunctionChange(obj, src, evtdata) %#ok<INUSD>
            % Actions to be taken when functions GUI Apply button clicked
            obj.reset(true, false, false);
        end % updateOnFunctionChange
        
        function updateOnPlotChange(obj, src, evtdata) %#ok<INUSD>
            % Actions to be taken when plot list GUI Apply button clicked
            % Update the view
            obj.reset(false, true, false);
        end % updateOnPlotChange
        
        function updateOnPropertyChange(obj, src, evtdata) %#ok<INUSD>
            % Actions to be taken when properties GUI Apply button clicked
            obj.reset(false, false, true);
        end % updateOnPropertyChange
        
    end % public methods
    
    methods (Access = private)
        
        function adjustMargins(obj)
            % Adjust panel margins to assure even borders around outside
            minGaps = visviews.axesPanel.MinimumGaps;
            maxGaps = visviews.axesPanel.MaximumGaps;
            summaryGaps = getGaps(obj.SummaryPanel);
            detailGaps = getGaps(obj.DetailPanel);
            detailMargins = [max([detailGaps(1), summaryGaps(1)]), ...
                detailGaps(2), ...
                max([detailGaps(3), summaryGaps(3)]), ...
                minGaps(4)];
            summaryMargins = [max([detailGaps(1),summaryGaps(1)]), ...
                summaryGaps(2)...
                max([detailGaps(3), summaryGaps(3)]), ...
                minGaps(4)];
            reposition(obj.DetailPanel, min(detailMargins, maxGaps));
            reposition(obj.SummaryPanel, min(summaryMargins, maxGaps));
        end % adjustMargins
        
        function closeRequestCallback(obj, src, eventdata) %#ok<INUSD>
            % On window closing, delete everything
            if isempty(src) || ~ishandle(src) || obj.GUIClosing
                return;
            end
            obj.delete();
        end % closeRequestCallback
        
        function createLayout(obj)
            % Create the layout for the visualization but do not force draw
            mainVBox = uiextras.VBoxFlex('Parent', obj.VisFig, ...
                'Tag', 'MainVBox', ...
                'Spacing', 5, 'Padding', 5, ...
                'BackgroundColor', [0.92, 0.92, 0.92]);
            obj.SummaryPanel = visviews.tabPanel(mainVBox, obj.PropSelect.getManager(), []);
            obj.DetailPanel = visviews.verticalPanel(mainVBox, obj.PropSelect.getManager(), []);
            obj.ExploratoryCursor = visviews.cursorExplorer(obj.VisFig);
            hToolbar = findall(obj.VisFig, 'Type', 'uitoolbar');
            p = which('pop_visviews.m');
            p = p(1:strfind(p, 'pop_visviews.m') - 1);
            fxIcon = imread([p 'icons/fx20LighterBlue.png']);
            plotsIcon = imread([p 'icons/plottoolsLighterBlue.png']);
            settingsIcon = imread([p 'icons/settingsLighterBlue.png']);
            uipushtool(hToolbar, 'CData', fxIcon,...
                'Separator', 'on', 'HandleVisibility','off', 'TooltipString', ...
                'Edit functions', ...
                'Tag', 'FunctionsDualView', ...
                'ClickedCallback', {@viscore.dataSelector.configureCallback, ...
                obj.FunSelect, [obj.VisName ': Edit functions']});
            uipushtool(hToolbar, 'CData', plotsIcon,...
                'Separator', 'on', 'HandleVisibility','off', 'TooltipString', ...
                'PlotListDualView',  'Tag', 'PlotsDualView', ...
                'ClickedCallback', {@viscore.dataSelector.configureCallback, ...
                obj.PlotSelect, [obj.VisName ': Edit list of plots']});
            uipushtool(hToolbar, 'CData', settingsIcon,...
                'Separator', 'on', 'HandleVisibility','off', 'TooltipString', ...
                'Edit visualization settings', ...
                'Tag', 'PropertiesDualView', ...
                'ClickedCallback', {@viscore.dataSelector.configureCallback, ...
                obj.PropSelect, [obj.VisName ': Configure properties']});
        end % createLayout
        
        function deleteDependentViews(obj)
            % Delete any GUIs associated with this object's selectors
            dvs = {obj.FunSelect, obj.PlotSelect, obj.PropSelect};
            obj.FunSelect = [];
            obj.PlotSelect = [];
            obj.PropSelect = [];
            for k = 1:length(dvs)
                if ~isempty(dvs{k}) && isvalid(dvs{k})
                    delete(dvs{k});
                end
            end
        end % deleteDependentViews
        
        function initializePlots(obj)
            % Replot each of the panels - plot window 1 in the details
            slice1 = viscore.dataSlice('Slices', {':', ':', ':'}, ...
                   'DimNames', obj.getDimensionNames());
            obj.SummaryPanel.plot(obj.VisData, slice1);
            slice2 = viscore.dataSlice('Slices', {':', ':', '1'}, ...
                   'DimNames', obj.getDimensionNames());
            bFunction = obj.SummaryPanel.getSelectedFunction();
            obj.DetailPanel.plot(obj.VisData, bFunction, slice2)
        end % initializePlots
        
        function parseParameters(obj, varargin)
            % Parse command line parameters and set defaults
            %
            % Inputs:
            %    varargin   command line parameters for class
            %
            % Notes:
            %   - See visviews.dualView.getParser for command line specification
            %   - This method is only called for initialization
            parser = visviews.dualView.getParser();
            parser.parse(varargin{:});
            if isempty(parser.Results)
                data = [];
            else
                data = parser.Results;
            end          
 
            % Set up the functions
            fMan = obj.FunSelect.getManager();
            if isfield(data, 'Functions') && ...
                    isa(data.Functions, 'viscore.dataManager')
                bfs = data.Functions.getObjects();
            elseif isfield(data, 'Functions') && ~isempty(data.Functions)
                bfs = data.Functions;
            else
                bfs = visviews.dualView.getDefaultFunctions();
            end
            bfs = visfuncs.functionObj.createObjects( ...
                'visfuncs.functionObj', bfs);
            fMan.putObjects(bfs);
            obj.FunSelect.setManager(fMan);            
            % Set up the plots
            pMan = obj.PlotSelect.getManager();
            if isfield(data, 'Plots') && ...
                    isa(data.Plots, 'viscore.dataManager')
                pls = data.Plots.getObjects();
            elseif isfield(data, 'Plots') && ~isempty(data.Plots)
                pls = data.Plots;
            else
                pls = visviews.dualView.getDefaultPlots();
            end
            pls = visviews.plotObj.createObjects('visviews.plotObj', pls);
            pMan.putObjects(pls);
            obj.PlotSelect.setManager(pMan);            
            % Set up the configurable properties
            sMan = obj.PropSelect.getManager();
            if isfield(data, 'Properties') && ...
                    isa(data.Properties, 'viscore.dataManager')
                prs = data.Properties.getObjects();
            elseif isfield(data, 'Properties') && ~isempty(data.Properties)
                prs = data.Properties;
            else
                prs = {};
            end
            prs = visprops.configurableObj.createObjects(prs);
            sMan.putObjects(prs);
            
            obj.PropSelect.setManager(sMan);            
            % Initialize the data
            if isfield(data, 'VisData') && isa(data.VisData, 'viscore.blockedData')
                obj.VisData = data.VisData;
            elseif isfield(data, 'VisData') && ~isempty(data.VisData)
                obj.VisData = viscore.blockedData(data.VisData, ...
                    [obj.VisName ' (' obj.VisSource ') args']);
            else
                obj.VisData = [];
            end
        end % parseParameters
        

    end  % private methods
    
    methods (Static=true)
               
        function fStruct = getDefaultFunctions()
            % Structure specifying the default functions (one per tab)
            fStruct = struct( ...
                'Enabled',        {true,          true}, ...
                'Category',       {'block',       'block'}, ...
                'DisplayName',    {'Kurtosis',    'Std Dev'}, ...
                'ShortName',      {'K',        'SD'}, ...
                'Definition',     {'@(x) (kurtosis(x, 1, 2))', ...
                '@(x) (std(x, 0, 2))'}, ...
                'ThresholdType',  {'z score',    'z score'}, ...
                'ThresholdScope', {'global'     'global'}, ...
                'ThresholdLevels', {3,              3}, ...
                'ThresholdColors', {[1, 0, 0],    [0, 1, 1]}, ...
                'BackgroundColor', {[0.7, 0.7, 0.7], [0.7, 0.7, 0.7]}, ...
                'Description',    {'Kurtosis computed for each (element, block)', ...
                'Standard deviation computed for each (element, block)' ...
                });
        end % getDefaultFunctions
        
        function settings = getDefaultProperties()
            % Structure specifying how to set configurable public properties
            cName = 'visviews.dualView';
            settings = struct( ...
                'Enabled',       {true,         true,          true,             true,             true}, ...
                'Category',      {cName,        cName,         cName,            cName,            cName}, ...
                'DisplayName',   {'Block name', 'Block size',  'Element name',   'Epoch name',     'Visualization name'}, ...
                'FieldName',     {'BlockName', 'BlockSize'     'ElementName',    'EpochName',      'VisName'}, ...
                'Value',         {'Window',     1000,          'Channel',        'Epoch',          'eegvis'}, ...
                'Type',          { ...
                'visprops.stringProperty', ...
                'visprops.doubleProperty', ...
                'visprops.stringProperty', ...
                'visprops.stringProperty', ...
                'visprops.stringProperty'}, ...
                'Editable',      {true,         true,          true,             true,             true}, ...
                'Options',       {'',           [0, inf],      '',               '',               ''}, ...
                'Description',   {...
                'Block name or label (e.g. ''Window'')', ...
                'Number of samples in a block (unsigned int)', ...
                'Element name (e.g. ''Channel'')', ...
                'Epoch name or label (e.g. ''Epoch'')', ...
                'Visualization figure title bar identification' ...
                });
        end % getDefaultProperties
        
        function pStruct = getDefaultPlots()
            % Structure specifying the individual visualizations used
            pStruct = struct( ...
                'Enabled',        {true,           true,           true,          false,            false,          false,            true,           true}, ...
                'Category',       {'summary',      'summary',      'summary',     'summary',       'summary',       'summary',       'detail',        'detail'}, ...
                'DisplayName',    {'Block image',  'Element box',  'Block box',   'Block histogram', 'Block Scalp', 'Signal histogram', 'Stacked signal', 'Shadow signal'}, ...
                'Definition', { ...
                'visviews.blockImagePlot', ...
                'visviews.elementBoxPlot', ...
                'visviews.blockBoxPlot', ...
                'visviews.blockHistogramPlot', ...
                'visviews.blockScalpPlot', ....
                'visviews.signalHistogramPlot', ...
                'visviews.signalShadowPlot', ...
                'visviews.signalStackedPlot', ...
                }, ...
                'Sources', { ...
                'None', ...
                'None', ...
                'None', ... 
                'None', ...
                'None', ...
                'None', ...
                'Master', ...
                'Master'}, ...
                'Description', { ...
                'Image of blocked value array', ...
                'Box plot of block summary values for each element', ...
                'Box plot of block summary values for groups of blocks', ...
                'Histogram of the block summary values', ...
                'Scalp map of the block summary values', ...
                'Histogram of the signal values', ...
                'Stacked plot of raw signals in a time window', ...
                'Shadow plot of raw signals in a time window' ...
                });
        end % getDefaultPlots

        function parser = getParser()
            % Create an inputparser for DualView
            parser = inputParser;
            parser.addParamValue('VisData', [], ...
                @(x) validateattributes(x, ...
                {'viscore.blockedData', 'numeric'}, {}));
            parser.addParamValue('Functions', [], ...
                @(x) validateattributes(x, ...
                {'struct', 'cell', 'viscore.dataManager'}, {}));
            parser.addParamValue('Plots', [], ...
                @(x) validateattributes(x, ...
                {'struct', 'cell', 'viscore.dataManager'}, {}));
            parser.addParamValue('Properties', [], ...
                @(x) validateattributes(x, ...
                {'cell', 'viscore.dataManager'}, {}));
        end % getParser()
        
    end % static methods
    
end % dualView

