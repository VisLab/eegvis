function test_suite = testSimpleTestClass %#ok<STOUT>
% Unit tests for simpleTestClass
initTestSuite;

function testSimpleTestClassConstructor %#ok<DEFNU>
% unit tests for normal constructor
fprintf('\nUnit tests for simpleTestClass\n');
ms = simpleTestClass();
assertTrue(~isempty(ms));

function testSimpleTestClassConstructorCloneFalse %#ok<DEFNU>
% unit tests for normal constructor
ms = simpleTestClass();
assertTrue(~isempty(ms));
assertTrue(~isempty(ms.Select));

function testSimpleTestClassGetDefaultStructure %#ok<DEFNU>
% test simpleTestClass static getDefaultSettings
mp = simpleTestClass.getDefaultProperties();
assertTrue(~isempty(mp));
mo = viscore.managedObj([], mp);
assertTrue(strcmp(mo.getValueByFieldID('BlockName', 'Value'), 'Window'));

function testSimpleTestClassGetStructure %#ok<DEFNU>
% test simpleTestClass getProperties
ms = simpleTestClass();
s = ms.Select.getObject(class(ms));
assertTrue(isa(s, 'viscore.managedObj'));
t = s.getValueByFieldID('BlockName', 'Value');
assertTrue(strcmp(t, 'Window'));
ms.BlockName = 'Epoch';
ms.Select.getManager.putValue(class(ms), 1, 'Value', ms.BlockName);
s = ms.Select.getObject(class(ms));
v = s.getValueByFieldID('BlockName', 'Value');
assertTrue(strcmp(v, 'Epoch'));


