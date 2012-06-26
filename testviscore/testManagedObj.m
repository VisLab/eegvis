function test_suite = testmanagedObj %#ok<FNDEF,STOUT>
% Unit tests for testmanagedObj
initTestSuite;

function values = setup %#ok<DEFNU>
values.s = baseTestClass.getDefaults();
values.settings = viscore.managedObj([], values.s);

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testConstuctor(values) %#ok<DEFNU>
% Unit test for viscore.managedObj for normal constructor
fprintf('\nUnit tests for viscore.managedObj valid constructor with default structure\n');

fprintf('It should create a valid object when constructor has a structure parameter\n');
assertTrue(isobject(values.settings));
values.settings.printObject();

fprintf('It should create a valid object when the constructor parameters are both empty\n');
settings = viscore.managedObj([], []);
assertTrue(isobject(settings));
settings.printObject();

function testGetValueByFieldID(values) %#ok<DEFNU>
% Unit test for viscore.managedObj for getValueByFieldID
fprintf('\nUnit tests for viscore.managedObj for getValueByFieldID\n');

fprintf('It should have retrieve fields correctly by their ID value\n');
settings = viscore.managedObj('ead', values.s);
Value = values.settings.getValueByFieldID('BlockName', 'Value');
assertTrue(strcmp(Value, values.s(1).Value));
Value = settings.getValueByFieldID('BlockSize', 'Value');
assertAlmostEqual(Value, values.s(2).Value);
Value = settings.getValueByFieldID('WindowType', 'Value');
assertTrue(strcmp(Value, values.s(3).Value));
Value = settings.getValueByFieldID('BoxColors', 'Value');
assertAlmostEqual(Value, values.s(4).Value);
Value = settings.getValueByFieldID('BoxLimits', 'Value');
assertAlmostEqual(Value, values.s(5).Value);
Value = settings.getValueByFieldID('Background', 'Value');
assertAlmostEqual(Value, values.s(6).Value);
Value = settings.getValueByFieldID('Counter', 'Value');
assertEqual(Value, values.s(7).Value);
Value = settings.getValueByFieldID('SimpleInteger', 'Value');
assertEqual(Value, values.s(8).Value);

function testSetValueByFieldID(values) %#ok<DEFNU>
% Unit test for viscore.managedObj for setValueByFieldID
fprintf('\nUnit tests for viscore.managedObj for setValueByFieldID\n');

fprintf('It should have set fields correctly by their ID value\n');
values.settings.setValueByFieldID('BlockName', 'Value', 'Blech');
Value = values.settings.getValueByFieldID('BlockName', 'Value');
assertTrue(strcmp(Value, 'Blech'));

values.settings.setValueByFieldID('BlockSize', 'Value', 3000);
Value = values.settings.getValueByFieldID('BlockSize', 'Value');
assertAlmostEqual(Value, 3000);

values.settings.setValueByFieldID('WindowType', 'Value', 'Epoched');
Value = values.settings.getValueByFieldID('WindowType', 'Value');
assertTrue(strcmp(Value, 'Epoched'));

values.settings.setValueByFieldID('BoxColors', 'Value', [1, 0, 0; 0, 1, 0; 1, 1, 0]);
Value = values.settings.getValueByFieldID('BoxColors', 'Value');
assertAlmostEqual(Value, [1, 0, 0; 0, 1, 0; 1, 1, 0]);

values.settings.setValueByFieldID('BoxLimits', 'Value', [1, 2]);
Value = values.settings.getValueByFieldID('BoxLimits', 'Value');
assertAlmostEqual(Value, [1, 2]);

values.settings.setValueByFieldID('Background', 'Value', [1, 0, 1]);
Value = values.settings.getValueByFieldID('Background', 'Value');
assertAlmostEqual(Value, [1, 0, 1]);

values.settings.setValueByFieldID('Counter', 'Value', 5);
Value = values.settings.getValueByFieldID('Counter', 'Value');
assertEqual(Value, 5);

values.settings.setValueByFieldID('SimpleInteger', 'Value', -1);
Value = values.settings.getValueByFieldID('SimpleInteger', 'Value');
assertEqual(Value, -1);

function testCreateStruct(values) %#ok<INUSD,DEFNU>
% Unit test for viscore.managedObj for static createStruct method
fprintf('\nUnit tests for viscore.managedObj for static createStruct method\n');

fprintf('It create a default structure when parameters are empty\n');
bfs = viscore.managedObj.createStruct([], [], []);
assertTrue(isa(bfs, 'struct'));

function testCreateObjects(values) %#ok<INUSD,DEFNU>
% Unit test for viscore.managedObj for static createObject method
fprintf('\nUnit tests for viscore.managedObj for static createObject method\n');

fprintf('It should create a default cell array of objects when parameters are empty\n');
s = viscore.managedObj.createObjects('viscore.managedObj', [], []);
assertTrue(isa(s, 'cell'));
s = s{1};
assertTrue(isa(s, 'viscore.managedObj'));
ps = s.getStructure();
assertTrue(~isempty(ps.ID));
assertTrue(~isempty(s.getObjectID()));

fprintf('It should create a cell array of objects when a structure array is passed\n');
s = viscore.managedObj.createObjects('viscore.managedObj', ...
    tableTestObj.getDefaults(), []);
assertEqual(length(s), 2);
assertTrue(isa(s{1}, 'viscore.managedObj'));

fprintf('It should create a cell array of objects when a another cell array of managed objects is passed is passed\n');
p = [s; s];
assertEqual(length(p), 4);
sNew = viscore.managedObj.createObjects('viscore.managedObj', p, []);
assertEqual(length(sNew), 4);
% Cell array with an invalid input item

