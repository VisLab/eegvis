function test_suite = testColorListProperty %#ok<STOUT>
% Unit tests for visprops.colorListProperty
initTestSuite;

function testConstuctor %#ok<DEFNU>
% Unit test for visprops.colorListProperty normal constructor
fprintf('\nUnit tests for visprops.colorListProperty valid constructor\n');

fprintf('It should construct a valid property from a property structure with 1 color\n');
setStruct = propertyTestClass.getDefaultProperties();
setting = setStruct(4);
assertTrue(strcmp('BoxColors', setting.FieldName));
visprops.colorListProperty([], setting);
setting.value = [0.7, 0.7, 0.7];
assertTrue(strcmp('BoxColors', setting.FieldName));
cList = visprops.colorListProperty([], setting);
assertTrue(isvalid(cList));

function testConstuctorInvalid %#ok<DEFNU>
% Unit test for visprops.colorListProperty invalid constructor
fprintf('\nUnit tests for visprops.colorListProperty invalid constructor\n');

fprintf('It should throw an exception when constructor called with no parameters\n');
f = @()visprops.colorListProperty();
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

function testConvertValueToJIDE %#ok<DEFNU>
% Unit test for visprops.colorListProperty convertValueToJIDE method
fprintf('\nUnit tests for visprops.colorListProperty convertValueToJIDE method\n');

fprintf('It should construct a single color to JIDE representation\n');
setStruct = propertyTestClass.getDefaultProperties();
settings = setStruct(4);
assertTrue(strcmp('BoxColors', settings.FieldName));
bm = visprops.colorListProperty([], settings);
[value, isvalid, msg] = bm.convertValueToJIDE([0.3, 0.3, 0.3]); %#ok<ASGLU>
assertTrue(isvalid);
assertTrue(isempty(msg));

function testFieldNames %#ok<DEFNU>
% Unit test for visprops.colorListProperty convertValueToJIDE method
fprintf('\nUnit tests for visprops.colorListProperty convertValueToJIDE method\n');

fprintf('It should construct a single color to JIDE representation\n');
setStruct = propertyTestClass.getDefaultProperties();
settings = setStruct(4);
assertTrue(strcmp('BoxColors', settings.FieldName));
bm = visprops.colorListProperty([], settings);
names = bm.getFullNames();
assertEqual(length(names), 3);

function testValidateAndSetFromJIDE %#ok<DEFNU>
% Unit test for visprops.colorListProperty validateAndSetFromJIDE method
fprintf('\nUnit tests for visprops.colorListProperty validateAndSetFromJIDE method\n');

fprintf('It should correctly set a color value from a JIDE representation\n');
settings = propertyTestClass.getDefaultProperties();
assertEqual(length(settings), 11);
x = visprops.colorListProperty('temp', settings(4));
assertAlmostEqual(x.CurrentValue, [0.7, 0.7, 0.7; 1, 0, 1]);
assertAlmostEqual(settings(4).Value, [0.7, 0.7, 0.7; 1, 0, 1]);
[oldColor, valid, msg] = x.convertValueToJIDE([0.7, 0.7, 0.7]); %#ok<ASGLU>
assertTrue(valid);
assertTrue(isempty(msg));
[newColor, valid, msg] = x.convertValueToJIDE([1, 0.0, 0.0]);
assertTrue(valid);
assertTrue(isempty(msg));
rootName = char(x.getFullName());
x.validateAndSetFromJIDE([rootName '.1'], newColor(1));

function testGetPropertyStructure %#ok<DEFNU>
% Unit test for visprops.colorListProperty getPropertyStructure method
fprintf('\nUnit tests for visprops.colorListProperty getPropertyStructure method\n');

fprintf('It should correctly get the property structure\n');
setStruct = propertyTestClass.getDefaultProperties();
s = setStruct(4);
cm = visprops.colorListProperty([], s);
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
%assertEqual(sNew.Editable, s.Editable);
