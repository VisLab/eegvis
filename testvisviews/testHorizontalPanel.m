function test_suite = testHorizontalPanel %#ok<STOUT>
% Unit tests for horizontalPanel
initTestSuite;

function testNormalConstructor %#ok<DEFNU>
% Unit test for visviews.horizontalPanel constructor
fprintf('\nUnit tests for visviews.horizontalPanel valid constructor\n');

fprintf('It should construct a valid block box plot when only parent passed\n');
hf = figure('Name', 'Valid panel when only parent passed');
visviews.horizontalPanel(hf, [], []);
drawnow
delete(hf);

function testInvalidParentConstructor %#ok<DEFNU>
% Unit test for visviews.horizontalPanel bad constructor
fprintf('\nUnit tests for visviews.horizontalPanel invalid constructor parameters\n');

fprintf('It should throw an exception when no parameters are passed\n');
sfig = figure('Name', 'Bad constructor');
f = @() visviews.horizontalPanel();
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when only one parameter is passed\n');
f = @() visviews.horizontalPanel(sfig);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when only two parameters are passed\n');
f = @() visviews.horizontalPanel(sfig, []);

fprintf('It should throw an exception when more than three parameters are passed\n');
f = @() visviews.horizontalPanel(sfig, [], [], []);
assertExceptionThrown(f, 'MATLAB:maxrhs');
delete(sfig);

function testReset %#ok<DEFNU>
% Unit test for visviews.horizontalPanel reset method
fprintf('\nUnit tests for visviews.horizontalPanel reset method\n');

fprintf('It should have allow empty parameters\n');
hf = figure('Name', 'Empty parameters allows reset');
tp = visviews.horizontalPanel(hf, [], []);
tp.reset([], []);
drawnow


fprintf('It should allow a manager and plots list parameters\n');
hf1 = figure('Name', 'Accommodates manager and plot list parameters');
tp = visviews.horizontalPanel(hf1, [], []);
defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
    viewTestClass.getDefaultFunctionsNoSqueeze());
fMan = viscore.dataManager();
fMan.putObjects(defaults);
plots = visviews.plotObj.createObjects( 'visviews.plotObj', ...
    viewTestClass.getDefaultPlotsSummaryOnly(), []);
man = viscore.dataManager();
tp.reset(man, plots);
drawnow
delete(hf);
delete(hf1);

function testPlot %#ok<DEFNU>
% Unit test for visviews.horizontalPanel plot method
fprintf('\nUnit tests for visviews.horizontalPanel plot method\n');

fprintf('It should allow plotting with an non empty slice\n');
hf = figure('Name', 'Handles plotting with non empty slice');
tp = visviews.horizontalPanel(hf, [], []);
data = random('exp', 2, [32, 1000, 20]);
vdata = viscore.blockedData(data, 'Random exponential');
defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
    viewTestClass.getDefaultFunctionsNoSqueeze(), []);
fMan = viscore.dataManager();
fMan.putObjects(defaults);
func = fMan.getEnabledObjects('');
thisFunc = func{1};
plots = visviews.plotObj.createObjects( ...
           'visviews.plotObj', viewTestClass.getDefaultPlots(), []);
plots = plots(1:3);
man = viscore.dataManager();
tp.reset(man, plots);
slice1 = viscore.dataSlice('Slices', {':', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
tp.plot(vdata, thisFunc, slice1);
drawnow
delete(hf);

function testGetSourceMap %#ok<DEFNU>
% Unit test for visviews.horizontalPanel getSourceMap method
fprintf('\nUnit tests for visviews.horizontalPanel getSourceMap method\n');

fprintf('It should have the correct items in the source map\n');
hf = figure('Name', 'Handles source maps and linked panels');
tp = visviews.horizontalPanel(hf, [], []);
data = random('exp', 2, [32, 1000, 20]);
vdata = viscore.blockedData(data, 'Random exponential');
defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
    viewTestClass.getDefaultFunctionsNoSqueeze());
fMan = viscore.dataManager();
fMan.putObjects(defaults);
func = fMan.getEnabledObjects('');
thisFunc = func{1};
thisFunc.setData(vdata);
plots = visviews.plotObj.createObjects( ...
           'visviews.plotObj', viewTestClass.getDefaultPlotsSummaryOnly(), []);
man = viscore.dataManager();
tp.reset(man, plots);
keys = tp.getSourceMapKeys();
assertTrue(isa(keys, 'cell'));
assertEqual(length(keys), 3);
keys = tp.getSourceMapKeys();
fprintf('Sources:\n');
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
delete(hf);

function testReposition %#ok<DEFNU>
% Unit test for visviews.horizontalPanel reposition method
fprintf('\nUnit tests for visviews.horizontalPanel reposition method\n');

fprintf('It should allow reposition after plotting\n');
hf = figure('Name', 'Repositions the panel');
tp = visviews.horizontalPanel(hf, [], []);
data = random('exp', 2, [32, 1000, 20]);
vdata = viscore.blockedData(data, 'Random exponential');
defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
    viewTestClass.getDefaultFunctionsNoSqueeze());
fMan = viscore.dataManager();
fMan.putObjects(defaults);
func = fMan.getEnabledObjects('');
thisFunc = func{1};
plots = visviews.plotObj.createObjects( ...
           'visviews.plotObj', viewTestClass.getDefaultPlots(), []);
plots = plots(1:3);
man = viscore.dataManager();
tp.reset(man, plots);
slice1 = viscore.dataSlice('Slices', {':', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
tp.plot(vdata, thisFunc, slice1);
gaps = tp.getGaps();
tp.reposition(gaps);
drawnow
delete(hf);

