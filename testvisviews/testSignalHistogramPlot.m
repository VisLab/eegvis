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
%delete(sfig);
%delete(sfig1)


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
%delete(sfig)

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
%delete(sfig);