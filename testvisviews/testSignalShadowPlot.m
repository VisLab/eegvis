function test_suite = testSignalShadowPlot %#ok<STOUT>
% Unit tests for signalShadowPlot
initTestSuite;

function testNormalConstructor %#ok<DEFNU>
% testSignalShadowPlot unit test for visviews.signalShadowPlot constructor
fprintf('\nUnit tests for visviews.signalShadowPlot valid constructor\n');

fprintf('It should construct a valid shadow signal plot when only parent passed\n')
sfig = figure('Name', 'Creates plot panel when only parent is passed');
sp = visviews.signalShadowPlot(sfig, [], []);
assertTrue(isvalid(sp));
drawnow
delete(sfig);

function testBadConstructor %#ok<DEFNU>
% testSignalShadowPlot unit test for signalShadowPlot constructor
fprintf('\nUnit tests for visviews.signalShadowPlot invalid constructor parameters\n');

fprintf('It should throw an exception when no parameters are passed\n');
f = @() visviews.signalShadowPlot();
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});


fprintf('It should throw an exception when only one parameter is passed\n');
sfig = figure('Name', 'Invalid constructor');
f = @() visviews.signalShadowPlot(sfig);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});


fprintf('It should throw an exception when only two parameters are passed\n');
f = @() visviews.signalShadowPlot(sfig, []);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});


fprintf('It should throw an exception when more than three parameters are passed\n');
f = @() visviews.signalShadowPlot(sfig, [], [], []);
assertExceptionThrown(f, 'MATLAB:maxrhs');
delete(sfig);

function testGetDefaultProperties %#ok<DEFNU>
% testStackedSignalPlot unit test for static getDefaultProperties
fprintf('\nUnit tests for visviews.signalShadowPlot getDefaultProperties\n');
fprintf('It should have a getDefaultProperties method that returns a structure\n');
s = visviews.signalShadowPlot.getDefaultProperties();
assertTrue(isa(s, 'struct'));
assertEqual(length(s), 8);

function testRegisterCallbacks %#ok<DEFNU>
% test stackedSignalPlot plotSlice 
fprintf('\nUnit tests for visviews.signalShadowPlot registering callbacks\n')

fprintf('It should allow callbacks to be registered\n')
sfig = figure('Name', 'visviews.signalShadowPlot test plot slice window');
sp = visviews.signalShadowPlot(sfig, [], []);
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
%test signalShadowPlot plot
fprintf('\nUnit tests for visviews.signalShadowPlot plot method\n')

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
sp = visviews.signalShadowPlot(sfig, [], []);
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
sp1 = visviews.signalShadowPlot(sfig1, [], []);
assertTrue(testVD1.isEpoched())
sp1.plot(testVD1, fun, slice1);
gaps = sp1.getGaps();
sp1.reposition(gaps);
sp1.registerCallbacks([]);
drawnow

