function test_suite = testIntegerProperty %#ok<STOUT>
% Unit tests for integerProperty
initTestSuite;

function testConstuctor %#ok<DEFNU>
% Unit test for visprops.integerProperty valid constructor
fprintf('\nUnit tests for visprops.integerProperty invalid constructor\n');

fprintf('It should create an object when a valid settings structure is passed to the constructor\n');
setStruct = propertyTestClass.getDefaultProperties();
settings = setStruct(8);
assertTrue(strcmp('SimpleInteger', settings.FieldName));
p = visprops.integerProperty([], settings);
assertTrue(isvalid(p));

fprintf('It should have the right CurrentValue when a valid settings structure is passed to the constructor\n');
assertAlmostEqual(1, settings.Value);
assertAlmostEqual(p.CurrentValue, 1);


function testInvalidConstructor %#ok<DEFNU>
% Unit test for visprops.integerProperty invalid constructor
fprintf('\nUnit tests for visprops.integerProperty invalid constructor\n');

fprintf('It should throw an exception if constructor is called with no arguments\n');
f = @()visprops.integerProperty();
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception if constructor is called with a settings structure with non numeric value\n');
setStruct = propertyTestClass.getDefaultProperties();
settings = setStruct(1);
f = @()visprops.integerProperty([], settings);
assertExceptionThrown(f, 'integerProperty:property');

fprintf('It should throw an exception if constructor is called with a settings structure with a double value\n');
setStruct = propertyTestClass.getDefaultProperties();
settings = setStruct(8);
settings.Value = 3.423;
f = @()visprops.integerProperty([], settings);
assertExceptionThrown(f, 'integerProperty:property');

function testGetJIDEProperty %#ok<DEFNU>
% Unit test for visprops.integerProperty getJIDEProperty method
fprintf('\nUnit tests for visprops.integerProperty getJIDEProperty method\n');

fprintf('It should return a JIDE property\n');
setStruct = propertyTestClass.getDefaultProperties();
settings = setStruct(8);
assertAlmostEqual(1, settings.Value);
bm = visprops.integerProperty([], settings);
jProp = bm.getJIDEProperty();
assert(~isempty(jProp));

function testConvertValueToJIDE %#ok<DEFNU>
% Unit test for visprops.integerProperty convertValueToJIDE method
fprintf('\nUnit tests for visprops.integerProperty convertValueToJIDE method\n');

fprintf('It should convert a valid integer to a valid JIDE property\n');
setStruct = propertyTestClass.getDefaultProperties();
settings = setStruct(8);
bm = visprops.integerProperty([], settings);
[jValue, valid, msg] = bm.convertValueToJIDE(3);
assertTrue(valid);
assertTrue(isempty(msg));
assertEqual('3', jValue);

fprintf('It should return invalid when called to convert a non-numeric value\n');
setStruct = propertyTestClass.getDefaultProperties();
settings = setStruct(8);
bm = visprops.integerProperty([], settings);
[value, valid, msg] = bm.convertValueToJIDE('abcde');
assertTrue(isempty(value));
assertFalse(valid);
assertFalse(isempty(msg));

function testValidateAndSetFromJIDE %#ok<DEFNU>
% Unit test for visprops.integerProperty validateAndSetFromJIDE method
fprintf('\nUnit tests for visprops.integerProperty validateAndSetFromJIDE method\n');

fprintf('It should have the correct value when set from a JIDE property\n');
settings = propertyTestClass.getDefaultProperties();
assertEqual(length(settings), 11);
x = visprops.integerProperty('temp', settings(8));
x.validateAndSetFromJIDE('Name', '10');
assertEqual(x.CurrentValue, int32(10));

function testGetPropertyStructure %#ok<DEFNU>
% Unit test for visprops.integerProperty getPropertyStructure method
fprintf('\nUnit tests for visprops.integerProperty getPropertyStructure method\n');

fprintf('It should return a property structure containing the correct values\n');
setStruct = propertyTestClass.getDefaultProperties();
s = setStruct(8);
dm = visprops.integerProperty([], s);
assertTrue(isvalid(dm));
sNew = dm.getPropertyStructure();
assertTrue(strcmp(sNew.FieldName, s.FieldName));
assertTrue(strcmp(sNew.Category, s.Category));
assertTrue(strcmp(sNew.DisplayName, s.DisplayName));
assertTrue(strcmp(sNew.Type, s.Type));
assertVectorsAlmostEqual(sNew.Value, s.Value);
assertElementsAlmostEqual(sNew.Options(1), -Inf)
assertElementsAlmostEqual(sNew.Options(2), Inf)
assertTrue(strcmp(sNew.Description, s.Description));
assertEqual(sNew.Editable, s.Editable);
