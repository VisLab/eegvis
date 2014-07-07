function test_suite = testBlockScalpPlot %#ok<STOUT>
initTestSuite;

function values = setup %#ok<DEFNU>
defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
    viewTestClass.getDefaultFunctionsNoSqueeze());
fMan = viscore.dataManager();
fMan.putObjects(defaults);
func = fMan.getEnabledObjects('block');
values.fun = func{1};
values.slice = viscore.dataSlice('Slices', {':', ':', ':'}, ...
        'DimNames', {'Channel', 'Sample', 'Window'});
load('EEG.mat');
hdf5File = regexprep(which('EEG.mat'), 'EEG.mat$', 'EEG.hdf5');
values.hdf5SFrameFile = regexprep(which('EEG.mat'), 'EEG.mat$', 'EEG_SINGLE_FRAME.hdf5');
values.hdf5SChannelFile = regexprep(which('EEG.mat'), 'EEG.mat$', 'EEG_SINGLE_CHANNEL.hdf5');
values.EEG = EEG;
values.bData = viscore.memoryData(EEG.data, 'EEG', ...
    'SampleRate', EEG.srate, 'ElementLocations', EEG.chanlocs);
values.sFrame = viscore.memoryData(EEG.data(:, 1), 'EEG', ...
    'SampleRate', EEG.srate, 'ElementLocations', EEG.chanlocs);  
values.sChannel = viscore.memoryData(EEG.data(:, 1), 'EEG', ...
    'SampleRate', EEG.srate, 'ElementLocations', EEG.chanlocs); 
values.hdf5Data = viscore.hdf5Data(EEG.data, 'EEG', hdf5File, ...
    'SampleRate', EEG.srate, 'ElementLocations', EEG.chanlocs);
values.hdf5SFrame = viscore.hdf5Data(EEG.data(:, 1), 'EEG', values.hdf5SFrameFile, ...
    'SampleRate', EEG.srate, 'ElementLocations', EEG.chanlocs); 
values.hdf5SChannel = viscore.hdf5Data(EEG.data(:, 1), 'EEG', values.hdf5SChannelFile, ...
    'SampleRate', EEG.srate, 'ElementLocations', EEG.chanlocs); 
values.deleteFigures = true;

function teardown(values)  %#ok<DEFNU>
% Function executed after each test
delete(values.hdf5SFrameFile);
delete(values.hdf5SChannelFile);

function testNormalConstructor(values) %#ok<DEFNU>
% Unit test for visviews.blockScalpPlot constructor
fprintf('\nUnit tests for visviews.blockScalpPlot valid constructor\n');

fprintf('It should construct a valid scalp plot when only parent passed\n');
fig = figure('Name', 'Empty plot');
bp = visviews.blockScalpPlot(fig, [], []);
assertTrue(isvalid(bp));

drawnow
if values.deleteFigures
  delete(fig);
end

function testBadConstructor(values) %#ok<DEFNU>
% Unit test for visviews.blockScalpPlot invalid constructor
fprintf('\nUnit tests for visviews.blockScalpPlot invalid constructor parameters\n');

fprintf('It should throw an exception when no parameters are passed\n');
f = @() visviews.blockScalpPlot();
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when only one parameter is passed\n');
fig = figure('Name', 'Bad constructor');
f = @() visviews.blockScalpPlot(fig);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when only two parameters are passed\n');
f = @() visviews.blockScalpPlot(fig, []);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when more than three parameters are passed\n');
f = @() visviews.blockScalpPlot(fig, [], [], []);
assertExceptionThrown(f, 'MATLAB:maxrhs');

drawnow
if values.deleteFigures
  delete(fig);
end

function testPlot(values) %#ok<DEFNU>
% Unit test evisviews.blockScalpPlot plot
fprintf('\nUnit tests for visviews.blockScalpPlot plot method\n');

fprintf('It should produce a plot for identity slice\n');
fig1 = figure('Name', 'Clumps of one element');
sm1 = visviews.blockScalpPlot(fig1, [], []);
assertTrue(isvalid(sm1));
sm1.plot(values.bData, values.fun, values.slice);
gaps = sm1.getGaps();
sm1.reposition(gaps);

