% eegbrowse GUI for selecting files for visualization
%
% Usage:
%   >> eegbrowse()
%   >> eegbrowse('name1', 'value1', ....)
%   >> obj = eegbrowse(...)
%
% Description:
% eegbrowse()   opens a GUI for selecting files for visualization. 
%     After moving to a directory containing EEG files, click on a file 
%     name to choose a file.  Currently eegbrowse only works for EEGLAB 
%    .set files, but support for additional formats should be available. 
%
% eegbrowse('name1', 'value1', ....) specifies optional parameter
%    name/value pairs:
%
%    'FileName'   name of an initial data file to be read in
%
%    'FilePath'   path of the initial data file to be read
%
%    'Functions'  manager, structure array, or cell array of initial 
%              summary functions
%
%    'Plots'      manager, structure array, or cell array of 
%              visualizations to use
%
%    'Properties' manager or cell array specifying defaults
%              for public properties
%
%    'Title'      string displayed on the figure window title bar
%
%    'UseEEGLab'  if true, start eeglab if necessary when data set loaded
%
%
% obj = eegbrowse(...) returns a handle to the created GUI.
%
%
% eegbrowse is configurable and resizable.
%
% eegbrowse GUI operation (component actions):
%
%     Browse          Push this button to display a modal file 
%                     chooser for selecting a directory containing 
%                     EEG .set files. After the chooser displays a 
%                     list of files, click on one to visualize or
%                     load into the workspace.
%
%     Open            Push this button to load the currently 
%                     selected file into an EEG structure in the 
%                     base workspace and to update ALLEEG and 
%                     ALLCOM for EEGLAB.
%
%     Functions       Push this button to display a GUI for
%                     configuring the summary functions to use in 
%                     subsequent visualizations.  These
%                     changes do not affect the current
%                     visualization, but rather eegbrowse uses
%                     them in creating the next visualization.
%
%     Plots           Push this button to display a GUI for
%                     configuring which visualization panels to use
%                     in subsequent visualizatons. These
%                     changes do not affect the current
%                     visualization, but rather eegbrowse uses
%                     them in creating the next visualization.
%
%     Properties      Push this button to display a property
%                     manager GUI for setting the public properties
%                     of eegbrowse as well as the default public
%                     properties of the visualization panels used in
%                     subsequent visualizations.
%
%     Load            Push this button to display a modal
%                     file browser for loading a saved configuration
%                     into eegbrowse. The configuration 
%                     should be in the format described for Save.
%                     If vars.configuration.funs is non empty,
%                     it replaces the current list of summary functions
%                     for subsequent visualizations. 
%
%                     If vars.configuration.plots is non empty,
%                     it replaces the current list of visualization panels.
%
%                     If vars.configuration.props is non empty,
%                     it replaces the current values of the configurable
%                     properties of eegbrowse as well as the
%                     default values of the configurable public properties
%                     of the visualization panels in subsequent
%                     visualizations.
%
%     Save            Push this button to display a modal
%                     file browser for saving an eegbrowse
%                     configuration structure vars. The fields
%                     of the vars structure are:                     
%                          vars.date
%                          vars.class (in this case eegbrowse)
%                          vars.configuration.funcs
%                          vars.configuration.plots
%                          vars.configuration.props
%
%     Load workspace  Check this box to load the selected file
%                     into the base workspace and update ALLEEG and
%                     ALLCOM each time the user clicks a file name. If
%                     the checkbox is unchecked (the default), do not
%                     update the workspace when a file name is clicked.
%
%     Preview         Check this box to display a visualization when
%                     a file name is clicked. If the checkbox is unchecked,
%                     a visualization is not displayed.
%
%     New figure      Check this box to create a new figure window
%                     for each visualization. This checkbox has not effect
%                     if Preview is unchecked.
%
% Configurable properties:
% The eegbrowse has one configurable public property: 
%
%     title           String displayed on the figure window title bar.
%
% Example:
% Create a browser for previewing EEG files
%
%    eegbrowse('FilePath', 'M:\NeuroErgonomicsData\Attention Shift',  ...
%              'Title', 'Browsing data');
%
% Notes:
% - eegbrowse can be run either as a standalone program or as a
%   plugin for EEGLab.
%
% Class documentation:
% Execute the following in the MATLAB command window to view the class 
% documentation for eegbrowse:
%
%    doc eegbrowse
%
% See also: visviews.dualView, eegplugin_eegvis, and eegvis
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

