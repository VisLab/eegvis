function test_suite = testmanagedObj %#ok<FNDEF,STOUT>
% Unit tests for testmanagedObj
initTestSuite;

function testConstuctor %#ok<DEFNU>
% Unit test for viscore.managedObj for normal constructor
fprintf('\nUnit tests for viscore.managedObj valid constructor with default structure\n');

fprintf('It should create a valid object when constructor has a structure parameter\n');
s = baseTestClass.getDefaults();
settings = viscore.managedObj([], s);
assertTrue(isobject(settings));
settings.printObject();

fprintf('It should create a valid object when the constructor parameters are both empty\n');
settings = viscore.managedObj([], []);
assertTrue(isobject(settings));
settings.printObject();

function testGetValueByFieldID %#ok<DEFNU>
% Unit test for viscore.managedObj for getValueByFieldID
fprintf('\nUnit tests for viscore.managedObj for getValueByFieldID\n');

fprintf('It should have retrieve fields correctly by their ID value\n');
s = baseTestClass.getDefaults();
settings = viscore.managedObj('ead', s);
Value = settings.getValueByFieldID('BlockName', 'Value');
assertTrue(strcmp(Value, s(1).Value));
Value = settings.getValueByFieldID('BlockSize', 'Value');
assertAlmostEqual(Value, s(2).Value);
Value = settings.getValueByFieldID('WindowType', 'Value');
assertTrue(strcmp(Value, s(3).Value));
Value = settings.getValueByFieldID('BoxColors', 'Value');
assertAlmostEqual(Value, s(4).Value);
Value = settings.getValueByFieldID('BoxLimits', 'Value');
assertAlmostEqual(Value, s(5).Value);
Value = settings.getValueByFieldID('Background', 'Value');
assertAlmostEqual(Value, s(6).Value);
Value = settings.getValueByFieldID('Counter', 'Value');
assertEqual(Value, s(7).Value);
Value = settings.getValueByFieldID('SimpleInteger', 'Value');
assertEqual(Value, s(8).Value);

function testSetValueByFieldID %#ok<DEFNU>
% Unit test for viscore.managedObj for setValueByFieldID
fprintf('\nUnit tests for viscore.managedObj for setValueByFieldID\n');

fprintf('It should have set fields correctly by their ID value\n');
s = baseTestClass.getDefaults();
settings = viscore.managedObj([], s);
settings.setValueByFieldID('BlockName', 'Value', 'Blech');
Value = settings.getValueByFieldID('BlockName', 'Value');
assertTrue(strcmp(Value, 'Blech'));

settings.setValueByFieldID('BlockSize', 'Value', 3000);
Value = settings.getValueByFieldID('BlockSize', 'Value');
assertAlmostEqual(Value, 3000);

settings.setValueByFieldID('WindowType', 'Value', 'Epoched');
Value = settings.getValueByFieldID('WindowType', 'Value');
assertTrue(strcmp(Value, 'Epoched'));

settings.setValueByFieldID('BoxColors', 'Value', [1, 0, 0; 0, 1, 0; 1, 1, 0]);
Value = settings.getValueByFieldID('BoxColors', 'Value');
assertAlmostEqual(Value, [1, 0, 0; 0, 1, 0; 1, 1, 0]);

settings.setValueByFieldID('BoxLimits', 'Value', [1, 2]);
Value = settings.getValueByFieldID('BoxLimits', 'Value');
assertAlmostEqual(Value, [1, 2]);

settings.setValueByFieldID('Background', 'Value', [1, 0, 1]);
Value = settings.getValueByFieldID('Background', 'Value');
assertAlmostEqual(Value, [1, 0, 1]);

settings.setValueByFieldID('Counter', 'Value', 5);
Value = settings.getValueByFieldID('Counter', 'Value');
assertEqual(Value, 5);

settings.setValueByFieldID('SimpleInteger', 'Value', -1);
Value = settings.getValueByFieldID('SimpleInteger', 'Value');
assertEqual(Value, -1);

function testCreateStruct %#ok<DEFNU>
% Unit test for viscore.managedObj for static createStruct method
fprintf('\nUnit tests for viscore.managedObj for static createStruct method\n');

fprintf('It create a default structure when parameters are empty\n');
bfs = viscore.managedObj.createStruct([], [], []);
assertTrue(isa(bfs, 'struct'));

function testCreateObjects %#ok<DEFNU>
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

function testgetCategory  %#ok<DEFNU>
% Unit test for viscore.managedObj for getCategory method
fprintf('\nUnit tests for viscore.managedObj for getCategory method\n');

fprintf('It correctly returns categories of managed objects\n');
s = baseTestClass.getDefaults();
settings = viscore.managedObj([], s);
assertTrue(isa(settings, 'viscore.managedObj'));
category = settings.getCategories(); 
assertTrue(~isempty(category));
assertTrue(strcmp(category{1}, 'baseTestClass') == 1)

function testIsEnabled %#ok<DEFNU>
% Unit test for viscore.managedObj for isEnabled method
fprintf('\nUnit tests for viscore.managedObj for isEnabled method\n');

