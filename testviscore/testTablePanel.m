function test_suite = testTablePanel %#ok<STOUT>
% Unit tests for viscore.tablePanel
initTestSuite;

function testNormalConstructor %#ok<DEFNU>
% Unit test for viscore.tableConfig normal constructor
fprintf('\nUnit tests for viscore.tableConfig valid constructor\n');

fprintf('It should construct a valid table when parent, column names, formats, editability, and widths are passed\n');
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
assertTrue(isvalid(tp));
delete(sfig);

