% visprops.propertyConfig GUI for configuration of public properties of configurable objects
%
% Usage:
%   >>  visprops.propertyConfig(selector, title);
%   >>  obj = visprops.propertyConfig(selector, title);
%
% Description:
%    visprops.propertyConfig(selector, title) creates a configuration
%         GUI for specified public properties of configurable objects. 
%         The selector must be a non-empty object of type 
%         viscore.dataSelector and a configuration type of
%         'visprops.propertyConfig'. The title string appears on the 
%         title bar of the figure window.
%
%     obj = visprops.propertyConfig(selector, title) returns a handle to
%         a property configuration GUI
%
% The property configuration GUI is similar in format to the MATLAB
% property manager. 
%
% The property configuration GUI only processes configurable objects 
% in its object manager.
%
% Example:
% Create a property configuration GUI for a double property
%
%     settings = struct( ...
%                 'Enabled',       {true}, ...
%                 'Category',      {'Summary'}, ...
%                 'DisplayName',   {'Block size'}, ...
%                 'FieldName',     {'BlockSize'}, ... 
%                 'Value',         {1000.0}, ...
%                 'Type',          {'visprops.doubleProperty'}, ...
%                 'Editable',      {true}, ...
%                 'Options',       {[0, inf]}, ...
%                 'Description',   {'Block size for computation (must be non negative)'} ...
%                                   );
%      selector = viscore.dataSelector('visprops.propertyConfig');
%      settings.Category = [settings.Category ':' settings.DisplayName];
%      theProps = viscore.managedObj(theName, settings);
%      selector.putObject(theName, theProps);
%      bfc1 = visprops.propertyConfig(selector, 'Testing property config');  
%  
% Class documentation:
% Execute the following in the MATLAB command window to view the class 
% documentation for visprops.propertyConfig:
%
%    doc visprops.propertyConfig
%
% See also: visprops.configurableObj, visprops.configurable, 
%           viscore.dataConfig, viscore.dataManager, 
%           viscore.dataSelector, and viscore.managedObj
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

% $Log: PropertyConfiguration.m,v $
% Revision: 1.00  04-Dec-2011 09:11:20  krobbins $
% Initial version $
%

classdef propertyConfig < hgsetget & viscore.dataConfig
    
    properties (Access = private)
        JIDEModel              % java model that interacts with GUI
        PropertyMap            % map indexing property names to objects
        RegisteredEditors      % reminder to unregister on deletion
    end % private properties
    
    methods
        
        function obj = propertyConfig(selector, title)
            % Create a GUI for configuring properties
            obj = obj@viscore.dataConfig(selector, title);
            com.mathworks.mwswing.MJUtilities.initJIDE;
            import java.awt.*;
            import javax.swing.*;
        end % propertyConfig constructor
        
    end % public methods
    
    methods (Access = protected)
        
        function createButtonPanel(obj, parent)
            % Create the button panel on the side of GUI
            buttonGrid = uiextras.Grid('Parent', parent, ...
                'Tag', 'EditGrid', 'Spacing', 2, 'Padding', 1);
            obj.ApplyButton = uicontrol('Parent', buttonGrid, ...
                'Style', 'pushbutton', 'Tag', 'SettingApplyButton', ...
                'String', 'Apply', 'Enable', 'off', 'Tooltip', ...
                'Apply the parameters to the visualization', ...
                'Callback', {@obj.applyButtonCallback});
            obj.ResetButton = uicontrol('Parent', buttonGrid, ...
                'Style', 'pushbutton', 'Tag', 'SettingResetButton', ...
                'String', 'Reset', 'Enable', 'on', 'Tooltip', ...
                'Reset to original plot list', ...
                'Callback', {@obj.resetButtonCallback});
            uiextras.Empty('Parent', buttonGrid);
            obj.createCloseButtons(buttonGrid);
            set(buttonGrid, 'RowSizes', [30, 30, -1, 30, 30, 30], ...
                'ColumnSizes', 100);
        end % createButtonPanel
        
        function  createMainPanel(obj, parent) 
            % Create the main panel for editing properties
           com.mathworks.mwswing.MJUtilities.initJIDE;
           borderPanel = uiextras.Panel('Parent', parent, ...
                'Units', 'pixels', ...
                'Padding', 10, 'BackgroundColor', [0.97, 0.97, 0.97]);
            obj.MainPanel = uipanel('Parent', borderPanel, ...
                'BorderType', 'none', 'BackgroundColor', [0.97, 0.97, 0.97]);
        end % createMainPanel  
        
        function enterEditMode(obj)
            % Set the buttons to reflect that the GUI is in edit mode
            set(obj.ApplyButton, 'Enable', 'off');
        end % enterEditMode
        
        function exitEditMode(obj)
            % Set the buttons to exit edit mode and enable apply
            set(obj.ApplyButton, 'Enable', 'on');
        end %exitEditMode
        
