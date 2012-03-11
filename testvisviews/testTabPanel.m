function test_suite = testTabPanel %#ok<STOUT>
% Unit tests for tabPanel
initTestSuite;

function testNormalConstructor %#ok<DEFNU>
% Unit test for visviews.tabPanel constructor
fprintf('\nUnit tests for visviews.tabPanel valid constructor\n');

fprintf('It should construct a valid tab panel when only parent passed\n');
hf = figure('Name', 'Creates a valid panel when only parent is passed');
visviews.tabPanel(hf, [], []);
drawnow
delete(hf);


function testInvalidParentConstructor %#ok<DEFNU>
% Unit test for visviews.tabPanel bad constructor
fprintf('\nUnit tests for visviews.tabPanel invalid constructor parameters\n');

fprintf('It should throw an exception when no parameters are passed\n');
sfig = figure('Name', 'Invalid constructor');
f = @() visviews.tabPanel();
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when an invalid parameter is passed\n');
f = @() visviews.tabPanel(3.2, [], []);
assertExceptionThrown(f,  'MATLAB:hg:dt_conv:Matrix_to_HObject:BadHandle');

fprintf('It should throw an exception when only one parameter is passed\n');
f = @() visviews.tabPanel(sfig);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when only two parameters are passed\n');
f = @() visviews.tabPanel(sfig, []);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when more than three parameters are passed\n');
f = @() visviews.tabPanel(sfig, [], [], []);
assertExceptionThrown(f, 'MATLAB:maxrhs');
delete(sfig);


function testReset %#ok<DEFNU>
% Unit test for visviews.tabPanel reset method
fprintf('\nUnit tests for visviews.tabPanel reset method\n');

fprintf('It should allow reset with no parameters\n');
hf = figure('Name', 'Allows reset with no parameters');
tp = visviews.tabPanel(hf, [], []);
tp.reset();
drawnow


fprintf('It should allow reset when a list of plots and a manager are specified\n');
hf1 = figure('Name', 'Allows reset when manager and list of plots passed');
tp = visviews.tabPanel(hf1, [], []);
defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
   viewTestClass.getDefaultFunctionsNoSqueeze(), []);
fMan = viscore.dataManager();
fMan.putObjects(defaults);
tp.setFunctions(fMan.getEnabledObjects(''));
plots = visviews.plotObj.createObjects( ...
           'visviews.plotObj', viewTestClass.getDefaultPlotsSummaryOnly(), []);
man = viscore.dataManager();
tp.reset(man, plots);
drawnow


fprintf('It should allow reset with fewer functions so that tabs are removed\n');
hf2 = figure('Name', 'Allows removal of tabs');
tp = visviews.tabPanel(hf2, [], []);
defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
    viewTestClass.getDefaultFunctionsNoSqueeze());
fMan = viscore.dataManager();
fMan.putObjects(defaults);
tp.setFunctions(fMan.getEnabledObjects(''));
plots = visviews.plotObj.createObjects( ...
           'visviews.plotObj', viewTestClass.getDefaultPlotsSummaryOnly(), []);
man = viscore.dataManager();
tp.reset(man, plots);
defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
    viewTestClass.getDefaultFunctionsNoSqueeze(), []);
fMan = viscore.dataManager();
fMan.putObjects(defaults{1});
tp.setFunctions(fMan.getEnabledObjects(''));
tp.reset(man, plots);
drawnow
delete(hf);
delete(hf1);
delete(hf2);


function testPlot %#ok<DEFNU>
% Unit test for visviews.tabPanel plot method
fprintf('\nUnit tests for visviews.tabPanel plot method\n');

fprintf('It should allow plot with a full slice\n');
hf = figure('Name', 'Plotting a full slice');
tp = visviews.tabPanel(hf, [], []);
data = random('exp', 2, [32, 1000, 20]);
vdata = viscore.blockedData(data, 'Random exponential');
defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
    viewTestClass.getDefaultFunctionsNoSqueeze(), []);
fMan = viscore.dataManager();
fMan.putObjects(defaults);
func = fMan.getEnabledObjects('');
thisFunc = func{1};
thisFunc.setData(vdata);
tp.setFunctions(func);
plots = visviews.plotObj.createObjects( ...
           'visviews.plotObj', viewTestClass.getDefaultPlotsSummaryOnly(), []);
man = viscore.dataManager();
tp.reset(man, plots);
slice1 = viscore.dataSlice('Slices', {':', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
tp.plot(vdata, slice1);
drawnow
delete(hf);

function testReposition %#ok<DEFNU>
% Unit test for visviews.tabPanel reposition method
fprintf('\nUnit tests for visviews.tabPanel reposition method\n');

fprintf('It should allow repositioning after reset and plot\n');
hf = figure('Name', 'visview.tabPanel testing repositioning');
tp = visviews.tabPanel(hf, [], []);
data = random('exp', 2, [32, 1000, 20]);
vdata = viscore.blockedData(data, 'Random exponential');
defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
    viewTestClass.getDefaultFunctionsNoSqueeze(), []);
fMan = viscore.dataManager();
fMan.putObjects(defaults);
func = fMan.getEnabledObjects('');

tp.setFunctions(func);
plots = visviews.plotObj.createObjects( ...
           'visviews.plotObj', viewTestClass.getDefaultPlotsSummaryOnly(), []);
man = viscore.dataManager();
tp.reset(man, plots);
slice1 = viscore.dataSlice('Slices', {':', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
tp.plot(vdata, slice1);
gaps = tp.getGaps();
tp.reposition(gaps);
drawnow
delete(hf);


function testMergeSources %#ok<DEFNU>
% Unit test for visviews.tabPanel mergeSources method
fprintf('\nUnit tests for visviews.tabPanel mergeSources method\n');

fprintf('It should allow child sources to be merged\n');
hf = figure('Name', 'visview.tabPanel merging sources');
tp = visviews.tabPanel(hf, [], []);
data = random('exp', 2, [32, 1000, 20]);
vdata = viscore.blockedData(data, 'Random exponential');
defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
    viewTestClass.getDefaultFunctionsNoSqueeze(), []);
fMan = viscore.dataManager();
fMan.putObjects(defaults);
func = fMan.getEnabledObjects('');
thisFunc = func{1};
thisFunc.setData(vdata);
tp.setFunctions(func);
plots = visviews.plotObj.createObjects( ...
           'visviews.plotObj', viewTestClass.getDefaultPlotsSummaryOnly(), []);
man = viscore.dataManager();
tp.reset(man, plots);
slice1 = viscore.dataSlice('Slices', {':', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
tp.plot(vdata, slice1);
gaps = tp.getGaps();
tp.reposition(gaps);
keys = tp.getSourceMapKeys();
fprintf('\nSources:\n');
for k = 1:length(keys)
    visviews.clickable.printStructure(tp.getSourceMap(keys{k}));
end
fprintf('\nUnmapped sources:\n')
uKeys = tp.getUnmappedKeys();
for k = 1:length(uKeys)
    fprintf('%s: \n', uKeys{k} );
    values = tp.getUnmapped(uKeys{k});
    for j = 1:length(values)
      s = tp.getSourceMap(values{j});
      visviews.clickable.printStructure(s);  
    end
end
assertEqual(length(keys), 6);
drawnow
delete(hf);
