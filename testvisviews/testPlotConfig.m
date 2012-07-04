function test_suite = testPlotConfig %#ok<STOUT>
initTestSuite;

function values = setup %#ok<DEFNU>
values.deleteFigures = false;

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testConstructor(values) %#ok<DEFNU>
% Unit test for visviews.plotConfig normal constructor
fprintf('\nUnit tests for visviews.plotConfig valid constructor\n');

fprintf('It should construct a valid plot configuration GUI when passed a selector and title\n');
defaults = visviews.plotObj.createObjects(...
       'visviews.plotObj',  viewTestClass.getDefaultPlots());
selector = viscore.dataSelector('visviews.plotConfig');
selector.getManager().putObjects(defaults);
title = 'plotConfig test figure normal constructor';
fig1 = visviews.plotConfig(selector, title);
assertTrue(isvalid(fig1));
fprintf('It should construct a valid plot configuration with an empty string title');
fig2 = visviews.plotConfig(selector, '');
assertTrue(isvalid(fig2));

drawnow
if values.deleteFigures
    delete(fig1);
    delete(fig2);
end

function testInvalidConstructor(values) %#ok<DEFNU>
% Unit test for visviews.plotConfig constructor
fprintf('\nUnit tests for visviews.plotConfig invalid constructor\n');

fprintf('It should throw an exception when no parameters are passed\n');
fig1 = @() visviews.plotConfig();
assertAltExceptionThrown(fig1, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should thrown an exception when an empty selector is passed\n');
fig2 =  @() visviews.plotConfig([], 'Empty selector test');
assertExceptionThrown(fig2, 'dataConfig:InvalidParameters');

fprintf('It should thrown an exception when a selector with wrong config type is passed\n');
sel = viscore.dataSelector([]);
fig3 =  @() visviews.plotConfig(sel, 'Wrong selector type test');
assertExceptionThrown(fig3, 'plotConfig:InvalidParameters');

fprintf('It should thrown an exception when empty title rather than empty string title is passed\n');
sel = viscore.dataSelector([]);
fig4 =  @() visviews.plotConfig(sel, []);
assertExceptionThrown(fig4, 'MATLAB:hg:set_chck:Matrix_to_string_set_check_fcn:ExpectedString');

drawnow
if values.deleteFigures
    delete(fig1);
    delete(fig2);
    delete(fig3);
    delete(fig4);
end