%         function s = makeConfig(obj, objList) %#ok<MANU>
%             % Create configuration structure for the objList
%             if isempty(objList)
%                 s = [];
%                 return;
%             end
%             
%             s(length(objList)) = struct('CategoryModifier', '', ...
%                 'ClassName', '', ...
%                 'ObjectID', '', ...
%                 'TargetClass', '', ...
%                 'properties', '');
%             
%             for k = 1:length(objList)  % Only save properties of configurable objects
%                 if isa(objList{k}, 'visprops.configurableObj')
%                     s(k).CategoryModifier = objList{k}.CategoryModifier;
%                     s(k).ObjectID = objList{k}.getObjectID();
%                     s(k).ClassName = class(objList{k});
%                     s(k).TargetClass = objList{k}.getClassName();
%                     s(k).properties = objList{k}.getStructure();
%                 end
%             end
%         end % makeConfig
        
        function mObjs = makeManagedObjs(obj, s) %#ok<MANU>
            % Create a list of managed objects from a configuration
            mObjs = cell(length(s), 1);
            for k = 1:length(s)
                evalStr = char([s(k).ClassName '(''' s(k).ObjectID ''' ,' ...
                    '[], ''' s(k).TargetClass ''')']);
                mObjs{k} = eval(evalStr);
                mObjs{k}.setProperties(s(k).properties);
                mObjs{k}.CategoryModifier = s(k).CategoryModifier;
            end
        end % makeManagedObjs
        
        %% CALLBACKS -------------------------------------------------
        function onPropertyChangeCallback(obj, src, event)
            % Callback for any property change in the property panel
            propertyName = char(event.getPropertyName());
            if ~obj.PropertyMap.isKey(propertyName)
                return;
            end
            modelProp = obj.PropertyMap(propertyName);
            if ~obj.CurrentManager.isKey(modelProp.getObjectID())
                return;
            end
            % Set the model property and update reference if needed
            modelProp.validateAndSetFromJIDE(propertyName, event.getNewValue());
            value = modelProp.CurrentValue;
            s = modelProp.getStructure().FieldName;
            obj.CurrentManager.putValueByField(modelProp.getObjectID(), s, value);
            set(obj.ApplyButton, 'Enable', 'on');
            src.refresh();  % Refresh value onscreen
            drawnow
        end % onPropertyChangeCallback
        
        function updatePanelFromManager(obj) 
            % Create a new settings panel in the SettingsFig window
            obj.resetJIDEModel();   % recreate the JIDE model
            grid = com.jidesoft.grid.PropertyTable(obj.JIDEModel);
            grid.setBackground(java.awt.Color.WHITE);
            pane = com.jidesoft.grid.PropertyPane(grid);
            pane.setBackground(java.awt.Color.WHITE);
            globalPanel = javax.swing.JPanel(java.awt.BorderLayout);
            globalPanel.setBackground(java.awt.Color.WHITE);
            globalPanel.add(pane, java.awt.BorderLayout.CENTER);
            oldUnits = get(obj.MainPanel, 'Units');
            set(obj.MainPanel, 'Units', 'pixels');
            pos = get(obj.MainPanel, 'position');
            [jcomp, hcont] = javacomponent(globalPanel, ...
                [0, 0, pos(3:4)], obj.MainPanel); %#ok<ASGLU>
            set(hcont, 'units', 'normalized');
            set(obj.MainPanel, 'Units', oldUnits);
            drawnow
        end % updatePanelFromManager       
  
    end % protected methods
    
    methods (Access = private)
        
        function addProperty(obj, mProperty)
            % Add a new property or replace an existing one
            pNames  = mProperty.getFullNames();
            for k = 1:length(pNames)
                if obj.PropertyMap.isKey(char(pNames{k}))
                    obj.PropertyMap.remove(char(pNames{k}));
                end
                obj.PropertyMap(char(pNames{k})) = mProperty;
            end
        end % addProperty
        
        function resetJIDEModel(obj)
            % Create a property map if it doesn't exist and fill
            obj.PropertyMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
            jideList = java.util.ArrayList();
            keys = obj.CurrentManager.getKeys();
            for k = 1:length(keys)
                tObj = obj.CurrentManager.getObject(keys{k});
                s  = tObj.getStructure();
                categoryModifier = '';  % keyModifier qualifies category
                if  isa(tObj, 'visprops.configurableObj') && ~isempty(tObj.CategoryModifier)
                    categoryModifier = [': ' tObj.CategoryModifier];
                end
                for j = 1:length(s)
                    IDString = '';
                    try
                       IDString = [s(j).Category ' ' ...
                           s(j).DisplayName ' ' s(j).Type];
                       s(j).Category = [s(j).Category categoryModifier];
                       
                       p = eval([s(j).Type '(keys{k}, s(j))']);
                       obj.addProperty(p);
                       jideList.add(p.getJIDEProperty());
                    catch ME 
                        warning('PropertyConfig:InvalidPropertySpecification', ...
                            [IDString ' is being ignored: ' ME.message]);
                    end     
                end
            end
            obj.JIDEModel = com.jidesoft.grid.PropertyTableModel(jideList);
            obj.JIDEModel.expandAll();
            hModel = handle(obj.JIDEModel, 'CallbackProperties');
            set(hModel, 'PropertyChangeCallback', {@obj.onPropertyChangeCallback});
            obj.JIDEModel.refresh();
        end % resetJIDEModel
        
    end % private methods
    
end % propertyConfiguration