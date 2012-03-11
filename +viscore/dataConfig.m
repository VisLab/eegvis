% viscore.dataConfig  GUI base class for configuration
%
% Usage:
%   >>  viscore.dataConfig(selector, title);
%   >>  obj = viscore.dataConfig(selector, title);
%
% Description:
% viscore.dataConfig(selector, title) creates a basic figure shell for
%     configuration, including New, Edit, Delete, Apply,
%     Reset, Load, Save, and Close buttons. The selector must be a
%     non-empty object of type viscore.dataSelector. The title string
%     appears on the title bar of the figure window.
%
% obj = viscore.dataConfig(selector, title) returns a handle to
%      the GUI base class for configuration
%
% Example:
% Create an empty data configuration GUI.
%
%   sel = viscore.dataSelector('viscore.dataConfig');
%   dc = viscore.dataConfig(sel, 'Example of viscore.dataConfig'); 
%
% Notes:
% - This class is not meant to be called directly, but rather provides
%    base class infrastructure for extending classes.
%
% See also: viscore.dataManager, viscore.dataSelector, 
%           visfuncs.functionConfig, viscore.managedObj,
%           visviews.plotConfig, and visprops.propertyConfig
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

% $Log: dataConfig.m,v $
% Revision: 1.00  04-Dec-2011 09:11:20  krobbins $
% Initial version $
%

