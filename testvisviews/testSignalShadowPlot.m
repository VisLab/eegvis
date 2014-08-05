function test_suite = testSignalShadowPlot %#ok<STOUT>
% Unit tests for signalShadowPlot
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
load('EEG.mat');
bData = viscore.memoryData(EEG.data, 'EEG', ...
    'SampleRate', EEG.srate); 
fig1 = figure('Name', 'Normal plot slice along dimension 3');
sp1 = visviews.signalShadowPlot(fig1, [], []);
assertTrue(isvalid(sp1));
sp1.plot(bData, values.fun, values.slice);
gaps = sp1.getGaps();
sp1.reposition(gaps);

fprintf('It should produce a plot multiple window slice along dimension 3\n');
fig2 = figure('Name', 'Multiple windows - combine dim 3');
sp2 = visviews.signalShadowPlot(fig2, [], []);
assertTrue(isvalid(sp2));
slice2 = viscore.dataSlice('Slices', {':', ':', '2:5'}, 'CombineDim', 3, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
sp2.plot(bData, values.fun, slice2);
gaps = sp2.getGaps();
sp2.reposition(gaps);

fprintf('It should produce a plot for EEG with combineDim 1\n');
fig3 = figure('Name', 'Single element - combine dim 1');
sp3 = visviews.signalShadowPlot(fig3, [], []);
assertTrue(isvalid(sp3));
slice3 = viscore.dataSlice('Slices', {'1', ':', ':'}, 'CombineDim', 1, ...
    'DimNames', {'Channel', 'Sample', 'Window'}); 
sp3.plot(bData, values.fun, slice3);
gaps = sp3.getGaps();
sp3.reposition(gaps);

fprintf('It should produce a plot for EEG with multiple elements combineDim 1\n');
fig4 = figure('Name', 'Multiple elements - combine dim 1');
sp4 = visviews.signalShadowPlot(fig4, [], []);
assertTrue(isvalid(sp4));
slice4 = viscore.dataSlice('Slices', {'1', ':', ':'}, 'CombineDim', 1, ...
    'DimNames', {'Channel', 'Sample', 'Window'}); 
sp4.plot(bData, values.fun, slice4);
gaps = sp4.getGaps();
sp4.reposition(gaps);

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
sp5 = visviews.signalShadowPlot(fig5, [], []);
sp5.plot(bDataEpoched, values.fun, values.slice);
gaps = sp5.getGaps();
sp5.reposition(gaps);

fprintf('It should produce a plot multiple window slice along dimension 3\n');
fig6 = figure('Name', 'Epoched data, multiple windows - combine dim 3');
sp6 = visviews.signalShadowPlot(fig6, [], []);
assertTrue(isvalid(sp6));
slice6 = viscore.dataSlice('Slices', {':', ':', '2:5'}, 'CombineDim', 3, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
sp6.plot(bDataEpoched, values.fun, slice6);
gaps = sp6.getGaps();
sp6.reposition(gaps);

fprintf('It should produce a plot for EEG epoched data with combineDim 1\n');
fig7 = figure('Name', 'Single element epoched - combine dim 1');
sp7 = visviews.signalShadowPlot(fig7, [], []);
assertTrue(isvalid(sp7));
slice7 = viscore.dataSlice('Slices', {'1', ':', ':'}, 'CombineDim', 1, ...
    'DimNames', {'Channel', 'Sample', 'Window'}); 
sp7.plot(bDataEpoched, values.fun, slice7);
gaps = sp7.getGaps();
sp7.reposition(gaps);

fprintf('It should produce a plot for EEG epoched data with multiple elements combineDim 1\n');
fig8 = figure('Name', 'Multiple elements epoched - combine dim 1');
sp8 = visviews.signalShadowPlot(fig8, [], []);
assertTrue(isvalid(sp8));
slice8 = viscore.dataSlice('Slices', {'1', ':', ':'}, 'CombineDim', 1, ...
    'DimNames', {'Channel', 'Sample', 'Window'}); 
sp8.plot(bDataEpoched, values.fun, slice8);
gaps = sp8.getGaps();
sp8.reposition(gaps);

fprintf('It should plot smooth signals\n');
load('DataSmooth.mat');
bDataSmooth =  viscore.memoryData(dataSmooth, 'Smooth');
fig9 = figure('Name', 'Plot with smoothed signals');
sp9 = visviews.signalShadowPlot(fig9, [], []);
assertTrue(isvalid(sp9));
sp9.CutoffScore = 2.0;
sp9.plot(bDataSmooth, values.fun, values.slice);
gaps = sp9.getGaps();
sp9.reposition(gaps);

fprintf('It should plot smooth signals with a trim percent\n');
load('DataSmoothTrim.mat');
bDataSmoothTrim =  viscore.memoryData(dataSmoothTrim, 'Large Cosine');
fig10 = figure('Name', 'Plot with smoothed signals with out of range signal');
sp10 = visviews.signalShadowPlot(fig10, [], []);
assertTrue(isvalid(sp6));
sp10.CutoffScore = 2.0;
sp10.TrimPercent = 5;
sp10.plot(bDataSmoothTrim, values.fun, values.slice);
gaps = sp10.getGaps();
sp10.reposition(gaps);

fprintf('It should produce a plot for a clump of nonepoched windows sliced along dim 3 \n');
fig11 = figure('Name', 'Plot clump for slice along dimension 3, not epoched');
sp11 = visviews.signalShadowPlot(fig11, [], []);
assertTrue(isvalid(sp11));
slice11 = viscore.dataSlice('Slices', {':', ':', '2:4'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'}, 'CombineDim', 3);
sp11.plot(bDataSmooth, values.fun, slice11);
gaps = sp11.getGaps();
sp11.reposition(gaps);

fprintf('It should produce a plot for a clump of nonepoched windows sliced along dim 3 \n');
fig12 = figure('Name', 'Plot clump for slice along dimension 3, epoched');
sp12 = visviews.signalShadowPlot(fig12, [], []);
assertTrue(isvalid(sp12));
slice12 = viscore.dataSlice('Slices', {':', ':', '2:4'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'}, 'CombineDim', 3);
sp12.plot(bDataEpoched, values.fun, slice12);
gaps = sp12.getGaps();
sp12.reposition(gaps);

fprintf('It should produce a single window plot for a clump of epoched windows sliced along dim 3 \n');
load('DataSmoothSingleWindow.mat');
bDataSmoothSingleWindow =  viscore.memoryData(dataSmoothSingleWindow, 'Sinusoidal', ...
    'Epoched', true, 'SampleRate', 256);
fig13 = figure('Name', 'Plot clump for slice along dimension 3, epoched (epoch 5 and 7 are big)');
sp13 = visviews.signalShadowPlot(fig13, [], []);
assertTrue(isvalid(sp13));
slice13 = viscore.dataSlice('Slices', {':', ':', '4:8'}, ...
    'DimNames', {'Channel', 'Sample', 'Epoch'}, 'CombineDim', 3);
sp13.plot(bDataSmoothSingleWindow, values.fun, slice13);
gaps = sp13.getGaps();
sp13.reposition(gaps);

fprintf('It should produce a plot for a clump of nonepoched windows\n');
fig14 = figure('Name', 'Plot clump for channels 2:4 sliced dimension 1, big windows [5, 7], not epoched');
sp14 = visviews.signalShadowPlot(fig14, [], []);
assertTrue(isvalid(sp4));
slice14 = viscore.dataSlice('Slices', {'30:32', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'}, 'CombineDim', 1);
sp14.plot(bDataSmoothSingleWindow, values.fun, slice14);
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

function testPlotHDF5(values) %#ok<DEFNU>
%test signalShadowPlot plot
fprintf('\nUnit tests for visviews.signalShadowPlot plot method\n')

fprintf('It should produce a plot for a normal slice along dim 3\n');
load('EEG.mat');
eegFile = regexprep(which('EEG.mat'), 'EEG.mat$', 'EEG.hdf5');
hdf5Data = viscore.hdf5Data(EEG.data, 'EEG', eegFile, ...
    'SampleRate', EEG.srate);
fig1 = figure('Name', 'Normal plot slice along dimension 3');
sp1 = visviews.signalShadowPlot(fig1, [], []);
assertTrue(isvalid(sp1));
sp1.plot(hdf5Data, values.fun, values.slice);
gaps = sp1.getGaps();
sp1.reposition(gaps);

fprintf('It should produce a plot multiple window slice along dimension 3\n');
fig2 = figure('Name', 'Multiple windows - combine dim 3');
sp2 = visviews.signalShadowPlot(fig2, [], []);
assertTrue(isvalid(sp2));
slice2 = viscore.dataSlice('Slices', {':', ':', '2:5'}, 'CombineDim', 3, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
sp2.plot(hdf5Data, values.fun, slice2);
gaps = sp2.getGaps();
sp2.reposition(gaps);

fprintf('It should produce a plot for EEG with combineDim 1\n');
fig3 = figure('Name', 'Single element - combine dim 1');
sp3 = visviews.signalShadowPlot(fig3, [], []);
assertTrue(isvalid(sp3));
slice3 = viscore.dataSlice('Slices', {'1', ':', ':'}, 'CombineDim', 1, ...
    'DimNames', {'Channel', 'Sample', 'Window'}); 
sp3.plot(hdf5Data, values.fun, slice3);
gaps = sp3.getGaps();
sp3.reposition(gaps);

fprintf('It should produce a plot for EEG with multiple elements combineDim 1\n');
fig4 = figure('Name', 'Multiple elements - combine dim 1');
sp4 = visviews.signalShadowPlot(fig4, [], []);
assertTrue(isvalid(sp4));
slice4 = viscore.dataSlice('Slices', {'1', ':', ':'}, 'CombineDim', 1, ...
    'DimNames', {'Channel', 'Sample', 'Window'}); 
sp4.plot(hdf5Data, values.fun, slice4);
gaps = sp4.getGaps();
sp4.reposition(gaps);

fprintf('It should produce a plot of epoched data for a normal slice along dim 3\n');
load('EEGEpoch.mat');
eegEpochFile = regexprep(which('EEG.mat'), 'EEG.mat$', 'EEGEpoch.hdf5');
[event, startTimes, timeScale] = ...
           viscore.blockedEvents.getEEGTimes(EEGEpoch);
hdf5DataEpoched = viscore.hdf5Data(EEGEpoch.data, 'EEGEpoch', eegEpochFile, ...
    'SampleRate', EEGEpoch.srate, 'Epoched', true, ...
    'Events', event, 'BlockStartTimes', startTimes, ...
    'BlockTimeScale', timeScale);
assertTrue(hdf5DataEpoched.isEpoched())
fig5 = figure('Name', 'Plot when EEG data is epoched along dim 3');
sp5 = visviews.signalShadowPlot(fig5, [], []);
sp5.plot(hdf5DataEpoched, values.fun, values.slice);
gaps = sp5.getGaps();
sp5.reposition(gaps);

fprintf('It should produce a plot multiple window slice along dimension 3\n');
fig6 = figure('Name', 'Epoched data, multiple windows - combine dim 3');
sp6 = visviews.signalShadowPlot(fig6, [], []);
assertTrue(isvalid(sp6));
slice6 = viscore.dataSlice('Slices', {':', ':', '2:5'}, 'CombineDim', 3, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
sp6.plot(hdf5DataEpoched, values.fun, slice6);
gaps = sp6.getGaps();
sp6.reposition(gaps);

fprintf('It should produce a plot for EEG epoched data with combineDim 1\n');
fig7 = figure('Name', 'Single element epoched - combine dim 1');
sp7 = visviews.signalShadowPlot(fig7, [], []);
assertTrue(isvalid(sp7));
slice7 = viscore.dataSlice('Slices', {'1', ':', ':'}, 'CombineDim', 1, ...
    'DimNames', {'Channel', 'Sample', 'Window'}); 
sp7.plot(hdf5DataEpoched, values.fun, slice7);
gaps = sp7.getGaps();
sp7.reposition(gaps);

fprintf('It should produce a plot for EEG epoched data with multiple elements combineDim 1\n');
fig8 = figure('Name', 'Multiple elements epoched - combine dim 1');
sp8 = visviews.signalShadowPlot(fig8, [], []);
assertTrue(isvalid(sp8));
slice8 = viscore.dataSlice('Slices', {'1', ':', ':'}, 'CombineDim', 1, ...
    'DimNames', {'Channel', 'Sample', 'Window'}); 
sp8.plot(hdf5DataEpoched, values.fun, slice8);
gaps = sp8.getGaps();
sp8.reposition(gaps);

fprintf('It should plot smooth signals\n');
load('DataSmooth.mat');
smoothFile = regexprep(which('EEG.mat'), 'EEG.mat$', 'DataSmooth.hdf5');
hdf5DataSmooth =  viscore.hdf5Data(dataSmooth, 'Smooth', smoothFile);
fig9 = figure('Name', 'Plot with smoothed signals');
sp9 = visviews.signalShadowPlot(fig9, [], []);
assertTrue(isvalid(sp9));
sp9.CutoffScore = 2.0;
sp9.plot(hdf5DataSmooth, values.fun, values.slice);
gaps = sp9.getGaps();
sp9.reposition(gaps);

fprintf('It should plot smooth signals with a trim percent\n');
load('DataSmoothTrim.mat');
smoothTrimFile = regexprep(which('EEG.mat'), 'EEG.mat$', 'DataSmoothTrim.hdf5');
hdf5DataSmoothTrim =  viscore.hdf5Data(dataSmoothTrim, 'Large Cosine', smoothTrimFile);
fig10 = figure('Name', 'Plot with smoothed signals with out of range signal');
sp10 = visviews.signalShadowPlot(fig10, [], []);
assertTrue(isvalid(sp6));
sp10.CutoffScore = 2.0;
sp10.TrimPercent = 5;
sp10.plot(hdf5DataSmoothTrim, values.fun, values.slice);
gaps = sp10.getGaps();
sp10.reposition(gaps);

fprintf('It should produce a plot for a clump of nonepoched windows sliced along dim 3 \n');
fig11 = figure('Name', 'Plot clump for slice along dimension 3, not epoched');
sp11 = visviews.signalShadowPlot(fig11, [], []);
assertTrue(isvalid(sp11));
slice11 = viscore.dataSlice('Slices', {':', ':', '2:4'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'}, 'CombineDim', 3);
sp11.plot(hdf5DataSmooth, values.fun, slice11);
gaps = sp11.getGaps();
sp11.reposition(gaps);

fprintf('It should produce a plot for a clump of nonepoched windows sliced along dim 3 \n');
fig12 = figure('Name', 'Plot clump for slice along dimension 3, epoched');
sp12 = visviews.signalShadowPlot(fig12, [], []);
assertTrue(isvalid(sp12));
slice12 = viscore.dataSlice('Slices', {':', ':', '2:4'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'}, 'CombineDim', 3);
sp12.plot(hdf5DataEpoched, values.fun, slice12);
gaps = sp12.getGaps();
sp12.reposition(gaps);

fprintf('It should produce a single window plot for a clump of epoched windows sliced along dim 3 \n');
load('DataSmoothSingleWindow.mat');
smoothSingleWindowFile = regexprep(which('EEG.mat'), 'EEG.mat$', 'DataSmoothSingleWindow.hdf5');
hdf5DataSmoothSingleWindow =  viscore.hdf5Data(dataSmoothSingleWindow, 'Sinusoidal', smoothSingleWindowFile, ...
    'Epoched', true, 'SampleRate', 256);
fig13 = figure('Name', 'Plot clump for slice along dimension 3, epoched (epoch 5 and 7 are big)');
sp13 = visviews.signalShadowPlot(fig13, [], []);
assertTrue(isvalid(sp13));
slice13 = viscore.dataSlice('Slices', {':', ':', '4:8'}, ...
    'DimNames', {'Channel', 'Sample', 'Epoch'}, 'CombineDim', 3);
sp13.plot(hdf5DataSmoothSingleWindow, values.fun, slice13);
gaps = sp13.getGaps();
sp13.reposition(gaps);

fprintf('It should produce a plot for a clump of nonepoched windows\n');
fig14 = figure('Name', 'Plot clump for channels 2:4 sliced dimension 1, big windows [5, 7], not epoched');
sp14 = visviews.signalShadowPlot(fig14, [], []);
assertTrue(isvalid(sp4));
slice14 = viscore.dataSlice('Slices', {'30:32', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'}, 'CombineDim', 1);
sp14.plot(hdf5DataSmoothSingleWindow, values.fun, slice14);
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
load('AllZeros.mat');
testVD1 = viscore.memoryData(allZeros, 'All zeros');
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
load('AllNaN.mat');
testVD3 = viscore.memoryData(allNaN, 'Data NaN');
fig3 = figure('Name', 'Data NaNs');
bp3 = visviews.signalShadowPlot(fig3, [], []);
assertTrue(isvalid(bp3));
bp3.plot(testVD3, values.fun, values.slice);
gaps = bp3.getGaps();
bp3.reposition(gaps);

% Data slice empty
fprintf('It should produce empty axes when data slice is empty (---see warning)\n');
load('EmptySlice.mat');
testVD4 = viscore.memoryData(emptySlice, 'Data empty');
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

function testConstantAndNaNValuesHDF5(values) %#ok<DEFNU>
% Unit test visviews.signalShadowPlot plot constant and NaN
fprintf('\nUnit tests for visviews.signalShadowPlot plot method with constant and NaN values\n')

% All zeros
fprintf('It should produce a plot for when all of the values are 0\n');
allZerosFile = regexprep(which('EEG.mat'), 'EEG.mat$', 'AllZeros.hdf5');
load('AllZeros.mat');
testVD1 = viscore.hdf5Data(allZeros, 'All zeros', allZerosFile);
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
NaNFile = regexprep(which('EEG.mat'), 'EEG.mat$', 'NaN.hdf5');
load('AllNaN.mat');
testVD3 = viscore.hdf5Data(allNaN,'Data NaN', NaNFile);
fig3 = figure('Name', 'Data NaNs');
bp3 = visviews.signalShadowPlot(fig3, [], []);
assertTrue(isvalid(bp3));
bp3.plot(testVD3, values.fun, values.slice);
gaps = bp3.getGaps();
bp3.reposition(gaps);

% Data slice empty
fprintf('It should produce empty axes when data slice is empty (---see warning)\n');
emptySliceFile = regexprep(which('EEG.mat'), 'EEG.mat$', 'EmptySlice.hdf5');
load('EmptySlice.mat');
testVD4 = viscore.hdf5Data(emptySlice, 'Data empty', emptySliceFile);
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