function test_suite = testFunctionConfig %#ok<STOUT>
% Unit tests for visfunc.functionConfig
initTestSuite;

function values = setup %#ok<DEFNU>
values.deleteFigures = true;

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testConstructor(values) %#ok<DEFNU>
% Unit test for visfunc.functionConfig constructor
fprintf('\nUnit tests for visfunc.functionConfig valid constructor\n');

fprintf('It should construct a valid function configuration when a selector and title are passed as parameters\n');
keyfun = @(x) x.('ShortName');
defaults = visfuncs.functionObj.createObjects( ...
    'visfuncs.functionObj', functionTestClass.getDefaultFunctionsNoSqueeze(), keyfun);
selector = viscore.dataSelector('visfuncs.functionConfig');
selector.getManager().putObjects(defaults);
title = 'Test function configuration';
fc1 = visfuncs.functionConfig(selector, title);
assertTrue(isvalid(fc1));
drawnow
fprintf('It should construct a valid function configuration with an empty title');
fc2 = visfuncs.functionConfig(selector, title);
assertTrue(isvalid(fc2));
drawnow
if values.deleteFigures
   delete(fc1);
   delete(fc2);
end


function testInvalidConstructor(values) %#ok<DEFNU>
% Unit test for visfuncs.functionConfig constructor
fprintf('\nUnit tests for visfuncs.functionConfig invalid constructor\n');

fprintf('It should throw an exception when no parameters are passed\n');
fc1 = @() visfuncs.functionConfig();
assertAltExceptionThrown(fc1, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should thrown an exception when an empty selector is passed\n');
fc2 =  @() visfuncs.functionConfig([], 'Empty selector test');
assertExceptionThrown(fc2, 'dataConfig:InvalidParameters');

fprintf('It should thrown an exception when a selector with wrong config type is passed\n');
sel = viscore.dataSelector([]);
fc3 =  @() visfuncs.functionConfig(sel, 'Wrong selector type test');
assertExceptionThrown(fc3, 'functionConfig:InvalidParameters');
