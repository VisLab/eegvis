function test_suite = testDoubleProperty %#ok<STOUT>
% Unit tests for doubleProperty
initTestSuite;

function testConstuctor %#ok<DEFNU>
% Unit test for visprops.doubleProperty valid constructor
fprintf('\nUnit tests for visprops.doubleProperty invalid constructor\n');

fprintf('It should create an object when a valid settings structure is passed to the constructor\n');
setStruct = propertyTestClass.getDefaultProperties();
settings = setStruct(2);
assertTrue(strcmp('BlockSize', settings.FieldName));
visprops.doubleProperty([], settings);
setStruct = propertyTestClass.getDefaultProperties();
settings = setStruct(2);
assertElementsAlmostEqual(1000, settings.Value);
bm = visprops.doubleProperty([], settings);
assertTrue(isvalid(bm));
fprintf('It should have the right value when created from a settings structure\n');
assertElementsAlmostEqual(bm.CurrentValue, settings.Value);

function testInvalidConstructor %#ok<DEFNU>
% Unit test for visprops.doubleProperty invalid constructor
fprintf('\nUnit tests for visprops.doubleProperty invalid constructor\n');

fprintf('It should throw an exception when the specified value is outside interval specified in options\n');
setStruct = propertyTestClass.getDefaultProperties();
settings = setStruct(2);
assertElementsAlmostEqual(1000, settings.Value);
settings.Value = -342;
f = @()visprops.doubleProperty([], settings);
assertExceptionThrown(f, 'doubleProperty:property');

fprintf('It should throw an exception when the settings structure has a non-numeric value\n');
setStruct = propertyTestClass.getDefaultProperties();
settings = setStruct(2);
assertElementsAlmostEqual(1000, settings.Value);
settings.Value = 'abcd';
f = @()visprops.doubleProperty([], settings);
assertExceptionThrown(f, 'doubleProperty:property');

function testGetJIDEProperty %#ok<DEFNU>
% Unit test for visprops.doubleProperty getJIDEProperty method
fprintf('\nUnit tests for visprops.doubleProperty getJIDEProperty method\n');

fprintf('It should return a JIDE property\n');
setStruct = propertyTestClass.getDefaultProperties();
settings = setStruct(2);
assertElementsAlmostEqual(1000, settings.Value);
bm = visprops.doubleProperty([], settings);
jProp = bm.getJIDEProperty();
assertTrue(~isempty(jProp));

fprintf('It should allow settings structure value to be changed before converting to JIDE\n');
setStruct = propertyTestClass.getDefaultProperties();
settings = setStruct(2);
settings.value = 0.45;
assertElementsAlmostEqual(0.45, settings.value);
bm = visprops.doubleProperty([], settings);
jProp = bm.getJIDEProperty();
assertTrue(~isempty(jProp));

function testConvertValueToJIDE %#ok<DEFNU>
% Unit test for visprops.doubleProperty convertValueToJIDE method
fprintf('\nUnit tests for visprops.doubleProperty convertValueToJIDE method\n');

fprintf('It should convert a settings structure representing a double to JIDE representation\n');
setStruct = propertyTestClass.getDefaultProperties();
settings = setStruct(2);
assertElementsAlmostEqual(1000, settings.Value);
bm = visprops.doubleProperty([], settings);
jProp = bm.getJIDEProperty();
assertTrue(~isempty(jProp));
[value, isvalid, msg] = bm.convertValueToJIDE('abcde');
assertTrue(isempty(value));
assertFalse(isvalid);
assertFalse(isempty(msg));

function testSetCurrentValue %#ok<DEFNU>
% Unit test for visprops.doubleProperty setCurrentValue method
fprintf('\nUnit tests for visprops.doubleProperty setCurrentValue method\n');

fprintf('It should allow the current value to be changed to another valid value\n');
setStruct = propertyTestClass.getDefaultProperties();
settings = setStruct(2);
assertElementsAlmostEqual(1000, settings.Value);
bm = visprops.doubleProperty([], settings);
bm.setCurrentValue(543); 
assertElementsAlmostEqual(bm.CurrentValue, 543);

fprintf('It should not change the current value to an invalid value\n');
setStruct = propertyTestClass.getDefaultProperties();
settings = setStruct(2);
assertElementsAlmostEqual(1000, settings.Value);
bm = visprops.doubleProperty([], settings);
bm.setCurrentValue('asdf3');
assertElementsAlmostEqual(bm.CurrentValue, 1000);

function testGetFullNames %#ok<DEFNU>
% Unit test for visprops.doubleProperty getFullNames method
fprintf('\nUnit tests for visprops.doubleProperty getFullNames method\n');

fprintf('It should return a cell array with one name\n');
setStruct = propertyTestClass.getDefaultProperties();
settings = setStruct(2);
bm = visprops.doubleProperty([], settings);
names = bm.getFullNames();
assertEqual(length(names), 1);

function testGetPropertyStructure %#ok<DEFNU>
% Unit test for visprops.doubleProperty getPropertyStructure method
fprintf('\nUnit tests for visprops.doubleProperty getPropertyStructure method\n');

fprintf('It should return a property structure with the right values\n')
setStruct = propertyTestClass.getDefaultProperties();
s = setStruct(2);
dm = visprops.doubleProperty([], s);
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

function testSetInclusive %#ok<DEFNU>
% Unit test for visprops.doubleProperty setInclusive method
fprintf('\nUnit tests for visprops.doubleProperty setInclusive method\n');

fprintf('It should not include endpoints of limit interval when inclusive settings are false\n');
setStruct = propertyTestClass.getDefaultProperties();
s = setStruct(2);
dm = visprops.doubleProperty([], s);
assertTrue(isvalid(dm));
assertTrue(dm.testInLimits(3.0));
assertTrue(dm.testInLimits(0.0));
assertFalse(dm.testInLimits(-0.01));
assertTrue(dm.testInLimits(inf));
dm.setInclusive([false, false]);
assertFalse(dm.testInLimits(0.0));
assertFalse(dm.testInLimits(inf));

fprintf('It should include endpoints of limit interval when inclusive settings are true\n');
dm.setInclusive([true, false]);
assertTrue(dm.testInLimits(0.0));