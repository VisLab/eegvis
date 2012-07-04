function test_suite = testStringListProperty %#ok<STOUT>
% Unit tests for stringListProperty
initTestSuite;

function values = setup %#ok<DEFNU>
values.setStruct = propertyTestClass.getDefaultProperties();
values.myNumber = 10;

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testConstuctor(values) %#ok<DEFNU>
% Unit test for visprops.stringListProperty valid constructor
fprintf('\nUnit tests for visprops.stringListProperty invalid constructor\n');

fprintf('It should create an object when a valid settings structure is passed to the constructor\n');
settings = values.setStruct(values.myNumber);
assertTrue(strcmp('StringList', settings.FieldName));
visprops.stringListProperty([], settings);

function testInvalidConstructor(values) %#ok<DEFNU>
% Unit test for visprops.stringListProperty invalid constructor
fprintf('\nUnit tests for visprops.stringListProperty invalid constructor\n');

fprintf('It should throw an exception when called with only one parameter\n');
settings = values.setStruct(values.myNumber);
f = @()visprops.stringListProperty(settings);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when its structure value is numeric\n');
settings.Value = 3;
f = @()visprops.stringListProperty([], settings);
assertExceptionThrown(f, 'stringListProperty:property');

fprintf('It should throw an exception when its structure value is a vector\n');
settings.Value = [5, 3];
f = @()visprops.stringListProperty([], settings);
assertExceptionThrown(f, 'stringListProperty:property');

function testGetJIDEProperty(values) %#ok<DEFNU>
% Unit test for visprops.stringListProperty getJIDEProperty method
fprintf('\nUnit tests for visprops.stringListProperty getJIDEProperty method\n');

fprintf('It should return a JIDE property\n');
settings = values.setStruct(values.myNumber);
bm = visprops.stringListProperty([], settings);
jProp = bm.getJIDEProperty();
assertTrue(~isempty(jProp));

function testConvertValueToJIDE (values)%#ok<DEFNU>
% Unit test for visprops.stringListProperty convertValueToJIDE method
fprintf('\nUnit tests for visprops.stringListProperty convertValueToJIDE method\n');

fprintf('It should convert a settings structure representing a cell array of strings to JIDE representation\n');
settings = values.setStruct(values.myNumber);
bm = visprops.stringListProperty([], settings);
[jValue, valid, msg] = bm.convertValueToJIDE({'Ab', 'cat', 'deal'});
assertTrue(strcmp(jValue{1}, 'Ab') == 1);
assertTrue(strcmp(jValue{2}, 'cat') == 1);
assertEqual(length(jValue), 3);
assertTrue(valid);
assertTrue(isempty(msg));

function testGetFullNames(values) %#ok<DEFNU>
% Unit test for visprops.stringListProperty getFullNames method
fprintf('\nUnit tests for visprops.stringListProperty getFullNames method\n');

fprintf('It should return a cell array of length one more than size of the list\n');
settings = values.setStruct(values.myNumber);
bm = visprops.stringListProperty([], settings);
names = bm.getFullNames();
assertEqual(length(names), length(settings.Value) + 1);
