function test_suite = testSignalHistogramPlot %#ok<STOUT>
% Unit tests for visviews.signalHistogramPlot
initTestSuite;

function values = setup %#ok<DEFNU>
keyfun = @(x) x.('ShortName');
defFuns= visfuncs.functionObj.createObjects( ...
    'visfuncs.functionObj', viewTestClass.getDefaultFunctions(), keyfun);
values.fun = defFuns{1};

values.slice = viscore.dataSlice('Slices', {':', ':', '1'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
values.deleteFigures = true;

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
% test signalHistogramPlot plot
fprintf('\nUnit tests for visviews.signalHistogramPlot plot method\n')

fprintf('It should produce a plot for a normal slice along dim 3\n');
load('EEG.mat'); 
bData = viscore.memoryData(EEG.data, 'EEG', ...
    'SampleRate', EEG.srate);
fig1 = figure('Name', 'Normal plot slice along dimension 3');
sh1 = visviews.signalHistogramPlot(fig1, [], []);
assertTrue(isvalid(sh1));
sh1.plot(bData, values.fun, values.slice);
gaps = sh1.getGaps();
sh1.reposition(gaps);

fprintf('It should produce a plot multiple window slice along dimension 3\n');
fig2 = figure('Name', 'Multiple windows - combine dim 3');
sh2 = visviews.signalHistogramPlot(fig2, [], []);
assertTrue(isvalid(sh2));
slice2 = viscore.dataSlice('Slices', {':', ':', '2:5'}, 'CombineDim', 3, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
sh2.plot(bData, values.fun, slice2);
gaps = sh2.getGaps();
sh2.reposition(gaps);

fprintf('It should produce a plot for EEG with combineDim 1\n');
fig3 = figure('Name', 'Single element - combine dim 1');
sh3 = visviews.signalHistogramPlot(fig3, [], []);
assertTrue(isvalid(sh3));
slice3 = viscore.dataSlice('Slices', {'1', ':', ':'}, 'CombineDim', 1, ...
    'DimNames', {'Channel', 'Sample', 'Window'}); 
sh3.plot(bData, values.fun, slice3);
gaps = sh3.getGaps();
sh3.reposition(gaps);

fprintf('It should produce a plot for EEG with multiple elements combineDim 1\n');
fig4 = figure('Name', 'Multiple elements - combine dim 1');
sh4 = visviews.signalHistogramPlot(fig4, [], []);
assertTrue(isvalid(sh4));
slice4 = viscore.dataSlice('Slices', {'1', ':', ':'}, 'CombineDim', 1, ...
    'DimNames', {'Channel', 'Sample', 'Window'}); 
sh4.plot(bData, values.fun, slice4);
gaps = sh4.getGaps();
sh4.reposition(gaps);

fprintf('It should produce a plot of epoched data for a normal slice along dim 3\n');
load('EEGEpoch.mat');
[event, startTimes, timeScale] = ...
           viscore.blockedEvents.getEEGTimes(EEGEpoch);
bDataEpoched = viscore.memoryData(EEGEpoch.data, 'EEGEpoch', ...
    'SampleRate', EEGEpoch.srate, 'Epoched', true, ...
    'Events', event, 'BlockStartTimes', startTimes, ...
    'BlockTimeScale', timeScale);
assertTrue(bDataEpoched.isEpoched())
fig5 = figure('Name', 'Plot when EEG data is epoched along dim 3');
sh5 = visviews.signalHistogramPlot(fig5, [], []);
sh5.plot(bDataEpoched, values.fun, values.slice);
gaps = sh5.getGaps();
sh5.reposition(gaps);

fprintf('It should produce a plot multiple window slice along dimension 3\n');
fig6 = figure('Name', 'Epoched data, multiple windows - combine dim 3');
sh6 = visviews.signalHistogramPlot(fig6, [], []);
assertTrue(isvalid(sh6));
slice6 = viscore.dataSlice('Slices', {':', ':', '2:5'}, 'CombineDim', 3, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
sh6.plot(bDataEpoched, values.fun, slice6);
gaps = sh6.getGaps();
sh6.reposition(gaps);

fprintf('It should produce a plot for EEG epoched data with combineDim 1\n');
fig7 = figure('Name', 'Single element epoched - combine dim 1');
sh7 = visviews.signalHistogramPlot(fig7, [], []);
assertTrue(isvalid(sh7));
slice7 = viscore.dataSlice('Slices', {'1', ':', ':'}, 'CombineDim', 1, ...
    'DimNames', {'Channel', 'Sample', 'Window'}); 
sh7.plot(bDataEpoched, values.fun, slice7);
gaps = sh7.getGaps();
sh7.reposition(gaps);

fprintf('It should produce a plot for EEG epoched data with multiple elements combineDim 1\n');
fig8 = figure('Name', 'Multiple elements epoched - combine dim 1');
sh8 = visviews.signalHistogramPlot(fig8, [], []);
assertTrue(isvalid(sh8));
slice8 = viscore.dataSlice('Slices', {'1', ':', ':'}, 'CombineDim', 1, ...
    'DimNames', {'Channel', 'Sample', 'Window'}); 
sh8.plot(bDataEpoched, values.fun, slice8);
gaps = sh8.getGaps();
sh8.reposition(gaps);

fprintf('It should plot smooth signals with red bars\n');
load('DataSmooth.mat');
bDataSmooth =  viscore.memoryData(dataSmooth, 'Smooth');
fig9 = figure('Name', 'Plot with smoothed signals');
sh9 = visviews.signalHistogramPlot(fig9, [], []);
assertTrue(isvalid(sh9));
sh9.HistogramColor = [1, 0, 0];
sh9.plot(bDataSmooth, values.fun, values.slice);
gaps = sh9.getGaps();
sh9.reposition(gaps);

fprintf('It should plot smooth signals with large deviation\n');
load('DataSmoothTrim.mat');
bDataSmoothTrim =  viscore.memoryData(dataSmoothTrim, 'Large Cosine');
fig10 = figure('Name', 'Plot with smoothed signals with out of range signal');
sh10 = visviews.signalHistogramPlot(fig10, [], []);
assertTrue(isvalid(sh10));
sh10.plot(bDataSmoothTrim, values.fun, values.slice);
gaps = sh10.getGaps();
sh10.reposition(gaps);

fprintf('It should produce a plot for a clump of nonepoched windows sliced along dim 3 \n');
fig11 = figure('Name', 'Plot clump for slice along dimension 3, not epoched');
sh11 = visviews.signalHistogramPlot(fig11, [], []);
assertTrue(isvalid(sh11));
slice11 = viscore.dataSlice('Slices', {':', ':', '2:4'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'}, 'CombineDim', 3);
sh11.plot(bDataSmooth, values.fun, slice11);
gaps = sh11.getGaps();
sh11.reposition(gaps);
drawnow;

fprintf('It should produce a plot for a clump of nonepoched windows sliced along dim 3 \n');
fig12 = figure('Name', 'Plot clump for slice along dimension 3, epoched');
sh12 = visviews.signalHistogramPlot(fig12, [], []);
assertTrue(isvalid(sh12));
slice12 = viscore.dataSlice('Slices', {':', ':', '2:4'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'}, 'CombineDim', 3);
sh12.plot(bDataEpoched, values.fun, slice12);
gaps = sh12.getGaps();
sh12.reposition(gaps);

fprintf('It should produce a single window plot for a clump of epoched windows sliced along dim 3 \n');
load('DataSmoothSingleWindow.mat');
bDataSmoothSingleWindow =  viscore.memoryData(dataSmoothSingleWindow, 'Sinusoidal', ...
    'Epoched', true, 'SampleRate', 256);
fig13 = figure('Name', 'Plot clump for slice along dimension 3, epoched (epoch 5 and 7 are big)');
sh13 = visviews.signalHistogramPlot(fig13, [], []);
assertTrue(isvalid(sh13));
slice13 = viscore.dataSlice('Slices', {':', ':', '4:8'}, ...
    'DimNames', {'Channel', 'Sample', 'Epoch'}, 'CombineDim', 3);
sh13.plot(bDataSmoothSingleWindow, values.fun, slice13);
gaps = sh13.getGaps();
sh13.reposition(gaps);

fprintf('It should produce a plot for a clump of nonepoched windows\n');
fig14 = figure('Name', 'Plot clump for channels 2:4 sliced dimension 1, big windows [5, 7], not epoched');
sh14 = visviews.signalHistogramPlot(fig14, [], []);
assertTrue(isvalid(sh14));
slice14 = viscore.dataSlice('Slices', {'30:32', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'}, 'CombineDim', 1);
sh14.plot(bDataSmoothSingleWindow, values.fun, slice14);
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
eegFile = regexprep(which('EEG.mat'), 'EEG.mat$', 'EEG.hdf5');
load('EEG.mat');
hdf5Data = viscore.hdf5Data(EEG.data, 'EEG', eegFile, ...
    'SampleRate', EEG.srate);
fig1 = figure('Name', 'Normal plot slice along dimension 3');
sh1 = visviews.signalHistogramPlot(fig1, [], []);
assertTrue(isvalid(sh1));
sh1.plot(hdf5Data, values.fun, values.slice);
gaps = sh1.getGaps();
sh1.reposition(gaps);

fprintf('It should produce a plot multiple window slice along dimension 3\n');
fig2 = figure('Name', 'Multiple windows - combine dim 3');
sh2 = visviews.signalHistogramPlot(fig2, [], []);
assertTrue(isvalid(sh2));
slice2 = viscore.dataSlice('Slices', {':', ':', '2:5'}, 'CombineDim', 3, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
sh2.plot(hdf5Data, values.fun, slice2);
gaps = sh2.getGaps();
sh2.reposition(gaps);

fprintf('It should produce a plot for EEG with combineDim 1\n');
fig3 = figure('Name', 'Single element - combine dim 1');
sh3 = visviews.signalHistogramPlot(fig3, [], []);
assertTrue(isvalid(sh3));
slice3 = viscore.dataSlice('Slices', {'1', ':', ':'}, 'CombineDim', 1, ...
    'DimNames', {'Channel', 'Sample', 'Window'}); 
sh3.plot(hdf5Data, values.fun, slice3);
gaps = sh3.getGaps();
sh3.reposition(gaps);

fprintf('It should produce a plot for EEG with multiple elements combineDim 1\n');
fig4 = figure('Name', 'Multiple elements - combine dim 1');
sh4 = visviews.signalHistogramPlot(fig4, [], []);
assertTrue(isvalid(sh4));
slice4 = viscore.dataSlice('Slices', {'1', ':', ':'}, 'CombineDim', 1, ...
    'DimNames', {'Channel', 'Sample', 'Window'}); 
sh4.plot(hdf5Data, values.fun, slice4);
gaps = sh4.getGaps();
sh4.reposition(gaps);

fprintf('It should produce a plot of epoched data for a normal slice along dim 3\n');
eegEpochFile = regexprep(which('EEG.mat'), 'EEG.mat$', 'EEGEpoch.hdf5');
load('EEGEpoch.mat');
[event, startTimes, timeScale] = ...
           viscore.blockedEvents.getEEGTimes(EEGEpoch);
hdf5DataEpoched = viscore.hdf5Data(EEGEpoch.data, 'EEGEpoch', eegEpochFile, ...
    'SampleRate', EEGEpoch.srate, 'Epoched', true, ...
    'Events', event, 'BlockStartTimes', startTimes, ...
    'BlockTimeScale', timeScale);
assertTrue(hdf5DataEpoched.isEpoched())
fig5 = figure('Name', 'Plot when EEG data is epoched along dim 3');
sh5 = visviews.signalHistogramPlot(fig5, [], []);
sh5.plot(hdf5DataEpoched, values.fun, values.slice);
gaps = sh5.getGaps();
sh5.reposition(gaps);

fprintf('It should produce a plot multiple window slice along dimension 3\n');
fig6 = figure('Name', 'Epoched data, multiple windows - combine dim 3');
sh6 = visviews.signalHistogramPlot(fig6, [], []);
assertTrue(isvalid(sh6));
slice6 = viscore.dataSlice('Slices', {':', ':', '2:5'}, 'CombineDim', 3, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
sh6.plot(hdf5DataEpoched, values.fun, slice6);
gaps = sh6.getGaps();
sh6.reposition(gaps);

fprintf('It should produce a plot for EEG epoched data with combineDim 1\n');
fig7 = figure('Name', 'Single element epoched - combine dim 1');
sh7 = visviews.signalHistogramPlot(fig7, [], []);
assertTrue(isvalid(sh7));
slice7 = viscore.dataSlice('Slices', {'1', ':', ':'}, 'CombineDim', 1, ...
    'DimNames', {'Channel', 'Sample', 'Window'}); 
sh7.plot(hdf5DataEpoched, values.fun, slice7);
gaps = sh7.getGaps();
sh7.reposition(gaps);

fprintf('It should produce a plot for EEG epoched data with multiple elements combineDim 1\n');
fig8 = figure('Name', 'Multiple elements epoched - combine dim 1');
sh8 = visviews.signalHistogramPlot(fig8, [], []);
assertTrue(isvalid(sh8));
slice8 = viscore.dataSlice('Slices', {'1', ':', ':'}, 'CombineDim', 1, ...
    'DimNames', {'Channel', 'Sample', 'Window'}); 
sh8.plot(hdf5DataEpoched, values.fun, slice8);
gaps = sh8.getGaps();
sh8.reposition(gaps);

fprintf('It should plot smooth signals with red bars\n');
load('DataSmooth.mat');
smoothFile = regexprep(which('EEG.mat'), 'EEG.mat$', 'dataSmooth.hdf5');
hdf5DataSmooth =  viscore.hdf5Data(dataSmooth, 'Smooth', smoothFile);
fig9 = figure('Name', 'Plot with smoothed signals');
sh9 = visviews.signalHistogramPlot(fig9, [], []);
assertTrue(isvalid(sh9));
sh9.HistogramColor = [1, 0, 0];
sh9.plot(hdf5DataSmooth, values.fun, values.slice);
gaps = sh9.getGaps();
sh9.reposition(gaps);

fprintf('It should plot smooth signals with large deviation\n');
load('DataSmoothTrim.mat');
smoothTrimFile = regexprep(which('EEG.mat'), 'EEG.mat$', 'dataSmoothTrim.hdf5');
hdf5DataSmoothTrim =  viscore.hdf5Data(dataSmoothTrim, 'Large Cosine', smoothTrimFile);
fig10 = figure('Name', 'Plot with smoothed signals with out of range signal');
sh10 = visviews.signalHistogramPlot(fig10, [], []);
assertTrue(isvalid(sh10));
sh10.plot(hdf5DataSmoothTrim, values.fun, values.slice);
gaps = sh10.getGaps();
sh10.reposition(gaps);

fprintf('It should produce a plot for a clump of nonepoched windows sliced along dim 3 \n');
fig11 = figure('Name', 'Plot clump for slice along dimension 3, not epoched');
sh11 = visviews.signalHistogramPlot(fig11, [], []);
assertTrue(isvalid(sh11));
slice11 = viscore.dataSlice('Slices', {':', ':', '2:4'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'}, 'CombineDim', 3);
sh11.plot(hdf5DataSmooth, values.fun, slice11);
gaps = sh11.getGaps();
sh11.reposition(gaps);

fprintf('It should produce a plot for a clump of nonepoched windows sliced along dim 3 \n');
fig12 = figure('Name', 'Plot clump for slice along dimension 3, epoched');
sh12 = visviews.signalHistogramPlot(fig12, [], []);
assertTrue(isvalid(sh12));
slice12 = viscore.dataSlice('Slices', {':', ':', '2:4'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'}, 'CombineDim', 3);
sh12.plot(hdf5DataEpoched, values.fun, slice12);
gaps = sh12.getGaps();
sh12.reposition(gaps);

fprintf('It should produce a single window plot for a clump of epoched windows sliced along dim 3 \n');
load('DataSmoothSingleWindow.mat');
smoothSingleWindowFile = regexprep(which('EEG.mat'), 'EEG.mat$', 'dataSmoothSingleWindow.hdf5');
hdf5DataSmoothSingleWindow =  viscore.hdf5Data(dataSmoothSingleWindow, 'Sinusoidal', smoothSingleWindowFile, ...
    'Epoched', true, 'SampleRate', 256);
fig13 = figure('Name', 'Plot clump for slice along dimension 3, epoched (epoch 5 and 7 are big)');
sh13 = visviews.signalHistogramPlot(fig13, [], []);
assertTrue(isvalid(sh13));
slice13 = viscore.dataSlice('Slices', {':', ':', '4:8'}, ...
    'DimNames', {'Channel', 'Sample', 'Epoch'}, 'CombineDim', 3);
sh13.plot(hdf5DataSmoothSingleWindow, values.fun, slice13);
gaps = sh13.getGaps();
sh13.reposition(gaps);

fprintf('It should produce a plot for a clump of nonepoched windows\n');
fig14 = figure('Name', 'Plot clump for channels 2:4 sliced dimension 1, big windows [5, 7], not epoched');
sh14 = visviews.signalHistogramPlot(fig14, [], []);
assertTrue(isvalid(sh14));
slice14 = viscore.dataSlice('Slices', {'30:32', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'}, 'CombineDim', 1);
sh14.plot(hdf5DataSmoothSingleWindow, values.fun, slice14);
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


function testConstantAndNaNValues(values) %#ok<DEFNU>
% Unit test visviews.signalHistogramPlot plot constant and NaN
fprintf('\nUnit tests for visviews.signalHistogramPlot plot method with constant and NaN values\n')

% All zeros
fprintf('It should produce a plot for when all of the values are 0\n');
load('AllZeros.mat');
testVD1 = viscore.memoryData(allZeros, 'All zeros');
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
load('AllNaN.mat');
testVD3 = viscore.memoryData(allNaN, 'Data NaN');
fig3 = figure('Name', 'Data NaNs');
sh3 = visviews.signalHistogramPlot(fig3, [], []);
assertTrue(isvalid(sh3));
sh3.plot(testVD3, values.fun, values.slice);
gaps = sh3.getGaps();
sh3.reposition(gaps);

% Data slice empty
fprintf('It should produce empty axes when data slice is empty (---see warning)\n');
load('EmptySlice.mat');
testVD4 = viscore.memoryData(emptySlice, 'Data empty');
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
allZerosFile = regexprep(which('EEG.mat'), 'EEG.mat$', 'AllZeros.hdf5');
load('AllZeros.mat');
testVD1 = viscore.hdf5Data(allZeros, 'All zeros', allZerosFile);
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
NaNFile = regexprep(which('EEG.mat'), 'EEG.mat$', 'NaN.hdf5');
load('AllNaN.mat');
testVD3 = viscore.hdf5Data(allNaN,'Data NaN', NaNFile);
fig3 = figure('Name', 'Data NaNs');
sh3 = visviews.signalHistogramPlot(fig3, [], []);
assertTrue(isvalid(sh3));
sh3.plot(testVD3, values.fun, values.slice);
gaps = sh3.getGaps();
sh3.reposition(gaps);

% Data slice empty
fprintf('It should produce empty axes when data slice is empty (---see warning)\n');
emptySliceFile = regexprep(which('EEG.mat'), 'EEG.mat$', 'EmptySlice.hdf5');
load('EmptySlice.mat');
testVD4 = viscore.hdf5Data(emptySlice, 'Data empty', emptySliceFile);
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

function testGetDefaultProperties(values) %#ok<INUSD,DEFNU>
% testStackedSignalPlot unit test for static getDefaultProperties
fprintf('\nUnit tests for visviews.signalHistogramPlot getDefaultProperties\n');
fprintf('It should have a getDefaultProperties method that returns a structure\n');
s = visviews.signalHistogramPlot.getDefaultProperties();
assertTrue(isa(s, 'struct'));