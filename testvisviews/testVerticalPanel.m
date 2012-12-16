function test_suite = testVerticalPanel %#ok<STOUT>
% Unit tests for verticalPanel
initTestSuite;

function values = setup %#ok<DEFNU>
defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
    viewTestClass.getDefaultFunctionsNoSqueeze());
fMan = viscore.dataManager();
fMan.putObjects(defaults);
func = fMan.getEnabledObjects('block');
values.fun = func{1};
values.plots = visviews.plotObj.createObjects( ...
           'visviews.plotObj', viewTestClass.getDefaultPlotsDetailOnly(), []);
values.man = viscore.dataManager();
values.slice = viscore.dataSlice('Slices', {':', ':', ':'}, ...
        'DimNames', {'Channel', 'Sample', 'Window'});
load('EEG.mat'); 
values.bData = viscore.blockedData(EEG.data, 'EEG', ...
    'SampleRate', EEG.srate);    
values.deleteFigures = true;

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testNormalConstructor(values) %#ok<DEFNU>
% Unit test for visviews.verticalPanel normal constructor
fprintf('\nUnit tests for visviews.verticalPanel valid constructor\n');

fprintf('It should construct a valid vertical panel when only parent is non empty\n');
fig1 = figure('Name', 'Creates a panel when only parent is passed');
visviews.verticalPanel(fig1, [], []);

drawnow
if values.deleteFigures
  delete(fig1);
end

function testInvalidConstructor(values) %#ok<DEFNU>
% Unit test for visviews.verticalPanel bad constructor
fprintf('\nUnit tests for visviews.verticalPanel invalid constructor parameters\n');

fprintf('It should throw an exception when no parameters are passed\n');
f = @() visviews.verticalPanel();
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when the first parameter is invalid\n');
f = @() visviews.verticalPanel(3.2, []);
assertExceptionThrown(f, 'MATLAB:hg:dt_conv:Matrix_to_HObject:BadHandle');

fprintf('It should throw an exception when only one parameter is passed\n');
fig1 = figure('Name', 'Invalid constructor');
f = @() visviews.verticalPanel(fig1);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when only two parameters are passed\n');
f = @() visviews.verticalPanel(fig1, []);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when more than three parameters are passed\n');
f = @() visviews.verticalPanel(fig1, [], [], []);
assertExceptionThrown(f, 'MATLAB:maxrhs');

drawnow
if values.deleteFigures
  delete(fig1);
end

function testGetSourceMapKeys(values) %#ok<DEFNU>
% Unit test visviews.verticalPanel getSourceMapKeys
fprintf('\nUnit tests for visviews.verticalPanel getSourceMapKeys\n')

fprintf('It should extract the sources from its child plots\n');
fig1 = figure('Name', 'visviews.verticalPanel test extracting sources from children');
vp1 = visviews.horizontalPanel(fig1, [], []);
vp1.reset(values.man, values.plots);
keys = vp1.getSourceMapKeys();
assertTrue(isa(keys, 'cell'));
assertEqual(length(keys), 2);
keys = vp1.getSourceMapKeys();
fprintf('Sources:\n');
for k = 1:length(keys)
    visviews.clickable.printStructure(vp1.getSourceMap(keys{k}));
end
fprintf('\nUnmapped sources:\n')
uKeys = vp1.getUnmappedKeys();
for k = 1:length(uKeys)
    fprintf('%s: \n', uKeys{k} );
    tvalues = vp1.getUnmapped(uKeys{k});
    for j = 1:length(tvalues)
      s = vp1.getSourceMap(tvalues{j});
      visviews.clickable.printStructure(s);  
    end
end

drawnow
if values.deleteFigures
    delete(fig1);
end

function testPlot(values) %#ok<DEFNU>
% Unit test visviews.verticalPanel plot
fprintf('\nUnit tests for visviews.verticalPanel plot method\n')

fprintf('It should produce a plot for a slice in dimension 3\n');
fig1 = figure('Name', 'visviews.verticalPanel slice of dimension 3');
vp1 = visviews.verticalPanel(fig1, [], []);
vp1.reset(values.man, values.plots);
vp1.plot(values.bData, values.fun, values.slice);
gaps = vp1.getGaps();
vp1.reposition(gaps);

drawnow
if values.deleteFigures
    delete(fig1);
end