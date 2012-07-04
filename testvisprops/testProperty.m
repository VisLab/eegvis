function test_suite = testProperty %#ok<STOUT>
% Unit tests for property
initTestSuite;

function values = setup %#ok<DEFNU>
values.setStruct = propertyTestClass.getDefaultProperties();
values.myNumber = 1;

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testConstuctor(values) %#ok<DEFNU>
% Unit test for visprops.property for normal constructor
fprintf('\nUnit tests for visprops.property invalid constructor\n');

fprintf('It should create an object when a valid settings structure is passed to the constructor\n');
settings = values.setStruct(values.myNumber);
assertTrue(strcmp('BlockName', settings.FieldName));
visprops.property([], settings);

function testConvertJIDEValue(values) %#ok<DEFNU>
% Unit test for visprops.property convertValueToJIDE method
fprintf('\nUnit tests for visprops.property convertValueToJIDE method\n');

fprintf('It should convert a settings structure representing a string to JIDE representation\n');
settings = values.setStruct(values.myNumber);
bm = visprops.property([], settings);
jProp = bm.getJIDEProperty();
[value, isvalid, msg] = bm.convertValueToMATLAB(get(jProp, 'Value'));
assertTrue(strcmp(value, 'Window'));
assertTrue(isvalid);
assertTrue(isempty(msg));

function testGetPropertyStructure(values) %#ok<DEFNU>
% Unit test for visprops.property getPropertyStructure method
fprintf('\nUnit tests for visprops.property getPropertyStructure method\n');

fprintf('It should return a property structure with the right values\n')
s = values.setStruct(values.myNumber);
bm = visprops.property([], s);
assertTrue(isvalid(bm));
sNew = bm.getPropertyStructure();
sNew = sNew(1);
assertTrue(strcmp(sNew.FieldName, s.FieldName));
assertTrue(strcmp(sNew.Category, s.Category));
assertTrue(strcmp(sNew.DisplayName, s.DisplayName));
assertTrue(strcmp(sNew.Type, s.Type) == 0);
assertTrue(strcmp(sNew.Value, s.Value));
assertTrue(strcmp(sNew.Options, s.Options));
assertTrue(strcmp(sNew.Description, s.Description));
assertEqual(sNew.Editable, s.Editable);

function testGetJIDEPropertyByName(values) %#ok<DEFNU>
% Unit test for visprops.property getJIDEPropertyByName method
fprintf('\nUnit tests for visprops.property getJIDEPropertyByName method\n');

fprintf('It should return the JIDE full name\n')
settings = values.setStruct(values.myNumber);
bm = visprops.property([], settings);
name = bm.getFullName();
[jObj, pos] = bm.getJIDEPropertyByName(name); %#ok<ASGLU>
assertElementsAlmostEqual(pos, 0);
