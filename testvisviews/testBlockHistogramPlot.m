function test_suite = testBlockHistogramPlot %#ok<STOUT>
% Unit tests for blockHistogramPlot
initTestSuite;

function testNormalConstructor %#ok<DEFNU>
% Unit test for visviews.blockHistogramPlot constructor
fprintf('\nUnit tests for visviews.blockHistogramPlot normal constructor\n');
fprintf('It should create a valid object with a figure and 2 empty arguments\n');
sfig = figure('Name', 'Creates a panel when only parent passed');
ip = visviews.blockHistogramPlot(sfig, [], []);
assertTrue(isvalid(ip));
drawnow
delete(sfig);

function testBadConstructor %#ok<DEFNU>
% Unit test for visviews.blockHistogramPlot invalid constructor
fprintf('\nUnit tests for visviews.blockHistogramPlot invalid constructor\n');

fprintf('It should throw an exception when no parameters are passed\n');
f = @() visviews.blockHistogramPlot();
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when only one parameter is passed\n');
sfig = figure('Name', 'visviews.BlockHistogramPlot: invalid constructor');
f = @() visviews.blockHistogramPlot(sfig);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when only two parameters are passed\n');
f = @() visviews.blockHistogramPlot(sfig, []);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when more than three parameters are passed\n');
f = @() visviews.blockHistogramPlot(sfig, [], [], []);
assertExceptionThrown(f, 'MATLAB:maxrhs');
delete(sfig);

function testPlot %#ok<DEFNU>
% Unit test for visviews.blockHistogramPlot plot method
fprintf('\nUnit tests for visviews.blockHistogramPlot plot method\n');

fprintf('It should plot data when a valid slice is passed\n');
sfig = figure('Name', 'visviews.blockHistogramPlot: data slice passed');
ip = visviews.blockHistogramPlot(sfig, [], []);
assertTrue(isvalid(ip));
% Generate some data to plot
data = random('exp', 1, [32, 1000, 20]);
testVD = viscore.blockedData(data, 'Rand1');
defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
    viewTestClass.getDefaultFunctionsNoSqueeze());
fMan = viscore.dataManager();
fMan.putObjects(defaults);
func = fMan.getEnabledObjects('block');
thisFunc = func{1};
thisFunc.setData(testVD);
slice1 = viscore.dataSlice('Slices', {':', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
ip.plot(testVD, thisFunc, slice1);
drawnow

fprintf('It should allow its public parameters to be changed (bars are red)\n');
sfig1 = figure('Name', 'visviews.BlockHistogramPlot: bar colors changed to red');
hp = visviews.blockHistogramPlot(sfig1, [], []);
hp.HistogramColor = [1, 0, 0];
assertTrue(isvalid(hp));
% Generate some data to plot
data = random('exp', 1, [32, 1000, 20]);
testVD = viscore.blockedData(data, 'Rand1');
defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
    viewTestClass.getDefaultFunctionsNoSqueeze());
fMan = viscore.dataManager();
fMan.putObjects(defaults);
func = fMan.getEnabledObjects('');
thisFunc = func{1};
thisFunc.setData(testVD);
slice1 = viscore.dataSlice('Slices', {':', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
hp.plot(testVD, thisFunc, slice1);
gaps = hp.getGaps();
hp.reposition(gaps);
drawnow
delete(sfig);
delete(sfig1)


function testPlotOneValue %#ok<DEFNU>
% Unit test of visviews.blockHistogramPlot for a single value
fprintf('\nUnit tests for visviews.blockHistogramPlot plot method one value\n')
fprintf('It should produce a valid plot for one value\n');
% test blockHistogramPlot plot
sfig = figure('Name', 'One value');
bp = visviews.blockHistogramPlot(sfig, [], []);
assertTrue(isvalid(bp));
% Generate some data to plot
data = random('exp', 1, [32, 1000, 20]);
testVD = viscore.blockedData(data, 'Rand1');
defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
    viewTestClass.getDefaultFunctionsNoSqueeze());
fMan = viscore.dataManager();
fMan.putObjects(defaults);
func = fMan.getEnabledObjects('block');
thisFunc = func{1};
thisFunc.setData(testVD);
%bp.ClumpFactor = 20;
slice1 = viscore.dataSlice('Slices', {'3', ':', '2'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
bp.plot(testVD, thisFunc, slice1);
drawnow
gaps = bp.getGaps();
bp.reposition(gaps);
delete(sfig)

function testPlotSlice %#ok<DEFNU>
% Unit test of visviews.blockHistogramPlot for plotting a slice
fprintf('\nUnit tests for visviews.blockHistogramPlot plot method for a slice\n')
fprintf('It should produce a valid plot for a slice\n');
% test blockHistogramPlot plot
sfig = figure('Name', 'One value');
bp = visviews.blockHistogramPlot(sfig, [], []);
assertTrue(isvalid(bp));
% Generate some data to plot
data = random('exp', 1, [32, 1000, 20]);
testVD = viscore.blockedData(data, 'Rand1');
defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
    viewTestClass.getDefaultFunctionsNoSqueeze());
fMan = viscore.dataManager();
fMan.putObjects(defaults);
func = fMan.getEnabledObjects('block');
thisFunc = func{1};
thisFunc.setData(testVD);
%bp.ClumpFactor = 20;
slice1 = viscore.dataSlice('Slices', {'3:10', ':', '2:3'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
bp.plot(testVD, thisFunc, slice1);
drawnow
gaps = bp.getGaps();
bp.reposition(gaps);
delete(sfig);