function test_suite = testStringProperty %#ok<STOUT>
% Unit tests for stringProperty
initTestSuite;

function testConstuctor %#ok<DEFNU>
% Unit test for visprops.stringProperty valid constructor
fprintf('\nUnit tests for visprops.stringProperty invalid constructor\n');

fprintf('It should create an object when a valid settings structure is passed to the constructor\n');
setStruct = propertyTestClass.getDefaultProperties();
settings = setStruct(1);
assertTrue(strcmp('BlockName', settings.FieldName));
bm = visprops.stringProperty([], settings);
fprintf('It should create an object with the right value\n');
value = bm.CurrentValue;
assertTrue(strcmpi(value, 'Window'));

function testInvalidConstructor %#ok<DEFNU>
% Unit test for visprops.stringProperty invalid constructor
fprintf('\nUnit tests for visprops.stringProperty invalid constructor\n');

fprintf('It should throw an exception when the specified value is numeric instead of char\n');
setStruct = propertyTestClass.getDefaultProperties();
s = setStruct(1);
s.Value = 1234;
f = @()visprops.stringProperty([], s);
assertExceptionThrown(f, 'stringProperty:property');


function testGetJIDEProperty %#ok<DEFNU>
% Unit test for visprops.stringProperty getJIDEProperty method
fprintf('\nUnit tests for visprops.stringProperty getJIDEProperty method\n');

fprintf('It should return an object with the correct value.\n');
setStruct = propertyTestClass.getDefaultProperties();
bm = visprops.stringProperty([], setStruct(1));
jProp = bm.getJIDEProperty();
value = jProp.getValue();
assertTrue(strcmp(value, 'Window'));

function testConvertValueToJIDE %#ok<DEFNU>
% Unit test for visprops.stringProperty convertValueToJIDE method
fprintf('\nUnit tests for visprops.stringProperty convertValueToJIDE method\n');

fprintf('It should not return invalid when trying to convert a numeric value to JIDE representation\n');
setStruct = propertyTestClass.getDefaultProperties();
bm = visprops.stringProperty([], setStruct(1));
[value, isvalid, msg] = bm.convertValueToJIDE(1234);
assertTrue(isempty(value));
assertFalse(isvalid);
assertFalse(isempty(msg));

function testGetPropertyStructure %#ok<DEFNU>
% Unit test for visprops.stringProperty getPropertyStructure method
fprintf('\nUnit tests for visprops.stringProperty getPropertyStructure method\n');

fprintf('It should return a property structure with the right values\n')
s = propertyTestClass.getDefaultProperties();
s = s(1);
bm = visprops.stringProperty([], s);
assertTrue(isvalid(bm));
sNew = bm.getPropertyStructure();
sNew = sNew(1);
assertTrue(strcmp(sNew.FieldName, s.FieldName));
assertTrue(strcmp(sNew.Category, s.Category));
assertTrue(strcmp(sNew.DisplayName, s.DisplayName));
assertTrue(strcmp(sNew.Type, s.Type));
assertTrue(strcmp(sNew.Value, s.Value));
assertTrue(strcmp(sNew.Options, s.Options));
assertTrue(strcmp(sNew.Description, s.Description));
assertEqual(sNew.Editable, s.Editable);

