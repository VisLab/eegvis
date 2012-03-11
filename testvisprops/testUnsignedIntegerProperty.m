function test_suite = testUnsignedIntegerProperty %#ok<STOUT>
% Unit tests for unsignedIntegerProperty
initTestSuite;

function testConstuctor %#ok<DEFNU>
% Unit test for visprops.unsignedIntegerProperty valid constructor
fprintf('\nUnit tests for visprops.unsignedIntegerProperty invalid constructor\n');

fprintf('It should create an object when a valid settings structure is passed to the constructor\n');
setStruct = propertyTestClass.getDefaultProperties();
settings = setStruct(7);
assertTrue(strcmp('Counter', settings.FieldName));
visprops.unsignedIntegerProperty([], settings);

fprintf('It should have the correct value if a valid settings structure is passed to the constructor\n');
settings.Value = 1000;
assertAlmostEqual(1000, settings.Value);
bm = visprops.unsignedIntegerProperty([], settings);
assertAlmostEqual(bm.CurrentValue, 1000);

function testInvalidConstructorValue %#ok<DEFNU>
% Unit test for visprops.unsignedIntegerProperty invalid constructor
fprintf('\nUnit tests for visprops.unsignedIntegerProperty invalid constructor\n');

fprintf('It should throw an exception if constructor is called with no arguments\n');
f = @()visprops.unsignedIntegerProperty();
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception if the settings structure argument has a non numeric value\n');
setStruct = propertyTestClass.getDefaultProperties();
settings = setStruct(1);
f = @()visprops.unsignedIntegerProperty(settings);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception if the settings structure argument has a negative value\n');
settings = setStruct(7);
settings.Value = -342;
f = @()visprops.unsignedIntegerProperty([], settings);
assertExceptionThrown(f, 'unsignedIntegerProperty:property');

function testGetJIDEProperty %#ok<DEFNU>
% Unit test for visprops.unsignedIntegerProperty getJIDEProperty method
fprintf('\nUnit tests for visprops.unsignedIntegerProperty getJIDEProperty method\n');

fprintf('It should return a JIDE property\n');
setStruct = propertyTestClass.getDefaultProperties();
settings = setStruct(7);
settings.Value = 1000;
assertAlmostEqual(1000, settings.Value);
bm = visprops.unsignedIntegerProperty([], settings);
jProp = bm.getJIDEProperty();
assert(~isempty(jProp));

function testConvertValueToJIDE %#ok<DEFNU>
% Unit test for visprops..unsignedIntegerProperty convertValueToJIDE method
fprintf('\nUnit tests for visprops..unsignedIntegerProperty convertValueToJIDE method\n');

fprintf('It should convert a valid unsigned integer to a valid JIDE property\n');
setStruct = propertyTestClass.getDefaultProperties();
settings = setStruct(7);
bm = visprops.unsignedIntegerProperty([], settings);
[jValue, valid, msg] = bm.convertValueToJIDE(3);
assertTrue(valid);
assertTrue(isempty(msg));
assertEqual('3', jValue);

fprintf('It should not convert a negative number to JIDE\n');
setStruct = propertyTestClass.getDefaultProperties();
settings = setStruct(7);
bm = visprops.unsignedIntegerProperty([], settings);
[jValue, valid, msg] = bm.convertValueToJIDE(-345);
assertTrue(isempty(jValue));
assertFalse(valid);
assertFalse(isempty(msg));

fprintf('It should not convert a non-numeric string to JIDE\n');
setStruct = propertyTestClass.getDefaultProperties();
settings = setStruct(7);
bm = visprops.unsignedIntegerProperty([], settings);
[jValue, valid, msg] = bm.convertValueToJIDE('abcde');
assertTrue(isempty(jValue));
assertFalse(valid);
assertFalse(isempty(msg));

fprintf('It should not convert a non integral double to JIDE\n');
setStruct = propertyTestClass.getDefaultProperties();
settings = setStruct(7);
bm = visprops.unsignedIntegerProperty([], settings);
[jValue, valid, msg] = bm.convertValueToJIDE(345.2);
assertTrue(isempty(jValue));
assertFalse(valid);
assertFalse(isempty(msg));

function testValidateAndSetFromJIDE %#ok<DEFNU>
% Unit test for visprops.unsignedIntegerProperty validateAndSetFromJIDE method
fprintf('\nUnit tests for visprops.unsignedIntegerProperty validateAndSetFromJIDE method\n');

fprintf('It should have the correct value when set from a JIDE property\n');
settings = propertyTestClass.getDefaultProperties();
assertEqual(length(settings), 11);
mProp = visprops.unsignedIntegerProperty('temp', settings(7));
mProp.validateAndSetFromJIDE('Name', '3');
assertEqual(mProp.CurrentValue, uint32(3));

function testGetPropertyStructure %#ok<DEFNU>
% Unit test for visprops.unsignedIntegerProperty getPropertyStructure method
fprintf('\nUnit tests for visprops.unsignedIntegerProperty getPropertyStructure method\n');

fprintf('It should return a property structure containing the correct values\n');
setStruct = propertyTestClass.getDefaultProperties();
s = setStruct(7);
dm = visprops.unsignedIntegerProperty([], s);
assertTrue(isvalid(dm));
sNew = dm.getStructure();
sNew = sNew(1);
assertTrue(strcmp(sNew.FieldName, s.FieldName));
assertTrue(strcmp(sNew.Category, s.Category));
assertTrue(strcmp(sNew.DisplayName, s.DisplayName));
assertTrue(strcmp(sNew.Type, s.Type));
assertVectorsAlmostEqual(sNew.Value, s.Value);
assertElementsAlmostEqual(sNew.Options(1), 0)
assertElementsAlmostEqual(sNew.Options(2), inf)
assertTrue(strcmp(sNew.Description, s.Description));
assertEqual(sNew.Editable, s.Editable);
