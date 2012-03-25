function test_suite = testSignalHistogramPlot %#ok<STOUT>
% Unit tests for visviews.signalHistogramPlot
initTestSuite;

function testNormalConstructor %#ok<DEFNU>
% testSignalPlot unit test for visviews.signalHistogramPlot constructor
fprintf('\nUnit tests for visviews.signalHistogramPlot valid constructor\n');

fprintf('It should construct a valid stacked signal plot when only parent passed\n')
sfig = figure('Name', 'Constructs a panel when only parent passed');
ip = visviews.signalHistogramPlot(sfig, [], []);
assertTrue(isvalid(ip));
drawnow
delete(sfig);

function testBadConstructor %#ok<DEFNU>
% testSignalPlot unit test for visviews.signalHistogramPlot constructor
fprintf('\nUnit tests for visviews.signalHistogramPlot invalid constructor parameters\n');

fprintf('It should throw an exception when no paramters are passed\n');
f = @() visviews.signalHistogramPlot();
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when only one parameter is passed\n');
sfig = figure('Name', 'Invalid constructor');
f = @() visviews.signalHistogramPlot(sfig);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when only two parameters are passed\n');
f = @() visviews.signalHistogramPlot(sfig, []);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when more than three parameters are passed\n');
f = @() visviews.signalHistogramPlot(sfig, [], [], []);
assertExceptionThrown(f, 'MATLAB:maxrhs');
delete(sfig);


function testPlot %#ok<DEFNU>
% Unit test for visviews.signalHistogramPlot plot method
fprintf('\nUnit tests for visviews.signalHistogramPlot plot method\n');

fprintf('It should plot data when a valid slice is passed\n');
sfig = figure('Name', 'visviews.signalHistogramPlot: data slice passed');
sp = visviews.signalHistogramPlot(sfig, [], []);
assertTrue(isvalid(sp));
% Generate some data to plot
data = random('exp', 1, [32, 1000, 20]);
testVD = viscore.blockedData(data, 'Rand1');
slice1 = viscore.dataSlice('Slices', {':', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
sp.plot(testVD, [], slice1);
gaps = sp.getGaps();
sp.reposition(gaps);
drawnow

fprintf('It should allow its public parameters to be changed (bars are red)\n');
sfig1 = figure('Name', 'visviews.signalHistogramPlot: bar colors changed to red');
sp = visviews.signalHistogramPlot(sfig1, [], []);
sp.HistogramColor = [1, 0, 0];
assertTrue(isvalid(sp));
% Generate some data to plot
data = random('exp', 1, [32, 1000, 20]);
testVD = viscore.blockedData(data, 'Rand1');

slice1 = viscore.dataSlice('Slices', {':', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
sp.plot(testVD, [], slice1);
gaps = sp.getGaps();
sp.reposition(gaps);
drawnow
delete(sfig);
delete(sfig1)


function testPlotOneValue %#ok<DEFNU>
% Unit test of visviews.signalHistogramPlot for a single value
fprintf('\nUnit tests for visviews.signalHistogramPlot plot method one value\n')
fprintf('It should produce a valid plot for one value\n');
% test signalHistogramPlot plot
sfig = figure('Name', 'One value');
sp = visviews.signalHistogramPlot(sfig, [], []);
assertTrue(isvalid(sp));
% Generate some data to plot
data = random('exp', 1, [32, 1000, 20]);
testVD = viscore.blockedData(data, 'Rand1');

slice1 = viscore.dataSlice('Slices', {'3', ':', '2'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
sp.plot(testVD, [], slice1);
drawnow
gaps = sp.getGaps();
sp.reposition(gaps);

fprintf('It should produce a valid plot for when mean is not removed\n');
% test signalHistogramPlot plot
sfig1 = figure('Name', 'One value no mean removed');
sp1 = visviews.signalHistogramPlot(sfig1, [], []);
assertTrue(isvalid(sp1));
% Generate some data to plot
data = random('exp', 1, [32, 1000, 20]);
testVD = viscore.blockedData(data, 'Rand1');

slice1 = viscore.dataSlice('Slices', {'3', ':', '2'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
sp1.RemoveMean = false;
sp1.plot(testVD, [], slice1);
drawnow
gaps = sp1.getGaps();
sp1.reposition(gaps);
delete(sfig)
delete(sfig1)

function testPlotSlice %#ok<DEFNU>
% Unit test of visviews.signalHistogramPlot for plotting a slice
fprintf('\nUnit tests for visviews.signalHistogramPlot plot method for a slice\n')
fprintf('It should produce a valid plot for a slice\n');
% test blockHistogramPlot plot
sfig = figure('Name', 'One value');
sp = visviews.signalHistogramPlot(sfig, [], []);
assertTrue(isvalid(sp));
% Generate some data to plot
data = random('exp', 1, [32, 1000, 20]);
testVD = viscore.blockedData(data, 'Rand1');
slice1 = viscore.dataSlice('Slices', {'3:10', ':', '2:3'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
sp.plot(testVD, [], slice1);
drawnow
gaps = sp.getGaps();
sp.reposition(gaps);
delete(sfig);

function testConstantAndNaNValues %#ok<DEFNU>
% Unit test visviews.signalHistogramPlot plot constant and NaN
fprintf('\nUnit tests for visviews.signalHistogramPlot plot method with constant and NaN values\n')

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
bp1 = visviews.signalHistogramPlot(sfig1, [], []);
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
bp2 = visviews.signalHistogramPlot(sfig2, [], []);
assertTrue(isvalid(bp1));
bp2.plot(testVD, thisFuncK, slice2);
gaps = bp2.getGaps();
bp2.reposition(gaps);
drawnow

% Data NaN
fprintf('It should produce a plot for when data is zero, funcs NaNs\n');
data = NaN([32, 1000, 20]);
testVD = viscore.blockedData(data, 'Data NaN');
slice3 = viscore.dataSlice('Slices', {':', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
sfig3 = figure('Name', 'Data NaNs');
bp3 = visviews.signalHistogramPlot(sfig3, [], []);
assertTrue(isvalid(bp1));
bp3.plot(testVD, thisFuncS, slice3);
gaps = bp3.getGaps();
bp3.reposition(gaps);
drawnow

% Data slice empty
fprintf('It should produce a plot for when data slice is empty\n');
data = zeros(5, 1);
testVD = viscore.blockedData(data, 'Data empty');
slice4 = viscore.dataSlice('Slices', {'6', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
sfig4 = figure('Name', 'Data slice is empty');
bp4 = visviews.signalHistogramPlot(sfig4, [], []);
assertTrue(isvalid(bp4));
bp4.plot(testVD, thisFuncS, slice4);
gaps = bp4.getGaps();
bp4.reposition(gaps);
drawnow
delete(sfig1);
delete(sfig2);
delete(sfig3);
delete(sfig4);
