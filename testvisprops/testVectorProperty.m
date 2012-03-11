function test_suite = testVectorProperty %#ok<STOUT>
% Unit tests for vectorProperty
initTestSuite;

function testConstuctor %#ok<DEFNU>
% Unit test for visprops.vectorProperty valid constructor
fprintf('\nUnit tests for visprops.vectorProperty invalid constructor\n');

fprintf('It should create an object when a valid settings structure is passed to the constructor\n');
setStruct = propertyTestClass.getDefaultProperties();
settings = setStruct(11);
assertTrue(strcmp('Vector', settings.FieldName));
dm = visprops.vectorProperty([], settings);

fprintf('It should include the limit endpoints by default in tests for validity\n');
assertTrue(dm.testInLimits(1.0));
assertTrue(dm.testInLimits(3.0));
assertFalse(dm.testInLimits(10));


function testInvalidConstructor %#ok<DEFNU>
% Unit test for visprops.integerProperty invalid constructor
fprintf('\nUnit tests for visprops.integerProperty invalid constructor\n');

fprintf('It should throw an exception if constructor is called with no arguments\n');
f = @()visprops.integerProperty();
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception if constructor is called with a settings structure with a non numeric value\n');
setStruct = propertyTestClass.getDefaultProperties();
settings = setStruct(11);
assertElementsAlmostEqual([1, 2, 3, 4], settings.Value);
settings.Value = 'abcd';
f = @()visprops.vectorProperty([], settings);
assertExceptionThrown(f, 'vectorProperty:property');

fprintf('It should throw an exception if constructor is called with a settings value outside limits\n');
setStruct = propertyTestClass.getDefaultProperties();
settings = setStruct(11);
assertElementsAlmostEqual([1, 2, 3, 4], settings.Value);
settings.Value = -342;
f = @()visprops.vectorProperty([], settings);
assertExceptionThrown(f, 'vectorProperty:property');

fprintf('It should throw and exception if any of the values are outside the limits\n');
setStruct = propertyTestClass.getDefaultProperties();
settings = setStruct(11);
settings.Options = [1, 3];
f = @()visprops.vectorProperty([], settings);
assertExceptionThrown(f, 'vectorProperty:property');

function testGetJIDEProperty %#ok<DEFNU>
% Unit test for visprops.vectorProperty getJIDEProperty method
fprintf('\nUnit tests for visprops.vectorProperty getJIDEProperty method\n');

fprintf('It should return a JIDE property for an integer value\n');
setStruct = propertyTestClass.getDefaultProperties();
settings = setStruct(2);
assertElementsAlmostEqual(1000, settings.Value);
bm = visprops.vectorProperty([], settings);
jProp = bm.getJIDEProperty();
assertTrue(~isempty(jProp));

fprintf('It should return a JIDE property for an double value\n');
setStruct = propertyTestClass.getDefaultProperties();
settings = setStruct(2);
settings.value = 0.45;
assertElementsAlmostEqual(0.45, settings.value);
bm = visprops.vectorProperty([], settings);
jProp = bm.getJIDEProperty();
assertTrue(~isempty(jProp));



function testConvertValueToJIDE %#ok<DEFNU>
% Unit test for visprops.vectorProperty convertValueToJIDE method
fprintf('\nUnit tests for visprops.vectorProperty convertValueToJIDE method\n');

fprintf('It should convert a valid vector to a valid JIDE property\n');
setStruct = propertyTestClass.getDefaultProperties();
settings = setStruct(11);
assertElementsAlmostEqual([1, 2, 3, 4], settings.Value);
bm = visprops.vectorProperty([], settings);
jProp = bm.getJIDEProperty();
assertTrue(~isempty(jProp));
[value, isvalid, msg] = bm.convertValueToJIDE(1:4);
assertTrue(~isempty(value));
assertTrue(isvalid);
assertTrue(isempty(msg));


function testSetCurrentValue %#ok<DEFNU>
% Unit test for visprops.vectorProperty setCurrentValue method
fprintf('\nUnit tests for visprops.vectorProperty setCurrentValue method\n');

fprintf('It should change the current value if the input value is valid\n');
setStruct = propertyTestClass.getDefaultProperties();
settings = setStruct(11);
assertElementsAlmostEqual(1:4, settings.Value);
bm = visprops.vectorProperty([], settings);
assertElementsAlmostEqual(bm.CurrentValue, 1:4);
bm.setCurrentValue(2:4); 
assertElementsAlmostEqual(bm.CurrentValue, 2:4);

fprintf('It should not change the current value if the input valid is invalid\n');
bm.setCurrentValue('abcd');
assertElementsAlmostEqual(bm.CurrentValue, 2:4);

function testGetFullNames %#ok<DEFNU>
% Unit test for visprops.vectorProperty getFullNames method
fprintf('\nUnit tests for visprops.vectorProperty getFullNames method\n');

fprintf('It should return a cell array with one name\n');
setStruct = propertyTestClass.getDefaultProperties();
settings = setStruct(2);
bm = visprops.vectorProperty([], settings);
names = bm.getFullNames();
assertEqual(length(names), 1);

function testGetPropertyStructure %#ok<DEFNU>
% Unit test for visprops.vectorProperty getPropertyStructure method
fprintf('\nUnit tests for visprops.vectorProperty getPropertyStructure method\n');

fprintf('It should return a property structure containing the correct values\n');
setStruct = propertyTestClass.getDefaultProperties();
s = setStruct(11);
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
