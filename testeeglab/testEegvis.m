function test_suite = testEegvis %#ok<STOUT>
% Unit tests for eegvis 
initTestSuite;

function testNormalConstructor %#ok<DEFNU>
% Unit test for eegvis constructor
fprintf('\nUnit tests for eegbrowse valid constructor\n');

fprintf('It should create a valid figure when a 3D data array is passed\n');
data = random('exp', 2, [32, 1000, 20]);
bv = eegvis(data);
drawnow
assertTrue(ishandle(bv));

fprintf('It should create a valid figure when a functions structure is passed for ''Functions'' in the constructor\n');
f = eegbrowse.getDefaultFunctions();
bv1 = eegvis(data, 'Functions', f); 
drawnow
assertTrue(ishandle(bv1));

fprintf('It should produce a valid figure when a function manager is passed for ''Functions'' in the constructor\n');
fMan = viscore.dataManager();
fMan.putObjects(visfuncs.functionObj.createObjects('visfuncs.functionObj', f));
bv2 = eegvis(data, 'Functions', fMan); 
drawnow
assertTrue(ishandle(bv2));

fprintf('It should create a valid figure when a functions object list is passed for ''Furnctions'' in the constructor\n');
fns = visfuncs.functionObj.createObjects('visfuncs.functionObj', f);
bv3 = eegvis(data, 'Functions', fns); 
drawnow
assertTrue(ishandle(bv3));

fprintf('It should create a valid figure when a plot structure is passed for ''Plots'' in the constructor\n');
p = eegbrowse.getDefaultPlots();
bv4 = eegvis(data, 'Plots', p); 
assertTrue(ishandle(bv4));
drawnow

fprintf('It should create a valid figure when a plots object list is passed for ''Plots'' in the constructor\n');
pls = visviews.plotObj.createObjects('visviews.plotObj', p);
assertEqual(length(p), length(pls));
bv5 = eegvis(data, 'Plots', pls); 
assertTrue(ishandle(bv5));
drawnow

fprintf('It should create a valid figure when a plot manager is passed for ''Plots'' in the constructor\n');
pMan = viscore.dataManager();
pMan.putObjects(pls);
bv6 = eegvis(data, 'Plots', pMan); 
assertTrue(ishandle(bv6));
drawnow


fprintf('It should create a valid figure when a configurable object is passed for ''Properties'' in the constructor\n');
testSettings = viscore.dataManager();
s = viewTestClass.getDefaultProperties();
s(1).Value = 'ABC';
confObj = visprops.configurableObj('visviews.dualView', s, 'visviews.dualView');
testSettings.putObject('visviews.dualView', confObj); 
bv7 = eegvis(data, 'Properties', testSettings);
assertTrue(ishandle(bv7));
drawnow

fprintf('It should ignore non configurable objects when a cell array of configurable objects is passed for ''Properties'' in the constructor\n'); 
sNext = visviews.blockBoxPlot.getDefaultProperties();
confObj2 = visprops.configurableObj('Block box', sNext, 'visviews.blockBoxPlot');
propList = {confObj, 'Test it', confObj2};
bv8 = eegvis(data, 'Properties', propList);
assertTrue(ishandle(bv8));

delete(bv);
delete(bv1);
delete(bv2);
delete(bv3);
delete(bv4);
delete(bv5);
delete(bv6);
delete(bv7);
delete(bv8);


