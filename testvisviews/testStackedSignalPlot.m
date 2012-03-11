function test_suite = testStackedSignalPlot %#ok<STOUT>
% Unit tests for visviews.stackedSignalPlot
initTestSuite;

function testNormalConstructor %#ok<DEFNU>
% testStackedSignalPlot unit test for visviews.stackedSignalPlot constructor
fprintf('\nUnit tests for visviews.stackedSignalPlot valid constructor\n');

fprintf('It should construct a valid stacked signal plot when only parent passed')
sfig = figure('Name', 'Creates a panel when only parent is passed');
sp = visviews.stackedSignalPlot(sfig, [], []);
assertTrue(isvalid(sp));
drawnow
delete(sfig);

function testBadConstructor %#ok<DEFNU>
% testStackedSignalPlot unit test for stackedSignalPlot constructor
fprintf('\nUnit tests for visviews.stackedSignalPlot invalid constructor parameters\n');

fprintf('It should throw an exception when no paramters are passed\n');
f = @() visviews.stackedSignalPlot();
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when only one parameter is passed\n');
sfig = figure('Name', 'Invalid constructor');
f = @() visviews.stackedSignalPlot(sfig);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when only two parameters are passed\n');
f = @() visviews.stackedSignalPlot(sfig, []);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});


fprintf('It should throw an exception when more than three parameters are passed\n');
f = @() visviews.stackedSignalPlot(sfig, [], [], []);
assertExceptionThrown(f, 'MATLAB:maxrhs');
delete(sfig);

function testGetDefaultProperties %#ok<DEFNU>
% Unit test for visviews.stackedSignalPlot getDefaultProperties
fprintf('\nUnit tests for visviews.stackedSignalPlot getDefaultProperties\n');
fprintf('It should have a getDefaultProperties method that returns a structure\n');
s = visviews.stackedSignalPlot.getDefaultProperties();
assertTrue(isa(s, 'struct'));

function testPlot %#ok<DEFNU>
% Unit test visviews.stackedSignalPlot plot
fprintf('\nUnit tests for visviews.stackedSignalPlot plot method\n')
% Generate some data for testing
data = random('normal', 0, 1, [32, 1000, 20]);
nSamples = 1000;
nChans = 32;
nWindows = 20;
x = linspace(0, nWindows, nSamples*nWindows);

a = 10*rand(nChans, 1);
p = pi*rand(nChans, 1);
dataSmooth = 0.01*random('normal', 0, 1, [nChans, nSamples*nWindows]);
for k = 1:nChans
    dataSmooth(k, :) = dataSmooth(k, :) + a(k)*cos(2*pi*x + p(k));
end
dataSmooth(1, :) = 3*dataSmooth(1, :);
dataSmooth = dataSmooth';
dataSmooth = reshape(dataSmooth, [nSamples, nWindows, nChans]);
dataSmooth = permute(dataSmooth, [3, 1, 2]);

fprintf('It should produce a plot for a slice along dimension 3\n');
sfig = figure('Name', 'visviews.stackedSignalPlot test plot slice window');
sp = visviews.stackedSignalPlot(sfig, [], []);
sp.SignalScale = 8.0;
assertTrue(isvalid(sp));
testVD = viscore.blockedData(data, 'Rand1');
keyfun = @(x) x.('ShortName');
defFuns= visfuncs.functionObj.createObjects( ...
    'visfuncs.functionObj', viewTestClass.getDefaultFunctions(), keyfun);
