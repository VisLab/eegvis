function test_suite = testPropertyTestClass %#ok<STOUT>
% Unit tests for propertyTestClass
initTestSuite;

function testNormalConstructor %#ok<DEFNU>
% unit tests for normal constructor of propertyTestClass
fprintf('\nUnit tests for propertyTestClass\n');
ms = propertyTestClass();
assertTrue(~isempty(ms));


function testGetProperties %#ok<DEFNU>
% Test getProperties method of propertyTestClass
ms = propertyTestClass();
assertTrue(~isempty(ms));
assertVectorsAlmostEqual(ms.Background, [0.7, 0.7, 0.7]);
ms.Background = [1, 0, 0];
s = visprops.property.getProperties(ms);
assertEqual(length(s), 11);
assertAlmostEqual(s(6).Value, [1, 0, 0]);