% $Log: eegbrowse.m,v $
% Revision 1.00  10-Jun-2011 16:44:07  krobbins
% Initial version
%

classdef eegbrowse < hgsetget & visprops.configurable
    
    properties
        ConFig                % figure window for the browser
        Title = 'eegbrowse';  % title for selector figure window
        UseEEGLab = false;    % if true, EEGLAB is loaded when data loaded into workspace
        VisSource = '';       % origination for visualization (for figure title)
        VisualFig             % current figure window for the visualizations
    end % public properties
    
    properties(SetAccess = private)
        CurrentDirectory      % current directory for browser
        DirectoryCtrl         % editable text box with selected directory
        FigList;              % cell array of figures created by this browser
        FileList              % list of files in currently selected directory
        FileName = [];        % name of currently selected set file
        FilePath = [];        % path to currently selected directory
        FunSelect;            % FunctionSelector for handling function list
        GUIClosing;           % indicates whether GUI is initiating close
        LoadSaveFile = ''     % path where configuration was last loaded or saved
        LoadSavePath = ''     % path where configuration was last loaded or saved
        LoadOnSelectCB        % if true, load data into base workspace on file selection
        NewFigureCB           % if true, a new figure is created on each reset
        PlotSelect;           % PlotSelector for handling plot list
        PreviewOnSelectCB     % if true, update visualization on file selection
        PropSelect;           % PropertySelector for handling configuration
    end % private properties
    
    methods
        
        function obj = eegbrowse(varargin)
            % Constructor sets up GUI for launching visualizations
            obj = obj@visprops.configurable([]);
            obj.FunSelect = viscore.dataSelector('visfuncs.functionConfig');
            addlistener(obj.FunSelect, 'StateChanged', @obj.updateOnFunctionChange);
            obj.PlotSelect = viscore.dataSelector('visviews.plotConfig');
            addlistener(obj.PlotSelect, 'StateChanged', @obj.updateOnPlotChange);
            obj.PropSelect = viscore.dataSelector('visprops.propertyConfig');
            addlistener(obj.PropSelect, 'StateChanged', @obj.updateOnPropertyChange);
            obj.parseParameters(varargin{:});
            obj.FigList = {};
            obj.GUIClosing = false;
            obj.ConFig = figure( ...
                'Toolbar', 'none', 'MenuBar', 'none', ...
                'WindowStyle', 'normal', 'DockControls', 'on', ...
                'NumberTitle','off', 'Name', obj.Title, ...
                'Color', [0.941176 0.941176 0.941176], ...
                'UserData', obj, ...
                'DeleteFcn', {@obj.closeRequestCallback});
            uimenu(obj.ConFig);  % Make this GUI dockable
            obj.createLayout(obj.ConFig);
            obj.updateFileList();
            obj.reset(true);
        end % eegbrowse constructor
        
        function delete(obj)
            % Delete the associated figure when this object is deleted
            if obj.GUIClosing
                return;
            end
            obj.GUIClosing = true;
            obj.deleteDependentViews() % should vis figures be deleted?
            x = obj.ConFig;
            obj.ConFig = [];
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
            conObjs = [{obj.getConfigObj(), vConf}, pConf(:)'];
        end % getConfigurableObjs
        
        function reset(obj, reread)
            % Redraw visualization with new data, plots, settings and functions
            %
            % Inputs:
            %    reread    if true this reset came from selecting new
            %              data. If false this reset came from changing
            %              configuration and data may not need to be loaded
            %
            try
 
                if isempty(obj.FileName) || isempty(obj.FilePath)
                    return; % Data file cannot be read so don't do anything
                end
                % Do we need a new window if previewing?
                createNew = get(obj.NewFigureCB, 'Value') == get(obj.NewFigureCB,'Max') ...
                    || isempty(obj.VisualFig) || ~isvalid(obj.VisualFig) ...
                    || ~isa(obj.VisualFig, 'hgsetget')  ...
                    || ~ishandle(obj.VisualFig.VisFig);
                
                % Should we be previewing data because selected?
                previewSelected = reread && ...
                    (get(obj.PreviewOnSelectCB, 'Value') == ...
                    get(obj.PreviewOnSelectCB,'Max'));
                
                % Should we be trying to load the base workspace with EEG?
                loadSelected = reread && (get(obj.LoadOnSelectCB, 'Value') ...
                    == get(obj.LoadOnSelectCB,'Max'));
                
                % Should we actually read the data?
                readData = previewSelected || loadSelected || ...
                    (~reread && createNew);
                
                % Should we actually preview the data?
                previewData = previewSelected || ~reread;
                
                % If not going to preview or load data, no point continuing
                if ~(readData || previewData)
                    return;
                end
                
                if createNew   % Create a new figure window if necessary
                    obj.VisualFig = visviews.dualView();
                    obj.FigList{end+1} = obj.VisualFig;
                end
                
                % Set the managers for the functions, plots and properties
                obj.VisualFig.setFunctionManager(obj.FunSelect.getManager().clone());
                obj.VisualFig.setPlotManager(obj.PlotSelect.getManager().clone());
                obj.VisualFig.setPropertyManager(obj.PropSelect.getManager().clone());
                
   
                if readData %Read the data if needed
                    eData = eegbrowse.readEEG(obj.FileName, obj.FilePath, ...
                                            loadSelected);
                    if loadSelected && obj.UseEEGLab
                          cmd ='eeglab(''redraw'');';
                          evalin('base', cmd);
                          cmd = '''eeglab(''''redraw'''');''';
                          evalin('base', ['ALLCOM = {' cmd ' ALLCOM{:}};']);
                    end
                    if ~previewData % Don't need to show the data, so done
                        return;
                    end
                    dataID = [obj.FileName ' [' obj.FilePath ']'];
                    obj.VisualFig.setDataSource(...
                        eegbrowse.getBlockDataFromEEG(eData, dataID));
                end
                
                % Now actually draw visualization
                obj.VisualFig.VisSource = obj.VisSource;
                obj.VisualFig.reset(true, true, true);
                drawnow
               
            catch ME
                fprintf(['eegbrowse: Data could not be read ' ...
                    '[%s]:%s\n'], ME.identifier, ME.message);
            end
        end % reset
        
        function updateOnFunctionChange(obj, src, evtdata) %#ok<MANU,INUSD>
            % Actions to be taken when Functions GUI Apply button clicked
        end % updateOnFunctionChange
        
        function updateOnPlotChange(obj, src, evtdata) %#ok<INUSD>
            % Actions to be taken when Plot list GUI Apply button clicked
            pConf = obj.getConfigurableObjs();        % get new plots
            propMan = obj.PropSelect.getManager();    % get current configurable objects
            % Update the property manager based on the plots
            visprops.configurableObj.updateManager(propMan, pConf);
            % Update the property view GUI if it is open
            obj.PropSelect.setManager(propMan);
        end % updateOnPlotChange
        
        function updateOnPropertyChange(obj, src, evtdata) %#ok<MANU,INUSD>
            % Actions to be taken when Properties GUI Apply button clicked
        end % updateOnPropertyChange
        
    end % public methods
    
    methods (Access = protected)
        
        function buttons = createButtonPanel(obj, parent)
            % Create the button panel on the side of GUI
            buttons = uiextras.Grid('Parent', parent, ...
                'Tag', 'EditGrid', 'Spacing', 2, 'Padding', 1);
            obj.createControlButtons(buttons);
            uiextras.Empty('Parent', buttons);
            obj.createCloseButtons(buttons);
            set(buttons, 'RowSizes', [30, 30, 30, 30, 30, -1, 30, 30, 30], ...
                'ColumnSizes', 100);
        end % createButtonPanel
        
        function numButtons = createCloseButtons(obj, parent)
            % Create the close button subpanel
            numButtons = 3;
            uicontrol('Parent', parent, ...
                'Style', 'pushbutton', 'Tag', 'LoadButton', ...
                'String', 'Load', 'Enable', 'on', 'Tooltip', ...
                'Load a new configuration from a file', ...
                'Callback', {@obj.loadButtonCallback});
            uicontrol('Parent', parent, ...
                'Style', 'pushbutton', 'Tag', 'SaveButton', ...
                'String', 'Save', 'Enable', 'on', 'Tooltip', ...
                'Save the current configuration in a file', ...
                'Callback', {@obj.saveButtonCallback});
            uicontrol('Parent', parent, ...
                'Style', 'pushbutton', 'Tag', 'CloseButton', ...
                'String', 'Close', 'Enable', 'on', 'Tooltip',  ...
                'Close configuration window with no further changes', ...
                'Callback', {@obj.closeButtonCallback});
        end % createCloseButtons
        
        function numButtons = createControlButtons(obj, parent)
            % Create the button panel on the side of GUI
            numButtons = 5;
            uicontrol('Parent', parent, ...
                'Style', 'pushbutton', 'String', 'Browse...', ...
                'Tag', 'BrowseEEGBrowse', 'TooltipString', ...
                'Browse for directory of .set files for visualization', ...
                'Callback', {@obj.browseCallback, obj.DirectoryCtrl, ...
                [obj.Title ': Browse for data directory']});
            uicontrol('Parent', parent, ...
                'Style', 'pushbutton', 'String', 'Load WS', ...
                'Tag', 'LoadWSEEGBrowse', 'TooltipString', ...
                'Load an EEG data set into the MATLAB base workspace', ...
                'Callback', {@obj.openCallback});            
            uicontrol('Parent', parent, ...
                'Style', 'pushbutton', 'String', 'Functions', ...
                'Tag', 'FunctionsEEGBrowse', 'TooltipString', ...
                'Edit default block functions used for visualization', ...
                'Callback',  {@viscore.dataSelector.configureCallback, ...
                obj.FunSelect, [obj.Title ': Edit block summary functions']});            
            uicontrol('Parent', parent, ...
                'Style', 'pushbutton', 'String', 'Plot list', ...
                'Tag', 'PlotsEEGBrowse', 'TooltipString', ...
                'Edit default list of plots for visualization', ...
                'Callback', {@viscore.dataSelector.configureCallback, ...
                obj.PlotSelect, [obj.Title ': Edit list of plots']});            
            uicontrol('Parent', parent, ...
                'Style', 'pushbutton', 'String', 'Properties', ...
                'Tag', 'PropertiesEEGBrowse', 'TooltipString', ...
                'Edit default visualization properties', ...
                'Callback', {@viscore.dataSelector.configureCallback, ...
                obj.PropSelect, [obj.Title ': Edit properties']});...
        end % createControlButtons
    
        function obj = createLayout(obj, parent)
            % Create the layout for the GUI but do not display
            mainVBox = uiextras.VBox('Parent', parent, ...
                'Tag', 'MainVBox',  'Spacing', 1);
            mainHBox = uiextras.HBox('Parent', mainVBox, ...
                'Tag', 'MainHBox',  'Spacing', 5, 'Padding', 5);
            createStatusPanel(obj, mainVBox)
            set(mainVBox, 'Sizes', [-1, 35]);
            obj.createMainPanel(mainHBox)
            createButtonPanel(obj, mainHBox);
            set(mainHBox, 'Sizes', [-1, 105]);
            drawnow
        end % createLayout
    
        function createMainPanel(obj, parent)
            % Create the panel with the directory controls on the GUI
            directoryVBox =  uiextras.VBox('Parent', parent, ...
                'Tag', 'DirectoryVBox', 'Spacing', 5, 'Padding', 5);
            directoryHBox = uiextras.HBox('Parent', directoryVBox, ...
                'Tag', 'DirectoryHBox', 'Spacing', 5);        
            obj.FileList = uicontrol('parent', directoryVBox, ...
                'style', 'listbox', 'Tag', 'FileList', ...
                'TooltipString', ...
                'Select a file to load or visualize by clicking on the name', ...
                'Value', 1, 'Callback', {@obj.fileListCallback});
            set(directoryVBox, 'Sizes', [23, -1]);
            uicontrol('Parent', directoryHBox, ...
                'style','text', 'string', 'Directory:', ...
                'HorizontalAlignment', 'Right');
            obj.DirectoryCtrl = uicontrol('Parent', directoryHBox, 'style', 'edit', ...
                'BackgroundColor', 'w', 'HorizontalAlignment', 'left', ...
                'Tag', 'DirectoryCtrl', 'String', obj.FilePath, ...
                'TooltipString', ...
                'Directory of .set files for visualization', ...
                'Callback', {@obj.directoryCtrlCallback});
            set(directoryHBox, 'Sizes', [60, -1]);
        end % createMainPanel
    
        function createStatusPanel(obj, parent)
            % Create status panel at bottom of GUI
            statusGrid = uiextras.Grid('Parent', parent, ...
                'Tag', 'StatusGrid', 'Spacing', 5, 'Padding', 5);
            obj.LoadOnSelectCB = uicontrol('Parent', statusGrid, ...
                'Style', 'checkbox', 'String', 'Load workspace', ...
                'Value', 0, ...
                'Tag', 'LoadOnSelect', 'TooltipString', ...
                'Load data into base workspace each .set file selection');
            obj.PreviewOnSelectCB = uicontrol('Parent', statusGrid, ...
                'Style', 'checkbox', 'String', 'Preview', ...
                'Value', 1, ...
                'Tag', 'PreviewOnSelect', 'TooltipString', ...
                'Visualize the data on each .set file selection');
            obj.NewFigureCB = uicontrol('Parent', statusGrid, ...
                'Style', 'checkbox', 'String', 'New figure', ...
                'Value', 0, ...
                'Tag', 'NewFigure', 'TooltipString', ...
                'Check to create a new figure on each application of new values');
            uiextras.Empty('Parent', statusGrid);
            set(statusGrid, 'ColumnSizes', [130, 100, 130 -1]);
        end % createStatusPanel
    
        function deleteFigs = deleteDependentViews(obj)
            % Give user the option of deleting the dependent views on closing
            deleteFigs = false;
            % Delete any active selectors with their GUIS first
            dvs = {obj.FunSelect, obj.PlotSelect, obj.PropSelect};
            obj.FunSelect = [];
            obj.PlotSelect = [];
            obj.PropSelect = [];
            for k = 1:length(dvs)
                if ~isempty(dvs{k}) && isvalid(dvs{k})
                delete(dvs{k});
                end
            end
            % If any viewing windows are open, ask the user whether to delete
            if isempty(obj.FigList)
                return;
            end
            deleteFigs = strcmpi(questdlg('Do you want to also close any open views?',...
            [obj.Title ': Closing'], 'Yes', 'No', 'Yes'), 'Yes');
            if ~deleteFigs
                return;
            end
            % Need to delete the visualization figures too
            for k = 1:length(obj.FigList)
                x = obj.FigList{k};
                obj.FigList{k} = [];
                if ~isempty(x) && isvalid(x)
                    delete(x);
                end
            end
            obj.FigList = [];
        end % deleteDependentViews
    
        function parseParameters(obj, varargin)
            % Parse command line parameters and set defaults
            %
            % Inputs:
            %    varargin   command line parameters for class
            %
            % Notes:
            %   - See eegbrowse.getParser for command line specification
            %   - This method is only called for initialization
            parser = eegbrowse.getParser();
            parser.parse(varargin{:})
            if isempty(parser.Results)
                return;
            end
            data = parser.Results;
            % Initialize the starting file name and file path
            if isfield(data, 'FileName') && ~isempty(data.FileName)
                obj.FileName = data.FileName;
            end
            % Set selected path to current directory if no path is given
            if isfield(data, 'FilePath') && ~isempty(data.FilePath) ...
                && isdir(data.FilePath)
                obj.FilePath = data.FilePath;
            elseif isempty(obj.FilePath)
                obj.FilePath = pwd;
            end
            
            % Set up the functions (Function GUI not yet active)
            if isfield(data, 'Functions') && ...
                isa(data.Functions, 'viscore.dataManager')
                bfs = data.Functions.getObjects();
            elseif isfield(data, 'Functions') && ~isempty(data.Functions)
                bfs = data.Functions;
            else
                bfs = visviews.dualView.getDefaultFunctions();
            end
            obj.resetFunctions(bfs);
             
            % Set up the plots, merging with command line values
            if isfield(data, 'Plots') && ...
                isa(data.Plots, 'viscore.dataManager')
                pls = data.Plots.getObjects();
            elseif isfield(data, 'Plots') && ~isempty(data.Plots)
                pls = data.Plots;
            else
                pls = visviews.dualView.getDefaultPlots();
            end
            obj.resetPlots(pls);
             
            % Set up the configurable properties and merge arguments passed in
            if isfield(data, 'Properties') && ...
                isa(data.Properties, 'viscore.dataManager')
                prs = data.Properties.getObjects();
            elseif isfield(data, 'Properties') && ~isempty(data.Properties)
                prs = data.Properties;
            else
                prs = {};
            end
            sMan = obj.PropSelect.getManager();
            for k = 1:length(prs)
                if isa(prs{k}, 'visprops.configurableObj')
                    sMan.putObject(prs{k}.getObjectID(), prs{k});
                end
            end
            % Get the configurable properties from the plots
            pConf = obj.getConfigurableObjs();
            % Account for input configuration
            visprops.configurableObj.updateManager(sMan, pConf);
            % Handle the title
            if isfield(data, 'Title') && ~isempty(data.Title)
                obj.Title = data.Title;
            end
            if isfield(data, 'UseEEGLab') && ~isempty(data.UseEEGLab)
                obj.UseEEGLab = data.UseEEGLab;
            end
        end % parseParameters
    
        function updateFileList(obj)
            % Update list of .set files displayed in selector
            % Use this function for all changes to the drop-down file list
            if isempty(obj.FilePath) || ~ischar(obj.FilePath) || ~isdir(obj.FilePath)
                obj.FilePath = '';
                return;
            end        
            % See *.set files are available in this directory
            tmpDirectory = cd(obj.FilePath);
            obj.FilePath = pwd;
            cd(tmpDirectory);
            files = dir([obj.FilePath filesep '*.set']);
            if isempty(files)
                set(obj.FileList, 'TooltipString', 'Choose a directory', ...
                    'String', '');
                obj.FileName = '';
                return;
            end
            % Set the file list and the tooltip after sorting file names
            sortedFiles = sortrows({files.name}');
            set(obj.FileList, 'String', sortedFiles, ...
                'TooltipString', 'Choose a file by clicking');
            % Adjust the directory control and see if
            set(obj.DirectoryCtrl, 'String', obj.FilePath);
            selectedPosition = find(strcmp(sortedFiles, obj.FileName), 1);
            if ~isempty(selectedPosition)
                set(obj.FileList, 'Value', selectedPosition);
            else
                obj.FileName = '';
            end
        end % updateFileList
    
    %% Callbacks ------------------------------------------------------
        function browseCallback(obj, src, eventdata, directoryCtrl, myTitle) %#ok<INUSL>
            % Callback for browse button sets a directory for control
            startPath = get(directoryCtrl, 'String');
            if isempty(startPath) || ~ischar(startPath) || ~isdir(startPath)
                startPath = pwd;
            end
            dName = uigetdir(startPath, myTitle);  % Get
            if ~isempty(dName) && ischar(dName) && isdir(dName)
                set(directoryCtrl, 'String', dName);
                obj.FilePath = dName;
                obj.FileName = '';
                obj.updateFileList();
            end
        end % browseCallback
    
        function closeButtonCallback(obj, src, eventdata) %#ok<INUSD>
            % Close button closes the figure and all that entails
            obj.delete();
        end % closeButtonCallback
    
        function closeRequestCallback(obj, src, eventdata)  %#ok<INUSD>
            % Callback for closing GUI window
            if isempty(src) || ~ishandle(src) || obj.GUIClosing
                return;
            end
            obj.delete();
        end % closeRequestCallback
    
        function directoryCtrlCallback(obj, hObject, eventdata) %#ok<INUSD>
            % Callback for user directly editing directory control textbox
            directoryName = get(hObject, 'String');
            if isdir(directoryName)
                obj.FilePath = directoryName;
                obj.FileName = '';
                obj.updateFileList();
            else  % if user entered invalid directory reset back
                set(hObject, 'String', obj.FilePath);
            end
        end % directoryCtrlCallback
    
        function fileListCallback(obj, hObject, eventdata) %#ok<INUSD>
            % Callback to reset when file name is clicked
            fileNames = get(hObject, 'String');
            if isempty(fileNames)
                return;
            end
            obj.FileName = fileNames{get(hObject, 'Value')};
            obj.reset(true);
        end % fileListCallback
        
       function loadButtonCallback(obj, src, eventdata) %#ok<INUSD>
            % Load loads a previously saved configuration into browser
            uiopen('load')
            if ~exist('vars', 'var') || ~isa(vars, 'struct') || ~isfield(vars, 'configuration')
                return;
            end
            s = vars.configuration;
            if isempty(s)
                return;
            end
            if ~isempty(s.funs)
              fMan = obj.FunSelect.getManager();
              fMan.clear();
              mObjs = viscore.dataManager.createManagedObjs(s.funs);
              fMan.putObjects(mObjs);
            end
            if ~isempty(s.plots)
              pMan = obj.PlotSelect.getManager();
              pMan.clear();
              mObjs = viscore.dataManager.createManagedObjs(s.plots);
              pMan.putObjects(mObjs);
            end
            if ~isempty(s.props)
              pMan = obj.PropSelect.getManager();
              pMan.clear();
              mObjs = viscore.dataManager.createManagedObjs(s.props);
              pMan.putObjects(mObjs);
            end
            obj.reset(false);
        end % loadButtonCallback
    
        function openCallback(obj, hObject, eventdata) %#ok<INUSD>
            % Callback for loading EEG into workspace on open button click
            eegbrowse.readEEG(obj.FileName, obj.FilePath, true);
        end % openCallback
        
        function saveButtonCallback(obj, src, eventdata) %#ok<INUSD>
            % Saves the configuration in a file 
            vars.date = datestr(now);
            vars.class = class(obj);
            [mObjs, keys] = obj.FunSelect.getManager().getObjects();
            vars.configuration.funs = viscore.dataManager.createConfig(mObjs, keys);
            [mObjs, keys] = obj.PlotSelect.getManager().getObjects();
            vars.configuration.plots = viscore.dataManager.createConfig(mObjs, keys);
            [mObjs, keys] = obj.PropSelect.getManager().getObjects();
            vars.configuration.props = viscore.dataManager.createConfig(mObjs, keys);
            uisave('vars', [class(obj) 'config.mat']);
        end % saveButtonCallback
    
    end % protected methods
    
    methods(Access = private)
        
         function resetFunctions(obj, fns)
            fns = visfuncs.functionObj.createObjects('visviews.functionObj', fns);
            fMan = viscore.dataManager();
            fMan.putObjects(fns);
            obj.FunSelect.setManager(fMan);
        end  % resetFunctions
        
        function resetPlots(obj, pls)
            pls = visviews.plotObj.createObjects('visviews.plotObj', pls);
            pMan = viscore.dataManager();
            pMan.putObjects(pls);
            obj.PlotSelect.setManager(pMan);
        end  % resetPlots 
        
        function resetProperties(obj, prs)
            pMan = viscore.getManager();
            for k = 1:length(prs)
                if isa(prs{k}, 'visprops.configurableObj')
                    pMan.putObject(prs{k}.getObjectID(), prs{k});
                end
            end
            obj.PropSelect.setManager(pMan);
        end  % resetPlots 
    end
    
    methods(Static = true)
        
        function visData = getBlockDataFromEEG(EEG, dataID)
            % Create a BlockData object for an EEG structure
            chLocs = EEG.chanlocs;
            if ~isa(chLocs, 'struct')
                chLocs = struct();
            end
            visData = viscore.blockedData(EEG.data, dataID, ...
                'EpochTimes', EEG.times, 'SampleRate', EEG.srate, ...
                'Epoched', ~isempty(EEG.times), 'ElementLocations', chLocs);
        end % getBlockDataFromEEG
        
        function settings = getConfigurableDefaults()
            % Field name, class name, class modifier, display name, type, default, options,
            % descriptions
            settings = [];
        end % getConfigurableDefaults
        
        function parser = getParser()
            % Create an inputparser for FileSelector
            parser = inputParser;
            parser.addParamValue('FileName', {}, ...
                @(x) validateattributes(x, {'char'}, {}));
            parser.addParamValue('FilePath', {}, ...
                @(x) validateattributes(x, {'char'}, {}));
            parser.addParamValue('Functions', [], ...
                @(x) validateattributes(x, ...
                {'struct', 'cell', 'viscore.dataManager'}, {}));
            parser.addParamValue('Plots', [], ...
                @(x) validateattributes(x, ...
                {'struct', 'cell', 'viscore.dataManager'}, {}));
            parser.addParamValue('Properties', [], ...
                @(x) validateattributes(x, ...
                {'cell', 'viscore.dataManager'}, {}));
            parser.addParamValue('Tag', 'eegbrowse', ...
                @(x) validateattributes(x, {'char'}, {}));
            parser.addParamValue('Title', [], ...
                @(x) validateattributes(x, {'char'}, {}));
            parser.addParamValue('UseEEGLab', false, ...
                @(x) validateattributes(x, {'logical'}, {}));
        end % getParser
        
        function fStruct = getDefaultFunctions()
            % Structure specifying the default functions (one per tab)
            fStruct = struct( ...
                'Enabled',        {true,         true}, ...
                'Category',       {'block',      'block'}, ...
                'DisplayName',    {'Kurtosis',   'Std Dev'}, ...
                'ShortName',      {'K',          'SD'}, ...
                'Definition',     {'@(x) (squeeze(kurtosis(x, 1, 2)))', ...
                '@(x) (squeeze(std(x, 0, 2)))'}, ...
                'ThresholdType',  {'z score',    'z score'}, ...
                'ThresholdScope', {'global'     'global'}, ...
                'ThresholdLevels', {3,              3}, ...
                'ThresholdColors', {[1, 0, 0],    [0, 1, 1]}, ...
                'BackgroundColor', {[0.7, 0.7, 0.7], [0.7, 0.7, 0.7]}, ...
                'Description',    {'Kurtosis computed for each (element, block)', ...
                'Block size for computation (must be positive)' ...
                });
        end % getDefaultFunctions
        
        function pStruct = getDefaultPlots()
            % Structure specifying the individual visualizations used
            pStruct = struct( ...
                'Enabled',        {true,           true,            true,          true,           true}, ...
                'Category',       {'summary',      'summary',      'summary',     'detail',        'detail'}, ...
                'DisplayName',    {'Block image',  'Element box',  'Block box',   'Stacked signal', 'Shadow signal'}, ...
                'Definition',     { ...
                'visviews.blockImagePlot', ...
                'visviews.elementBoxPlot', ...
                'visviews.blockBoxPlot', ...
                'visviews.stackedSignalPlot', ...
                'visviews.shadowSignalPlot', ...
                }, ...
                'Sources', {' ',            ' ',            ' ',           ' ',             ' '}, ...
                'Description',    { ...
                'Displays an array of windowed values as an image', ...
                'Displays a box plot of blocked values for each element', ...
                'Displays a box plot of blocked values for groups of blocks', ...
                'Displays raw signal in a time window in a stacked plot', ...
                'Displays raw signal in a time window in a shadow plot' ...
                });
        end % getDefaultPlots
        
        function settings = getDefaultProperties()
            % Structure specifying how to set configurable public properties
            cName = 'eegbrowse';
            settings = struct( ...
                'Enabled',       {true}, ...
                'Category',      {cName}, ...
                'DisplayName',   {'Selector title'}, ...
                'FieldName',     {'Title'}, ...
                'Value',         {'eegbrowse'}, ...
                'Type',          {'visprops.stringProperty'}, ...
                'Editable',      {true}, ...
                'Options',       {''}, ...
                'Description',   {'Title prefix on selector figure window'} ...
                );
        end % getDefaultProperties
        
        function EEG = readEEG(fileName, filePath, loadWorkspace)
            % Return an EEG struct for .set file specified by fileName and filePath.
            %
            % Inputs:
            %     fileName         name of .set file to read
            %     filePath         path of file to be read
            %     loadWorkspace    if true, load into base workspace
            %
            % Outputs:
            %     EEG     EEGLAB EEG structure if read was successful
            %             or an empty structure if unsuccessfull
            %
            % Notes: This function calls EEGLAB pop_loadset.
            EEG = [];
            try
                if isempty(fileName) || isempty(filePath)
                    return; % Data file cannot be read so don't do anything
                end
                EEG = pop_loadset('filename', fileName, ...
                    'filepath', filePath);
                if ~loadWorkspace
                    return;
                end                
                assignin('base', 'EEG', EEG);
                if evalin('base', '~exist(''ALLCOM'', ''var'')')
                    assignin('base', 'ALLCOM', {});
                end
                if evalin('base', '~exist(''ALLEEG'', ''var'')')
                    assignin('base', 'ALLEEG', []);
                end                
                cmd = ['''EEG = pop_loadset(''''filename'''', ''''' fileName  ...
                    ''''', ''''filepath'''', ''''' filePath ''''');'''];
                evalin('base', ['ALLCOM = {' cmd ' ALLCOM{:}};']);
                cmd = '[ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG);';
                evalin('base', cmd);
                evalin('base', ['ALLCOM = {''' cmd ''' ALLCOM{:}};']);
            catch ME
                fprintf('EEGRead:%s\n',  ME.message);
            end
        end % readEEG
        
    end % static methods
    
end % eegbrowse
