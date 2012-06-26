function test_suite = testTableConfig %#ok<STOUT>
initTestSuite;

function values = setup %#ok<DEFNU>
values.deleteFigures = true;

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test


function testConstructor(values) %#ok<DEFNU>
% Unit test for viscore.tableConfig constructor
fprintf('\nUnit tests for viscore.tableConfig valid constructor\n');

fprintf('It should construct a valid table configuration when a selector and title are passed as parameters\n');
keyfun = @(x) x.('DisplayName');
defaults = tableTestObj.createObjects('viscore.managedObj', ...
                                      tableTestObj.getDefaults(), keyfun);
selector = viscore.dataSelector('viscore.tableConfig');
selector.getManager().putObjects(defaults);
title = 'test figure';
plistc = viscore.tableConfig(selector, title);
assertTrue(isvalid(plistc));
drawnow
if values.deleteFigures
   delete(plistc);
end

function testColorMap2String(values) %#ok<INUSD,DEFNU>
% Unit test for viscore.tableConfig constructor
fprintf('\nUnit tests for viscore.tableConfig colorMap2String static method\n');

fprintf('It should convert from a color map to a string representation\n');
x = '[0, 1, 1; 1, 0.5, 1]';
y = num2str(x);
assertTrue(ischar(y));
z = viscore.tableConfig.string2ColorMap(y);
assertVectorsAlmostEqual(z, [0, 1, 1; 1, 0.5, 1]);
w = viscore.tableConfig.colorMap2String(z);
fprintf('%s : %s\n', x, w);
assertTrue(strcmpi(w, x) == 1);


function testConfigFromVariables(values) %#ok<DEFNU>
% Unit test for viscore.tableConfig load and save
fprintf('\nUnit tests for viscore.tableConfig getting and setting configuration\n');
fprintf('It should get and set the configuration\n');
title = 'test get/set figure';
keyfun = @(x) x.('DisplayName');
defaults = tableTestObj.createObjects('viscore.managedObj', ...
                                      tableTestObj.getDefaults(), keyfun);
selector = viscore.dataSelector('viscore.dataConfig');
selector.getManager().putObjects(defaults);
bfc = tableConfigTestClass(selector, title); 
drawnow
assertTrue(isvalid(bfc));
objList = bfc.getCurrentManager().getObjects();
fprintf('It should make a configuration structure for each managed object\n');
for k = 1:length(objList)
    s = objList{k}.getConfiguration();
    assertTrue(isa(s, 'struct'));
end

keyfun = @(x) x.('DisplayName');
defaults2 = tableTestObj.createObjects('viscore.managedObj', ...
                                    tableTestObj.getDefaultPlots(), keyfun);                           
selector = viscore.dataSelector('viscore.dataConfig');
selector.getManager().putObjects(defaults2);
title2 = 'test get/set figure with more rows';
bfc2 = tableConfigTestClass(selector, title2); 
fprintf('The configuration replaces the old values\n');
objList2 = bfc2.getCurrentManager().getObjects();
fprintf('It should make a configuration structure for each managed object\n');
for k = 1:length(objList2)
    s = objList2{k}.getConfiguration();
    assertTrue(isa(s, 'struct'));
end
if values.deleteFigures
    delete(bfc);
    delete(bfc2);
end