function test_suite = testColorProperty %#ok<STOUT>
% Unit tests for colorProperty
initTestSuite;

function values = setup %#ok<DEFNU>
values.setStruct = propertyTestClass.getDefaultProperties();
values.myNumber = 6;

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testConstuctor(values) %#ok<DEFNU>
% Unit test for visprops.colorProperty normal constructor
fprintf('\nUnit tests for visprops.colorProperty valid constructor\n');

fprintf('It should construct a valid property from a property structure with 1 color\n');
settings = values.setStruct(values.myNumber);
assertTrue(strcmp('Background', settings.FieldName));
cp = visprops.colorProperty([], settings);
assertTrue(isvalid(cp));

function testConstuctorInvalid(values) %#ok<DEFNU>
% Unit test for visprops.colorProperty invalid constructor
fprintf('\nUnit tests for visprops.colorProperty invalid constructor\n');

fprintf('It should throw an exception when an invalid color property is passed to the constructor\n');
setStruct = propertyTestClass.getDefaultProperties();
setting = setStruct(1);
f = @()visprops.colorProperty([], setting);
assertExceptionThrown(f, 'colorProperty:property');

fprintf('It should throw an exception if constructor is called with a settings structure with a non color value\n');
settings = values.setStruct(values.myNumber);
settings.Value = 'abcd';
f = @()visprops.colorProperty([], settings);
assertExceptionThrown(f, 'colorProperty:property');

function testGetFullNames(values) %#ok<DEFNU>
% Unit test for visprops.colorProperty getFullNames method
fprintf('\nUnit tests for visprops.colorProperty getFullNames method\n');

fprintf('It should return a cell array containing one full name\n');
settings = values.setStruct(values.myNumber);
bm = visprops.colorProperty([], settings);
names = bm.getFullNames();
assertEqual(length(names), 1);
assertTrue(isa(names, 'cell'));

function testValidateAndSetJIDE(values) %#ok<DEFNU>
% Unit test for visprops.colorProperty validateAndSetFromJIDE method
fprintf('\nUnit tests for visprops.colorProperty validateAndSetFromJIDE method\n');

fprintf('It should correctly set a color value from a valid JIDE representation\n');
settings = values.setStruct(values.myNumber);
x = visprops.colorProperty('temp', settings);
[oldColor, valid, msg] = x.convertValueToJIDE([0.7, 0.7, 0.7]);  %#ok<ASGLU>
assertTrue(valid);
assertTrue(isempty(msg));
[newColor, valid, msg] = x.convertValueToJIDE([1, 0.0, 0.0]);
assertTrue(valid);
assertTrue(isempty(msg));
x.validateAndSetFromJIDE('Name', newColor);

function testGetPropertyStructure(values) %#ok<DEFNU>
% Unit test for visprops.colorProperty getPropertyStructure method
fprintf('\nUnit tests for visprops.colorProperty getPropertyStructure method\n');

fprintf('It should correctly get the property structure\n');
s= values.setStruct(values.myNumber);
assertTrue(strcmp('Background', s.FieldName));
cm = visprops.colorProperty([], s);
assertTrue(isvalid(cm));
sNew = cm.getPropertyStructure();
sNew = sNew(1);
assertTrue(strcmp(sNew.FieldName, s.FieldName));
assertTrue(strcmp(sNew.Category, s.Category));
assertTrue(strcmp(sNew.DisplayName, s.DisplayName));
assertTrue(strcmp(sNew.Type, s.Type));
assertVectorsAlmostEqual(sNew.Value, s.Value);
assertTrue(strcmp(sNew.Options, s.Options));
assertTrue(strcmp(sNew.Description, s.Description));
assertEqual(sNew.Editable, s.Editable);
