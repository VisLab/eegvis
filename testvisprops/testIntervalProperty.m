function test_suite = testIntervalProperty %#ok<STOUT>
% Unit tests for visprops.intervalProperty
initTestSuite;

function testConstuctor %#ok<DEFNU>
% Unit test for visprops.intervalProperty valid constructor
fprintf('\nUnit tests for visprops.intervalProperty invalid constructor\n');

fprintf('It should create an object when a valid settings structure is passed to the constructor\n');
setStruct = propertyTestClass.getDefaultProperties();
settings = setStruct(5);
assertTrue(strcmp('BoxLimits', settings.FieldName));
ip = visprops.intervalProperty([], settings);
assertTrue(isvalid(ip));

function testInvalidConstuctor %#ok<DEFNU>
% Unit test for visprops.intervalProperty invalid constructor
fprintf('\nUnit tests for visprops.intervalProperty invalid constructor\n');

fprintf('It should throw an exception if constructor is called with no arguments\n');
f = @()visprops.intervalProperty();
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception if constructor is called with one parameter\n');
setStruct = propertyTestClass.getDefaultProperties();
setting = setStruct(5);
f = @()visprops.intervalProperty(setting);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw and exception if the constructor is called with a scalar value\n');
setting.Value = 3;
f = @()visprops.intervalProperty([], setting);
assertExceptionThrown(f, 'intervalProperty:property');

fprintf('It should throw and exception if the constructor when lower interval endpoint is larger than the upeper endpoint\n');
setting.Value = [5, 3];
f = @()visprops.intervalProperty([], setting);
assertExceptionThrown(f, 'intervalProperty:property');

function testGetJIDEProperty %#ok<DEFNU>
% Unit test for visprops.integerProperty getJIDEProperty method
fprintf('\nUnit tests for visprops.intervalProperty getJIDEProperty method\n');

fprintf('It should return a JIDE property when the value is valid\n');
setStruct = propertyTestClass.getDefaultProperties();
settings = setStruct(5);
bm = visprops.intervalProperty([], settings);
jProp = bm.getJIDEProperty();
assertTrue(~isempty(jProp));

function testConvertValueToJIDE %#ok<DEFNU>
% Unit test for visprops.intervalProperty convertValueToJIDE method
fprintf('\nUnit tests for visprops.intervalProperty convertValueToJIDE method\n');

fprintf('It should convert a valid integer to a valid JIDE property\n');
setStruct = propertyTestClass.getDefaultProperties();
settings = setStruct(5);
bm = visprops.intervalProperty([], settings);
[jValue, valid, msg] = bm.convertValueToJIDE([35, 37]);
assertTrue(strcmp(jValue{1}, '35') == 1);
assertTrue(strcmp(jValue{2}, '37') == 1);
assertTrue(valid);
assertTrue(isempty(msg));

function testGetFullNames %#ok<DEFNU>
% Unit test for visprops.intervalProperty getFullNames method
fprintf('\nUnit tests for visprops.intervalProperty getFullNames method\n');

fprintf('It should return a cell array of the right length\n');
setStruct = propertyTestClass.getDefaultProperties();
settings = setStruct(5);
bm = visprops.intervalProperty([], settings);
names = bm.getFullNames();
assertEqual(length(names), 3);
assertTrue(isa(names, 'cell'));
