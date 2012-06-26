function test_suite = testDataSelector %#ok<STOUT>
% Unit tests for dataSelector
initTestSuite;

function values = setup %#ok<DEFNU>
values = [];

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testNormalConstuctor(values) %#ok<INUSD,DEFNU>
% Unit test for viscore.dataSelector normal constructor
fprintf('\nUnit tests for viscore.dataSelector normal constructor\n');

fprintf('It should create a valid object given a configuration class name\n');
vs =  viscore.dataSelector('viscore.dataConfig');
assertTrue(isvalid(vs));



