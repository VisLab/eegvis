% viscore.tableConfig  GUI base class for table-based configuration
%
% Usage:
%    >>  viscore.tableConfig(selector, title)
%    >>  obj = viscore.tableConfig(selector, title)
%
% Description:
% viscore.tableConfig(selector, title) creates a table GUI for
%     configuration by extending viscore.dataConfig. The selector must be a
%     non-empty object of type viscore.dataSelector. The title string
%     appears on the title bar of the figure window. 
%
%     The table configuration class provides methods for creating a MATLAB
%     uitable (as extended by viscore.tablePanel) in the central panel 
%     of the GUI. The class also provides methods to update
%     managed objects from the table and to set the table from managed objects.
%     The visviews.plotConfig and visfuncs.functionConfig GUIs extend
%     this class to provide specific configuration for plots and functions,
%     respectively.
%
%
% obj = viscore.dataConfig(selector, title) returns a handle to
%     the GUI base class for configuration
%
%
% Example:
% Create a table configuration for a structure using the display name 
% as the unique field
%    s = struct( ...
%           'Enabled',        {true,              true}, ...
%           'Category',       {'summary',        'detail'}, ...
%           'DisplayName',    {'Block Image',    'Signal'}, ...
%           'Definition',     {'visviews.blockImagePlot', ...
%                              'visviews.stackedSignalPlot'}, ...
%           'Description',    {'Displays an array as an image', ...
%                              'Displays raw signal using a stacked view'});
%   
%    keyfun = @(x) x.('DisplayName');
%    v = viscore.managedObj.createObjects('viscore.managedObj', s, keyfun);
%    selector = viscore.dataSelector('viscore.tableConfig');
%    selector.getManager().putObjects(v);
%    tc = viscore.tableConfig(selector, 'test figure');
%
% Class documentation:
% Execute the following in the MATLAB command window to view the class 
% documentation for viscore.tableConfig:
%
%    doc viscore.tableConfig
%
% See also: viscore.dataManager, viscore.dataSelector,
%    visfuncs.functionConfig, viscore.managedObj, visviews.plotConfig,  
%    visprops.propertyConfig, and viscore.tablePanel
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

% $Log: tableConfig.m,v $
% Revision: 1.00  04-Dec-2011 09:11:20  krobbins $
% Initial version $
%

