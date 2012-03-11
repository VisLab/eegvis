function test_suite = testConfigurableTestClass %#ok<STOUT>
% Unit tests for ConfigurableTestClass
initTestSuite;

function testPropertyTestClassConstructor %#ok<DEFNU>
% unit tests for normal constructor
fprintf('\nUnit tests for ConfigurableTestClass\n');
ms = configurableTestClass();
assertTrue(~isempty(ms));


function testPropertyTestClassProperties %#ok<DEFNU>
ms = configurableTestClass();
assertTrue(~isempty(ms));
assertVectorsAlmostEqual(ms.Background, [0.7, 0.7, 0.7]);
ms.Background = [1, 0, 0];
s = visprops.property.getProperties(ms);
assertEqual(length(s), 11);
assertAlmostEqual(s(6).Value, [1, 0, 0]);


function testPropertyTestClassClone %#ok<DEFNU>
ms = configurableTestClass();
assertTrue(~isempty(ms));
assertVectorsAlmostEqual(ms.Background, [0.7, 0.7, 0.7]);
ms.Background = [1, 0, 0];
s = visprops.property.getProperties(ms);
assertEqual(length(s), 11);
assertAlmostEqual(s(6).Value, [1, 0, 0]);