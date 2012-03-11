function test_suite = testShadowSignalPlot %#ok<STOUT>
% Unit tests for shadowSignalPlot
initTestSuite;

function testNormalConstructor %#ok<DEFNU>
% testShadowSignalPlot unit test for visviews.shadowSignalPlot constructor
fprintf('\nUnit tests for visviews.shadowSignalPlot valid constructor\n');

fprintf('It should construct a valid shadow signal plot when only parent passed\n')
sfig = figure('Name', 'Creates plot panel when only parent is passed');
sp = visviews.shadowSignalPlot(sfig, [], []);
assertTrue(isvalid(sp));
drawnow
delete(sfig);

function testBadConstructor %#ok<DEFNU>
% testShadowSignalPlot unit test for shadowSignalPlot constructor
fprintf('\nUnit tests for visviews.shadowSignalPlot invalid constructor parameters\n');

fprintf('It should throw an exception when no parameters are passed\n');
f = @() visviews.shadowSignalPlot();
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});


fprintf('It should throw an exception when only one parameter is passed\n');
sfig = figure('Name', 'Invalid constructor');
f = @() visviews.shadowSignalPlot(sfig);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});


fprintf('It should throw an exception when only two parameters are passed\n');
f = @() visviews.shadowSignalPlot(sfig, []);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});


fprintf('It should throw an exception when more than three parameters are passed\n');
f = @() visviews.shadowSignalPlot(sfig, [], [], []);
assertExceptionThrown(f, 'MATLAB:maxrhs');
delete(sfig);

function testGetDefaultProperties %#ok<DEFNU>
% testStackedSignalPlot unit test for static getDefaultProperties
fprintf('\nUnit tests for visviews.shadowSignalPlot getDefaultProperties\n');
fprintf('It should have a getDefaultProperties method that returns a structure\n');
s = visviews.shadowSignalPlot.getDefaultProperties();
assertTrue(isa(s, 'struct'));
assertEqual(length(s), 8);

function testRegisterCallbacks %#ok<DEFNU>
% test stackedSignalPlot plotSlice 
fprintf('\nUnit tests for visviews.shadowSignalPlot registering callbacks\n')

fprintf('It should allow callbacks to be registered\n')
sfig = figure('Name', 'visviews.shadowSignalPlot test plot slice window');
sp = visviews.shadowSignalPlot(sfig, [], []);
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
sp.registerCallbacks([]);
delete(sfig);

function testPlot %#ok<DEFNU>
%test shadowSignalPlot plot
fprintf('\nUnit tests for visviews.shadowSignalPlot plot method\n')

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
sfig = figure('Name', 'Normal plot slice along dimension 3');
sp = visviews.shadowSignalPlot(sfig, [], []);
assertTrue(isvalid(sp));
% Generate some data to plot
keyfun = @(x) x.('ShortName');
defFuns= visfuncs.functionObj.createObjects( ...
    'visfuncs.functionObj', viewTestClass.getDefaultFunctions(), keyfun);
fun = defFuns{1};

