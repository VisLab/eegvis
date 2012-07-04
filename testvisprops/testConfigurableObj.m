function test_suite = testConfigurableObj %#ok<STOUT>
% Unit tests for configurableObj
initTestSuite;

function values = setup %#ok<DEFNU>
   values = [];
   
function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testConstructor(values) %#ok<INUSD,DEFNU>
% Unit test for visprops.configurableObj normal constructor
fprintf('\nUnit tests for visprops.configurableObj valid constructor\n');

fprintf('It should create a valid object when three empty parameters are passed to constructor\n');
ms = visprops.configurableObj([], [], []);
assertTrue(~isempty(ms));

fprintf('It should create a valid object when a valid target name is passed to constructor\n');
ms = visprops.configurableObj([], [], 'propertyTestClass');
assertTrue(~isempty(ms));
s = ms.getStructure();
assertEqual(length(s), 11);

function testGetDefaultFields(values) %#ok<INUSD,DEFNU>
% Unit test for visprops.configurableObj getDefaultFields static method
fprintf('\nUnit tests for visprops.configurableObj getDefaultFields static method\n');

fprintf('It should correctly return the a cell array of 11 default fields\n');
dFields = visprops.configurableObj.getDefaultFields();
assertEqual(length(dFields), 11);
s = viscore.managedObj.createEmptyStruct([], dFields);
fieldNames = fields(s);
assertEqual(length(fieldNames), 11);

function testUpdateManager(values) %#ok<INUSD,DEFNU>
% Unit test for visprops.configurableObj updateManager method
fprintf('\nUnit tests for visprops.configurableObj updateManager static method\n');

fprintf('It should correctly update manager after objects are added\n');
cObj1 = visprops.configurableObj([], [], 'configurableTestClass');
cObj2 = visprops.configurableObj('Apples', [], 'configurableTestClass');
cObj3 = visprops.configurableObj('ConfigurableTestClass', [], 'configurableTestClass2');
assertTrue(strcmpi(cObj1.getObjectID(), 'configurableTestClass'));
assertTrue(strcmpi(cObj2.getObjectID(), 'Apples'));
assertTrue(strcmpi(cObj3.getObjectID(), 'configurableTestClass'));

% Test all values removed
pMan = viscore.dataManager();
pMan.putObjects({cObj1, cObj2});
keys = pMan.getKeys();
assertEqual(length(keys), 2);
visprops.configurableObj.updateManager(pMan, [])
keys = pMan.getKeys();
assertTrue(isempty(keys));

fprintf('It should correctly update one new object\n');
pMan = viscore.dataManager();
pMan.putObjects({cObj1, cObj2});
visprops.configurableObj.updateManager(pMan, {cObj3})
keys = pMan.getKeys();
assertEqual(length(keys), 1);
tObj = pMan.getObject('ConfigurableTestClass');
q = tObj.getStructure();
assertTrue(strcmp(q(1).Value, 'Epoch') == 1);

