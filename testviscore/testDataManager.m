function test_suite = testDataManager %#ok<STOUT>
% Unit tests for viscore.dataManager
initTestSuite;

function testConstuctor %#ok<DEFNU>
% Unit test for viscore.dataManager valid constructor 
fprintf('\nUnit tests for viscore.dataManager valid constructor\n');

fprintf('It should create a valid object when no parameters are passed to constructor\n');
ms = viscore.dataManager();
assertTrue(isobject(ms));

function testPutObject %#ok<DEFNU>
% Unit test for viscore.dataManager putObject method
fprintf('\nUnit tests for viscore.dataManager putObject method\n');

fprintf('It should allow an object to be put by key in the manager\n');
ms = viscore.dataManager();
cName = 'myKey';
mObj = viscore.managedObj(cName, baseTestClass.getDefaults());
ms.putObject(cName, mObj);
thisList = ms.getObject(cName);
assertTrue(~isempty(thisList));
assertTrue(length(thisList.getStructure()) == 8);

function testGetEnabledObjects %#ok<DEFNU>
% Unit test for viscore.dataManager getEnabledObjects method
fprintf('\nUnit tests for viscore.dataManager getEnabledObjects method\n');

fprintf('It should return a cell array of enabled objects\n');
ms = viscore.dataManager();
cName = 'myKey';
mObj = viscore.managedObj(cName, baseTestClass.getDefaults());
ms.putObject(cName, mObj);
ms.putObject('baseTestClass', mObj);
ls = ms.getEnabledObjects('');
assertTrue(length(ls) == 2);
assertTrue(isa(ls, 'cell'));


function testGetObject %#ok<DEFNU>
% Unit test for viscore.dataManager getObject method
fprintf('\nUnit tests for viscore.dataManager getObject method\n');

fprintf('It should return the correct object given its name\n');
ms = viscore.dataManager();
settings = baseTestClass.getDefaults();
mp = viscore.managedObj([], settings);
cName = 'CoreTestClass//';
ms.putObject(cName, mp);
settingsNew = ms.getObject(cName).getStructure();
assertEqual(length(settings), length(settingsNew));
sNew = settingsNew(1);
s = settings(1);
assertTrue(strcmp(sNew.ID, s.ID));
assertTrue(sNew.Enabled == s.Enabled);
assertTrue(strcmp(sNew.Category, s.Category));
assertTrue(strcmp(sNew.DisplayName, s.DisplayName));
assertTrue(strcmp(sNew.Description, s.Description));
assertTrue(strcmp(sNew.Options, s.Options));

function testDeleteItems %#ok<DEFNU>
% Unit test for viscore.dataManager deleteItems method
fprintf('\nUnit tests for viscore.dataManager deleteItems method\n');

fprintf('It should correctly delete items from the manager\n');
ms = viscore.dataManager();
settings = baseTestClass.getDefaults();
cName = 'CoreTestClass';
mp = viscore.managedObj('CoreTestClass', settings);
ms.putObject(cName, mp);
settingsNew = ms.getObject(cName).getStructure();
assertEqual(length(settings), length(settingsNew));
mp = viscore.managedObj('Apples', settings);
ms.putObject('Apples', mp);
mp = viscore.managedObj('Bananas', settings);
ms.putObject('Bananas', mp);
mp = viscore.managedObj('Grapes', settings);
ms.putObject('Grapes', mp);
mp = viscore.managedObj('Pears', settings);
ms.putObject('Pears', mp);
ms.printObjects('See the order');
assertEqual(ms.getNumberObjects(), 5);
ms.remove('Apples');
ms.remove('Grapes');
assertEqual(ms.getNumberObjects(), 3);
ms.printObjects('\nAfter deletion');


function testCreateConfigur %#ok<DEFNU>
% Unit test for viscore.dataManager createConfigur static method
fprintf('\nUnit tests for viscore.dataManager createConfig static method\n');

fprintf('It should return a cell array of enabled objects\n');
ms = viscore.dataManager();
cName = 'myKey';
mObj = viscore.managedObj(cName, baseTestClass.getDefaults());
ms.putObject(cName, mObj);
ms.putObject('baseTestClass', mObj);
ls = ms.getEnabledObjects('');
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
