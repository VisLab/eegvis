%% viscore.tablePanel
% Spreadsheet-like grid for editing values
%
%% Syntax
%    tablePanel(parent, cNames, cFormat, cEditable, cWidthRatio)
%    obj = tablePanel(parent, cNames, cFormat, cEditable, cWidthRatio)
%
%% Description
% |tablePanel(parent, cNames, cFormat, cEditable, cWidthRatio)| creates
% a table panel object embedded in the |parent|. Here |parent| is the
% handle to a container or figure. The |cNames| parameter is a cell
% array containing the names of the table columns. The |cFormat| is a
% cell array specifying the formats of the respective columns. Allowed
% values include |'logical'| (column displays as a checkbox with 
% checked indicating |true|), |'char'| (column displays as an editable
% text box), or a cell array of strings (column displays as a
% pull-down menu of those strings). The |cEditable| is
% a vector of logicals indicating whether the respective columns may
% be modified. The |cWidthRatio| is a vector indicating the relative
% sizes of the columns. The relative sizes are preserved on table resize.
% 
%
% |obj = tablePanel(parent, cNames, cFormat, cEditable, cWidthRatio)| 
% returns a handle to the spreadsheet GUI panel.
%
%
%% Example
% Create a table panel in a figure
   sfig = figure('Toolbar', 'none', 'MenuBar', 'none', ...
              'WindowStyle', 'normal', 'DockControls', 'on');
   cNames = {'Enabled', 'Summary plots', 'Choices'};
   cFormat = {'logical', 'char', {'This', 'That'}};
   cEditable = [true, true, true];
   cWidths = [ 1, 2, 1];
   mainHBox = uiextras.HBox('Parent', sfig, ...
                'Tag', 'MainHBox',  'Spacing', 5, 'Padding', 5);
   tp = viscore.tablePanel(mainHBox, cNames, cFormat, cEditable, cWidths);
   tdata = cell(2, 4);
   tdata(1, :) = {true, 'Help me', 'This', 'Tag1'};
   tdata(2, :) = {false, 'Help you', 'That', 'Tag2'};
   tp.setTableData(tdata);
   
%% Class documentation
% Execute the following in the MATLAB command window to view the class 
% documentation for |viscore.tablePanel|:
%
%    doc viscore.tablePanel
%
%% See also
% <dataConfig_help.html |viscore.dataConfig|>,
% <functionConfig_help.html |visfuncs.functionConfig|>,
% <managedObj_help.html |viscore.managedObj|>,
% <plotConfig_help.html |visviews.plotConfig|>, and
% <tableConfig_help.html |viscore.tableConfig|>

%% 
% Copyright 2011 Kay A. Robbins, University of Texas at San Antonio