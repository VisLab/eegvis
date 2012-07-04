function test_suite = testSignalShadowPlot %#ok<STOUT>
% Unit tests for signalShadowPlot
initTestSuite;

function values = setup %#ok<DEFNU>
load('EEG.mat'); 
values.bData = viscore.blockedData(EEG.data, 'EEG', ...
    'SampleRate', EEG.srate);  

load('EEGEpoch.mat');
[values.event, values.startTimes, values.timeScale] = ...
           viscore.blockedEvents.getEEGTimes(EEGEpoch);
values.bDataEpoched = viscore.blockedData(EEGEpoch.data, 'EEGEpoch', ...
    'SampleRate', EEGEpoch.srate, 'Epoched', true, ...
    'Events', values.event, 'BlockStartTimes', values.startTimes, ...
    'BlockTimeScale', values.timeScale);

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
values.bDataSmooth =  viscore.blockedData(dataSmooth, 'Smooth');

keyfun = @(x) x.('ShortName');
defFuns= visfuncs.functionObj.createObjects( ...
    'visfuncs.functionObj', viewTestClass.getDefaultFunctions(), keyfun);
values.fun = defFuns{1};

values.slice = viscore.dataSlice('Slices', {':', ':', '1'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
values.deleteFigures = false;

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testNormalConstructor(values) %#ok<DEFNU>
% testSignalShadowPlot unit test for visviews.signalShadowPlot constructor
fprintf('\nUnit tests for visviews.signalShadowPlot valid constructor\n');

fprintf('It should construct a valid shadow signal plot when only parent passed\n')
fig = figure('Name', 'Creates plot panel when only parent is passed');
sp = visviews.signalShadowPlot(fig, [], []);
assertTrue(isvalid(sp));

fprintf('It should allow callbacks to be registered\n')
sp.registerCallbacks([]);

drawnow
if values.deleteFigures
  delete(fig);
end

function testBadConstructor(values) %#ok<DEFNU>
% testSignalShadowPlot unit test for signalShadowPlot constructor
fprintf('\nUnit tests for visviews.signalShadowPlot invalid constructor parameters\n');

fprintf('It should throw an exception when no parameters are passed\n');
f = @() visviews.signalShadowPlot();
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when only one parameter is passed\n');
fig = figure('Name', 'Invalid constructor');
f = @() visviews.signalShadowPlot(fig);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when only two parameters are passed\n');
f = @() visviews.signalShadowPlot(fig, []);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when more than three parameters are passed\n');
f = @() visviews.signalShadowPlot(fig, [], [], []);
assertExceptionThrown(f, 'MATLAB:maxrhs');

if values.deleteFigures
  delete(fig);
end

function testPlot(values) %#ok<DEFNU>
%test signalShadowPlot plot
fprintf('\nUnit tests for visviews.signalShadowPlot plot method\n')

fprintf('It should produce a plot for a normal slice along dim 3\n');
fig1 = figure('Name', 'Normal plot slice along dimension 3');
sp1 = visviews.signalShadowPlot(fig1, [], []);
assertTrue(isvalid(sp1));
sp1.plot(values.bData, values.fun, values.slice);
gaps = sp1.getGaps();
sp1.reposition(gaps);

fprintf('It should produce a plot multiple window slice along dimension 3\n');
fig2 = figure('Name', 'Multiple windows - combine dim 3');
sp2 = visviews.signalShadowPlot(fig2, [], []);
assertTrue(isvalid(sp2));
slice2 = viscore.dataSlice('Slices', {':', ':', '2:5'}, 'CombineDim', 3, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
sp2.plot(values.bData, values.fun, slice2);
gaps = sp2.getGaps();
sp2.reposition(gaps);

fprintf('It should produce a plot for EEG with combineDim 1\n');
fig3 = figure('Name', 'Single element - combine dim 1');
sp3 = visviews.signalShadowPlot(fig3, [], []);
assertTrue(isvalid(sp3));
slice3 = viscore.dataSlice('Slices', {'1', ':', ':'}, 'CombineDim', 1, ...
    'DimNames', {'Channel', 'Sample', 'Window'}); 
sp3.plot(values.bData, values.fun, slice3);
gaps = sp3.getGaps();
sp3.reposition(gaps);

fprintf('It should produce a plot for EEG with multiple elements combineDim 1\n');
fig4 = figure('Name', 'Multiple elements - combine dim 1');
sp4 = visviews.signalShadowPlot(fig4, [], []);
assertTrue(isvalid(sp4));
slice4 = viscore.dataSlice('Slices', {'1', ':', ':'}, 'CombineDim', 1, ...
    'DimNames', {'Channel', 'Sample', 'Window'}); 
sp4.plot(values.bData, values.fun, slice4);
gaps = sp4.getGaps();
sp4.reposition(gaps);

fprintf('It should produce a plot of epoched data for a normal slice along dim 3\n');
assertTrue(values.bDataEpoched.isEpoched())
fig5 = figure('Name', 'Plot when EEG data is epoched along dim 3');
sp5 = visviews.signalShadowPlot(fig5, [], []);
sp5.plot(values.bDataEpoched, values.fun, values.slice);
gaps = sp5.getGaps();
sp5.reposition(gaps);

fprintf('It should produce a plot multiple window slice along dimension 3\n');
fig6 = figure('Name', 'Epoched data, multiple windows - combine dim 3');
sp6 = visviews.signalShadowPlot(fig6, [], []);
assertTrue(isvalid(sp6));
slice6 = viscore.dataSlice('Slices', {':', ':', '2:5'}, 'CombineDim', 3, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
sp6.plot(values.bDataEpoched, values.fun, slice6);
gaps = sp6.getGaps();
sp6.reposition(gaps);

fprintf('It should produce a plot for EEG epoched data with combineDim 1\n');
fig7 = figure('Name', 'Single element epoched - combine dim 1');
sp7 = visviews.signalShadowPlot(fig7, [], []);
assertTrue(isvalid(sp7));
slice7 = viscore.dataSlice('Slices', {'1', ':', ':'}, 'CombineDim', 1, ...
    'DimNames', {'Channel', 'Sample', 'Window'}); 
sp7.plot(values.bDataEpoched, values.fun, slice7);
gaps = sp7.getGaps();
sp7.reposition(gaps);

fprintf('It should produce a plot for EEG epoched data with multiple elements combineDim 1\n');
fig8 = figure('Name', 'Multiple elements epoched - combine dim 1');
sp8 = visviews.signalShadowPlot(fig8, [], []);
assertTrue(isvalid(sp8));
slice8 = viscore.dataSlice('Slices', {'1', ':', ':'}, 'CombineDim', 1, ...
    'DimNames', {'Channel', 'Sample', 'Window'}); 
sp8.plot(values.bDataEpoched, values.fun, slice8);
gaps = sp8.getGaps();
sp8.reposition(gaps);

fprintf('It should plot smooth signals\n');
fig9 = figure('Name', 'Plot with smoothed signals');
sp9 = visviews.signalShadowPlot(fig9, [], []);
assertTrue(isvalid(sp9));
sp9.CutoffScore = 2.0;
sp9.plot(values.bDataSmooth, values.fun, values.slice);
gaps = sp9.getGaps();
sp9.reposition(gaps);

fprintf('It should plot smooth signals with a trim percent\n');
fig10 = figure('Name', 'Plot with smoothed signals with out of range signal');
sp10 = visviews.signalShadowPlot(fig10, [], []);
assertTrue(isvalid(sp6));
data10 = values.bDataSmooth.getData();
data10(2,:) = 100*data10(6, :);
testVD10 = viscore.blockedData(data10, 'Large Cosine');
sp10.CutoffScore = 2.0;
sp10.TrimPercent = 5;
sp10.plot(testVD10, values.fun, values.slice);
gaps = sp10.getGaps();
sp10.reposition(gaps);

fprintf('It should produce a plot for a clump of nonepoched windows sliced along dim 3 \n');
fig11 = figure('Name', 'Plot clump for slice along dimension 3, not epoched');
sp11 = visviews.signalShadowPlot(fig11, [], []);
assertTrue(isvalid(sp11));
slice11 = viscore.dataSlice('Slices', {':', ':', '2:4'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'}, 'CombineDim', 3);
sp11.plot(values.bDataSmooth, values.fun, slice11);
gaps = sp11.getGaps();
sp11.reposition(gaps);

fprintf('It should produce a plot for a clump of nonepoched windows sliced along dim 3 \n');
fig12 = figure('Name', 'Plot clump for slice along dimension 3, epoched');
sp12 = visviews.signalShadowPlot(fig12, [], []);
assertTrue(isvalid(sp12));
slice12 = viscore.dataSlice('Slices', {':', ':', '2:4'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'}, 'CombineDim', 3);
sp12.plot(values.bDataEpoched, values.fun, slice12);
gaps = sp12.getGaps();
sp12.reposition(gaps);

fprintf('It should produce a single window plot for a clump of epoched windows sliced along dim 3 \n');
fig13 = figure('Name', 'Plot clump for slice along dimension 3, epoched (epoch 5 and 7 are big)');
sp13 = visviews.signalShadowPlot(fig13, [], []);
assertTrue(isvalid(sp13));
bigData = values.bDataSmooth.getData;
bigData(:, :, 5) = 3*bigData(:, :, 5);
bigData(:, :, 7) = 3.5*bigData(:, :, 7);
testVD13 = viscore.blockedData(bigData, 'Sinusoidal', ...
    'Epoched', true, 'SampleRate', 256);
slice13 = viscore.dataSlice('Slices', {':', ':', '4:8'}, ...
    'DimNames', {'Channel', 'Sample', 'Epoch'}, 'CombineDim', 3);
sp13.plot(testVD13, values.fun, slice13);
gaps = sp13.getGaps();
sp13.reposition(gaps);

fprintf('It should produce a plot for a clump of nonepoched windows\n');
fig14 = figure('Name', 'Plot clump for channels 2:4 sliced dimension 1, big windows [5, 7], not epoched');
sp14 = visviews.signalShadowPlot(fig14, [], []);
assertTrue(isvalid(sp4));
slice14 = viscore.dataSlice('Slices', {'30:32', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'}, 'CombineDim', 1);
sp14.plot(testVD13, values.fun, slice14);
gaps = sp14.getGaps();
sp14.reposition(gaps);
drawnow

if values.deleteFigures
    delete(fig1);
    delete(fig2);
    delete(fig3);
    delete(fig4);
    delete(fig5);
    delete(fig6);
    delete(fig7);
    delete(fig8);
    delete(fig9);
    delete(fig10);
    delete(fig11);
    delete(fig12);
    delete(fig13);
    delete(fig14);
end

function testConstantAndNaNValues(values) %#ok<DEFNU>
% Unit test visviews.signalShadowPlot plot constant and NaN
fprintf('\nUnit tests for visviews.signalShadowPlot plot method with constant and NaN values\n')

% All zeros
fprintf('It should produce a plot for when all of the values are 0\n');
data = zeros([32, 1000, 20]);
testVD1 = viscore.blockedData(data, 'All zeros');
fig1 = figure('Name', 'All zero values');
bp1 = visviews.signalShadowPlot(fig1, [], []);
assertTrue(isvalid(bp1));
bp1.plot(testVD1, values.fun, values.slice);
gaps = bp1.getGaps();
bp1.reposition(gaps);

% Data zeros, function NaN
fprintf('It should produce a plot for when data is zero, funcs NaNs (---see warning)\n');
fig2 = figure('Name', 'Data zero, func NaN');
bp2 = visviews.signalShadowPlot(fig2, [], []);
assertTrue(isvalid(bp2));
bp2.plot(testVD1, [], values.slice);
gaps = bp2.getGaps();
bp2.reposition(gaps);

% Data NaN
fprintf('It should produce a plot for when data is zero, funcs NaNs (---see warning)\n');
data = NaN([32, 1000, 20]);
testVD3 = viscore.blockedData(data, 'Data NaN');
fig3 = figure('Name', 'Data NaNs');
bp3 = visviews.signalShadowPlot(fig3, [], []);
assertTrue(isvalid(bp3));
bp3.plot(testVD3, values.fun, values.slice);
gaps = bp3.getGaps();
bp3.reposition(gaps);

% Data slice empty
fprintf('It should produce empty axes when data slice is empty (---see warning)\n');
data = zeros(5, 1);
testVD4 = viscore.blockedData(data, 'Data empty');
slice4 = viscore.dataSlice('Slices', {'6', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
fig4 = figure('Name', 'Data slice is empty');
bp4 = visviews.signalShadowPlot(fig4, [], []);
assertTrue(isvalid(bp4));
bp4.plot(testVD4, values.fun, slice4);
gaps = bp4.getGaps();
bp4.reposition(gaps);
drawnow
if values.deleteFigures
    delete(fig1);
    delete(fig2);
    delete(fig3);
    delete(fig4);
end

function testGetDefaultProperties(values) %#ok<INUSD,DEFNU>
% testStackedSignalPlot unit test for static getDefaultProperties
fprintf('\nUnit tests for visviews.signalShadowPlot getDefaultProperties\n');
fprintf('It should have a getDefaultProperties method that returns a structure\n');
s = visviews.signalShadowPlot.getDefaultProperties();
assertTrue(isa(s, 'struct'));

