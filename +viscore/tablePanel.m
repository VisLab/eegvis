% viscore.tablePanel  spreadsheet-like grid for editing values
%
% Usage:
%    >> obj = tablePanel(parent, cNames, cFormat, cEditable, cWidthRatio)
%
% Description:
% tablePanel(parent, cNames, cFormat, cEditable, cWidthRatio) creates
%     a table panel object embedded in the parent. Here parent is the
%     handle to a container or figure. The cNames parameter is a cell
%     array containing the names of the table columns. The cFormat is a
%     cell array specifying the formats of the respective columns. Allowed
%     values include 'logical' (column displays as a checkbox with 
%     checked indicating true), 'char' (column displays as an editable
%     text box), or a cell array of strings (column displays as a
%     pull-down menu of those strings). The cEditable is
%     a vector of logicals indicating whether the respective columns may
%     be modified. The cWidthRatio is a vector indicating the relative
%     sizes of the columns. The relative sizes are preserved on table resize.
% 
%
% obj = tablePanel(parent, cNames, cFormat, cEditable, cWidthRatio)
%     returns a handle to the spreadsheet GUI panel.
%
%
% Example:
% Create a table panel in a figure
%   sfig = figure('Toolbar', 'none', 'MenuBar', 'none', ...
%              'WindowStyle', 'normal', 'DockControls', 'on');
%   cNames = {'Enabled', 'Summary plots', 'Choices'};
%   cFormat = {'logical', 'char', {'This', 'That'}};
%   cEditable = [true, true, true];
%   cWidths = [ 1, 2, 1];
%   mainHBox = uiextras.HBox('Parent', sfig, ...
%                'Tag', 'MainHBox',  'Spacing', 5, 'Padding', 5);
%   tp = viscore.tablePanel(mainHBox, cNames, cFormat, cEditable, cWidths);
%   tdata = cell(2, 4);
%   tdata(1, :) = {true, 'Help me', 'This', 'Tag1'};
%   tdata(2, :) = {false, 'Help you', 'That', 'Tag2'};
%   tp.setTableData(tdata);
%   
% Class documentation:
% Execute the following in the MATLAB command window to view the class 
% documentation for viscore.tablePanel:
%
%    doc viscore.tablePanel
%
% See also: viscore.dataConfig, visfuncs.functionConfig,
% viscore.managedObj, visviews.plotConfig, and viscore.tableConfig

% Copyright (C) 2011 Arif Hoissan, Kay Robbins, UTSA, krobbins@cs.utsa.edu
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
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1.07  USA

% $Log: viscore.tablePanel.m,v $
% Revision: 1.00  04-Dec-2011 09:11:20  krobbins $
% Initial version $
%