fprintf('It should produce a plot for a slice along dimension 1\n');
sfig2 = figure('Name', 'Plot when sliced along dimension 1');
sp2 = visviews.signalShadowPlot(sfig2, [], []);
slice2 = viscore.dataSlice('Slices', {'2', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'}, 'CombineDim', 1);
sp2.plot(testVD, fun, slice2);
gaps = sp2.getGaps();
sp2.reposition(gaps);
sp2.registerCallbacks([]);
drawnow

fprintf('It should plot smooth signals\n');
sfig3 = figure('Name', 'Plot with smoothed signals');
sp3 = visviews.signalShadowPlot(sfig3, [], []);
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
sp4 = visviews.signalShadowPlot(sfig4, [], []);
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
sp5 = visviews.signalShadowPlot(sfig5, [], []);
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
sp6 = visviews.signalShadowPlot(sfig6, [], []);
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
sp7 = visviews.signalShadowPlot(sfig7, [], []);
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
% delete(sfig);
% delete(sfig1);
% delete(sfig2);
% delete(sfig3);
% delete(sfig4);
% delete(sfig5);
% delete(sfig6);
% delete(sfig7);


function testConstantAndNaNValues %#ok<DEFNU>
% Unit test visviews.signalShadowPlot plot constant and NaN
fprintf('\nUnit tests for visviews.signalShadowPlot plot method with constant and NaN values\n')

% Set up the functions
defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
    viewTestClass.getDefaultFunctions());
fMan = viscore.dataManager();
fMan.putObjects(defaults);
func = fMan.getEnabledObjects('block');
thisFuncK = func{1};
thisFuncS = func{2};

% All zeros
fprintf('It should produce a plot for when all of the values are 0\n');
data = zeros([32, 1000, 20]);
testVD = viscore.blockedData(data, 'All zeros');
slice1 = viscore.dataSlice('Slices', {':', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
sfig1 = figure('Name', 'All zero values');
bp1 = visviews.signalShadowPlot(sfig1, [], []);
assertTrue(isvalid(bp1));
bp1.plot(testVD, thisFuncS, slice1);
gaps = bp1.getGaps();
bp1.reposition(gaps);
drawnow

% Data zeros, function NaN
fprintf('It should produce a plot for when data is zero, funcs NaNs\n');
data = zeros([32, 1000, 20]);
testVD = viscore.blockedData(data, 'Data zeros, func NaN');
slice2 = viscore.dataSlice('Slices', {':', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
sfig2 = figure('Name', 'Data zero, func NaN');
bp2 = visviews.signalShadowPlot(sfig2, [], []);
assertTrue(isvalid(bp2));
bp2.plot(testVD, thisFuncK, slice2);
gaps = bp2.getGaps();
bp2.reposition(gaps);
drawnow

% Data NaN
fprintf('It should produce a plot for when data is zero, funcs NaNs (---see warning)\n');
data = NaN([32, 1000, 20]);
testVD = viscore.blockedData(data, 'Data NaN');
slice3 = viscore.dataSlice('Slices', {':', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
sfig3 = figure('Name', 'Data NaNs');
bp3 = visviews.signalShadowPlot(sfig3, [], []);
assertTrue(isvalid(bp3));
bp3.plot(testVD, thisFuncS, slice3);
gaps = bp3.getGaps();
bp3.reposition(gaps);
drawnow

% Data slice empty
fprintf('It should produce empty axes when data slice is empty (---see warning)\n');
data = zeros(5, 1);
testVD = viscore.blockedData(data, 'Data empty');
slice4 = viscore.dataSlice('Slices', {'6', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
sfig4 = figure('Name', 'Data slice is empty');
bp4 = visviews.signalShadowPlot(sfig4, [], []);
assertTrue(isvalid(bp4));
bp4.plot(testVD, thisFuncS, slice4);
gaps = bp4.getGaps();
bp4.reposition(gaps);
drawnow
delete(sfig1);
delete(sfig2);
delete(sfig3);
delete(sfig4);


function testPlotEpoched %#ok<DEFNU>
%test signalShadowPlot plot
fprintf('\nUnit tests for visviews.signalShadowPlot plot method on epoched data\n')
load('EEGEpoch.mat')

fprintf('It should produce a plot for epoched data no start times 3\n');
sfig = figure('Name', 'Epoched non-clumped slice along dimension 3');
sp = visviews.signalShadowPlot(sfig, [], []);
assertTrue(isvalid(sp));
% Generate some data to plot
keyfun = @(x) x.('ShortName');
defFuns= visfuncs.functionObj.createObjects( ...
    'visfuncs.functionObj', viewTestClass.getDefaultFunctions(), keyfun);
fun = defFuns{1};

testVD = viscore.blockedData(EEGEpoch.data, 'EpochedData', 'Epoched', true);
slice1 = viscore.dataSlice('Slices', {':', ':', '2'}, ...
    'DimNames', {'Channel', 'Sample', 'Epoch'});
sp.plot(testVD, fun, slice1);
gaps = sp.getGaps();
sp.reposition(gaps);
sp.registerCallbacks([]);
drawnow

fprintf('It should produce a plot epoched data with time scale 3\n');
sfig1 = figure('Name', 'Epoched with time scale');
sp1 = visviews.signalShadowPlot(sfig1, [], []);
assertTrue(isvalid(sp));
[event, startTimes, timeScale] = viscore.eventData.getEEGTimes(EEGEpoch); 
testVD1 = viscore.blockedData(EEGEpoch.data, 'EpochedTimeScale', ...
    'Epoched', true, 'EpochTimeScale', timeScale);
sp1.plot(testVD1, fun, slice1);
gaps = sp1.getGaps();
sp1.reposition(gaps);
sp1.registerCallbacks([]);
drawnow

fprintf('It should produce a plot epoched data with time scale and start times 3\n');
sfig2 = figure('Name', 'Epoched with time scale and start times');
sp2 = visviews.signalShadowPlot(sfig2, [], []);
assertTrue(isvalid(sp));
testVD2 = viscore.blockedData(EEGEpoch.data, 'EpochedTimeScale', ...
    'Epoched', true, 'EpochTimeScale', timeScale, ...
    'EpochStartTimes', startTimes);
sp2.plot(testVD2, fun, slice1);
gaps = sp2.getGaps();
sp2.reposition(gaps);
sp2.registerCallbacks([]);
drawnow
