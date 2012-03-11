function test_suite = testStringListProperty %#ok<STOUT>
% Unit tests for stringListProperty
initTestSuite;

function testConstuctor %#ok<DEFNU>
% Unit test for visprops.stringListProperty valid constructor
fprintf('\nUnit tests for visprops.stringListProperty invalid constructor\n');

fprintf('It should create an object when a valid settings structure is passed to the constructor\n');
setStruct = propertyTestClass.getDefaultProperties();
settings = setStruct(10);
assertTrue(strcmp('StringList', settings.FieldName));
visprops.stringListProperty([], settings);

function testInvalidConstructor %#ok<DEFNU>
% Unit test for visprops.stringListProperty invalid constructor
fprintf('\nUnit tests for visprops.stringListProperty invalid constructor\n');

fprintf('It should throw an exception when called with only one parameter\n');
setStruct = propertyTestClass.getDefaultProperties();
setting = setStruct(10);
f = @()visprops.stringListProperty(setting);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when its structure value is numeric\n');
setting.Value = 3;
f = @()visprops.stringListProperty([], setting);
assertExceptionThrown(f, 'stringListProperty:property');

fprintf('It should throw an exception when its structure value is a vector\n');
setting.Value = [5, 3];
f = @()visprops.stringListProperty([], setting);
assertExceptionThrown(f, 'stringListProperty:property');

function testGetJIDEProperty %#ok<DEFNU>
% Unit test for visprops.stringListProperty getJIDEProperty method
fprintf('\nUnit tests for visprops.stringListProperty getJIDEProperty method\n');

fprintf('It should return a JIDE property\n');
setStruct = propertyTestClass.getDefaultProperties();
settings = setStruct(10);
bm = visprops.stringListProperty([], settings);
jProp = bm.getJIDEProperty();
assertTrue(~isempty(jProp));

function testConvertValueToJIDE %#ok<DEFNU>
% Unit test for visprops.stringListProperty convertValueToJIDE method
fprintf('\nUnit tests for visprops.stringListProperty convertValueToJIDE method\n');

fprintf('It should convert a settings structure representing a cell array of strings to JIDE representation\n');
setStruct = propertyTestClass.getDefaultProperties();
settings = setStruct(10);
bm = visprops.stringListProperty([], settings);
[jValue, valid, msg] = bm.convertValueToJIDE({'Ab', 'cat', 'deal'});
assertTrue(strcmp(jValue{1}, 'Ab') == 1);
assertTrue(strcmp(jValue{2}, 'cat') == 1);
assertEqual(length(jValue), 3);
assertTrue(valid);
assertTrue(isempty(msg));

function testGetFullNames %#ok<DEFNU>
% Unit test for visprops.stringListProperty getFullNames method
fprintf('\nUnit tests for visprops.stringListProperty getFullNames method\n');

fprintf('It should return a cell array of length one more than size of the list\n');
setStruct = propertyTestClass.getDefaultProperties();
settings = setStruct(10);
bm = visprops.stringListProperty([], settings);
names = bm.getFullNames();
assertEqual(length(names), length(settings.Value) + 1);
