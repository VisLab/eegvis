function test_suite = testPlotConfig %#ok<STOUT>
initTestSuite;

function testConstructor %#ok<DEFNU>
% Unit test for visviews.plotConfig normal constructor
fprintf('\nUnit tests for visviews.plotConfig valid constructor\n');

fprintf('It should construct a valid plot configuration GUI when passed a selector and title\n');
defaults = visviews.plotObj.createObjects(...
       'visviews.plotObj',  viewTestClass.getDefaultPlots());
selector = viscore.dataSelector('visviews.plotConfig');
selector.getManager().putObjects(defaults);
title = 'plotConfig test figure normal constructor';
pc1 = visviews.plotConfig(selector, title);
assertTrue(isvalid(pc1));
fprintf('It should construct a valid plot configuration with an empty title');
pc2 = visviews.plotConfig(selector, title);
assertTrue(isvalid(pc2));
drawnow
delete(pc1);
delete(pc2);

function testInvalidConstructor %#ok<DEFNU>
% Unit test for visviews.plotConfig constructor
fprintf('\nUnit tests for visviews.plotConfig invalid constructor\n');

fprintf('It should throw an exception when no parameters are passed\n');
pc1 = @() visviews.plotConfig();
assertAltExceptionThrown(pc1, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should thrown an exception when an empty selector is passed\n');
pc2 =  @() visviews.plotConfig([], 'Empty selector test');
assertExceptionThrown(pc2, 'dataConfig:InvalidParameters');

fprintf('It should thrown an exception when a selector with wrong config type is passed\n');
sel = viscore.dataSelector([]);
pc3 =  @() visviews.plotConfig(sel, 'Wrong selector type test');
assertExceptionThrown(pc3, 'plotConfig:InvalidParameters');