fprintf('It should ignore invalid managed objects when the cell array of objects is passed is passed\n');
p = [s; s];
p{3} = 'abc';
assertEqual(length(p), 4);
sNew = viscore.managedObj.createObjects('viscore.managedObj', p, []);
assertEqual(length(sNew), 3);

function testgetCategory(values)  %#ok<DEFNU>
% Unit test for viscore.managedObj for getCategory method
fprintf('\nUnit tests for viscore.managedObj for getCategory method\n');

fprintf('It correctly returns categories of managed objects\n');
assertTrue(isa(values.settings, 'viscore.managedObj'));
category = values.settings.getCategories(); 
assertTrue(~isempty(category));
assertTrue(strcmp(category{1}, 'baseTestClass') == 1)

function testIsEnabled(values) %#ok<DEFNU>
% Unit test for viscore.managedObj for isEnabled method
fprintf('\nUnit tests for viscore.managedObj for isEnabled method\n');

fprintf('It correctly returns the number of enabled managed objects\n');
assertTrue(isa(values.settings, 'viscore.managedObj'));
enabled = values.settings.getNumberEnabled(); 
assertTrue(enabled > 0);

function testClone(values) %#ok<DEFNU>
fprintf('\nUnit tests for viscore.managedObj for clone method\n');

fprintf('It correctly clones a distinct managed object with same field values\n');
fprintf('Original object:\n');
values.settings.printObject();
nSettings = values.settings.clone();
fprintf('Cloned object:\n');
nSettings.printObject();
ns = nSettings.getStructure();
ns = ns(1);
s = values.settings.getStructure();
s = s(1);
oldName = values.settings.getValueByFieldID('BlockName', 'DisplayName');
newName = nSettings.getValueByFieldID('BlockName', 'DisplayName');
assertTrue(strcmpi(s.ID, ns.ID) == 1);
assertTrue(strcmpi(oldName, newName) == 1);
assertTrue(strcmpi(s.ID, ns.ID) == 1);
assertTrue(strcmpi(s.DisplayName, ns.DisplayName) == 1);
nSettings.setValueByFieldID('BlockName', 'DisplayName', 'Blech');
newName = nSettings.getValueByFieldID('BlockName', 'DisplayName');
assertTrue(strcmpi(newName, 'Blech') == 1);
oldName = values.settings.getValueByFieldID('BlockName', 'DisplayName');
assertTrue(strcmpi(oldName, 'Blech') == 0);


function testCloneCellArray(values) %#ok<DEFNU>
fprintf('\nUnit tests for viscore.managedObj for cloneCellArray method\n');

fprintf('It correctly clones a cell array of managed objects\n');
values.s = baseTestClass.getDefaults();
aCells = cell(length(values.s), 1);
assertEqual(length(values.s), 8);
for k = 1:length(values.s)
  aCells{k} = viscore.managedObj([], values.s(k));
end
assertEqual(length(aCells), 8);
% Get rid of a few
aCells{2} = '  ';
aCells{7} = '   ';
bCells = viscore.managedObj.cloneCellArray(aCells);
assertEqual(length(bCells), 6);

function testMergeStructures(values) %#ok<DEFNU>
fprintf('\nUnit tests for viscore.managedObj for static mergeStructures method\n');

fprintf('It correctly merges structures ( -- warning)\n');
values.s = baseTestClass.getDefaults();
r = baseTestClass.getDefaults();
r(1).Value = 'EpochA';
r(2).Value = 2000;
sNew = viscore.managedObj.mergeStructures(values.s, r, 'ID');
assertEqual(length(values.s), length(sNew));
assertTrue(strcmp(sNew(1).Value, r(1).Value));
assertElementsAlmostEqual(sNew(2).Value, r(2).Value);
% Duplicate keyFields so just return s
r(2).ID = 'BlockName';
sNew = viscore.managedObj.mergeStructures(values.s, r, 'ID');
assertElementsAlmostEqual(sNew(2).Value, values.s(2).Value);
assertEqual(length(sNew), length(values.s));
s = baseTestClass.getDefaults();
r = baseTestClass.getDefaults();
r(1).ID = 'Tender';
r(1).Value = 3234;
sNew = viscore.managedObj.mergeStructures(s, r, 'ID');
assertEqual(length(sNew), length(s)+1);
assertElementsAlmostEqual(sNew(9).Value, 3234);

function testGetMethods(values) %#ok<DEFNU>
fprintf('\nUnit tests for viscore.managedObj for get methods\n');

fprintf('It should correctly return the internal ID of a managed object\n');
settings = viscore.managedObj('ead', values.s);
objID = settings.getObjectID();
intID = settings.getInternalID();
% Internal ID is numeric
assertTrue(isnumeric(intID));
% Internal ID and object ID are different if object ID is explicitly set
fprintf('It should have different internal and object IDs if object ID is explicitly set\n');
assertFalse(strcmpi(num2str(intID), objID))
fprintf('It should return the correct display names\n');
dNames = settings.getDisplayNames();
assertEqual(length(dNames), length(values.s));
assertTrue(strcmp(dNames{1}, values.s(1).DisplayName));
fprintf('It should return a specific display name if requested\n');
dName = settings.getDisplayName(1);
assertTrue(strcmp(dName, values.s(1).DisplayName));

function testCreateFromConfig(values) %#ok<DEFNU>
fprintf('\nUnit tests for viscore.managedObj for static createFromConfig method\n');

fprintf('It should create a configuration structure\n');
mObj = viscore.managedObj('ead', values.s);
assertTrue(isvalid(mObj));
config = mObj.getConfiguration();
assertTrue(isa(config, 'struct'));
nObj = viscore.managedObj.createFromConfig(config);
assertTrue(isa(nObj, 'viscore.managedObj'))