fprintf('It correctly returns the number of enabled managed objects\n');
s = baseTestClass.getDefaults();
settings = viscore.managedObj([], s);
assertTrue(isa(settings, 'viscore.managedObj'));
enabled = settings.getNumberEnabled(); 
assertTrue(enabled > 0);

function testClone %#ok<DEFNU>
fprintf('\nUnit tests for viscore.managedObj for clone method\n');

fprintf('It correctly clones a distinct managed object with same field values\n');
s = baseTestClass.getDefaults();
settings = viscore.managedObj([], s);
assertTrue(isobject(settings));
fprintf('Original object:\n');
settings.printObject();
nSettings = settings.clone();
fprintf('Cloned object:\n');
nSettings.printObject();
ns = nSettings.getStructure();
ns = ns(1);
s = settings.getStructure();
s = s(1);
oldName = settings.getValueByFieldID('BlockName', 'DisplayName');
newName = nSettings.getValueByFieldID('BlockName', 'DisplayName');
assertTrue(strcmpi(s.ID, ns.ID) == 1);
assertTrue(strcmpi(oldName, newName) == 1);
assertTrue(strcmpi(s.ID, ns.ID) == 1);
assertTrue(strcmpi(s.DisplayName, ns.DisplayName) == 1);
nSettings.setValueByFieldID('BlockName', 'DisplayName', 'Blech');
newName = nSettings.getValueByFieldID('BlockName', 'DisplayName');
assertTrue(strcmpi(newName, 'Blech') == 1);
oldName = settings.getValueByFieldID('BlockName', 'DisplayName');
assertTrue(strcmpi(oldName, 'Blech') == 0);


function testCloneCellArray %#ok<DEFNU>
fprintf('\nUnit tests for viscore.managedObj for cloneCellArray method\n');

fprintf('It correctly clones a cell array of managed objects\n');
s = baseTestClass.getDefaults();
aCells = cell(length(s), 1);
assertEqual(length(s), 8);
for k = 1:length(s)
  aCells{k} = viscore.managedObj([], s(k));
end
assertEqual(length(aCells), 8);
% Get rid of a few
aCells{2} = '  ';
aCells{7} = '   ';
bCells = viscore.managedObj.cloneCellArray(aCells);
assertEqual(length(bCells), 6);

function testMergeStructures %#ok<DEFNU>
fprintf('\nUnit tests for viscore.managedObj for static mergeStructures method\n');

fprintf('It correctly merges structures\n');
s = baseTestClass.getDefaults();
r = baseTestClass.getDefaults();
r(1).Value = 'EpochA';
r(2).Value = 2000;
sNew = viscore.managedObj.mergeStructures(s, r, 'ID');
assertEqual(length(s), length(sNew));
assertTrue(strcmp(sNew(1).Value, r(1).Value));
assertElementsAlmostEqual(sNew(2).Value, r(2).Value);
% Duplicate keyFields so just return s
r(2).ID = 'BlockName';
sNew = viscore.managedObj.mergeStructures(s, r, 'ID');
assertElementsAlmostEqual(sNew(2).Value, s(2).Value);
assertEqual(length(sNew), length(s));
s = baseTestClass.getDefaults();
r = baseTestClass.getDefaults();
r(1).ID = 'Tender';
r(1).Value = 3234;
sNew = viscore.managedObj.mergeStructures(s, r, 'ID');
assertEqual(length(sNew), length(s)+1);
assertElementsAlmostEqual(sNew(9).Value, 3234);

function testGetMethods %#ok<DEFNU>
fprintf('\nUnit tests for viscore.managedObj for get methods\n');

fprintf('It should correctly return the internal ID of a managed object\n');
defStruct = baseTestClass.getDefaults();
s = viscore.managedObj('ead', defStruct);
objID = s.getObjectID();
intID = s.getInternalID();
% Internal ID is numeric
assertTrue(isnumeric(intID));
% Internal ID and object ID are different if object ID is explicitly set
fprintf('It should have different internal and object IDs if object ID is explicitly set\n');
assertFalse(strcmpi(num2str(intID), objID))
fprintf('It should return the correct display names\n');
dNames = s.getDisplayNames();
assertEqual(length(dNames), length(defStruct));
assertTrue(strcmp(dNames{1}, defStruct(1).DisplayName));
fprintf('It should return a specific display name if requested\n');
dName = s.getDisplayName(1);
assertTrue(strcmp(dName, defStruct(1).DisplayName));

function testCreateFromConfig %#ok<DEFNU>
fprintf('\nUnit tests for viscore.managedObj for static createFromConfig method\n');

fprintf('It should create a configuration structure\n');
mObj = viscore.managedObj('ead', baseTestClass.getDefaults());
assertTrue(isvalid(mObj));
config = mObj.getConfiguration();
assertTrue(isa(config, 'struct'));
nObj = viscore.managedObj.createFromConfig(config);
assertTrue(isa(nObj, 'viscore.managedObj'))