classdef dataConfig < hgsetget
    properties
        ConFig                   % figure that holds the property panel
    end % public properties
    
    properties (SetAccess = protected)
        Editing                  % flag indicating whether currently editing
        MainPanel                % parent panel for actual settings
        
        % Buttons that are enabled or disabled
        ApplyButton              % apply table data to selector and current
        DeleteButton             % delete a row and apply
        EditButton               % edit an existing row
        LoadButton               % load a list of functions from a file
        NewButton                % create a new row
        ResetButton              % reset table data to unapplied original
        SaveButton               % save the current list of functions in a file
    end % protected properties
    
    properties(SetAccess = private)
        CurrentManager     % dataManager holding current state
        OriginalManager    % dataManager corresponding to when GUI opened 
        Selector           % DataSelector in charge of configuration
    end % private properties
    
    methods
        
        function obj = dataConfig(selector, title)
            % Must have a DataSelector that has a DataManager
            if isempty(selector) || ...
                    ~isa(selector, 'viscore.dataSelector') || ...
                    isempty(selector.getManager())
                throw(MException('dataConfig:InvalidParameters', ...
                    ['First parameter must be a Selector with ' ...
                    'a nonempty Manager']));
            end
            obj.ConFig = figure('Name', title, ...
                'NumberTitle','off', 'MenuBar', ...
                'none', 'Toolbar', 'none', 'WindowStyle', 'normal', ...
                'Color', [0.941176 0.941176 0.941176], ...
                'DockControls', 'on', ...
                'DeleteFcn', ...
                {@viscore.dataConfig.deleteFcnCallback, obj});
            uimenu(obj.ConFig);  % Allow docking
            obj.Selector = selector;
            obj.OriginalManager = selector.getManager().clone();
            obj.CurrentManager = obj.OriginalManager.clone();
            obj.Editing = false;
            obj.createLayout(obj.ConFig);
            obj.updatePanelFromManager();
        end % dataConfig constructor
        
        function delete(obj)
            % Close the associated figure when this object is deleted
            x = obj.ConFig;
            obj.ConFig = [];
            if isempty(x) || ~ishandle(x) || ...
                    strcmpi('on', get(x, 'BeingDeleted'))
                return;
            end
            delete(x);
        end % delete
  
        function man = getCurrentManager(obj)
            % Return a handle to the current manager
            man = obj.CurrentManager;
        end % getCurrentManager
        
        function man = getOriginalManager(obj)
            % Return handle to clone of manager at time GUI started for reset
            man = obj.OriginalManager;
        end % getOriginalManager
        
        function title = getTitle(obj)
            % Return the title of the figure window for this GUI
            title = get(obj.ConFig, 'Name');
        end % getTitle
        
        function setCurrentManager(obj, man)
            % Set the current manager to man and update panel from manager
            obj.CurrentManager = man;
            obj.updatePanelFromManager();
        end % setCurrentManager
        
    end % public methods
    
    methods (Access = protected)
        
        function addDummyItem(obj) %#ok<MANU>
            % Add a new row specific to form of table 
        end % addDummyItem 
        
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
            % Create the close button section of the button panel
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
            % Create the control button section of the button panel
            numButtons = 5;
            obj.NewButton = uicontrol('Parent', parent, ...
                'Style', 'pushbutton', 'Tag', 'NewButton', ...
                'String', 'New', 'Enable', 'on', 'Tooltip', ...
                'Create a new function to add to the list', ...
                'Callback', {@obj.newButtonCallback});
            obj.EditButton = uicontrol('Parent', parent, ...
                'Style', 'pushbutton', 'Tag', 'editButton', ...
                'String', 'Edit', 'Enable', 'on', 'Tooltip', ...
                'Make editable (click again to disable)', ...
                'Callback', {@obj.editButtonCallback});
            obj.DeleteButton = uicontrol('Parent', parent, ...
                'Style', 'pushbutton', 'Tag', 'DeleteButton', ...
                'String', 'Delete', 'Enable', 'on', 'Tooltip', ...
                'Delete from list', ...
                'Callback', {@obj.deleteButtonCallback});
            obj.ApplyButton = uicontrol('Parent', parent, ...
                'Style', 'pushbutton', 'Tag', 'ApplyButton', ...
                'String', 'Apply', 'Enable', 'off', 'Tooltip', ...
                'Apply the current configuration', ...
                'Callback', {@obj.applyButtonCallback});
            obj.ResetButton = uicontrol('Parent', parent, ...
                'Style', 'pushbutton', 'Tag', 'ResetButton', ...
                'String', 'Reset', 'Enable', 'on', 'Tooltip', ...
                'Reset to original configuration (when GUI was opened)', ...
                'Callback', {@obj.resetButtonCallback});
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
        end % createLayout
        
        function createMainPanel(obj, parent) 
            % Create the main configuration panel
            borderPanel = uiextras.Panel('Parent', parent, ...
                'Padding', 10, 'BackgroundColor', [0.97, 0.97, 0.97]);
            obj.MainPanel = uipanel('Parent', borderPanel, ...
                'BorderType', 'none', 'BackgroundColor', [1, 1, 1]);
        end  % createMainPanel  
           
        function createStatusPanel(obj, parent) %#ok<MANU>
            % Create status panel at bottom of GUI
            uiextras.Grid('Parent', parent, ...
                'Tag', 'StatusGrid', 'Spacing', 5, 'Padding', 5);
        end % createStatusPanel
        
        function numDeleted = deleteManaged(obj)  %#ok<MANU>
            % Delete selected items from window and return number deleted (override)
            numDeleted = 0;
        end % deleteManaged 
        
        function enterEditMode(obj)
            % Set the buttons to reflect that the GUI is in edit mode
            set(obj.ApplyButton, 'Enable', 'off');
            set(obj.DeleteButton, 'Enable','off');
            set(obj.NewButton, 'Enable', 'off');
            set(obj.ResetButton, 'Enable', 'off');
        end % enterEditMode
        
        function exitEditMode(obj)
            % Set the buttons to exit edit mode and enable apply
            set(obj.ApplyButton, 'Enable', 'on');
            set(obj.DeleteButton, 'Enable', 'on');
            set(obj.NewButton, 'Enable', 'on');
            set(obj.ResetButton, 'Enable', 'on');
        end %exitEditMode
     
        function toggleEditable(obj)
            % Perform actions needed when entering and leaving edit mode.
            obj.Editing = ~obj.Editing;
        end % toggleEditable 
         
        function updateManagerFromPanel(obj) %#ok<MANU>
            % Update CurrentManager based on GUI settings (override)
        end % updateManagerFromPanel

        function updatePanelFromManager(obj) %#ok<MANU>
            % Create new settings panel in SettingsFig window (override)
        end % updatePanelFromManager
          
        %% Callbacks ******************************************************
        
        function applyButtonCallback(obj, src, eventdata) %#ok<INUSD>
            % Apply button updates the selector from current manager and disables Apply
            obj.Selector.updateState(obj.CurrentManager);
            set(obj.ApplyButton, 'Enable', 'off');
        end % applyButtonCallback
        
        function closeButtonCallback(obj, src, eventdata) %#ok<INUSD>
            % Close button closes the figure
            delete(obj);
        end %closeButtonCallback

        function deleteButtonCallback(obj, src, eventdata) %#ok<INUSD>
            % Delete button re-enables Apply if any items were deleted
            numDeleted = obj.deleteManaged();
            if numDeleted > 0
                set(obj.ApplyButton, 'Enable', 'on');
            end
        end  % deleteButtonCallback
        
        function editButtonCallback(obj, src, eventdata, tObject) %#ok<INUSD>
            % Disable everything except close while in editing mode
            obj.toggleEditable();
            if  obj.Editing  % now in editing mode
                obj.enterEditMode();
            else  % now not in editing mode
                obj.updateManagerFromPanel();
                obj.exitEditMode();       
            end    
        end % editButtonCallback
        
        function loadButtonCallback(obj, src, eventdata)  %#ok<INUSD>
            % Load loads a previously saved configuration 
            uiopen('load')
            if ~exist('vars', 'var') || ~isa(vars, 'struct') || ~isfield(vars, 'configuration')
                return;
            end
            s = vars.configuration;
            if isempty(s)
                return;
            end
            obj.CurrentManager.clear(); % start from scratch  
            mObjs = viscore.dataManager.createManagedObjs(s);
            obj.CurrentManager.putObjects(mObjs);
            obj.updatePanelFromManager();
            obj.exitEditMode();
        end % loadButtonCallback
        
        function newButtonCallback(obj, src, eventdata) %#ok<INUSD>
            % Create a new row with a dummy function
            addDummyItem(obj);   % adds a new dummy item to GUI and currentManager
            set(obj.ApplyButton, 'Enable', 'on');
        end % newButtonCallback
        
        function resetButtonCallback(obj,src, eventdata) %#ok<INUSD>
            % Reset restores CurrentManager to a copy of the original state
            obj.CurrentManager = obj.OriginalManager.clone();
            obj.updatePanelFromManager();
            set(obj.ApplyButton, 'Enable', 'on');
        end % resetButtonCallback
        
        function saveButtonCallback(obj, src, eventdata) %#ok<INUSD>
            % Saves the configuration in a file
            vars.date = datestr(now);
            vars.class = class(obj);
            [mObjs, keys] = obj.getCurrentManager().getObjects();
            vars.configuration = viscore.dataManager.createConfig(mObjs, keys);
            uisave('vars', [class(obj) 'config.mat']);
        end % saveButtonCallback
        
    end % protected methods
    
    methods (Static = true)
        
        function deleteFcnCallback(src, event, obj) %#ok<INUSL,INUSD>
            % If configuration GUI is closed, configuration should be deleted
            if isvalid(obj)
                delete(obj);
            end
        end % deleteFcnCallback
        
    end % static methods
    
end % dataConfig