slice1 = viscore.dataSlice('Slices', {':', ':', '1'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
fun = defFuns{1};
sp.plot(testVD, fun, slice1);
gaps = sp.getGaps();
sp.reposition(gaps);
drawnow
fprintf('It should allow callbacks to be registered\n')
sp.registerCallbacks([]);


fprintf('It should produce a plot when the data is epoched\n');
testVD1 = viscore.blockedData(data, 'Rand1', 'Epoched', true, ...
            'SampleRate', 250);
assertTrue(testVD1.isEpoched())
keyfun = @(x) x.('ShortName');
defFuns= visfuncs.functionObj.createObjects( ...
    'visfuncs.functionObj', viewTestClass.getDefaultFunctions(), keyfun);
fun = defFuns{1};
sfig1 = figure('Name', 'Plot when data is epoched\n');
sp1 = visviews.stackedSignalPlot(sfig1, [], []);
assertTrue(testVD1.isEpoched())
sp1.plot(testVD1, fun, slice1);
gaps = sp1.getGaps();
sp1.reposition(gaps);
sp1.registerCallbacks([]);
drawnow
assertAlmostEqual(testVD1.EpochTimes, (0:999)*4);

fprintf('It should produce a plot for a slice along dimension 1\n');
sfig2 = figure('Name', 'visviews.stackedSignalPlot test plot slice element');
sp2 = visviews.stackedSignalPlot(sfig2, [], []);
slice2 = viscore.dataSlice('Slices', {'1', ':', ':'}, 'CombineDim', 1, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
sp2.plot(testVD, fun, slice2);
gaps = sp2.getGaps();
sp2.reposition(gaps);
sp2.registerCallbacks([]);
drawnow

fprintf('It should work when the signal scale is small\n');
sfig3 = figure('Name', 'visviews.stackedSignalPlot test low signal scale');
sp3 = visviews.stackedSignalPlot(sfig3, [], []);
sp3.SignalScale = 3.0;
assertTrue(isvalid(sp3));
% Generate some data to plot
keyfun = @(x) x.('ShortName');
defFuns= visfuncs.functionObj.createObjects( ...
    'visfuncs.functionObj', viewTestClass.getDefaultFunctions(), keyfun);
slice3 = viscore.dataSlice('Slices', {':', ':', '1'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
fun = defFuns{1};
sp3.plot(testVD, fun, slice3);
gaps = sp3.getGaps();
sp3.reposition(gaps);
sp3.registerCallbacks([]);
drawnow

fprintf('It should work when the signal scale is large\n')
sfig4 = figure('Name', 'visviews.stackedSignalPlot test high signal scale');
sp4 = visviews.stackedSignalPlot(sfig4, [], []);
sp4.SignalScale = 15;
sp4.plot(testVD, fun, slice1);
gaps = sp4.getGaps();
sp4.reposition(gaps);
sp4.registerCallbacks([]);
drawnow

fprintf('It should plot smooth signals\n');
sfig5 = figure('Name', 'Plot with smoothed signals');
sp5 = visviews.stackedSignalPlot(sfig5, [], []);
assertTrue(isvalid(sp5));
% Generate some data to plot
nSamples = 1000;
nChans = 32;
x = linspace(0, 1, nSamples);

a = 10*rand(nChans, 1);
p = pi*rand(nChans, 1);
data5 = 0.01*random('normal', 0, 1, [nChans, nSamples]);
for k = 1:nChans
    data5(k, :) = data5(k, :) + a(k)*cos(2*pi*x + p(k));
end
data5(1, :) = 2*data5(1, :);
testVD5 = viscore.blockedData(data5, 'Cosine');
sp5.SignalScale = 2.0;
keyfun = @(x) x.('ShortName');
defFuns= visfuncs.functionObj.createObjects( ...
    'visfuncs.functionObj', viewTestClass.getDefaultFunctions(), keyfun);
slice5 = viscore.dataSlice('Slices', {':', ':', '1'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
fun = defFuns{1};
sp5.plot(testVD5, fun, slice5);
gaps = sp5.getGaps();
sp5.reposition(gaps);
sp5.registerCallbacks([]);
drawnow

fprintf('It should plot smooth signals with a trim percent\n');
sfig6 = figure('Name', 'Plot with smoothed signals with out of range signal');
sp6 = visviews.stackedSignalPlot(sfig6, [], []);
assertTrue(isvalid(sp3));
% Generate some data to plot
data6 = data5;
data6(2,:) = 100*data6(2, :);
testVD6 = viscore.blockedData(data6, 'Large Cosine');
sp6.SignalScale = 2.0;
sp6.TrimPercent = 5;
sp6.plot(testVD6, fun, slice3);
gaps = sp6.getGaps();
sp6.reposition(gaps);
sp6.registerCallbacks([]);

fprintf('It should produce a plot for a clump of nonepoched windows sliced along dim 3 \n');
sfig7 = figure('Name', 'Plot clump for slice along dimension 3, not epoched');
sp7 = visviews.stackedSignalPlot(sfig7, [], []);
assertTrue(isvalid(sp7));
% Generate some data to plot
keyfun = @(x) x.('ShortName');
defFuns= visfuncs.functionObj.createObjects( ...
    'visfuncs.functionObj', viewTestClass.getDefaultFunctions(), keyfun);
fun = defFuns{1};

testVD7 = viscore.blockedData(dataSmooth, 'Sinusoidal', 'Epoched', false);
slice7 = viscore.dataSlice('Slices', {':', ':', '2:4'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'}, 'CombineDim', 3);
sp7.plot(testVD7, fun, slice7);
gaps = sp7.getGaps();
sp7.reposition(gaps);
sp7.registerCallbacks([]);
drawnow


fprintf('It should produce a single window plot for a clump of epoched windows sliced along dim 3 \n');
sfig8 = figure('Name', 'Plot windows - clump for slice along dimension 3, epoched');
sp8 = visviews.stackedSignalPlot(sfig8, [], []);
assertTrue(isvalid(sp8));
% Generate some data to plot
keyfun = @(x) x.('ShortName');
defFuns= visfuncs.functionObj.createObjects( ...
    'visfuncs.functionObj', viewTestClass.getDefaultFunctions(), keyfun);
fun = defFuns{1};

testVD8 = viscore.blockedData(dataSmooth, 'Sinusoidal', ...
    'Epoched', true, 'SampleRate', 256);
slice8 = viscore.dataSlice('Slices', {':', ':', '4:8'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'}, 'CombineDim', 3);
sp8.plot(testVD8, fun, slice8);
gaps = sp8.getGaps();
sp8.reposition(gaps);
sp8.registerCallbacks([]);
drawnow

fprintf('It should produce a single element plot for a clump of epoched windows sliced along dim 1 \n');
sfig9 = figure('Name', 'Plot element - clump for slice along dimension 1, epoched');
sp9 = visviews.stackedSignalPlot(sfig9, [], []);
assertTrue(isvalid(sp9));
% Generate some data to plot
keyfun = @(x) x.('ShortName');
defFuns= visfuncs.functionObj.createObjects( ...
    'visfuncs.functionObj', viewTestClass.getDefaultFunctions(), keyfun);
fun = defFuns{1};

testVD9 = viscore.blockedData(dataSmooth, 'Sinusoidal', ...
    'Epoched', true, 'SampleRate', 256);
slice9 = viscore.dataSlice('Slices', {'4:8', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'}, 'CombineDim', 1);
sp9.plot(testVD9, fun, slice9);
gaps = sp9.getGaps();
sp9.reposition(gaps);
sp9.registerCallbacks([]);
drawnow

delete(sfig);
delete(sfig1);
delete(sfig2);
delete(sfig3);
delete(sfig4);
delete(sfig5);
delete(sfig6);
delete(sfig7);
delete(sfig8);
delete(sfig9);

function testSettingStructureScale %#ok<DEFNU>
% test stackedSignalPlot setting the scale
fprintf('\nUnit tests for visviews.stackedSignalPlot configuring Scale\n')

fprintf('It should allow the scale to be changed through the property manager\n')
sfig = figure('Name', 'visviews.stackedSignalPlot test settings structure scale');
spKey = 'Stacked signal';
sp = visviews.stackedSignalPlot(sfig, [], spKey);
assertTrue(isvalid(sp));


% check the underlying configurable object
pConf = sp.getConfigObj();
assertTrue(isa(pConf, 'visprops.configurableObj'));assertTrue(isa(pConf, 'visprops.configurableObj'));
assertTrue(strcmp(spKey, pConf.getObjectID()));

% Create and set the data manager
pMan = viscore.dataManager();
visprops.configurableObj.updateManager(pMan, {pConf});  
sp.updateProperties(pMan);
assertElementsAlmostEqual(sp.SignalScale, 3);

% Change the signal scale to 10 through the property manager
cObj = pMan.getObject(spKey);
assertTrue(isa(cObj, 'visprops.configurableObj'));
s = cObj.getStructure();
s(1).Value = 10;
cObj.setStructure(s);
sp.updateProperties(pMan);
assertElementsAlmostEqual(sp.SignalScale, s(5).Value);

fprintf('It should still plot after scale has been changed\n')
% Generate some data to plot
data = random('normal', 0, 1, [32, 1000, 20]);
testVD = viscore.blockedData(data, 'Rand1');
keyfun = @(x) x.('ShortName');
defFuns= visfuncs.functionObj.createObjects( ...
    'visfuncs.functionObj', viewTestClass.getDefaultFunctions(), keyfun);
slice1 = viscore.dataSlice('Slices', {':', ':', '1'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
fun = defFuns{1};
sp.plot(testVD, fun, slice1);
gaps = sp.getGaps();
sp.reposition(gaps);
drawnow
assertElementsAlmostEqual(sp.SignalScale, s(5).Value);
delete(sfig);

function testSettingStructureSignalLabel %#ok<DEFNU>
% test visviews.stackedSignalPlot setting axes label
fprintf('\nUnit tests for visviews.stackedSignalPlot setting axis label\n')

fprintf('It should allow the scale to be changed through the property manager\n')
sfig = figure('Name', 'visviews.stackedSignalPlot test settings structure label');
spKey = 'Stacked signal';
sp = visviews.stackedSignalPlot(sfig, [], spKey);
assertTrue(isvalid(sp));

% check the underlying configurable object
pConf = sp.getConfigObj();
assertTrue(isa(pConf, 'visprops.configurableObj'));
assertTrue(strcmp(spKey, pConf.getObjectID()));

% Create and set the data manager
pMan = viscore.dataManager();
visprops.configurableObj.updateManager(pMan, {pConf});  
sp.updateProperties(pMan);
assertTrue(strcmp(sp.SignalLabel, '{\mu}V'));

% Change the signal scale to 10 through the property manager
cObj = pMan.getObject(spKey);
assertTrue(isa(cObj, 'visprops.configurableObj'));
s = cObj.getStructure();
s(2).Value = 'ABC';
cObj.setStructure(s);
sp.updateProperties(pMan);
assertTrue(strcmp(sp.SignalLabel, s(4).Value));

fprintf('It should still plot after label has been changed\n')
% Generate some data to plot
data = random('normal', 0, 1, [32, 1000, 20]);
testVD = viscore.blockedData(data, 'Rand1');
keyfun = @(x) x.('ShortName');
defFuns= visfuncs.functionObj.createObjects( ...
    'visfuncs.functionObj', viewTestClass.getDefaultFunctions(), keyfun);
slice1 = viscore.dataSlice('Slices', {':', ':', '1'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
fun = defFuns{1};
sp.plot(testVD, fun, slice1);
gaps = sp.getGaps();
sp.reposition(gaps);
drawnow
assertTrue(strcmp(sp.SignalLabel, s(4).Value));
delete(sfig);

