function test_suite = testVerticalPanel %#ok<STOUT>
% Unit tests for verticalPanel
initTestSuite;

function testNormalConstructor %#ok<DEFNU>
% Unit test for visviews.verticalPanel normal constructor
fprintf('\nUnit tests for visviews.verticalPanel valid constructor\n');

fprintf('It should construct a valid vertical panel when only parent is non empty\n');
hf = figure('Name', 'Creates a panel when only parent is passed');
visviews.verticalPanel(hf, [], []);
drawnow
delete(hf);

function testInvalidParentConstructor %#ok<DEFNU>
% Unit test for visviews.verticalPanel bad constructor
fprintf('\nUnit tests for visviews.verticalPanel invalid constructor parameters\n');

fprintf('It should throw an exception when no parameters are passed\n');
f = @() visviews.verticalPanel();
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when the first parameter is invalid\n');
f = @() visviews.verticalPanel(3.2, []);
assertExceptionThrown(f, 'MATLAB:hg:dt_conv:Matrix_to_HObject:BadHandle');

fprintf('It should throw an exception when only one parameter is passed\n');
sfig = figure('Name', 'Invalid constructor');
f = @() visviews.verticalPanel(sfig);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when only two parameters are passed\n');
f = @() visviews.verticalPanel(sfig, []);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when more than three parameters are passed\n');
f = @() visviews.verticalPanel(sfig, [], [], []);
assertExceptionThrown(f, 'MATLAB:maxrhs');
delete(sfig);

function testGetSourceMapKeys %#ok<DEFNU>
% Unit test visviews.verticalPanel getSourceMapKeys
fprintf('\nUnit tests for visviews.verticalPanel getSourceMapKeys\n')

fprintf('It should extract the sources from its child plots\n');
hf = figure('Name', 'visviews.verticalPanel test extracting sources from children');
tp = visviews.horizontalPanel(hf, [], []);
defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
    viewTestClass.getDefaultFunctionsNoSqueeze());
fMan = viscore.dataManager();
fMan.putObjects(defaults);
plots = visviews.plotObj.createObjects( ...
           'visviews.plotObj', viewTestClass.getDefaultPlotsDetailOnly(), []);
man = viscore.dataManager();
tp.reset(man, plots);
keys = tp.getSourceMapKeys();
assertTrue(isa(keys, 'cell'));
assertEqual(length(keys), 2);
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

function testPlot %#ok<DEFNU>
% Unit test visviews.verticalPanel plot
fprintf('\nUnit tests for visviews.verticalPanel plot method\n')

fprintf('It should produce a plot for a slice in dimension 3\n');
hf = figure('Name', 'visviews.verticalPanel slice of dimension 3');
tp = visviews.verticalPanel(hf, [], []);
data = random('exp', 2, [32, 1000, 20]);
vdata = viscore.blockedData(data, 'Random exponential');
plots = visviews.plotObj.createObjects( ...
           'visviews.plotObj', viewTestClass.getDefaultPlotsDetailOnly(), []);

man = viscore.dataManager();
tp.reset(man, plots);
keyfun = @(x) x.('ShortName');
defFuns= visfuncs.functionObj.createObjects( ...
    'visfuncs.functionObj', viewTestClass.getDefaultFunctionsNoSqueeze(), keyfun);
fun = defFuns{1};
slice1 = viscore.dataSlice('Slices', {':', ':', '3'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
tp.plot(vdata, fun, slice1);
gaps = tp.getGaps();
tp.reposition(gaps);
drawnow
delete(hf);
