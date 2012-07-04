function test_suite = testEnumeratedProperty %#ok<STOUT>
% Unit tests for enumeratedProperty
initTestSuite;

function values = setup %#ok<DEFNU>
values.setStruct = propertyTestClass.getDefaultProperties();
values.myNumber = 3;

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testConstuctor(values) %#ok<DEFNU>
% Unit test for visprops.enumeratedProperty normal constructor
fprintf('\nUnit tests for visprops.enumeratedProperty valid constructor\n');

fprintf('It should construct a valid property from a valid property structure\n');
settings = values.setStruct(values.myNumber);
assertTrue(strcmp('WindowType', settings.FieldName));
bm = visprops.enumeratedProperty([], settings);
assertTrue(isvalid(bm));

function testEnumeratedPropertyBadConstuctor(values) %#ok<DEFNU>
% Unit test for visprops.enumeratedProperty invalid constructor
fprintf('\nUnit tests for visprops.enumeratedProperty invalid constructor\n');

fprintf('It should throw an exception when constructor called with no parameters\n');
f1 = @()visprops.enumeratedProperty();
assertAltExceptionThrown(f1, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when the setting structure parameter has an invalid value\n');
settings = values.setStruct(values.myNumber);
assertTrue(strcmp('WindowType', settings.FieldName));
settings.Value = 'None';
f = @()visprops.enumeratedProperty([], settings);
assertExceptionThrown(f, 'enumeratedProperty:property');

function testGetJIDEProperty(values) %#ok<DEFNU>
% Unit test for visprops.enumeratedProperty getJIDEProperty method
fprintf('\nUnit tests for visprops.enumeratedProperty getJIDEProperty method\n');

fprintf('It should return a valid property corresponding to settings value\n');
settings = values.setStruct(values.myNumber);
assertTrue(strcmp(settings.Value, 'Blocked'));
bm = visprops.enumeratedProperty([], settings);
jProp = bm.getJIDEProperty();
assertTrue(~isempty(jProp));
assertTrue(strcmp(settings.Value, jProp.getValue()));

function testGetPropertyStructure(values) %#ok<DEFNU>
% Unit test for visprops.enumeratedProperty getPropertyStructure method
fprintf('\nUnit tests for visprops.enumeratedProperty getPropertyStructure method\n');

fprintf('It should return a property structure with the right values\n');
s = values.setStruct(values.myNumber);
dm = visprops.enumeratedProperty([], s);
assertTrue(isvalid(dm));
sNew = dm.getPropertyStructure();
assertTrue(strcmp(sNew.FieldName, s.FieldName));
assertTrue(strcmp(sNew.Category, s.Category));
assertTrue(strcmp(sNew.DisplayName, s.DisplayName));
assertTrue(strcmp(sNew.Type, s.Type));
assertTrue(strcmp(sNew.Value,s.Value));
assertTrue(strcmp(sNew.Description, s.Description));
assertEqual(sNew.Editable, s.Editable);

sNames = s.Options;
sNewNames = sNew.Options;
assertEqual(length(sNames), length(sNewNames));
for k = 1:length(sNames)
    assertTrue(strcmp(sNames{k}, sNewNames{k}));
end