testVD = viscore.blockedData(data, 'Rand1');
slice1 = viscore.dataSlice('Slices', {':', ':', '1'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
sp.plot(testVD, fun, slice1);
gaps = sp.getGaps();
sp.reposition(gaps);
sp.registerCallbacks([]);
drawnow


fprintf('It should produce a plot when the data is epoched\n');
testVD1 = viscore.blockedData(data, 'Rand1', 'Epoched', true, ...
    'SampleRate', 250);
assertTrue(testVD1.isEpoched())
keyfun = @(x) x.('ShortName');
defFuns= visfuncs.functionObj.createObjects( ...
    'visfuncs.functionObj', viewTestClass.getDefaultFunctions(), keyfun);
fun = defFuns{1};
sfig1 = figure('Name', 'Plot when data is epoched');
sp1 = visviews.shadowSignalPlot(sfig1, [], []);
assertTrue(testVD1.isEpoched())
sp1.plot(testVD1, fun, slice1);
gaps = sp1.getGaps();
sp1.reposition(gaps);
sp1.registerCallbacks([]);
drawnow

fprintf('It should produce a plot for a slice along dimension 1\n');
sfig2 = figure('Name', 'Plot when sliced along dimension 1');
sp2 = visviews.shadowSignalPlot(sfig2, [], []);
slice2 = viscore.dataSlice('Slices', {'2', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'}, 'CombineDim', 1);
sp2.plot(testVD, fun, slice2);
gaps = sp2.getGaps();
sp2.reposition(gaps);
sp2.registerCallbacks([]);
drawnow

fprintf('It should plot smooth signals\n');
sfig3 = figure('Name', 'Plot with smoothed signals');
sp3 = visviews.shadowSignalPlot(sfig3, [], []);
assertTrue(isvalid(sp3));
% Generate some data to plot
nSamples = 1000;
nChans = 32;
x = linspace(0, 1, nSamples);

a = 10*rand(nChans, 1);
p = pi*rand(nChans, 1);
data3 = 0.01*random('normal', 0, 1, [nChans, nSamples]);
for k = 1:nChans
    data3(k, :) = data3(k, :) + a(k)*cos(2*pi*x + p(k));
end
data3(1, :) = 2*data3(1, :);
testVD3 = viscore.blockedData(data3, 'Cosine');
sp3.CutoffScore = 2.0;
keyfun = @(x) x.('ShortName');
defFuns= visfuncs.functionObj.createObjects( ...
    'visfuncs.functionObj', viewTestClass.getDefaultFunctions(), keyfun);
slice3 = viscore.dataSlice('Slices', {':', ':', '1'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
fun = defFuns{1};
sp3.plot(testVD3, fun, slice3);
gaps = sp3.getGaps();
sp3.reposition(gaps);
sp3.registerCallbacks([]);
drawnow

fprintf('It should plot smooth signals with a trim percent\n');
sfig4 = figure('Name', 'Plot with smoothed signals with out of range signal');
sp4 = visviews.shadowSignalPlot(sfig4, [], []);
assertTrue(isvalid(sp3));
% Generate some data to plot
data4 = data3;
data4(2,:) = 100*data4(2, :);
testVD4 = viscore.blockedData(data4, 'Large Cosine');
sp4.CutoffScore = 2.0;
sp4.TrimPercent = 5;
sp4.plot(testVD4, fun, slice3);
gaps = sp4.getGaps();
sp4.registerCallbacks([]);
sp4.reposition(gaps);

fprintf('It should produce a plot for a clump of nonepoched windows sliced along dim 3 \n');
sfig5 = figure('Name', 'Plot clump for slice along dimension 3, not epoched');
sp5 = visviews.shadowSignalPlot(sfig5, [], []);
assertTrue(isvalid(sp5));
% Generate some data to plot
keyfun = @(x) x.('ShortName');
defFuns= visfuncs.functionObj.createObjects( ...
    'visfuncs.functionObj', viewTestClass.getDefaultFunctions(), keyfun);
fun = defFuns{1};

testVD5 = viscore.blockedData(dataSmooth, 'Sinusoidal', 'Epoched', false);
slice5 = viscore.dataSlice('Slices', {':', ':', '2:4'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'}, 'CombineDim', 3);
sp5.plot(testVD5, fun, slice5);
gaps = sp5.getGaps();
sp5.reposition(gaps);
sp5.registerCallbacks([]);
drawnow


fprintf('It should produce a single window plot for a clump of epoched windows sliced along dim 3 \n');
sfig6 = figure('Name', 'Plot clump for slice along dimension 3, epoched (epoch 5 and 7 are big)');
sp6 = visviews.shadowSignalPlot(sfig6, [], []);
assertTrue(isvalid(sp6));
% Generate some data to plot
keyfun = @(x) x.('ShortName');
defFuns= visfuncs.functionObj.createObjects( ...
    'visfuncs.functionObj', viewTestClass.getDefaultFunctions(), keyfun);
fun = defFuns{1};
bigData = dataSmooth;
bigData(:, :, 5) = 3*bigData(:, :, 5);
bigData(:, :, 7) = 3.5*bigData(:, :, 7);
testVD6 = viscore.blockedData(bigData, 'Sinusoidal', ...
    'Epoched', true, 'SampleRate', 256);
slice6 = viscore.dataSlice('Slices', {':', ':', '4:8'}, ...
    'DimNames', {'Channel', 'Sample', 'Epoch'}, 'CombineDim', 3);
sp6.plot(testVD6, fun, slice6);
gaps = sp6.getGaps();
sp6.reposition(gaps);
sp6.registerCallbacks([]);
drawnow

fprintf('It should produce a plot for a clump of nonepoched windows  \n');
sfig7 = figure('Name', 'Plot clump for channels 2:4 sliced dimension 1, big windows [5, 7], not epoched');
sp7 = visviews.shadowSignalPlot(sfig7, [], []);
assertTrue(isvalid(sp7));
% Generate some data to plot
keyfun = @(x) x.('ShortName');
defFuns= visfuncs.functionObj.createObjects( ...
    'visfuncs.functionObj', viewTestClass.getDefaultFunctions(), keyfun);
fun = defFuns{1};

testVD7 = viscore.blockedData(bigData, 'Sinusoidal', 'Epoched', false);
slice7 = viscore.dataSlice('Slices', {'30:32', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'}, 'CombineDim', 1);
sp7.plot(testVD7, fun, slice7);
gaps = sp7.getGaps();
sp7.reposition(gaps);
sp7.registerCallbacks([]);
drawnow
delete(sfig);
delete(sfig1);
delete(sfig2);
delete(sfig3);
delete(sfig4);
delete(sfig5);
delete(sfig6);
delete(sfig7);





