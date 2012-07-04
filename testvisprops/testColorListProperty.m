function test_suite = testColorListProperty %#ok<STOUT>
% Unit tests for visprops.colorListProperty
initTestSuite;

function values = setup %#ok<DEFNU>
values.setStruct = propertyTestClass.getDefaultProperties();
values.myNumber = 4;

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testConstuctor(values) %#ok<DEFNU>
% Unit test for visprops.colorListProperty normal constructor
fprintf('\nUnit tests for visprops.colorListProperty valid constructor\n');

fprintf('It should construct a valid property from a property structure with 1 color\n');
setting = values.setStruct(values.myNumber);
assertTrue(strcmp('BoxColors', setting.FieldName));
visprops.colorListProperty([], setting);
setting.value = [0.7, 0.7, 0.7];
assertTrue(strcmp('BoxColors', setting.FieldName));
cList = visprops.colorListProperty([], setting);
assertTrue(isvalid(cList));

fprintf('It should construct a valid property from a property structure with 2 color\n');
setting = values.setStruct(values.myNumber);
assertTrue(strcmp('BoxColors', setting.FieldName));
visprops.colorListProperty([], setting);
setting.value = [0.7, 0.7, 0.7; 1.0, 1.0, 1.0];
assertTrue(strcmp('BoxColors', setting.FieldName));
cList = visprops.colorListProperty([], setting);
assertTrue(isvalid(cList));

function testConstuctorInvalid(values) %#ok<DEFNU>
% Unit test for visprops.colorListProperty invalid constructor
fprintf('\nUnit tests for visprops.colorListProperty invalid constructor\n');

fprintf('It should throw an exception when constructor called with no parameters\n');
f = @()visprops.colorListProperty();
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception if constructor is called with a settings structure with a color\n');
settings = values.setStruct(values.myNumber);
settings.Value = 'abcd';
f = @()visprops.colorListProperty([], settings);
assertExceptionThrown(f, 'colorListProperty:property');

function testConvertValueToJIDE(values) %#ok<DEFNU>
% Unit test for visprops.colorListProperty convertValueToJIDE method
fprintf('\nUnit tests for visprops.colorListProperty convertValueToJIDE method\n');

fprintf('It should construct a single color to JIDE representation\n');
settings = values.setStruct(values.myNumber);
assertTrue(strcmp('BoxColors', settings.FieldName));
bm = visprops.colorListProperty([], settings);
[value, isvalid, msg] = bm.convertValueToJIDE([0.3, 0.3, 0.3]); %#ok<ASGLU>
assertTrue(isvalid);
assertTrue(isempty(msg));

fprintf('It should construct a color list to JIDE representation\n');
settings = values.setStruct(values.myNumber);
assertTrue(strcmp('BoxColors', settings.FieldName));
bm = visprops.colorListProperty([], settings);
[value, isvalid, msg] = bm.convertValueToJIDE([0.3, 0.3, 0.3; 1.0, 0, 0]); %#ok<ASGLU>
assertTrue(isvalid);
assertTrue(isempty(msg));

function testFieldNames(values) %#ok<DEFNU>
% Unit test for visprops.colorListProperty convertValueToJIDE method
fprintf('\nUnit tests for visprops.colorListProperty convertValueToJIDE method\n');

fprintf('It should construct a single color to JIDE representation\n');
settings = values.setStruct(values.myNumber);
assertTrue(strcmp('BoxColors', settings.FieldName));
bm = visprops.colorListProperty([], settings);
names = bm.getFullNames();
assertEqual(length(names), 3);

function testValidateAndSetFromJIDE(values) %#ok<DEFNU>
% Unit test for visprops.colorListProperty validateAndSetFromJIDE method
fprintf('\nUnit tests for visprops.colorListProperty validateAndSetFromJIDE method\n');

fprintf('It should correctly set a color value from a JIDE representation\n');
settings = values.setStruct(values.myNumber);
x = visprops.colorListProperty('temp', settings);
assertAlmostEqual(x.CurrentValue, [0.7, 0.7, 0.7; 1, 0, 1]);
assertAlmostEqual(settings.Value, [0.7, 0.7, 0.7; 1, 0, 1]);
[oldColor, valid, msg] = x.convertValueToJIDE([0.7, 0.7, 0.7]); %#ok<ASGLU>
assertTrue(valid);
assertTrue(isempty(msg));
[newColor, valid, msg] = x.convertValueToJIDE([1, 0.0, 0.0]);
assertTrue(valid);
assertTrue(isempty(msg));
rootName = char(x.getFullName());
x.validateAndSetFromJIDE([rootName '.1'], newColor(1));

function testGetPropertyStructure(values) %#ok<DEFNU>
% Unit test for visprops.colorListProperty getPropertyStructure method
fprintf('\nUnit tests for visprops.colorListProperty getPropertyStructure method\n');

fprintf('It should correctly get the property structure\n');
s = values.setStruct(values.myNumber);
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

