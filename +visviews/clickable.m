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
% obj = visviews.clickable() returns a handle to the newly created
%     clickable object.
%
% The visviews.clickable base class defines a buttonDownCallback
% function that performs the linkage and a registerCallbacks function 
% that sets the ButtonDownFcn property of the handles returned by 
% getHitObjects. Extending classes should not override these functions 
% to perform additional actions in the callback. Instead, individual 
% classes should override the following two functions:
%
%      buttonDownPreCallback (obj, src, eventdata)
%
%      buttonDownPostCallback (obj, src, eventdata)
%
% The buttonDownCallback function calls the buttonDownPreCallback
% at the beginning of buttonDownCallback and the buttonDownPostCallback
% after processing the linkage.
%
% Configurable properties:
% The visviews.clickable has two configurable parameters: 
%
% IsClickable is a boolean specifying whether this plot should respond to
%    user mouse clicks when incorporated into a linkable figure. The
%    default value is true.
%
% LinkDetails is a boolean specifying whether clicking this plot in a
%    linkable figure should cause detail views to display the clicked
%    slice. The default value is true.
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

classdef clickable < handle
    
    properties
        IsClickable  = true;           % if true, this is clickable
        LinkDetails = true;            % if true, link to details
    end % public properties
    
    properties (Access = private)
        IDMap = [];           % contains (name, objIDs) for lookup
        SourceMap = [];       % local copy of sources (obj, sources, targets)
        Unmapped = []         % contains (sourceName, unmappedIDs) not mapped here
    end % private properties
    
    methods
        
        function obj = clickable()
            % Base class for clickable objects
            obj.clearClickable();
        end % constructor
        
        function clearClickable(obj)
            % Clear the maps with IDs and relationships
            obj.IDMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
            obj.SourceMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
            obj.Unmapped = containers.Map('KeyType', 'char', 'ValueType', 'any');
        end % clear
        
        function [dSlice, bFunction] = getClicked(obj) %#ok<MANU>
            % Return data slice at current clicked point [element, sample, block]
            %
            % Notes:
            %   - if the data slice is not valid, return empty
            %   - if one of element, sample or block is missing, use NaN
            dSlice = [];
            bFunction = [];
        end % getClicked
        
        function [cbHandles, hitHandles] = getHitObjects(obj) %#ok<MANU>
            % Return handles that should register callbacks as well has hit handles
            cbHandles = {};
            hitHandles = {};
        end % getHitObjects
        
        function value = getIDMap(obj, key)
            % Return cell array of IDs that have key as a name
            value = {};
            if obj.IDMap.isKey(key)
                value = obj.IDMap(key);
            end
        end % getMappedID
        
        function keys = getIDMapKeys(obj)
            % Return cell array with current IDMap keys
            keys = obj.IDMap.keys();
        end % getIDMapKeys
        
        function [dSlice, bFunction] = getInitialSourceInfo(obj) %#ok<MANU>
            % Return data slice for initializing downstream items
            %
            % Notes:
            %   - if the data slice is not valid, return empty
            %   - if one of element, sample or block is missing, use NaN
            dSlice = [];
            bFunction = [];
        end % getInitialSourceInfo
        
        function targets = getMasterTargets(obj)
            if obj.Unmapped.isKey('master')
                targets = obj.Unmapped('master');
            else
                targets = {};
            end
        end % getMasterTargets
        
        function value = getSourceMap(obj, key)
            % Return value associated with key in SourceMap
            value = [];
            if obj.SourceMap.isKey(key)
                value = obj.SourceMap(key);
            end
        end % getSourceMap
        
        function keys = getSourceMapKeys(obj)
            % Return cell array with current SourceMap keys
            keys = obj.SourceMap.keys();
        end % getSourceMapKeys
        
        function values = getUnmapped(obj, key)
            % Return cell array of values associated with key in Unmapped
            values = [];
            if obj.Unmapped.isKey(key)
                values = obj.Unmapped(key);
            end
        end % getUnmapped
        
        function keys = getUnmappedKeys(obj)
            % Return cell array with current Unmapped keys
            keys = obj.Unmapped.keys();
        end % getSourceMapKeys
        
        function initializeFromSources(obj)
            % Initialize from sources - should be controlled by master app
            keys = obj.getSourceMapKeys();
            for k = 1:length(keys)
                % Get the plot and see if it is a source
                source = obj.getSourceMap(keys{k});
                targets = source.targets;
                if isempty(targets)
                    continue;
                end
                source = source.plot;
                [dSlice, bFunction] = source.getInitialSourceInfo();
                
                % Ignore this source in initial display
                if isempty(dSlice) || isempty(bFunction)
                    continue;
                end
 
                data = bFunction.getData();
                
                for j = 1:length(targets)
                    tObj = obj.SourceMap(targets{j});
                    tObj = tObj.plot;  % get visualization out of structure
                    tObj.plot(data, bFunction, dSlice);
                end
            end
        end % initializeFromSources
             
        function putIDMap(obj, key, value)
            % Add key to the list associated with key in IDMap
            if isempty(value) || ~isa(value, 'char')
                return;
            elseif obj.IDMap.isKey(key)
                obj.IDMap(key) = [obj.IDMap(key) {value}];
            else
                obj.IDMap(key) = {value};
            end
        end % putIDMap
        
        function putSourceMap(obj, key, value)
            % Put (key, value) into source map, replacing existing value
            if isempty(value)
                return;
            else
                obj.SourceMap(key) = value;
            end
        end % putSourceMap
        
        function putUnmapped(obj, key, value)
            % Add value to the list associated with key in Unmapped
            if isempty(value)
                return;
            elseif obj.Unmapped.isKey(key)
                obj.Unmapped(key) = [obj.Unmapped(key) {value}];
            else
                obj.Unmapped(key) = {value};
            end
        end % putUnmapped
        
        function registerCallbacks(obj, master)
            % Register the callbacks for this clickable object
            [cbHandles, hitHandles] = getHitObjects(obj);
            for k = 1:length(cbHandles)  % set callbacks on underlying objects
                set(cbHandles{k}, 'ButtonDownFcn', ...
                    {@obj.buttonDownCallback, master});
            end
            for k = 1:length(hitHandles) % set HitTest on underlying targets
                set(hitHandles{k}, 'HitTest', 'on');
            end
        end % registerCallbacks
        
        function numUnmapped = remapSources(obj)
            % See if any unmapped sources have become available and remap
            numUnmapped = 0;
            uKeys = obj.getUnmappedKeys(); % Find unmapped keys
            for k = 1:length(uKeys)
                uValues = obj.getUnmapped(uKeys{k}); %
                if ~obj.IDMap.isKey(uKeys{k})  % Not here yet
                    numUnmapped = numUnmapped + length(uValues);
                    continue;
                end;
                % All of my IDs for this name have this target
                myIDs = obj.IDMap(uKeys{k});
                for j = 1:length(myIDs)
                    myValue = obj.getSourceMap(myIDs{j});
                    myValue.targets = [myValue.targets uValues];
                    obj.putSourceMap(myIDs{j}, myValue);
                end
                obj.Unmapped.remove(uKeys{k}); % no longer unmapped
            end
        end % remapSources
        
        function numUnmapped = mergeSource(obj, clickObj, independent)
            % Merge clickObj sources into this object's source map
            numUnmapped = 0;
            if ~isa(clickObj, 'visviews.clickable')
                return;
            end
            
            % Get the keys from clickObj and process
            cKeys = clickObj.getSourceMapKeys();
            for k = 1:length(cKeys)
                if obj.SourceMap.isKey(cKeys{k})
                    warning('clickable:duplicateKey', [class(clickObj) ...
                        ' ' num2str(clickObj.getInternalID()) ...
                        ' has duplicate key ' cKeys{k}]);
                    continue;
                end
                value = clickObj.getSourceMap(cKeys{k});
                obj.putSourceMap(cKeys{k}, value);
                % Update the IDMap as well
                obj.putIDMap(strtrim(lower(value.name)), cKeys{k});
            end
            
            % Now process unmapped sources
            uKeys = clickObj.getUnmappedKeys(); % Find unmapped keys
            if isempty(uKeys)
                return;
            elseif independent  % Should have no unmapped sources
                keyStr = ['\n' uKeys{1}];
                for k = 2:length(uKeys)
                    keyStr = sprintf('%s %s', keyStr, uKeys{k});
                end
                warning('clickable:unmergedSource', [class(clickObj) ...
                    ' ' num2str(clickObj.getInternalID()) ...
                    ' has unmatched sources: ' keyStr]);
                numUnmapped = numUnmapped + length(uKeys);
                return;
            end
            
            % Must handle unmapped sources
            for k = 1:length(uKeys)
                uValues = clickObj.getUnmapped(uKeys{k});
                if ~obj.IDMap.isKey(uKeys{k}) % Join ranks of unmapped
                    numUnmapped = numUnmapped + length(uValues);
                    for j = 1:length(uValues)
                        obj.putUnmapped(uKeys{k}, uValues{j});
                    end
                    continue;
                end;
                % All of my IDs for this name have this target
                myIDs = obj.IDMap(uKeys{k});
                for j = 1:length(myIDs)
                    myValue = obj.getSourceMap(myIDs{j});
                    myValue.targets = [myValue.targets uValues];
                    obj.putSourceMap(myIDs{j}, myValue);
                end
            end
        end % mergeSource
        
        function processSource(obj, p, pCon)
            % Update obj.SourceMap from plot p corresponding to plotObj pCon
            if ~isa(p, 'visviews.clickable') || ~isa(pCon, 'visviews.plotObj')
                return;
            end
            % If this object was already processed, skip and output warning
            plotID = num2str(p.getInternalID());
            plotName = strtrim(lower(pCon.getDisplayName()));
            if obj.SourceMap.isKey(plotID)
                warning('clickable:duplicatePlot', ['Already processed '
                    'object ' plotName ' with ID: ' num2str(plotID)]);
                return;
            end
            
            s = visviews.clickable.getStructure(p, pCon);
            % Add to the IDMap objects
            obj.putIDMap(plotName, plotID);
            
            % If this object resolves an unmapped plot, resolve it
            if obj.Unmapped.isKey(plotName)  % Unmapped source
                t = obj.Unmapped(plotName);
                s.targets = t;
                obj.Unmapped.remove(plotName); % no longer unmapped
            end
            obj.putSourceMap(plotID, s);
            
            % Now process sources
            srcs = strtrim(lower(s.sources));
            for k = 1:length(srcs)  % Merge sources if necessary
                if obj.IDMap.isKey(srcs{k})
                    srcIDs = obj.IDMap(srcs{k});
                    for j = 1:length(srcIDs)
                        src = obj.SourceMap(srcIDs{j});
                        src.targets = [src.targets, {plotID}];
                        obj.SourceMap(srcIDs{j}) = src;
                    end
                else  % Source is unmapped
                    obj.putUnmapped(srcs{k}, plotID);
                end
            end
            
        end % processSource
        
        % CALLBACKS ----------------------------------------
        
        function buttonDownCallback (obj, src, eventdata, master) %#%#ok<MSNU> ok<INUSL>
            % Callback links master component to details
            obj.buttonDownPreCallback(src, eventdata);
            id = num2str(obj.getInternalID());
            
            [dSlice, bFunction] = obj.getClicked();
            if isempty(dSlice) || isempty(bFunction)
                return;
            end
            
            % Plot slices for direct targets
            if ~isempty(master) && isa(master, 'visviews.clickable')
                plot = master.getSourceMap(id);
                targets = plot.targets;
                if ~isempty(targets)
                    data = bFunction.getData();
         
                    for k = 1:length(targets)
                        tObj = master.SourceMap(targets{k});
                        tObj = tObj.plot;  % get visualization out of structure
                        tObj.plot(data, bFunction, dSlice);
                    end
                end
                % Ask the master to plot links to details
                if obj.LinkDetails
                    master.plotDetails(bFunction, dSlice);
                end
                
                % Register callbacks because things might have changed
                master.registerCallbacks();
            end
            obj.buttonDownPostCallback(src, eventdata);
        end % buttonDownCallback
        
        function buttonDownPreCallback (obj, src, eventdata)  %#ok<INUSD,MANU>
            % Source-specific function called at beginning of callback
        end % buttonDownPreCallback
        
        function buttonDownPostCallback (obj, src, eventdata)  %#ok<INUSD,MANU>
            % Source-specific function called at end of callback
        end % buttonDownPostCallback
        
    end % public methods
    
    methods (Static = true)
        

        
      function s = getStructure(p, pCon)
            % Return a structure for the plot information for SourceMap
            s = struct('plot', '', 'plotObj', '', 'name', '', 'sources', {}, 'targets', {});
            s(1).plot = p;            % Actual plot
            s(1).plotObj = pCon;      % Plot object associated with plot
            if ~isempty(pCon)
                s(1).sources = strtrim(lower(pCon.getSources()));
                s(1).name = pCon.getDisplayName();
            end
        end % getStructure
        
        function printStructure(s)
            % Print a SourceMap value structure
            fprintf('Plot: %d name: %s class: %s, sources: {',  ...
                s.plot.getInternalID(), s.name, class(s.plot));
            for k = 1:length(s.sources)
                fprintf(' %s', s.sources{k});
            end
            fprintf(' }, targets: {');
            for k = 1:length(s.targets)
                fprintf(' %s', s.targets{k});
            end
            fprintf(' }\n');
        end % printStructure
    end % private methods
    
end % clickable

