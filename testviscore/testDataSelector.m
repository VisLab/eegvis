function test_suite = testDataSelector %#ok<STOUT>
% Unit tests for dataSelector
initTestSuite;

function testNormalConstuctor %#ok<DEFNU>
% Unit test for viscore.dataSelector normal constructor
fprintf('\nUnit tests for viscore.dataSelector normal constructor\n');

fprintf('It should create a valid object given a configuration class name\n');
vs =  viscore.dataSelector('viscore.dataConfig');
assertTrue(isvalid(vs));



