function test_suite = testProperty %#ok<STOUT>
% Unit tests for property
initTestSuite;

function testConstuctor %#ok<DEFNU>
% Unit test for visprops.property for normal constructor
fprintf('\nUnit tests for visprops.property invalid constructor\n');

fprintf('It should create an object when a valid settings structure is passed to the constructor\n');
setStruct = propertyTestClass.getDefaultProperties();
settings = setStruct(1);
assertTrue(strcmp('BlockName', settings.FieldName));
visprops.property([], settings);

function testConvertJIDEValue %#ok<DEFNU>
% Unit test for visprops.property convertValueToJIDE method
fprintf('\nUnit tests for visprops.property convertValueToJIDE method\n');

fprintf('It should convert a settings structure representing a string to JIDE representation\n');
setStruct = propertyTestClass.getDefaultProperties();
bm = visprops.property([], setStruct(1));
jProp = bm.getJIDEProperty();
[value, isvalid, msg] = bm.convertValueToMATLAB(get(jProp, 'Value'));
assertTrue(strcmp(value, 'Window'));
assertTrue(isvalid);
assertTrue(isempty(msg));

function testGetPropertyStructure %#ok<DEFNU>
% Unit test for visprops.property getPropertyStructure method
fprintf('\nUnit tests for visprops.property getPropertyStructure method\n');

fprintf('It should return a property structure with the right values\n')
s = propertyTestClass.getDefaultProperties();
bm = visprops.property([], s(1));
assertTrue(isvalid(bm));
sNew = bm.getPropertyStructure();
s = s(1);
sNew = sNew(1);
assertTrue(strcmp(sNew.FieldName, s.FieldName));
assertTrue(strcmp(sNew.Category, s.Category));
assertTrue(strcmp(sNew.DisplayName, s.DisplayName));
assertTrue(strcmp(sNew.Type, s.Type) == 0);
assertTrue(strcmp(sNew.Value, s.Value));
assertTrue(strcmp(sNew.Options, s.Options));
assertTrue(strcmp(sNew.Description, s.Description));
assertEqual(sNew.Editable, s.Editable);

function testGetJIDEPropertyByName %#ok<DEFNU>
% Unit test for visprops.property getJIDEPropertyByName method
fprintf('\nUnit tests for visprops.property getJIDEPropertyByName method\n');

fprintf('It should return the JIDE full name\n')
s = propertyTestClass.getDefaultProperties();
bm = visprops.property([], s(1));
name = bm.getFullName();
[jObj, pos] = bm.getJIDEPropertyByName(name);
assertElementsAlmostEqual(pos, 0);
