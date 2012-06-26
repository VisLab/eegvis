function test_suite = testDataManager %#ok<STOUT>
% Unit tests for viscore.dataManager
initTestSuite;

function values = setup %#ok<DEFNU>
values.ms = viscore.dataManager();

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testConstuctor(values) %#ok<DEFNU>
% Unit test for viscore.dataManager valid constructor 
fprintf('\nUnit tests for viscore.dataManager valid constructor\n');

fprintf('It should create a valid object when no parameters are passed to constructor\n');
assertTrue(isobject(values.ms));

function testPutObject(values) %#ok<DEFNU>
% Unit test for viscore.dataManager putObject method
fprintf('\nUnit tests for viscore.dataManager putObject method\n');

fprintf('It should allow an object to be put by key in the manager\n');
cName = 'myKey';
mObj = viscore.managedObj(cName, baseTestClass.getDefaults());
values.ms.putObject(cName, mObj);
thisList = values.ms.getObject(cName);
assertTrue(~isempty(thisList));
assertTrue(length(thisList.getStructure()) == 8);

function testGetEnabledObjects(values) %#ok<DEFNU>
% Unit test for viscore.dataManager getEnabledObjects method
fprintf('\nUnit tests for viscore.dataManager getEnabledObjects method\n');

fprintf('It should return a cell array of enabled objects\n');
cName = 'myKey';
mObj = viscore.managedObj(cName, baseTestClass.getDefaults());
values.ms.putObject(cName, mObj);
values.ms.putObject('baseTestClass', mObj);
ls = values.ms.getEnabledObjects('');
assertTrue(length(ls) == 2);
assertTrue(isa(ls, 'cell'));


function testGetObject(values) %#ok<DEFNU>
% Unit test for viscore.dataManager getObject method
fprintf('\nUnit tests for viscore.dataManager getObject method\n');

fprintf('It should return the correct object given its name\n');
settings = baseTestClass.getDefaults();
mp = viscore.managedObj([], settings);
cName = 'CoreTestClass//';
values.ms.putObject(cName, mp);
settingsNew = values.ms.getObject(cName).getStructure();
assertEqual(length(settings), length(settingsNew));
sNew = settingsNew(1);
s = settings(1);
assertTrue(strcmp(sNew.ID, s.ID));
assertTrue(sNew.Enabled == s.Enabled);
assertTrue(strcmp(sNew.Category, s.Category));
assertTrue(strcmp(sNew.DisplayName, s.DisplayName));
assertTrue(strcmp(sNew.Description, s.Description));
assertTrue(strcmp(sNew.Options, s.Options));

function testDeleteItems(values) %#ok<DEFNU>
% Unit test for viscore.dataManager deleteItems method
fprintf('\nUnit tests for viscore.dataManager deleteItems method\n');

fprintf('It should correctly delete items from the manager\n');
settings = baseTestClass.getDefaults();
cName = 'CoreTestClass';
mp = viscore.managedObj('CoreTestClass', settings);
values.ms.putObject(cName, mp);
settingsNew = values.ms.getObject(cName).getStructure();
assertEqual(length(settings), length(settingsNew));
mp = viscore.managedObj('Apples', settings);
values.ms.putObject('Apples', mp);
mp = viscore.managedObj('Bananas', settings);
values.ms.putObject('Bananas', mp);
mp = viscore.managedObj('Grapes', settings);
values.ms.putObject('Grapes', mp);
mp = viscore.managedObj('Pears', settings);
values.ms.putObject('Pears', mp);
values.ms.printObjects('See the order');
assertEqual(values.ms.getNumberObjects(), 5);
values.ms.remove('Apples');
values.ms.remove('Grapes');
assertEqual(values.ms.getNumberObjects(), 3);
values.ms.printObjects('\nAfter deletion');


function testCreateConfig(values) %#ok<DEFNU>
% Unit test for viscore.dataManager createConfig static method
fprintf('\nUnit tests for viscore.dataManager createConfig static method\n');

fprintf('It should return a cell array of enabled objects\n');
cName = 'myKey';
mObj = viscore.managedObj(cName, baseTestClass.getDefaults());
values.ms.putObject(cName, mObj);
values.ms.putObject('baseTestClass', mObj);
ls = values.ms.getEnabledObjects('');
assertTrue(length(ls) == 2);
assertTrue(isa(ls, 'cell'));
fprintf('It should use the object ID for the key if no keys are passed\n');
config1 = viscore.dataManager.createConfig({mObj, mObj}, []);
assertTrue(strcmp(config1(1).key, 'myKey'));
assertTrue(strcmp(config1(2).key, 'myKey'));
fprintf('It should use the pass key if it is passed\n');
config1 = viscore.dataManager.createConfig({mObj, mObj}, {'myKey', 'baseTestClass'});
assertTrue(strcmp(config1(1).key, 'myKey'));
assertTrue(strcmp(config1(2).key, 'baseTestClass'));
