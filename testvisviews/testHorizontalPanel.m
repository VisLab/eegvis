function test_suite = testHorizontalPanel %#ok<STOUT>
% Unit tests for horizontalPanel
initTestSuite;

function values = setup %#ok<DEFNU>
defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
    viewTestClass.getDefaultFunctionsNoSqueeze());
fMan = viscore.dataManager();
fMan.putObjects(defaults);
func = fMan.getEnabledObjects('block');
values.fun = func{1};
values.plots = visviews.plotObj.createObjects( 'visviews.plotObj', ...
    viewTestClass.getDefaultPlotsSummaryOnly(), []);
values.man = viscore.dataManager();
values.slice = viscore.dataSlice('Slices', {':', ':', ':'}, ...
        'DimNames', {'Channel', 'Sample', 'Window'});
load('EEG.mat'); 
values.bData = viscore.blockedData(EEG.data, 'EEG', ...
    'SampleRate', EEG.srate);    
values.deleteFigures = false;

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testNormalConstructor(values) %#ok<DEFNU>
% Unit test for visviews.horizontalPanel constructor
fprintf('\nUnit tests for visviews.horizontalPanel valid constructor\n');

fprintf('It should construct a valid block box plot when only parent passed\n');
fig1 = figure('Name', 'Valid panel when only parent passed');
visviews.horizontalPanel(fig1, [], []);

drawnow
if values.deleteFigures
  delete(fig1);
end

function testInvalidConstructor(values) %#ok<DEFNU>
% Unit test for visviews.horizontalPanel bad constructor
fprintf('\nUnit tests for visviews.horizontalPanel invalid constructor parameters\n');

fprintf('It should throw an exception when no parameters are passed\n');
fig1 = figure('Name', 'Horizontal panel bad constructor');
f = @() visviews.horizontalPanel();
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when only one parameter is passed\n');
f = @() visviews.horizontalPanel(fig1);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when only two parameters are passed\n');
f = @() visviews.horizontalPanel(fig1, []);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when more than three parameters are passed\n');
f = @() visviews.horizontalPanel(fig1, [], [], []);
assertExceptionThrown(f, 'MATLAB:maxrhs');

drawnow
if values.deleteFigures
  delete(fig1);
end

function testReset(values) %#ok<DEFNU>
% Unit test for visviews.horizontalPanel reset method
fprintf('\nUnit tests for visviews.horizontalPanel reset method\n');

fprintf('It should allow empty parameters\n');
fig1 = figure('Name', 'Empty parameters allows reset');
hp1 = visviews.horizontalPanel(fig1, [], []);
hp1.reset([], []);

fprintf('It should allow a manager and plots list parameters\n');
fig2 = figure('Name', 'Accommodates manager and plot list parameters');
hp2 = visviews.horizontalPanel(fig2, [], []);
hp2.reset(values.man, values.plots);
gaps = hp2.getGaps();
hp2.reposition(gaps);

drawnow
if values.deleteFigures
    delete(fig1);
    delete(fig2);
end

function testPlot(values) %#ok<DEFNU>
% Unit test for visviews.horizontalPanel plot method
fprintf('\nUnit tests for visviews.horizontalPanel plot method\n');

fprintf('It should allow plotting with an non empty slice\n');
fig1 = figure('Name', 'Handles plotting with non empty slice');
hp1 = visviews.horizontalPanel(fig1, [], []);
plots = visviews.plotObj.createObjects( ...
           'visviews.plotObj', viewTestClass.getDefaultPlots(), []);
man = viscore.dataManager();
hp1.reset(man, plots(1:3));
hp1.plot(values.bData, values.fun, values.slice);
gaps = hp1.getGaps();
hp1.reposition(gaps);

drawnow
if values.deleteFigures
    delete(fig1);
end

function testGetSourceMap(values) %#ok<DEFNU>
% Unit test for visviews.horizontalPanel getSourceMap method
fprintf('\nUnit tests for visviews.horizontalPanel getSourceMap method\n');

fprintf('It should have the correct items in the source map\n');
fig1 = figure('Name', 'Handles source maps and linked panels');
hp1 = visviews.horizontalPanel(fig1, [], []);
plots = visviews.plotObj.createObjects( ...
           'visviews.plotObj', viewTestClass.getDefaultPlotsSummaryOnly(), []);
man = viscore.dataManager();
hp1.reset(man, plots);
keys = hp1.getSourceMapKeys();
assertTrue(isa(keys, 'cell'));
assertEqual(length(keys), 3);
keys = hp1.getSourceMapKeys();
fprintf('Sources:\n');
for k = 1:length(keys)
    visviews.clickable.printStructure(hp1.getSourceMap(keys{k}));
end
fprintf('\nUnmapped sources:\n')
uKeys = hp1.getUnmappedKeys();
for k = 1:length(uKeys)
    fprintf('%s: \n', uKeys{k} );
    tvalues = hp1.getUnmapped(uKeys{k});
    for j = 1:length(tvalues)
      s = hp1.getSourceMap(tvalues{j});
      visviews.clickable.printStructure(s);  
    end
end

drawnow
if values.deleteFigures
    delete(fig1);
end



