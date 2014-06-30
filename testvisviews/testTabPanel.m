function test_suite = testTabPanel %#ok<STOUT>
% Unit tests for tabPanel
initTestSuite;

function values = setup %#ok<DEFNU>
defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
    viewTestClass.getDefaultFunctionsNoSqueeze());
fMan = viscore.dataManager();
fMan.putObjects(defaults);
values.fMan = fMan;
func = fMan.getEnabledObjects('block');
values.fun = func{1};
values.slice = viscore.dataSlice('Slices', {':', ':', ':'}, ...
        'DimNames', {'Channel', 'Sample', 'Window'});
load('EEG.mat'); 
values.bData = viscore.memoryData(EEG.data, 'EEG', ...
    'SampleRate', EEG.srate); 

values.plots = visviews.plotObj.createObjects( ...
           'visviews.plotObj', viewTestClass.getDefaultPlotsSummaryOnly(), []);
values.man = viscore.dataManager();
values.deleteFigures = true;

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testNormalConstructor(values) %#ok<DEFNU>
% Unit test for visviews.tabPanel constructor
fprintf('\nUnit tests for visviews.tabPanel valid constructor\n');

fprintf('It should construct a valid tab panel when only parent passed\n');
fig1 = figure('Name', 'Creates a valid panel when only parent is passed');
visviews.tabPanel(fig1, [], []);

drawnow
if values.deleteFigures
  delete(fig1);
end

function testInvalidConstructor(values) %#ok<DEFNU>
% Unit test for visviews.tabPanel bad constructor
fprintf('\nUnit tests for visviews.tabPanel invalid constructor parameters\n');

fprintf('It should throw an exception when no parameters are passed\n');
fig1 = figure('Name', 'Invalid constructor');
f = @() visviews.tabPanel();
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when an invalid parameter is passed\n');
f = @() visviews.tabPanel(3.2, [], []);
assertExceptionThrown(f,  'MATLAB:hg:dt_conv:Matrix_to_HObject:BadHandle');

fprintf('It should throw an exception when only one parameter is passed\n');
f = @() visviews.tabPanel(fig1);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when only two parameters are passed\n');
f = @() visviews.tabPanel(fig1, []);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when more than three parameters are passed\n');
f = @() visviews.tabPanel(fig1, [], [], []);
assertExceptionThrown(f, 'MATLAB:maxrhs');

drawnow
if values.deleteFigures
  delete(fig1);
end

function testReset(values) %#ok<DEFNU>
% Unit test for visviews.tabPanel reset method
fprintf('\nUnit tests for visviews.tabPanel reset method\n');

fprintf('It should allow reset with no parameters (-- see warning)\n');
fig1 = figure('Name', 'Allows reset with no parameters');
tp1 = visviews.tabPanel(fig1, [], []);
tp1.reset();

fprintf('It should allow reset when a list of plots and a manager are specified\n');
fig2 = figure('Name', 'Allows reset when manager and list of plots passed');
tp2 = visviews.tabPanel(fig2, [], []);
tp2.setFunctions(values.fMan.getEnabledObjects(''));
tp2.reset(values.man, values.plots);
gaps = tp2.getGaps();
tp2.reposition(gaps);

fprintf('It should allow reset with fewer functions so that tabs are removed\n');
fig3 = figure('Name', 'Allows removal of tabs');
tp3 = visviews.tabPanel(fig3, [], []);
tp3.setFunctions(values.fMan.getEnabledObjects(''));
tp3.reset(values.man, values.plots);
defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
    viewTestClass.getDefaultFunctionsNoSqueeze(), []);
fMan = viscore.dataManager();
fMan.putObjects(defaults{1});
tp3.setFunctions(fMan.getEnabledObjects(''));
tp3.reset(values.man, values.plots);
gaps = tp3.getGaps();
tp3.reposition(gaps);

drawnow
if values.deleteFigures
    delete(fig1);
    delete(fig2);
    delete(fig3);
end

function testPlot(values) %#ok<DEFNU>
% Unit test for visviews.tabPanel plot method
fprintf('\nUnit tests for visviews.tabPanel plot method\n');

fprintf('It should allow plot with a full slice\n');
fig1 = figure('Name', 'Plotting a full slice');
tp1 = visviews.tabPanel(fig1, [], []);
tp1.setFunctions(values.fMan.getEnabledObjects(''));
tp1.reset(values.man, values.plots);
tp1.plot(values.bData, values.slice);

drawnow
if values.deleteFigures
    delete(fig1);
end

function testMergeSources(values) %#ok<DEFNU>
% Unit test for visviews.tabPanel mergeSources method
fprintf('\nUnit tests for visviews.tabPanel mergeSources method\n');

fprintf('It should allow child sources to be merged\n');
fig1 = figure('Name', 'visview.tabPanel merging sources');
tp1 = visviews.tabPanel(fig1, [], []);
tp1.setFunctions(values.fMan.getEnabledObjects(''));
tp1.reset(values.man, values.plots);
tp1.plot(values.bData, values.slice);
gaps = tp1.getGaps();
tp1.reposition(gaps);
keys = tp1.getSourceMapKeys();
fprintf('\nSources:\n');
for k = 1:length(keys)
    visviews.clickable.printStructure(tp1.getSourceMap(keys{k}));
end
fprintf('\nUnmapped sources:\n')
uKeys = tp1.getUnmappedKeys();
for k = 1:length(uKeys)
    fprintf('%s: \n', uKeys{k} );
    tvalues = tp1.getUnmapped(uKeys{k});
    for j = 1:length(tvalues)
      s = tp1.getSourceMap(tvalues{j});
      visviews.clickable.printStructure(s);  
    end
end
assertEqual(length(keys), 6);

drawnow
if values.deleteFigures
    delete(fig1);
end