fprintf('It should allow callbacks to be registered\n')
sm1.registerCallbacks([]);

fprintf('It should produce a plot for empty slice\n');
fig2 = figure('Name', 'Empty slice');
sm2 = visviews.blockScalpPlot(fig2, [], []);
assertTrue(isvalid(sm2));
sm2.plot(values.bData, values.fun, []);
gaps = sm2.getGaps();
sm2.reposition(gaps);

fprintf('It should produce a plot when not all blocks in slice\n');
fig3 = figure('Name', 'Slice with Windows 6-8');
sm3 = visviews.blockScalpPlot(fig3, [], []);
slice3 = viscore.dataSlice('Slices', {':', ':', '6:8'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
sm3.plot(values.bData, values.fun, slice3);
gaps = sm3.getGaps();
sm3.reposition(gaps);

fprintf('It should produce a plot when not all channels in slice\n');
fig4 = figure('Name', 'Slice with Channels(2:10) Windows 4-7');
sm4 = visviews.blockScalpPlot(fig4, [], []);
assertTrue(isvalid(sm4));
slice4 = viscore.dataSlice('Slices', {'2:10', ':', '4:7'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
sm4.plot(values.bData, values.fun, slice4);
gaps = sm4.getGaps();
sm4.reposition(gaps);

fprintf('It should produce a plot for a slice consisting of single frame\n');
fig5 = figure('Name', 'Slice is single frame');
sm5 = visviews.blockScalpPlot(fig5, [], []);
slice5 = viscore.dataSlice('Slices', {':', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
assertTrue(isvalid(sm5));
sm5.plot(values.sFrame, values.fun, slice5);
gaps = sm5.getGaps();
sm5.reposition(gaps);

drawnow
if values.deleteFigures
    delete(fig1);
    delete(fig2);
    delete(fig3);
    delete(fig4);
    delete(fig5);
end

function testPlotHDF5(values) %#ok<DEFNU>
% Unit test evisviews.blockScalpPlot plot
fprintf('\nUnit tests for visviews.blockScalpPlot plot method\n');

fprintf('It should produce a plot for identity slice\n');
fig1 = figure('Name', 'Clumps of one element');
sm1 = visviews.blockScalpPlot(fig1, [], []);
assertTrue(isvalid(sm1));
sm1.plot(values.hdf5Data, values.fun, values.slice);
gaps = sm1.getGaps();
sm1.reposition(gaps);

fprintf('It should allow callbacks to be registered\n')
sm1.registerCallbacks([]);

fprintf('It should produce a plot for empty slice\n');
fig2 = figure('Name', 'Empty slice');
sm2 = visviews.blockScalpPlot(fig2, [], []);
assertTrue(isvalid(sm2));
sm2.plot(values.hdf5Data, values.fun, []);
gaps = sm2.getGaps();
sm2.reposition(gaps);

fprintf('It should produce a plot when not all blocks in slice\n');
fig3 = figure('Name', 'Slice with Windows 6-8');
sm3 = visviews.blockScalpPlot(fig3, [], []);
slice3 = viscore.dataSlice('Slices', {':', ':', '6:8'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
sm3.plot(values.hdf5Data, values.fun, slice3);
gaps = sm3.getGaps();
sm3.reposition(gaps);

fprintf('It should produce a plot when not all channels in slice\n');
fig4 = figure('Name', 'Slice with Channels(2:10) Windows 4-7');
sm4 = visviews.blockScalpPlot(fig4, [], []);
assertTrue(isvalid(sm4));
slice4 = viscore.dataSlice('Slices', {'2:10', ':', '4:7'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
sm4.plot(values.hdf5Data, values.fun, slice4);
gaps = sm4.getGaps();
sm4.reposition(gaps);

fprintf('It should produce a plot for a slice consisting of single frame\n');
fig5 = figure('Name', 'Slice is single frame');
sm5 = visviews.blockScalpPlot(fig5, [], []);
slice5 = viscore.dataSlice('Slices', {':', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
assertTrue(isvalid(sm5));
sm5.plot(values.hdf5SFrame, values.fun, slice5);
gaps = sm5.getGaps();
sm5.reposition(gaps);

drawnow
if values.deleteFigures
    delete(fig1);
    delete(fig2);
    delete(fig3);
    delete(fig4);
    delete(fig5);
end


function testConstantAndNaNValues(values) %#ok<DEFNU>
% Unit test visviews.blockScalpPlot plot constant and NaN
fprintf('\nUnit tests for visviews.blockScalpPlot plot method with constant and NaN values\n')

% All zeros
fprintf('It should produce a plot for when all of the values are 0\n');
data = zeros([32, 1000, 20]);
testVD1 = viscore.memoryData(data, 'All zeros');
fig1 = figure('Name', 'All zero values');
sm1 = visviews.blockScalpPlot(fig1, [], []);
assertTrue(isvalid(sm1));
sm1.plot(testVD1, values.fun, values.slice);
gaps = sm1.getGaps();
sm1.reposition(gaps);
drawnow

% Data zeros, function NaN
fprintf('It should produce a bad plot for when data is zero, funcs NaNs (---see warning)\n');
fig2 = figure('Name', 'Data zero, func NaN');
sm2 = visviews.blockScalpPlot(fig2, [], []);
assertTrue(isvalid(sm2));
sm2.plot(testVD1, [], values.slice);
gaps = sm2.getGaps();
sm2.reposition(gaps);

% Data NaN
fprintf('It should produce a plot for when data is NaN\n');
data = NaN([32, 1000, 20]);
testVD3 = viscore.memoryData(data, 'Data NaN');
fig3 = figure('Name', 'Data NaNs');
sm3 = visviews.blockScalpPlot(fig3, [], []);
assertTrue(isvalid(sm3));
sm3.plot(testVD3, values.fun, values.slice);
gaps = sm3.getGaps();
sm3.reposition(gaps);

% Data slice empty
fprintf('It should produce empty axes when data slice is empty (---see warning)\n');
data = zeros(5, 1);
testVD4 = viscore.memoryData(data, 'Data empty');
slice4 = viscore.dataSlice('Slices', {'6', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
fig4 = figure('Name', 'Data slice is empty');
sm4 = visviews.blockScalpPlot(fig4, [], []);
assertTrue(isvalid(sm4));
sm4.plot(testVD4, values.fun, slice4);
gaps = sm4.getGaps();
sm4.reposition(gaps);

drawnow
if values.deleteFigures
    delete(fig1);
    delete(fig2);
    delete(fig3);
    delete(fig4);
end


function testConstantAndNaNValuesHDF5(values) %#ok<DEFNU>
% Unit test visviews.blockScalpPlot plot constant and NaN
fprintf('\nUnit tests for visviews.blockScalpPlot plot method with constant and NaN values\n')

% All zeros
fprintf('It should produce a plot for when all of the values are 0\n');
data = zeros([32, 1000, 20]);
hdf5File = regexprep(which('EEG.mat'), 'EEG.mat$', 'EEG_NO_DATA.hdf5');
testVD1 = viscore.hdf5Data(data, 'All zeros', hdf5File);
fig1 = figure('Name', 'All zero values');
sm1 = visviews.blockScalpPlot(fig1, [], []);
assertTrue(isvalid(sm1));
sm1.plot(testVD1, values.fun, values.slice);
gaps = sm1.getGaps();
sm1.reposition(gaps);
drawnow
delete(hdf5File);

% Data zeros, function NaN
fprintf('It should produce a bad plot for when data is zero, funcs NaNs (---see warning)\n');
fig2 = figure('Name', 'Data zero, func NaN');
sm2 = visviews.blockScalpPlot(fig2, [], []);
assertTrue(isvalid(sm2));
sm2.plot(testVD1, [], values.slice);
gaps = sm2.getGaps();
sm2.reposition(gaps);

% Data NaN
fprintf('It should produce a plot for when data is NaN\n');
data = NaN([32, 1000, 20]);
hdf5File = regexprep(which('EEG.mat'), 'EEG.mat$', 'EEG_NO_DATA.hdf5');
testVD3 = viscore.hdf5Data(data, 'Data NaN', hdf5File);
fig3 = figure('Name', 'Data NaNs');
sm3 = visviews.blockScalpPlot(fig3, [], []);
assertTrue(isvalid(sm3));
sm3.plot(testVD3, values.fun, values.slice);
gaps = sm3.getGaps();
sm3.reposition(gaps);
delete(hdf5File);

% Data slice empty
fprintf('It should produce empty axes when data slice is empty (---see warning)\n');
data = zeros(5, 1);
hdf5File = regexprep(which('EEG.mat'), 'EEG.mat$', 'EEG_NO_DATA.hdf5');
testVD4 = viscore.hdf5Data(data, 'Data empty', hdf5File);
slice4 = viscore.dataSlice('Slices', {'6', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
fig4 = figure('Name', 'Data slice is empty');
sm4 = visviews.blockScalpPlot(fig4, [], []);
assertTrue(isvalid(sm4));
sm4.plot(testVD4, values.fun, slice4);
gaps = sm4.getGaps();
sm4.reposition(gaps);
delete(hdf5File);

drawnow
if values.deleteFigures
    delete(fig1);
    delete(fig2);
    delete(fig3);
    delete(fig4);
end

function testProperties(values) %#ok<DEFNU>
% Unit test for visviews.blockScalpPlot properties
fprintf('\nUnit tests for visviews.blockScalpPlot properties\n');

fprintf('It should have a getDefaultProperties method that returns a structure\n');
s = visviews.blockScalpPlot.getDefaultProperties();
assertTrue(isa(s, 'struct'));

fprintf('It should correctly set the background color when it changes\n');
fig1 = figure('Name', 'Change background to red');
sm1 = visviews.blockScalpPlot(fig1, [], []);
assertTrue(isvalid(sm1));
sm1.plot(values.bData, values.fun, values.slice);
gaps = sm1.getGaps();
sm1.reposition(gaps);
sm1.setBackgroundColor([1, 0, 0]);
sm1.plot(values.bData, values.fun, values.slice);

fprintf('It should produce a plot different interpolation methods\n');
fig2 = figure('Name', 'Random expoential: Interpolation v4 (default)');
fprintf('--It should produce a v4 plot\n')
sm2 = visviews.blockScalpPlot(fig2, [], []);
assertTrue(isvalid(sm2));
assertTrue(strcmp(sm2.InterpolationMethod, 'v4'));
sm2.plot(values.bData, values.fun, values.slice);
gaps = sm2.getGaps();
sm2.reposition(gaps);

fprintf('--It should produce a linear interpolation plot\n');
fig3 = figure('Name', 'Interpolation linear');
sm3 = visviews.blockScalpPlot(fig3, [], []);
assertTrue(isvalid(sm3));
sm3.InterpolationMethod = 'linear';
sm3.plot(values.bData, values.fun, values.slice);
gaps = sm3.getGaps();
sm3.reposition(gaps);

fig4 = figure('Name', 'Interpolation cubic');
sm4 = visviews.blockScalpPlot(fig4, [], []);
assertTrue(isvalid(sm4));
sm4.InterpolationMethod = 'cubic';
sm4.plot(values.bData, values.fun, values.slice);
gaps = sm4.getGaps();
sm4.reposition(gaps);

fig5 = figure('Name', 'Interpolation nearest');
sm5 = visviews.blockScalpPlot(fig5, [], []);
assertTrue(isvalid(sm5));
sm5.InterpolationMethod = 'nearest';
sm5.plot(values.bData, values.fun, values.slice);
gaps = sm5.getGaps();
sm5.reposition(gaps);

drawnow
if values.deleteFigures
    delete(fig1);
    delete(fig2);
    delete(fig3);
    delete(fig4);
    delete(fig5);
end


function testPropertiesHDF5(values) %#ok<DEFNU>
% Unit test for visviews.blockScalpPlot properties
fprintf('\nUnit tests for visviews.blockScalpPlot properties\n');

fprintf('It should have a getDefaultProperties method that returns a structure\n');
s = visviews.blockScalpPlot.getDefaultProperties();
assertTrue(isa(s, 'struct'));

fprintf('It should correctly set the background color when it changes\n');
fig1 = figure('Name', 'Change background to red');
sm1 = visviews.blockScalpPlot(fig1, [], []);
assertTrue(isvalid(sm1));
sm1.plot(values.hdf5Data, values.fun, values.slice);
gaps = sm1.getGaps();
sm1.reposition(gaps);
sm1.setBackgroundColor([1, 0, 0]);
sm1.plot(values.bData, values.fun, values.slice);

fprintf('It should produce a plot different interpolation methods\n');
fig2 = figure('Name', 'Random expoential: Interpolation v4 (default)');
fprintf('--It should produce a v4 plot\n')
sm2 = visviews.blockScalpPlot(fig2, [], []);
assertTrue(isvalid(sm2));
assertTrue(strcmp(sm2.InterpolationMethod, 'v4'));
sm2.plot(values.hdf5Data, values.fun, values.slice);
gaps = sm2.getGaps();
sm2.reposition(gaps);

fprintf('--It should produce a linear interpolation plot\n');
fig3 = figure('Name', 'Interpolation linear');
sm3 = visviews.blockScalpPlot(fig3, [], []);
assertTrue(isvalid(sm3));
sm3.InterpolationMethod = 'linear';
sm3.plot(values.hdf5Data, values.fun, values.slice);
gaps = sm3.getGaps();
sm3.reposition(gaps);

fig4 = figure('Name', 'Interpolation cubic');
sm4 = visviews.blockScalpPlot(fig4, [], []);
assertTrue(isvalid(sm4));
sm4.InterpolationMethod = 'cubic';
sm4.plot(values.hdf5Data, values.fun, values.slice);
gaps = sm4.getGaps();
sm4.reposition(gaps);

fig5 = figure('Name', 'Interpolation nearest');
sm5 = visviews.blockScalpPlot(fig5, [], []);
assertTrue(isvalid(sm5));
sm5.InterpolationMethod = 'nearest';
sm5.plot(values.hdf5Data, values.fun, values.slice);
gaps = sm5.getGaps();
sm5.reposition(gaps);

drawnow
if values.deleteFigures
    delete(fig1);
    delete(fig2);
    delete(fig3);
    delete(fig4);
    delete(fig5);
end

function testBlockPtr(values) %#ok<DEFNU>
% Unit test for visviews.blockScalpPlot position of block pointer
fprintf('\nUnit tests for visviews.blockScalpPlot positioning of block pointer\n');

fprintf('It should allow callbacks to be registers\n');
fig1 = figure('Name', 'Clumps of one window');
sm1 = visviews.blockScalpPlot(fig1, [], []);
assertTrue(isvalid(sm1));
sm1.plot(values.bData, values.fun, values.slice);
gaps = sm1.getGaps();
sm1.reposition(gaps);
sm1.registerCallbacks([]);

fprintf('It should move the position marker when incremented\n');
pause on
for k = 1:32
    pause(0.25);
    sm1.getClicked(k);
end
fprintf('It should move the marker to beginning when position is -inf\n');
pause(0.5);
sm1.getClicked(-inf);
fprintf('It should move the marker to end when position is inf\n');
pause(0.5);
sm1.getClicked(inf);
pause off
if values.deleteFigures
    delete(fig1);
end

function testBlockPtrHDF5(values) %#ok<DEFNU>
% Unit test for visviews.blockScalpPlot position of block pointer
fprintf('\nUnit tests for visviews.blockScalpPlot positioning of block pointer\n');

fprintf('It should allow callbacks to be registers\n');
fig1 = figure('Name', 'Clumps of one window');
sm1 = visviews.blockScalpPlot(fig1, [], []);
assertTrue(isvalid(sm1));
sm1.plot(values.hdf5Data, values.fun, values.slice);
gaps = sm1.getGaps();
sm1.reposition(gaps);
sm1.registerCallbacks([]);

fprintf('It should move the position marker when incremented\n');
pause on
for k = 1:32
    pause(0.25);
    sm1.getClicked(k);
end
fprintf('It should move the marker to beginning when position is -inf\n');
pause(0.5);
sm1.getClicked(-inf);
fprintf('It should move the marker to end when position is inf\n');
pause(0.5);
sm1.getClicked(inf);
pause off
if values.deleteFigures
    delete(fig1);
end


function testGetClicked(values) %#ok<DEFNU>
% Unit test for visviews.blockScalpPlot getClicked
fprintf('\nUnit tests for visviews.getClicked\n');

fprintf('It should allow callbacks to be registers\n');
fig1 = figure('Name', 'Testing click with channels');
sm1 = visviews.blockScalpPlot(fig1, [], []);
assertTrue(isvalid(sm1));
sm1.plot(values.bData, values.fun, values.slice);
gaps = sm1.getGaps();
sm1.reposition(gaps);
sm1.registerCallbacks([]);
bDataNoChannels = viscore.memoryData(values.EEG.data, 'EEG', ...
    'SampleRate', values.EEG.srate);    

fig2 = figure('Name', 'Testing click with no channels channels');
sm2 = visviews.blockScalpPlot(fig2, [], []);
assertTrue(isvalid(sm2));
sm2.plot(bDataNoChannels, values.fun, values.slice);
gaps = sm2.getGaps();
sm2.reposition(gaps);
sm2.registerCallbacks([]);

fprintf('It should produce an position and empty when clicked position is empty and channels\n');
[s1, bf1, p1] = sm1.getClicked([]);  %#ok<ASGLU>
assertTrue(isempty(s1));
assertTrue(isempty(p1));

fprintf('It should produce an empty slice and position when clicked position is empty and no channels\n');
[s2, bf2, p2] = sm2.getClicked([]); %#ok<ASGLU>
assertTrue(isempty(s2));
assertTrue(isempty(p2));


fprintf('It should produce an empty slice and position when clicked position is empty and no channels\n');
[s3, bf3, p3] = sm2.getClicked(inf); %#ok<ASGLU>
assertTrue(isempty(s3));
assertTrue(isempty(p3));

drawnow
if values.deleteFigures
    delete(fig1);
    delete(fig2);
end


function testGetClickedHDF5(values) %#ok<DEFNU>
% Unit test for visviews.blockScalpPlot getClicked
fprintf('\nUnit tests for visviews.getClicked\n');

fprintf('It should allow callbacks to be registers\n');
fig1 = figure('Name', 'Testing click with channels');
sm1 = visviews.blockScalpPlot(fig1, [], []);
assertTrue(isvalid(sm1));
sm1.plot(values.bData, values.fun, values.slice);
gaps = sm1.getGaps();
sm1.reposition(gaps);
sm1.registerCallbacks([]);
hdf5File = regexprep(which('EEG.mat'), 'EEG.mat$', 'EEG_NO_DATA.hdf5');
bDataNoChannels = viscore.hdf5Data(values.EEG.data, 'EEG', hdf5File, ...
    'SampleRate', values.EEG.srate);   

fig2 = figure('Name', 'Testing click with no channels channels');
sm2 = visviews.blockScalpPlot(fig2, [], []);
assertTrue(isvalid(sm2));
sm2.plot(bDataNoChannels, values.fun, values.slice);
gaps = sm2.getGaps();
sm2.reposition(gaps);
sm2.registerCallbacks([]);
delete(hdf5File);

fprintf('It should produce an position and empty when clicked position is empty and channels\n');
[s1, bf1, p1] = sm1.getClicked([]);  %#ok<ASGLU>
assertTrue(isempty(s1));
assertTrue(isempty(p1));

fprintf('It should produce an empty slice and position when clicked position is empty and no channels\n');
[s2, bf2, p2] = sm2.getClicked([]); %#ok<ASGLU>
assertTrue(isempty(s2));
assertTrue(isempty(p2));


fprintf('It should produce an empty slice and position when clicked position is empty and no channels\n');
[s3, bf3, p3] = sm2.getClicked(inf); %#ok<ASGLU>
assertTrue(isempty(s3));
assertTrue(isempty(p3));

drawnow
if values.deleteFigures
    delete(fig1);
    delete(fig2);
end


