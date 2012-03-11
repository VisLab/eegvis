function test_suite = testScalpMapPlot %#ok<STOUT>
% Unit tests for scalpMapPlot
initTestSuite;

function testNormalConstructor %#ok<DEFNU>
% Unit test for visviews.scalpMapPlot constructor
fprintf('\nUnit tests for visviews.scalpMapPlot valid constructor\n');

fprintf('It should construct a valid scalp map plot when only parent passed\n');
sfig = figure;
sp = visviews.scalpMapPlot(sfig, [], []);
assertTrue(isvalid(sp));
drawnow
delete(sfig);

function testBadConstructor %#ok<DEFNU>
% Unit test for visviews.scalpMapPlot bad constructor
fprintf('\nUnit tests for visviews.scalpMapPlot invalid constructor parameters\n');

fprintf('It should throw an exception when no parameters are passed\n');
f = @() visviews.scalpMapPlot();
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when only one parameter is passed\n');
sfig = figure;
f = @() visviews.scalpMapPlot(sfig);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when only two parameters are passed\n');
f = @() visviews.scalpMapPlot(sfig, []);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when more than three parameters are passed\n');
f = @() visviews.scalpMapPlot(sfig, [], [], []);
assertExceptionThrown(f, 'MATLAB:maxrhs');
delete(sfig);

