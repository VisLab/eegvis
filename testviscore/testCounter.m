function test_suite = testCounter %#ok<STOUT>
% Unit tests for counter
initTestSuite;

function testConstructor %#ok<DEFNU>
% Unit test for viscore.counter constructor getInstance
fprintf('\nUnit tests for viscore.counter valid constructor\n');

fprintf('It should return a valid instance on getInstance\n');
ms = viscore.counter.getInstance();
assertTrue(~isempty(ms));






