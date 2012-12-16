function test_suite = testBlockHistogramPlot %#ok<STOUT>
% Unit tests for visviews.blockHistogramPlot
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
values.bData = viscore.blockedData(EEG.data, 'EEG', ...
    'SampleRate', EEG.srate);    
values.deleteFigures = true;

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testNormalConstructor(values) %#ok<DEFNU>
% Unit test for visviews.blockHistogramPlot constructor
fprintf('\nUnit tests for visviews.blockHistogramPlot normal constructor\n');
fprintf('It should create a valid object with a figure and 2 empty arguments\n');
fig = figure('Name', 'Creates a panel when only parent passed');
ip = visviews.blockHistogramPlot(fig, [], []);
assertTrue(isvalid(ip));
drawnow
if values.deleteFigures
  delete(fig);
end

function testBadConstructor(values) %#ok<DEFNU>
% Unit test for visviews.blockHistogramPlot invalid constructor
fprintf('\nUnit tests for visviews.blockHistogramPlot invalid constructor\n');

fprintf('It should throw an exception when no parameters are passed\n');
f = @() visviews.blockHistogramPlot();
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when only one parameter is passed\n');
fig = figure('Name', 'visviews.BlockHistogramPlot: invalid constructor');
f = @() visviews.blockHistogramPlot(fig);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when only two parameters are passed\n');
f = @() visviews.blockHistogramPlot(fig, []);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when more than three parameters are passed\n');
f = @() visviews.blockHistogramPlot(fig, [], [], []);
assertExceptionThrown(f, 'MATLAB:maxrhs');
if values.deleteFigures
  delete(fig);
end

function testPlot(values) %#ok<DEFNU>
% Unit test for visviews.blockHistogramPlot plot method
fprintf('\nUnit tests for visviews.blockHistogramPlot plot method\n');

fprintf('It should plot data when a valid slice is passed\n');
fig1 = figure('Name', 'visviews.blockHistogramPlot: data slice passed');
hp1 = visviews.blockHistogramPlot(fig1, [], []);
assertTrue(isvalid(hp1));
hp1.plot(values.bData, values.fun, values.slice);
gaps = hp1.getGaps();
hp1.reposition(gaps);

fprintf('It should allow callbacks to be registered for clumps of one window\n')
hp1.registerCallbacks([]);

fprintf('It should allow its public parameters to be changed (bars are red)\n');
fig2 = figure('Name', 'visviews.blockHistogramPlot: bar colors changed to red');
hp2 = visviews.blockHistogramPlot(fig2, [], []);
hp2.HistogramColor = [1, 0, 0];
assertTrue(isvalid(hp2));
hp2.plot(values.bData, values.fun, values.slice);
gaps = hp2.getGaps();
hp2.reposition(gaps);

fprintf('It should produce a valid plot for one value\n');
% test blockHistogramPlot plot
fig3 = figure('Name', 'One value');
hp3 = visviews.blockHistogramPlot(fig3, [], []);
assertTrue(isvalid(hp3));
slice3 = viscore.dataSlice('Slices', {'3', ':', '2'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
hp3.plot(values.bData, values.fun, slice3);
gaps = hp3.getGaps();
hp3.reposition(gaps);

fprintf('It should produce a valid plot for a slice\n');
% test blockHistogramPlot plot
fig4 = figure('Name', 'One value');
hp4 = visviews.blockHistogramPlot(fig4, [], []);
assertTrue(isvalid(hp4));
slice4 = viscore.dataSlice('Slices', {'3:10', ':', '2:3'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
hp4.plot(values.bData, values.fun, slice4);
drawnow
gaps = hp4.getGaps();
hp4.reposition(gaps);

drawnow
if values.deleteFigures
    delete(fig1);
    delete(fig2);
    delete(fig3);
    delete(fig4);
end

function testConstantAndNaNValues(values) %#ok<DEFNU>
% Unit test visviews.blockHistogramPlot plot constant and NaN
fprintf('\nUnit tests for visviews.blockHistogramPlot plot method with constant and NaN values\n')

% All zeros
fprintf('It should produce a plot for when all of the values are 0 (---see warning)\n');
data = zeros([32, 1000, 20]);
testVD1 = viscore.blockedData(data, 'All zeros');
fig1 = figure('Name', 'All zero values');
hp1 = visviews.blockHistogramPlot(fig1, [], []);
assertTrue(isvalid(hp1));
hp1.plot(testVD1, values.fun, values.slice);
gaps = hp1.getGaps();
hp1.reposition(gaps);

% Data zeros, function NaN
fprintf('It should produce a plot for when data is zero, funcs NaNs (---see warning)\n');
fig2 = figure('Name', 'Data zero, func NaN');
hp2 = visviews.blockHistogramPlot(fig2, [], []);
assertTrue(isvalid(hp2));
hp2.plot(testVD1, [], values.slice);
gaps = hp2.getGaps();
hp2.reposition(gaps);

% Data NaN
fprintf('It should produce a plot for when data is zero, funcs NaNs (---see warning)\n');
data = NaN([32, 1000, 20]);
testVD3 = viscore.blockedData(data, 'Data NaN');
fig3 = figure('Name', 'Data NaNs');
hp3 = visviews.blockHistogramPlot(fig3, [], []);
assertTrue(isvalid(hp3));
hp3.plot(testVD3, values.fun, values.slice);
gaps = hp3.getGaps();
hp3.reposition(gaps);
drawnow

% Data slice empty
fprintf('It should produce a plot for when data slice is empty (---see warning)\n');
data = zeros(5, 1);
testVD4 = viscore.blockedData(data, 'Data empty');
slice4 = viscore.dataSlice('Slices', {'6', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
fig4 = figure('Name', 'Data slice is empty');
hp4 = visviews.blockHistogramPlot(fig4, [], []);
assertTrue(isvalid(hp4));
hp4.plot(testVD4, values.fun, slice4);
gaps = hp4.getGaps();
hp4.reposition(gaps);
drawnow
if values.deleteFigures
    delete(fig1);
    delete(fig2);
    delete(fig3);
    delete(fig4);
end
