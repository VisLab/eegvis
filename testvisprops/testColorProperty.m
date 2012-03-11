function test_suite = testColorProperty %#ok<STOUT>
% Unit tests for colorProperty
initTestSuite;

function testConstuctor %#ok<DEFNU>
% Unit test for visprops.colorProperty normal constructor
fprintf('\nUnit tests for visprops.colorProperty valid constructor\n');

fprintf('It should construct a valid property from a property structure with 1 color\n');
setStruct = propertyTestClass.getDefaultProperties();
setting = setStruct(6);
assertTrue(strcmp('Background', setting.FieldName));
cp = visprops.colorProperty([], setting);
assertTrue(isvalid(cp));


function testConstuctorInvalid %#ok<DEFNU>
% Unit test for visprops.colorProperty invalid constructor
fprintf('\nUnit tests for visprops.colorProperty invalid constructor\n');

fprintf('It should throw an exception when an invalid color property is passed to the constructor\n');
setStruct = propertyTestClass.getDefaultProperties();
setting = setStruct(1);
f = @()visprops.colorProperty([], setting);
assertExceptionThrown(f, 'colorProperty:property');

function testGetFullNames %#ok<DEFNU>
% Unit test for visprops.colorProperty getFullNames method
fprintf('\nUnit tests for visprops.colorProperty getFullNames method\n');

fprintf('It should return a cell array containing one full name\n');
setStruct = propertyTestClass.getDefaultProperties();
setting = setStruct(6);
bm = visprops.colorProperty([], setting);
names = bm.getFullNames();
assertEqual(length(names), 1);
assertTrue(isa(names, 'cell'));


function testValidateAndSetJIDE %#ok<DEFNU>
% Unit test for visprops.colorProperty validateAndSetFromJIDE method
fprintf('\nUnit tests for visprops.colorProperty validateAndSetFromJIDE method\n');

fprintf('It should correctly set a color value from a valid JIDE representation\n');
settings =  propertyTestClass.getDefaultProperties();
assertEqual(length(settings), 11);
x = visprops.colorProperty('temp', settings(6));
[oldColor, valid, msg] = x.convertValueToJIDE([0.7, 0.7, 0.7]);  %#ok<ASGLU>
assertTrue(valid);
assertTrue(isempty(msg));
[newColor, valid, msg] = x.convertValueToJIDE([1, 0.0, 0.0]);
assertTrue(valid);
assertTrue(isempty(msg));
x.validateAndSetFromJIDE('Name', newColor);

function testGetPropertyStructure %#ok<DEFNU>
% Unit test for visprops.colorProperty getPropertyStructure method
fprintf('\nUnit tests for visprops.colorProperty getPropertyStructure method\n');

fprintf('It should correctly get the property structure\n');
setStruct = propertyTestClass.getDefaultProperties();
s = setStruct(6);
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
