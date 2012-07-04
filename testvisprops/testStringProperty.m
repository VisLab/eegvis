function test_suite = testStringProperty %#ok<STOUT>
% Unit tests for stringProperty
initTestSuite;

function values = setup %#ok<DEFNU>
values.setStruct = propertyTestClass.getDefaultProperties();
values.myNumber = 1;

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testConstuctor(values) %#ok<DEFNU>
% Unit test for visprops.stringProperty valid constructor
fprintf('\nUnit tests for visprops.stringProperty invalid constructor\n');

fprintf('It should create an object when a valid settings structure is passed to the constructor\n');
settings = values.setStruct(values.myNumber);
assertTrue(strcmp('BlockName', settings.FieldName));
bm = visprops.stringProperty([], settings);
fprintf('It should create an object with the right value\n');
value = bm.CurrentValue;
assertTrue(strcmpi(value, 'Window'));

function testInvalidConstructor(values) %#ok<DEFNU>
% Unit test for visprops.stringProperty invalid constructor
fprintf('\nUnit tests for visprops.stringProperty invalid constructor\n');

fprintf('It should throw an exception when the specified value is numeric instead of char\n');
settings = values.setStruct(values.myNumber);
settings.Value = 1234;
f = @()visprops.stringProperty([], settings);
assertExceptionThrown(f, 'stringProperty:property');

function testGetJIDEProperty(values) %#ok<DEFNU>
% Unit test for visprops.stringProperty getJIDEProperty method
fprintf('\nUnit tests for visprops.stringProperty getJIDEProperty method\n');

fprintf('It should return an object with the correct value.\n');
settings = values.setStruct(values.myNumber);
bm = visprops.stringProperty([], settings);
jProp = bm.getJIDEProperty();
value = jProp.getValue();
assertTrue(strcmp(value, 'Window'));

function testConvertValueToJIDE(values) %#ok<DEFNU>
% Unit test for visprops.stringProperty convertValueToJIDE method
fprintf('\nUnit tests for visprops.stringProperty convertValueToJIDE method\n');

fprintf('It should not return invalid when trying to convert a numeric value to JIDE representation\n');
settings = values.setStruct(values.myNumber);
bm = visprops.stringProperty([], settings);
[value, isvalid, msg] = bm.convertValueToJIDE(1234);
assertTrue(isempty(value));
assertFalse(isvalid);
assertFalse(isempty(msg));

function testGetPropertyStructure(values) %#ok<DEFNU>
% Unit test for visprops.stringProperty getPropertyStructure method
fprintf('\nUnit tests for visprops.stringProperty getPropertyStructure method\n');

fprintf('It should return a property structure with the right values\n')
s = values.setStruct(values.myNumber);
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