classdef tableConfig < hgsetget & viscore.dataConfig
    properties
        MinNumberRows = 1;        % minimum number of rows required on delete
    end % public properties
    
    properties(SetAccess = private)
        ColumnWidthRatio;         % default column width ratios
        TableFields;              % field names of configuration structure
        TableFormats;             % formats of the underlying table
        tableObject;              % underlying table object
        TableTitles;              % title names of columns
        UniqueColumns;            % positions of field names with unique values
    end % private properties
    
    methods
        
        function obj = tableConfig(selector, title)
            % Constructor creates a table object
            obj = obj@viscore.dataConfig(selector, title);
            set(obj.ConFig, 'Position', [200 342 800 500]);
        end % tableConfig constructor
              
    end % public methods
    
    methods (Access = protected)
        
        function addDummyItem(obj)
            % Add a valid dummy row to the GUI configuration table
            s = eval([class(obj) '.getDefaultStructure()']);
            row = obj.getRowFromStructure(s);
            obj.tableObject.addRow(row);
            nObj = obj.getNewManagedObj(s);
            obj.CurrentManager.putObjects({nObj});
        end % addDummyItem
        
        function okay = checkUnique(obj)
            % Return true if specified unique columns have unique values
            okay = true;
            if isempty(obj.UniqueColumns)
                return;
            end
            tableData = obj.tableObject.getTableData();
            for k = 1:length(obj.UniqueColumns)
                names = unique(tableData(:, obj.UniqueColumns(k))); 
                if length(names) ~= size(tableData, 1) 
                    warning('tableConfig:NonUniqueNames', ...
                            [obj.TableTitles{obj.UniqueColumns(k)} ...
                            ' entries are not unique --- cannot exit Edit mode']);
                    okay = false;
                end
            end
        end % checkUnique
        
        function createMainPanel(obj, parent)
            % Create table part of the layout (called by base class)
            tStruct = eval([class(obj) '.getTableStructure()']);
            obj.TableFields = {tStruct.('name')};
            obj.UniqueColumns = find(cell2mat({tStruct.('unique')}));
            obj.TableTitles = {tStruct.('title')};
            obj.TableFormats = {tStruct.('format')};
            cFormats = obj.TableFormats;
            cPos = find(strcmpi(cFormats, 'colors'));
            for k = 1:length(cPos)
                cFormats{cPos(k)} = 'char';
            end
            columnWidths = cell2mat({tStruct.('width')});
            columnEditable = cell2mat({tStruct.('editable')});
            obj.tableObject = viscore.tablePanel(parent, obj.TableTitles, ...
                cFormats, columnEditable, columnWidths);
        end % createMainPanel
        
        function numDeleted = deleteManaged(obj)
            % Delete rows selected in the GUI table and update the manager
            numDeleted = 0; 
            
            % check to see if number of table rows already at minimum     
            tableData = obj.tableObject.getTableData();                      
            selected = obj.tableObject.getSelected();
            rows = find(selected);
            numberToDelete = min(length(rows), size(tableData, 1) - obj.MinNumberRows);
            if numberToDelete < 1
                return;
            end
            
            % Delete the rows one at a time from bottom up
            k = length(rows);
            while k > 0 && numberToDelete > 0
                key = obj.getKeyFromRow(tableData(rows(k), :));
                deleted = obj.getCurrentManager().remove(key);
                numberToDelete = numberToDelete - deleted;
                numDeleted = numDeleted + deleted;
                k = k - 1;
            end    
            obj.updatePanelFromManager();
        end % deleteManaged
        
        function key = getKeyFromRow(obj, row) 
            % Returns the key used to identify this structure (override)
            namePos = find(strcmp('DisplayName', obj.TableFields), 1, 'first');
            if isempty(namePos)
                key = '';
            else
                key = row{namePos};
            end
        end % getKeyFromRow
        
        function key = getKeyFromStructure(obj, s) %#ok<MANU>
            % Return key corresponding to this structure (override)
            key = s.('DisplayName');
        end % getKeyFromStructure
        
        function newObj = getNewManagedObj(obj, s) 
            % Returns new managed object for s using unique key (override)
            newObj = viscore.managedObj(obj.getKeyFromStructure(s), s);
        end % getNewManagedObj
    
        function row = getRowFromStructure(obj, s)
            % Return a cell array with the elements of object structure
            row = cell(1, length(obj.TableFields));
            for k = 1:length(obj.TableFields)
                if strcmpi(obj.TableFormats{k}, 'colors')
                     row{k} = viscore.tableConfig.colorMap2String(s.(obj.TableFields{k}));
                else
                     row{k} = s.(obj.TableFields{k});
                end
            end
        end % getRowFromStructure
        
        function s = getStructureFromRow(obj, row)
            % Return a structure constructed from the table row
            s = struct();
            for k = 1:length(obj.TableFields)
                if strcmpi(obj.TableFormats{k}, 'logical')
                    s.(obj.TableFields{k}) = row{k};
                elseif strcmpi(obj.TableFormats{k}, 'colors')
                    s.(obj.TableFields{k}) = ...
                        viscore.tableConfig.string2ColorMap(row{k});
                else
                    s.(obj.TableFields{k}) = char(row{k});
                end
            end
        end % getStructureFromRow
                 
        function toggleEditable(obj)
            % Toggle edibility if valid (extending class should check if toggled)
            if ~obj.Editing || obj.checkUnique() || obj.checkValidity()
                obj.toggleEditable@viscore.dataConfig();
                obj.tableObject.resetEditable(obj.Editing);
            end
        end % toggleEditable
        
        function updateManagerFromPanel(obj)
            % Update current manager based on GUI table
            tableData = obj.tableObject.getTableData();
            obj.CurrentManager.clear(); % start from scratch
            rows = size(tableData, 1);
            mObjs = cell(rows, 1);
            for k = 1:rows
                s = getStructureFromRow(obj, tableData(k, :));
                mObjs{k} = obj.getNewManagedObj(s);
            end
            obj.CurrentManager.putObjects(mObjs);
        end % updateManagerFromPanel
        
        function updatePanelFromManager(obj)
            % Update the GUI table from the current manager
            obj.Editing = false;
            objList = obj.getCurrentManager().getObjects();
            data = cell(length(objList), obj.tableObject.getNumberColumns());
            for k = 1:length(objList)
                data(k, :) = obj.getRowFromStructure(objList{k}.getStructure());
            end
            obj.tableObject.setTableData(data);
            obj.tableObject.resetEditable(false);
        end % updatePanelFromManager
        
    end % protected methods
    
    methods (Static = true)
        
        function s = getDefaultStructure()
            % Returns a valid structure corresponding to a dummy row (Override)
            c = viscore.counter.getInstance();  % needed for unique entries
            s.Enabled = true;
            s.Category = 'summary';
            s.DisplayName = ['Image plot ' num2str(c.getNext())];
            s.Definition = 'visviews.blockImagePlot';
            s.Description = 'Displays an array of windowed values as an image';
        end  % getDefaultStructure
        
        function colorMap = string2ColorMap(colorString)
            % Return a color map from a string representation
            colorMap = [];
            if isempty(colorString) || strcmp(colorString(1), '[') == 0 ...
                || strcmp(colorString(end), ']') == 0
                return;
            end
            % Assume enclosed in square brackets
            cString = colorString(2:end-1);
            if isempty(cString)
                return;
            end
            colors = regexp(cString, ';', 'split');
            numColors = length(colors);
            cMap = zeros(numColors, 3);
            for k = 1:numColors
                thisColor = regexp(colors{k}, '[,\s]', 'split');
                bInd = strcmp(thisColor', '');
                thisColor(bInd) = [];    
                if length(thisColor) ~= 3
                    return;
                end
                cMap(k, :) = [str2double(thisColor(1)), ...
                    str2double(thisColor(2)), str2double(thisColor(3))];   
            end
            colorMap = cMap;        
        end % string2ColorMap
        
        function colorString = colorMap2String(colorMap)
            % Return a string representation of a color map 
            colorString = '';
            if isempty(colorMap) || ~isnumeric(colorMap) || ...
                size(colorMap, 2) ~= 3 || max(colorMap(:)) > 1 || ...
                min(colorMap(:)) < 0 
                return;
            end
            % Assume enclosed in square brackets
            for k = 1:size(colorMap, 1)
                colorString = [colorString '; ' num2str(colorMap(k, 1)) ...
                    ', ' num2str(colorMap(k, 2)), ', ' num2str(colorMap(k, 3))]; %#ok<AGROW>
            end
            colorString = ['[' colorString(3:end) ']'];            
        end % colorMap2String
        

        function tableStruct = getTableStructure()
            % Default table structure for a table (Override)
            tableStruct = struct( ...
                'title',    {'Enabled', 'Category', 'Display Name', 'Definition', 'Description'}, ...
                'name',     {'Enabled', 'Category', 'DisplayName',  'Definition', 'Description'}, ...
                'format',   {'logical', 'char',     'char',         'char',      'char'}, ...
                'editable', {false,      false,      false,         false,       false}, ...
                'unique',   {false,      false,      true,          false,       false}, ...
                'width',    {1,          1,          2,             3,           3} ...
                );
        end % getTableStructure
  
    end % static methods
    
end % tableConfig