classdef tablePanel < hgsetget
    
    properties (Access = private)
        %         ColumnNames        % cell array with column names
        %         ColumnFormat       % cell array with column formats
        ColumnWidthRatio   % default sizes of the columns
        HomeTable          % matlab uitable for displaying the data
        SelectedRows       % holds logical vector of selected rows
    end % private properties

    properties (Constant)
        TableHeightPad = 10     % total top and bottom table border
        TableWidthPad = 16      % total right and left table border       
        TableXPad = 2           % offset of table from left of panel
        TableYPad = 2           % offset of table from bottom of panel       
    end % constant properties
    
    methods  
        
        function obj = tablePanel(parent, cNames, cFormat, ...
            cEditable, cWidthRatio)
            % Create a table panel with the specified columns
            hPanel = uipanel('Parent', parent, ...
                'Tag', 'HomePanel', 'Units', 'pixels');
            obj.ColumnWidthRatio = cWidthRatio;
            obj.HomeTable = uitable('Parent', hPanel, ...
                'ColumnName', cNames, ...
                'ColumnFormat', cFormat, ...
                'ColumnEditable', cEditable, ...
                'Tag', 'HomeTable', ...
                'RowName', [], 'Data', []);
            set(hPanel,'ResizeFcn',{@obj.panelResizeCallback});
            set(obj.HomeTable,'CellEditCallback', {@obj.cellEditCallback});
            set(obj.HomeTable,'CellSelectionCallback', ...
                {@obj.cellSelectionCallback});
            obj.SelectedRows = false(0, 0);
        end % tablePanel constructor
        
        function obj = addRow(obj, newRowData)
            % Append a row containing newRowData to the end of the table
            tableData = cat(1, get(obj.HomeTable, 'Data'), newRowData);
            set(obj.HomeTable, 'Data', tableData);
            obj.SelectedRows = false(size(tableData, 1), 1);
        end % addRow
        
        function clearSelected(obj)
            % Clear the internal designation of which rows are selected
            obj.SelectedRows(:) = false;            
        end % clearSelected
           
        function numCols = getNumberColumns(obj)
            % Return the number of columns currently in the table
            numCols = length(get(obj.HomeTable, 'ColumnName'));
        end % getNumberColumns
        
        function numRows = getNumberRows(obj)
            % Return the number of rows currently in the table
            numRows = length(obj.SelectedRows);
        end % getNumberRows
        
        function sRows = getSelected(obj)
            % Return a vector of selected table row indices or empty if none
            sRows = obj.SelectedRows;
        end % getSelectedRows
        
        function tData = getTableData(obj)
            %Return the Data property of the table
            tData = get(obj.HomeTable, 'Data');
        end % getTableData     
        
        function resetEditable(obj, editable)
            % Perform management tasks associated with editing
            columnEditable = repmat(editable, 1, obj.getNumberColumns());
            obj.setColumnEditable(columnEditable);
            obj.clearSelected();
        end % resetEditable
        
        function obj = setColumnEditable(obj, columnEditable)
            % Set whether the columns are editable or not
            %
            % Inputs:
            % columnEditable   logical vector indicating column editable
            set(obj.HomeTable, 'ColumnEditable', columnEditable);
        end % setColumnEditable
        
        function setTableData(obj, tableData)
            % Set the table Data property
            set(obj.HomeTable, 'Data', tableData);
            obj.SelectedRows = false(size(tableData, 1), 1);
        end % setTableData
        
    end % public methods
    
    methods (Access = private)
        
        function panelResizeCallback(obj, src, eventdata)  %#ok<INUSD>
            % Callback for table panel resize.            
            % First position the table correctly
            panelSize = get(src,'Position');
            set(obj.HomeTable, 'Position', ...
                [panelSize(1) + viscore.tablePanel.TableXPad, ...
                panelSize(2) - viscore.tablePanel.TableYPad, ...
                panelSize(3) - viscore.tablePanel.TableWidthPad, ...
                panelSize(4) - viscore.tablePanel.TableHeightPad]);
            % Change column widths of table according to the given ratio
            scale = (panelSize(3) - viscore.tablePanel.TableWidthPad)/ ...
                sum(obj.ColumnWidthRatio);
            newColumnWidth = obj.ColumnWidthRatio.*floor(scale(1));
            % Add the extra space to the last column as needed
            spaceLeft = panelSize(3) - viscore.tablePanel.TableWidthPad ...
                - sum(newColumnWidth) - 2;
            newColumnWidth(size(newColumnWidth, 2)) = ...
                newColumnWidth(size(newColumnWidth, 2)) + spaceLeft;
            set(obj.HomeTable, 'ColumnWidth', num2cell(newColumnWidth));
        end % panelResizeCallback
        
        function cellEditCallback(obj, src, eventdata)  %#ok<INUSL>
            % Callback for table cell editing
            tData = obj.getTableData();
            tData{eventdata.Indices(1), eventdata.Indices(2)} = ...
                eventdata.NewData;
            obj.setTableData(tData);
            obj.SelectedRows(:) = false;
        end % cellEditCallback
        
        function cellSelectionCallback(obj, src, eventdata)  %#ok<INUSL>
            % Callback for table cell selection
            obj.SelectedRows(:) = false;
            obj.SelectedRows(squeeze(eventdata.Indices(:, 1))) = true;
        end % cellSelectionCallback
        
    end % private methods
    
end  % tablePanel