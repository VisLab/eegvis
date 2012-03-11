% viscore.dataSelector  container connecting a configuration GUI and an object manager
%
% Usage:
%   >>   viscore.dataSelector(conType)
%   >>   obj = viscore.dataSelector(conType)
%
% Inputs:
%    manType     class name of manager
%    conType     class name for configuration
%
% Outputs:
%    obj         handle to this class
%
% Description:
% viscore.dataSelector(conType) creates a data selector object to hold a 
%     specified type of configuration. The conType variable should be the 
%     class name of the configuration GUI. The default conType is 
%     viscore.dataConfig. Other configuration GUIs include 
%     visfuncs.functionConfig for configuring block functions, 
%     visprops.propertyConfig for configuring object public properties,
%     and visviews.plotConfig for specifying the views to include 
%     in a visualization. 
%
%     The data selector automatically creates its
%     own data manager, but this manager can be replaced by using the
%     setManager method of viscore.dataSelector.
%
%     The viscore.dataSelector provides a convenient way of manipulating
%     configurations for objects such as visviews.dualView, which manages
%     three different configurations.
%
%
% obj = viscore.dataSelector(conType) returns a handle to a newly
%     created viscore.dataSelector object.
% 
%
% Example:
% Create a data selector for a data configuration GUI
%   vs =  viscore.dataSelector('viscore.dataConfig');
%
% Class documentation:
% Execute the following in the MATLAB command window to view the class 
% documentation for viscore.dataSelector:
%
%    doc viscore.dataSelector
%
% See also: viscore.dataConfig, visfuncs.functionConfig,
%           viscore.dataManager, visviews.plotConfig, and
%           visprops.propertyConfig
%

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

% $Log: dataSelector.m,v $
% Revision: 1.00  04-Dec-2011 09:11:20  krobbins $
% Initial version $
%

classdef dataSelector < hgsetget
    
    properties(Access = protected)
        Config;                   % GUI for this structure
        ConfigType;               % classname of configuration GUI
        Manager;                  % manager for this selector
    end % protected properties
    
    events
        StateChanged              % for notifying listeners of this selector
    end % events
    
    methods
        
        function obj = dataSelector(conType)
            % Create an empty selector for a particular configuration type type
            %
            % Inputs:
            %    conType     class name of configuration GUI for this selector
            %
            obj.Config = [];
            if isempty(conType)
                obj.ConfigType = 'viscore.dataConfig';
            else
                obj.ConfigType = conType;
            end
            obj.Manager = viscore.dataManager();
        end % dataSelector constructor
        
        function clear(obj)
            % Clear manager and close GUI if it exists
            obj.clearConfiguration();
            obj.Manager = viscore.dataManager();
        end % clear
        
        function clearConfiguration(obj)
            % Delete the current configuration
            if  ~isempty(obj.Config) && ...
                    isa(obj.Config, 'hgsetget') && isvalid(obj.Config)
                delete(obj.Config);
            end
            obj.Config = [];
        end % clearConfiguration
        
        function delete(obj)
            % Delete any existing data
            obj.clearConfiguration();
        end % delete
        
        function manager = getManager(obj)
            % Return the manager of this selector
            manager = obj.Manager;
        end %getManager 
        
        function s = getObject(obj, key)
            % Return the object associated with key or return empty
            if isempty(key) || isempty(obj.Manager)
                s = [];
            else
                s = obj.Manager.getObject(key);
            end
        end % getObject
        
        function objList = getObjects(obj)
            % Return a cell array of all objects in manager
            objList = obj.getManager().getObjects();
        end % getObjects
        
        function type = getType(obj)
            % Return class name of the configuration GUI for this selector
            type = obj.ConfigType;
        end % getType
        
        function OnStateChange(obj)
            % Call this method notify listeners of state change
            notify(obj, 'StateChanged'); % Broadcast notice of event
        end  % OnStateChange
        
        function putObject(obj, key, s)
            % Store s under key in the manager
            obj.Manager.putObject(key, s);
        end % putObject
        
        function remove(obj, key)
            % Remove the object associated with key if it exists
            if ~isempty(obj.Manager)
                obj.Manager.remove(key);
            end
        end % remove
        
        function setManager(obj, manager)
            % Set manager for this selector and inform GUI (not called by GUI)
            if isa(manager, 'viscore.dataManager')
                obj.Manager = manager;
            else
                warning(dataSelector:setManager, ...
                    ' manager is not correct type and could not be set');
            end
            
            % Inform the configuration GUI of the change
            if ~isempty(obj.Config)
                obj.Config.setCurrentManager(manager);
            end
        end % setManager
        
        function setObjects(obj, objList)
            % Set the objects of this selector's manager
            obj.getManager().setObjects(objList);
        end % setObjects
        
        function updateManager(obj, targetObj, key)
            % Refresh manager's data based on public properties of targetObj
            p = properties(targetObj);  % Find names of public properties
            s = obj.Manager.get(key);
            for k = 1:length(s)
                fieldName = s(k).field;
                inx = find(strcmp(p, fieldName), 1, 'first');
                if isempty(inx) || inx == 0
                    continue;
                end
                s(k).value = s.(fieldName);
            end
            if ~isempty(s)
                obj.Manager.put(key, s);
            end
        end % updateManager
        
        function updateState(obj, manager)
            % Update states of listeners of this selector (called by GUI)
            if isa(manager, 'viscore.dataManager')
                obj.Manager = manager;
                obj.notify('StateChanged');
            else
                warning(dataSelector:setManager, ...
                    ' manager is not correct type and could not be set');
            end
        end % updateState
        
        function updateTarget(obj, targetObj, key)
            % Refresh object properties from values stored in the manager
            p = properties(targetObj);  % Find names of public properties
            s = obj.Manager.get(key);
            for k = 1:length(s)
                fieldName = s.field;
                inx = find(strcmp(p, fieldName), 1, 'first');
                if isempty(inx) || inx == 0
                    continue;
                end
                set(targetObj, fieldName, s(k).value);
            end
        end % updateTarget
        
    end % public methods
    
    methods (Static = true)
        
        function configureCallback(src, eventdata, obj, title)  %#ok<INUSD,INUSL>
            % Create a dataConfig GUI for the selector obj if needed
            if  isempty(obj.Config) || ...
                    (isa(obj.Config, 'viscore.dataConfig') && ~isvalid(obj.Config))
                obj.Config = eval([obj.ConfigType '(obj, title);']);
            end
            drawnow
        end % configureCallback
        
    end % static methods
    
end % dataSelector

