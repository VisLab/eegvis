function test_suite = testSignalHistogramPlot %#ok<STOUT>
% Unit tests for visviews.signalHistogramPlot
initTestSuite;

function values = setup %#ok<DEFNU>
hdf5File = regexprep(which('EEG.mat'), 'EEG.mat$', 'EEG.hdf5');
load('EEG.mat'); 
values.bData = viscore.memoryData(EEG.data, 'EEG', ...
    'SampleRate', EEG.srate);
values.hdf5Data = viscore.hdf5Data(EEG.data, 'EEG', hdf5File, ...
    'SampleRate', EEG.srate);

hdf5EpochFile = regexprep(which('EEG.mat'), 'EEG.mat$', 'EEGEpoch.hdf5');
load('EEGEpoch.mat');
[values.event, values.startTimes, values.timeScale] = ...
           viscore.blockedEvents.getEEGTimes(EEGEpoch);
values.bDataEpoched = viscore.memoryData(EEGEpoch.data, 'EEGEpoch', ...
    'SampleRate', EEGEpoch.srate, 'Epoched', true, ...
    'Events', values.event, 'BlockStartTimes', values.startTimes, ...
    'BlockTimeScale', values.timeScale);
values.hdf5DataEpoched = viscore.hdf5Data(EEGEpoch.data, 'EEGEpoch', hdf5EpochFile, ...
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
values.bDataSmooth =  viscore.memoryData(dataSmooth, 'Smooth');

keyfun = @(x) x.('ShortName');
defFuns= visfuncs.functionObj.createObjects( ...
    'visfuncs.functionObj', viewTestClass.getDefaultFunctions(), keyfun);
values.fun = defFuns{1};

values.slice = viscore.dataSlice('Slices', {':', ':', '1'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
values.deleteFigures = true;

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testNormalConstructor(values) %#ok<DEFNU>
% testSignalShadowPlot unit test for visviews.signalHistogramPlot constructor
fprintf('\nUnit tests for visviews.signalHistogramPlot valid constructor\n');

fprintf('It should construct a valid shadow signal plot when only parent passed\n')
fig1 = figure('Name', 'Creates plot panel when only parent is passed');
sh1 = visviews.signalHistogramPlot(fig1, [], []);
assertTrue(isvalid(sh1));

fprintf('It should allow callbacks to be registered\n')
sh1.registerCallbacks([]);

drawnow
if values.deleteFigures
  delete(fig1);
end

function testBadConstructor(values) %#ok<DEFNU>
% testSignalShadowPlot unit test for signalHistogramPlot constructor
fprintf('\nUnit tests for visviews.signalHistogramPlot invalid constructor parameters\n');

fprintf('It should throw an exception when no parameters are passed\n');
f = @() visviews.signalHistogramPlot();
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when only one parameter is passed\n');
fig1 = figure('Name', 'Signal histogram invalid constructor');
f = @() visviews.signalHistogramPlot(fig1);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when only two parameters are passed\n');
f = @() visviews.signalHistogramPlot(fig1, []);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when more than three parameters are passed\n');
f = @() visviews.signalHistogramPlot(fig1, [], [], []);
assertExceptionThrown(f, 'MATLAB:maxrhs');

if values.deleteFigures
  delete(fig1);
end

function testPlot(values) %#ok<DEFNU>
%test signalHistogramPlot plot
fprintf('\nUnit tests for visviews.signalHistogramPlot plot method\n')

fprintf('It should produce a plot for a normal slice along dim 3\n');
fig1 = figure('Name', 'Normal plot slice along dimension 3');
sh1 = visviews.signalHistogramPlot(fig1, [], []);
assertTrue(isvalid(sh1));
sh1.plot(values.bData, values.fun, values.slice);
gaps = sh1.getGaps();
sh1.reposition(gaps);

fprintf('It should produce a plot multiple window slice along dimension 3\n');
fig2 = figure('Name', 'Multiple windows - combine dim 3');
sh2 = visviews.signalHistogramPlot(fig2, [], []);
assertTrue(isvalid(sh2));
slice2 = viscore.dataSlice('Slices', {':', ':', '2:5'}, 'CombineDim', 3, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
sh2.plot(values.bData, values.fun, slice2);
gaps = sh2.getGaps();
sh2.reposition(gaps);

fprintf('It should produce a plot for EEG with combineDim 1\n');
fig3 = figure('Name', 'Single element - combine dim 1');
sh3 = visviews.signalHistogramPlot(fig3, [], []);
assertTrue(isvalid(sh3));
slice3 = viscore.dataSlice('Slices', {'1', ':', ':'}, 'CombineDim', 1, ...
    'DimNames', {'Channel', 'Sample', 'Window'}); 
sh3.plot(values.bData, values.fun, slice3);
gaps = sh3.getGaps();
sh3.reposition(gaps);

fprintf('It should produce a plot for EEG with multiple elements combineDim 1\n');
fig4 = figure('Name', 'Multiple elements - combine dim 1');
sh4 = visviews.signalHistogramPlot(fig4, [], []);
assertTrue(isvalid(sh4));
slice4 = viscore.dataSlice('Slices', {'1', ':', ':'}, 'CombineDim', 1, ...
    'DimNames', {'Channel', 'Sample', 'Window'}); 
sh4.plot(values.bData, values.fun, slice4);
gaps = sh4.getGaps();
sh4.reposition(gaps);

fprintf('It should produce a plot of epoched data for a normal slice along dim 3\n');
assertTrue(values.bDataEpoched.isEpoched())
fig5 = figure('Name', 'Plot when EEG data is epoched along dim 3');
sh5 = visviews.signalHistogramPlot(fig5, [], []);
sh5.plot(values.bDataEpoched, values.fun, values.slice);
gaps = sh5.getGaps();
sh5.reposition(gaps);

fprintf('It should produce a plot multiple window slice along dimension 3\n');
fig6 = figure('Name', 'Epoched data, multiple windows - combine dim 3');
sh6 = visviews.signalHistogramPlot(fig6, [], []);
assertTrue(isvalid(sh6));
slice6 = viscore.dataSlice('Slices', {':', ':', '2:5'}, 'CombineDim', 3, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
sh6.plot(values.bDataEpoched, values.fun, slice6);
gaps = sh6.getGaps();
sh6.reposition(gaps);

fprintf('It should produce a plot for EEG epoched data with combineDim 1\n');
fig7 = figure('Name', 'Single element epoched - combine dim 1');
sh7 = visviews.signalHistogramPlot(fig7, [], []);
assertTrue(isvalid(sh7));
slice7 = viscore.dataSlice('Slices', {'1', ':', ':'}, 'CombineDim', 1, ...
    'DimNames', {'Channel', 'Sample', 'Window'}); 
sh7.plot(values.bDataEpoched, values.fun, slice7);
gaps = sh7.getGaps();
sh7.reposition(gaps);

fprintf('It should produce a plot for EEG epoched data with multiple elements combineDim 1\n');
fig8 = figure('Name', 'Multiple elements epoched - combine dim 1');
sh8 = visviews.signalHistogramPlot(fig8, [], []);
assertTrue(isvalid(sh8));
slice8 = viscore.dataSlice('Slices', {'1', ':', ':'}, 'CombineDim', 1, ...
    'DimNames', {'Channel', 'Sample', 'Window'}); 
sh8.plot(values.bDataEpoched, values.fun, slice8);
gaps = sh8.getGaps();
sh8.reposition(gaps);

fprintf('It should plot smooth signals with red bars\n');
fig9 = figure('Name', 'Plot with smoothed signals');
sh9 = visviews.signalHistogramPlot(fig9, [], []);
assertTrue(isvalid(sh9));
sh9.HistogramColor = [1, 0, 0];
sh9.plot(values.bDataSmooth, values.fun, values.slice);
gaps = sh9.getGaps();
sh9.reposition(gaps);

fprintf('It should plot smooth signals with large deviation\n');
fig10 = figure('Name', 'Plot with smoothed signals with out of range signal');
sh10 = visviews.signalHistogramPlot(fig10, [], []);
assertTrue(isvalid(sh10));
data10 = values.bDataSmooth.getData();
data10(2,:) = 100*data10(6, :);
testVD10 = viscore.memoryData(data10, 'Large Cosine');
sh10.plot(testVD10, values.fun, values.slice);
gaps = sh10.getGaps();
sh10.reposition(gaps);

fprintf('It should produce a plot for a clump of nonepoched windows sliced along dim 3 \n');
fig11 = figure('Name', 'Plot clump for slice along dimension 3, not epoched');
sh11 = visviews.signalHistogramPlot(fig11, [], []);
assertTrue(isvalid(sh11));
slice11 = viscore.dataSlice('Slices', {':', ':', '2:4'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'}, 'CombineDim', 3);
sh11.plot(values.bDataSmooth, values.fun, slice11);
gaps = sh11.getGaps();
sh11.reposition(gaps);

fprintf('It should produce a plot for a clump of nonepoched windows sliced along dim 3 \n');
fig12 = figure('Name', 'Plot clump for slice along dimension 3, epoched');
sh12 = visviews.signalHistogramPlot(fig12, [], []);
assertTrue(isvalid(sh12));
slice12 = viscore.dataSlice('Slices', {':', ':', '2:4'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'}, 'CombineDim', 3);
sh12.plot(values.bDataEpoched, values.fun, slice12);
gaps = sh12.getGaps();
sh12.reposition(gaps);

fprintf('It should produce a single window plot for a clump of epoched windows sliced along dim 3 \n');
fig13 = figure('Name', 'Plot clump for slice along dimension 3, epoched (epoch 5 and 7 are big)');
sh13 = visviews.signalHistogramPlot(fig13, [], []);
assertTrue(isvalid(sh13));
bigData = values.bDataSmooth.getData;
bigData(:, :, 5) = 3*bigData(:, :, 5);
bigData(:, :, 7) = 3.5*bigData(:, :, 7);
testVD13 = viscore.memoryData(bigData, 'Sinusoidal', ...
    'Epoched', true, 'SampleRate', 256);
slice13 = viscore.dataSlice('Slices', {':', ':', '4:8'}, ...
    'DimNames', {'Channel', 'Sample', 'Epoch'}, 'CombineDim', 3);
sh13.plot(testVD13, values.fun, slice13);
gaps = sh13.getGaps();
sh13.reposition(gaps);

fprintf('It should produce a plot for a clump of nonepoched windows\n');
fig14 = figure('Name', 'Plot clump for channels 2:4 sliced dimension 1, big windows [5, 7], not epoched');
sh14 = visviews.signalHistogramPlot(fig14, [], []);
assertTrue(isvalid(sh14));
slice14 = viscore.dataSlice('Slices', {'30:32', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'}, 'CombineDim', 1);
sh14.plot(testVD13, values.fun, slice14);
gaps = sh14.getGaps();
sh14.reposition(gaps);
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

function testPlotHDF5(values) %#ok<DEFNU>
%test signalHistogramPlot plot
fprintf('\nUnit tests for visviews.signalHistogramPlot plot method\n')

fprintf('It should produce a plot for a normal slice along dim 3\n');
fig1 = figure('Name', 'Normal plot slice along dimension 3');
sh1 = visviews.signalHistogramPlot(fig1, [], []);
assertTrue(isvalid(sh1));
sh1.plot(values.hdf5Data, values.fun, values.slice);
gaps = sh1.getGaps();
sh1.reposition(gaps);

fprintf('It should produce a plot multiple window slice along dimension 3\n');
fig2 = figure('Name', 'Multiple windows - combine dim 3');
sh2 = visviews.signalHistogramPlot(fig2, [], []);
assertTrue(isvalid(sh2));
slice2 = viscore.dataSlice('Slices', {':', ':', '2:5'}, 'CombineDim', 3, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
sh2.plot(values.hdf5Data, values.fun, slice2);
gaps = sh2.getGaps();
sh2.reposition(gaps);

fprintf('It should produce a plot for EEG with combineDim 1\n');
fig3 = figure('Name', 'Single element - combine dim 1');
sh3 = visviews.signalHistogramPlot(fig3, [], []);
assertTrue(isvalid(sh3));
slice3 = viscore.dataSlice('Slices', {'1', ':', ':'}, 'CombineDim', 1, ...
    'DimNames', {'Channel', 'Sample', 'Window'}); 
sh3.plot(values.hdf5Data, values.fun, slice3);
gaps = sh3.getGaps();
sh3.reposition(gaps);

fprintf('It should produce a plot for EEG with multiple elements combineDim 1\n');
fig4 = figure('Name', 'Multiple elements - combine dim 1');
sh4 = visviews.signalHistogramPlot(fig4, [], []);
assertTrue(isvalid(sh4));
slice4 = viscore.dataSlice('Slices', {'1', ':', ':'}, 'CombineDim', 1, ...
    'DimNames', {'Channel', 'Sample', 'Window'}); 
sh4.plot(values.hdf5Data, values.fun, slice4);
gaps = sh4.getGaps();
sh4.reposition(gaps);

fprintf('It should produce a plot of epoched data for a normal slice along dim 3\n');
assertTrue(values.bDataEpoched.isEpoched())
fig5 = figure('Name', 'Plot when EEG data is epoched along dim 3');
sh5 = visviews.signalHistogramPlot(fig5, [], []);
sh5.plot(values.hdf5DataEpoched, values.fun, values.slice);
gaps = sh5.getGaps();
sh5.reposition(gaps);

fprintf('It should produce a plot multiple window slice along dimension 3\n');
fig6 = figure('Name', 'Epoched data, multiple windows - combine dim 3');
sh6 = visviews.signalHistogramPlot(fig6, [], []);
assertTrue(isvalid(sh6));
slice6 = viscore.dataSlice('Slices', {':', ':', '2:5'}, 'CombineDim', 3, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
sh6.plot(values.hdf5DataEpoched, values.fun, slice6);
gaps = sh6.getGaps();
sh6.reposition(gaps);

fprintf('It should produce a plot for EEG epoched data with combineDim 1\n');
fig7 = figure('Name', 'Single element epoched - combine dim 1');
sh7 = visviews.signalHistogramPlot(fig7, [], []);
assertTrue(isvalid(sh7));
slice7 = viscore.dataSlice('Slices', {'1', ':', ':'}, 'CombineDim', 1, ...
    'DimNames', {'Channel', 'Sample', 'Window'}); 
sh7.plot(values.hdf5DataEpoched, values.fun, slice7);
gaps = sh7.getGaps();
sh7.reposition(gaps);

fprintf('It should produce a plot for EEG epoched data with multiple elements combineDim 1\n');
fig8 = figure('Name', 'Multiple elements epoched - combine dim 1');
sh8 = visviews.signalHistogramPlot(fig8, [], []);
assertTrue(isvalid(sh8));
slice8 = viscore.dataSlice('Slices', {'1', ':', ':'}, 'CombineDim', 1, ...
    'DimNames', {'Channel', 'Sample', 'Window'}); 
sh8.plot(values.hdf5DataEpoched, values.fun, slice8);
gaps = sh8.getGaps();
sh8.reposition(gaps);

fprintf('It should plot smooth signals with red bars\n');
fig9 = figure('Name', 'Plot with smoothed signals');
sh9 = visviews.signalHistogramPlot(fig9, [], []);
assertTrue(isvalid(sh9));
sh9.HistogramColor = [1, 0, 0];
sh9.plot(values.bDataSmooth, values.fun, values.slice);
gaps = sh9.getGaps();
sh9.reposition(gaps);

fprintf('It should plot smooth signals with large deviation\n');
fig10 = figure('Name', 'Plot with smoothed signals with out of range signal');
sh10 = visviews.signalHistogramPlot(fig10, [], []);
assertTrue(isvalid(sh10));
data10 = values.bDataSmooth.getData();
data10(2,:) = 100*data10(6, :);
hdf5File = regexprep(which('EEG.mat'), 'EEG.mat$', 'EEG_NO_DATA.hdf5');
testVD10 = viscore.hdf5Data(data10, 'Large Cosine', hdf5File);
sh10.plot(testVD10, values.fun, values.slice);
gaps = sh10.getGaps();
sh10.reposition(gaps);
delete(hdf5File);

fprintf('It should produce a plot for a clump of nonepoched windows sliced along dim 3 \n');
fig11 = figure('Name', 'Plot clump for slice along dimension 3, not epoched');
sh11 = visviews.signalHistogramPlot(fig11, [], []);
assertTrue(isvalid(sh11));
slice11 = viscore.dataSlice('Slices', {':', ':', '2:4'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'}, 'CombineDim', 3);
sh11.plot(values.bDataSmooth, values.fun, slice11);
gaps = sh11.getGaps();
sh11.reposition(gaps);

fprintf('It should produce a plot for a clump of nonepoched windows sliced along dim 3 \n');
fig12 = figure('Name', 'Plot clump for slice along dimension 3, epoched');
sh12 = visviews.signalHistogramPlot(fig12, [], []);
assertTrue(isvalid(sh12));
slice12 = viscore.dataSlice('Slices', {':', ':', '2:4'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'}, 'CombineDim', 3);
sh12.plot(values.hdf5DataEpoched, values.fun, slice12);
gaps = sh12.getGaps();
sh12.reposition(gaps);

fprintf('It should produce a single window plot for a clump of epoched windows sliced along dim 3 \n');
fig13 = figure('Name', 'Plot clump for slice along dimension 3, epoched (epoch 5 and 7 are big)');
sh13 = visviews.signalHistogramPlot(fig13, [], []);
assertTrue(isvalid(sh13));
bigData = values.bDataSmooth.getData;
bigData(:, :, 5) = 3*bigData(:, :, 5);
bigData(:, :, 7) = 3.5*bigData(:, :, 7);
hdf5File = regexprep(which('EEG.mat'), 'EEG.mat$', 'EEG_NO_DATA.hdf5');
testVD13 = viscore.hdf5Data(bigData, 'Sinusoidal', hdf5File, ...
    'Epoched', true, 'SampleRate', 256);
slice13 = viscore.dataSlice('Slices', {':', ':', '4:8'}, ...
    'DimNames', {'Channel', 'Sample', 'Epoch'}, 'CombineDim', 3);
sh13.plot(testVD13, values.fun, slice13);
gaps = sh13.getGaps();
sh13.reposition(gaps);

fprintf('It should produce a plot for a clump of nonepoched windows\n');
fig14 = figure('Name', 'Plot clump for channels 2:4 sliced dimension 1, big windows [5, 7], not epoched');
sh14 = visviews.signalHistogramPlot(fig14, [], []);
assertTrue(isvalid(sh14));
slice14 = viscore.dataSlice('Slices', {'30:32', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'}, 'CombineDim', 1);
sh14.plot(testVD13, values.fun, slice14);
gaps = sh14.getGaps();
sh14.reposition(gaps);
drawnow
delete(hdf5File);

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
% Unit test visviews.signalHistogramPlot plot constant and NaN
fprintf('\nUnit tests for visviews.signalHistogramPlot plot method with constant and NaN values\n')

% All zeros
fprintf('It should produce a plot for when all of the values are 0\n');
data = zeros([32, 1000, 20]);
testVD1 = viscore.memoryData(data, 'All zeros');
fig1 = figure('Name', 'All zero values');
sh1 = visviews.signalHistogramPlot(fig1, [], []);
assertTrue(isvalid(sh1));
sh1.plot(testVD1, values.fun, values.slice);
gaps = sh1.getGaps();
sh1.reposition(gaps);

% Data zeros, function NaN
fprintf('It should produce a plot for when data is zero, funcs NaNs (---see warning)\n');
fig2 = figure('Name', 'Data zero, func NaN');
sh2 = visviews.signalHistogramPlot(fig2, [], []);
assertTrue(isvalid(sh2));
sh2.plot(testVD1, [], values.slice);
gaps = sh2.getGaps();
sh2.reposition(gaps);

% Data NaN
fprintf('It should produce a plot for when data is zero, funcs NaNs (---see warning)\n');
data = NaN([32, 1000, 20]);
testVD3 = viscore.memoryData(data, 'Data NaN');
fig3 = figure('Name', 'Data NaNs');
sh3 = visviews.signalHistogramPlot(fig3, [], []);
assertTrue(isvalid(sh3));
sh3.plot(testVD3, values.fun, values.slice);
gaps = sh3.getGaps();
sh3.reposition(gaps);

% Data slice empty
fprintf('It should produce empty axes when data slice is empty (---see warning)\n');
data = zeros(5, 1);
testVD4 = viscore.memoryData(data, 'Data empty');
slice4 = viscore.dataSlice('Slices', {'6', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
fig4 = figure('Name', 'Data slice is empty');
sh4 = visviews.signalHistogramPlot(fig4, [], []);
assertTrue(isvalid(sh4));
sh4.plot(testVD4, values.fun, slice4);
gaps = sh4.getGaps();
sh4.reposition(gaps);
drawnow
if values.deleteFigures
    delete(fig1);
    delete(fig2);
    delete(fig3);
    delete(fig4);
end

function testConstantAndNaNValuesHDF5(values) %#ok<DEFNU>
% Unit test visviews.signalHistogramPlot plot constant and NaN
fprintf('\nUnit tests for visviews.signalHistogramPlot plot method with constant and NaN values\n')

% All zeros
fprintf('It should produce a plot for when all of the values are 0\n');
data = zeros([32, 1000, 20]);
hdf5File = regexprep(which('EEG.mat'), 'EEG.mat$', 'EEG_NO_DATA.hdf5');
testVD1 = viscore.hdf5Data(data, 'All zeros', hdf5File);
fig1 = figure('Name', 'All zero values');
sh1 = visviews.signalHistogramPlot(fig1, [], []);
assertTrue(isvalid(sh1));
sh1.plot(testVD1, values.fun, values.slice);
gaps = sh1.getGaps();
sh1.reposition(gaps);

% Data zeros, function NaN
fprintf('It should produce a plot for when data is zero, funcs NaNs (---see warning)\n');
fig2 = figure('Name', 'Data zero, func NaN');
sh2 = visviews.signalHistogramPlot(fig2, [], []);
assertTrue(isvalid(sh2));
sh2.plot(testVD1, [], values.slice);
gaps = sh2.getGaps();
sh2.reposition(gaps);
delete(hdf5File);

% Data NaN
fprintf('It should produce a plot for when data is zero, funcs NaNs (---see warning)\n');
data = NaN([32, 1000, 20]);
hdf5File = regexprep(which('EEG.mat'), 'EEG.mat$', 'EEG_NO_DATA.hdf5');
testVD3 = viscore.hdf5Data(data, 'Data NaN', hdf5File);
fig3 = figure('Name', 'Data NaNs');
sh3 = visviews.signalHistogramPlot(fig3, [], []);
assertTrue(isvalid(sh3));
sh3.plot(testVD3, values.fun, values.slice);
gaps = sh3.getGaps();
sh3.reposition(gaps);
delete(hdf5File);

% Data slice empty
fprintf('It should produce empty axes when data slice is empty (---see warning)\n');
data = zeros(5, 1);
hdf5File = regexprep(which('EEG.mat'), 'EEG.mat$', 'EEG_NO_DATA.hdf5');
testVD4 = viscore.hdf5Data(data, 'Data empty', hdf5File);
slice4 = viscore.dataSlice('Slices', {'6', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
fig4 = figure('Name', 'Data slice is empty');
sh4 = visviews.signalHistogramPlot(fig4, [], []);
assertTrue(isvalid(sh4));
sh4.plot(testVD4, values.fun, slice4);
gaps = sh4.getGaps();
sh4.reposition(gaps);
drawnow
delete(hdf5File);
if values.deleteFigures
    delete(fig1);
    delete(fig2);
    delete(fig3);
    delete(fig4);
end

function testGetDefaultProperties(values) %#ok<INUSD,DEFNU>
% testStackedSignalPlot unit test for static getDefaultProperties
fprintf('\nUnit tests for visviews.signalHistogramPlot getDefaultProperties\n');
fprintf('It should have a getDefaultProperties method that returns a structure\n');
s = visviews.signalHistogramPlot.getDefaultProperties();
assertTrue(isa(s, 'struct'));

