function test_suite = testLogicalProperty %#ok<STOUT>
% Unit tests for logicalProperty
initTestSuite;

function testConstuctor %#ok<DEFNU>
% Unit test for visprops.logicalProperty valid constructor
fprintf('\nUnit tests for visprops.logicalProperty invalid constructor\n');

fprintf('It should create an object when a valid settings structure is passed to the constructor\n');
setStruct = propertyTestClass.getDefaultProperties();
settings = setStruct(9);
assertTrue(strcmp('LogicalFlag', settings.FieldName));
p = visprops.logicalProperty([], settings);
assertTrue(isvalid(p));

fprintf('It should have the right value\n');
assertEqual(p.CurrentValue, true);


fprintf('It should create a valid object when the setting structure value is false\n');
setStruct = propertyTestClass.getDefaultProperties();
settings = setStruct(9);
settings.value = false;
assertEqual(false, settings.value);
bm = visprops.logicalProperty([], settings);
jProp = bm.getJIDEProperty();
assertTrue(~isempty(jProp));

function testInvalidConstructor %#ok<DEFNU>
% Unit test for visprops.logicalProperty invalid constructor
fprintf('\nUnit tests for visprops.logicalProperty invalid constructor\n');

fprintf('It should throw an exception if constructor is called with no arguments\n');
f = @()visprops.logicalProperty();
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception if constructor is called with a settings structure with numeric value\n');
setStruct = propertyTestClass.getDefaultProperties();
settings = setStruct(9);
assertEqual(true, settings.Value);
settings.Value = -342;
f = @()visprops.logicalProperty([], settings);
assertExceptionThrown(f, 'logicalProperty:property');

fprintf('It should throw an exception if constructor is called with a settings structure with a char value\n');
setStruct = propertyTestClass.getDefaultProperties();
settings = setStruct(9);
assertEqual(true, settings.Value);
settings.Value = 'abcd';
f = @()visprops.logicalProperty([], settings);
assertExceptionThrown(f, 'logicalProperty:property');

function testGetJIDEProperty %#ok<DEFNU>
% Unit test for visprops.logicalProperty getJIDEProperty method
fprintf('\nUnit tests for visprops.logicalProperty getJIDEProperty method\n');

fprintf('It should return a JIDE property\n');
setStruct = propertyTestClass.getDefaultProperties();
settings = setStruct(9);
assertEqual(true, settings.Value);
bm = visprops.logicalProperty([], settings);
jProp = bm.getJIDEProperty();
assertTrue(~isempty(jProp));

function testconvertValueToMATLAB %#ok<DEFNU>
% Unit test for visprops.logicalProperty getJIDEProperty method
fprintf('\nUnit tests for visprops.logicalProperty convertValueToMATLAB method\n');

fprintf('It should return logical property from a logical string\n');
setStruct = propertyTestClass.getDefaultProperties();
settings = setStruct(9);
assertEqual(true, settings.Value);
bm = visprops.logicalProperty([], settings);
jProp = bm.getJIDEProperty();
assertTrue(~isempty(jProp));
[value, isvalid, msg] = bm.convertValueToMATLAB('true');
assertTrue(value);
assertTrue(isvalid);
assertTrue(isempty(msg));


function testSetCurrentValue %#ok<DEFNU>
% Unit test for visprops.logicalProperty setCurrentValue method
fprintf('\nUnit tests for visprops.logicalProperty setCurrentValue method\n');

fprintf('It should have the right CurrentValue if set to valid value\n');
setStruct = propertyTestClass.getDefaultProperties();
settings = setStruct(9);
assertEqual(true, settings.Value);
bm = visprops.logicalProperty([], settings);
bm.setCurrentValue(false); 
assertEqual(bm.CurrentValue, false);

fprintf('It should not change its value if the value is invalid\n');
setStruct = propertyTestClass.getDefaultProperties();
settings = setStruct(9);
assertEqual(true, settings.Value);
bm = visprops.logicalProperty([], settings);
bm.setCurrentValue('asdf3');
assertEqual(bm.CurrentValue, true);

function testGetFullNames %#ok<DEFNU>
% Unit test for visprops.logicalProperty getFullNames method
fprintf('\nUnit tests for visprops.logicalProperty getFullNames method\n');

fprintf('It should return a cell array with on value\n');
setStruct = propertyTestClass.getDefaultProperties();
settings = setStruct(9);
bm = visprops.logicalProperty([], settings);
names = bm.getFullNames();
assertEqual(length(names), 1);
assertTrue(isa(names, 'cell'));

function testGetPropertyStructure %#ok<DEFNU>
%% Unit test for visprops.logicalProperty getPropertyStructure method
fprintf('\nUnit tests for visprops.logicalProperty getPropertyStructure method\n');

fprintf('It should return a structure with the right fields and values\n');
setStruct = propertyTestClass.getDefaultProperties();
s = setStruct(9);
dm = visprops.logicalProperty([], s);
assertTrue(isvalid(dm));
sNew = dm.getPropertyStructure();
sNew = sNew(1);
assertTrue(strcmp(sNew.FieldName, s.FieldName));
assertTrue(strcmp(sNew.Category, s.Category));
assertTrue(strcmp(sNew.DisplayName, s.DisplayName));
assertTrue(strcmp(sNew.Type, s.Type));
assertEqual(sNew.Value, s.Value);
assertEqual(length(sNew.Options), 2);
assertTrue(strcmp(sNew.Description, s.Description));
assertEqual(sNew.Editable, s.Editable);
