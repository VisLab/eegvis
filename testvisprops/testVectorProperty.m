function test_suite = testVectorProperty %#ok<STOUT>
% Unit tests for vectorProperty
initTestSuite;

function values = setup %#ok<DEFNU>
values.setStruct = propertyTestClass.getDefaultProperties();
values.myNumber = 11;

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testConstuctor(values) %#ok<DEFNU>
% Unit test for visprops.vectorProperty valid constructor
fprintf('\nUnit tests for visprops.vectorProperty invalid constructor\n');

fprintf('It should create an object when a valid settings structure is passed to the constructor\n');
settings = values.setStruct(values.myNumber);
assertTrue(strcmp('Vector', settings.FieldName));
dm = visprops.vectorProperty([], settings);

fprintf('It should include the limit endpoints by default in tests for validity\n');
assertTrue(dm.testInLimits(1.0));
assertTrue(dm.testInLimits(3.0));
assertFalse(dm.testInLimits(10));

fprintf('It should have the right value\n');
s = dm.getPropertyStructure();
assertVectorsAlmostEqual([1, 2, 3, 4], s.Value);


function testInvalidConstructor(values) %#ok<DEFNU>
% Unit test for visprops.integerProperty invalid constructor
fprintf('\nUnit tests for visprops.integerProperty invalid constructor\n');

fprintf('It should throw an exception if constructor is called with no arguments\n');
f = @()visprops.integerProperty();
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception if constructor is called with a settings structure with a non numeric value\n');
settings = values.setStruct(values.myNumber);
assertElementsAlmostEqual([1, 2, 3, 4], settings.Value);
settings.Value = 'abcd';
f = @()visprops.vectorProperty([], settings);
assertExceptionThrown(f, 'vectorProperty:property');

fprintf('It should throw an exception if constructor is called with a settings value outside limits\n');
settings = values.setStruct(values.myNumber);
assertElementsAlmostEqual([1, 2, 3, 4], settings.Value);
settings.Value = -342;
f = @()visprops.vectorProperty([], settings);
assertExceptionThrown(f, 'vectorProperty:property');

fprintf('It should throw and exception if any of the values are outside the limits\n');
settings = values.setStruct(values.myNumber);
settings.Options = [1, 3];
f = @()visprops.vectorProperty([], settings);
assertExceptionThrown(f, 'vectorProperty:property');

function testGetJIDEProperty(values) %#ok<DEFNU>
% Unit test for visprops.vectorProperty getJIDEProperty method
fprintf('\nUnit tests for visprops.vectorProperty getJIDEProperty method\n');

fprintf('It should return a JIDE property for an integer value\n');
settings = values.setStruct(values.myNumber);
settings.Value = 4;
assertElementsAlmostEqual(4, settings.Value);
bm = visprops.vectorProperty([], settings);
jProp = bm.getJIDEProperty();
assertTrue(~isempty(jProp));
s = bm.getPropertyStructure();
assertVectorsAlmostEqual(4, s.Value);

fprintf('It should return a JIDE property for an double value\n');
settings = values.setStruct(values.myNumber);
settings.Value = 1.45;
assertElementsAlmostEqual(1.45, settings.Value);
bm = visprops.vectorProperty([], settings);
jProp = bm.getJIDEProperty();
assertTrue(~isempty(jProp));
s = bm.getPropertyStructure();
assertVectorsAlmostEqual(1.45, s.Value)

function testConvertValueToJIDE(values) %#ok<DEFNU>
% Unit test for visprops.vectorProperty convertValueToJIDE method
fprintf('\nUnit tests for visprops.vectorProperty convertValueToJIDE method\n');

fprintf('It should convert a valid vector to a valid JIDE property\n');
settings = values.setStruct(values.myNumber);
assertElementsAlmostEqual([1, 2, 3, 4], settings.Value);
bm = visprops.vectorProperty([], settings);
jProp = bm.getJIDEProperty();
assertTrue(~isempty(jProp));
[value, isvalid, msg] = bm.convertValueToJIDE(1:4);
assertTrue(~isempty(value));
assertTrue(isvalid);
assertTrue(isempty(msg));

function testSetCurrentValue(values) %#ok<DEFNU>
% Unit test for visprops.vectorProperty setCurrentValue method
fprintf('\nUnit tests for visprops.vectorProperty setCurrentValue method\n');

fprintf('It should change the current value if the input value is valid\n');
settings = values.setStruct(values.myNumber);
assertElementsAlmostEqual(1:4, settings.Value);
bm = visprops.vectorProperty([], settings);
assertElementsAlmostEqual(bm.CurrentValue, 1:4);
bm.setCurrentValue(2:4); 
assertElementsAlmostEqual(bm.CurrentValue, 2:4);

fprintf('It should not change the current value if the input valid is invalid\n');
bm.setCurrentValue('abcd');
assertElementsAlmostEqual(bm.CurrentValue, 2:4);

function testGetFullNames(values) %#ok<DEFNU>
% Unit test for visprops.vectorProperty getFullNames method
fprintf('\nUnit tests for visprops.vectorProperty getFullNames method\n');

fprintf('It should return a cell array with one name\n');
settings = values.setStruct(values.myNumber);
bm = visprops.vectorProperty([], settings);
names = bm.getFullNames();
assertEqual(length(names), 1);

function testGetPropertyStructure(values) %#ok<DEFNU>
% Unit test for visprops.vectorProperty getPropertyStructure method
fprintf('\nUnit tests for visprops.vectorProperty getPropertyStructure method\n');

fprintf('It should return a property structure containing the correct values\n');
s = values.setStruct(values.myNumber);
dm = visprops.vectorProperty([], s);
assertTrue(isvalid(dm));
sNew = dm.getPropertyStructure();
sNew = sNew(1);
assertTrue(strcmp(sNew.FieldName, s.FieldName));
assertTrue(strcmp(sNew.Category, s.Category));
assertTrue(strcmp(sNew.DisplayName, s.DisplayName));
assertTrue(strcmp(sNew.Type, s.Type));
assertVectorsAlmostEqual(sNew.Value, s.Value);
assertElementsAlmostEqual(sNew.Options(1), s.Options(1))
assertElementsAlmostEqual(sNew.Options(2), s.Options(2))
assertTrue(strcmp(sNew.Description, s.Description));
assertEqual(sNew.Editable, s.Editable);
