function test_suite = testBlockHistogramPlot %#ok<STOUT>
% Unit tests for visviews.blockHistogramPlot
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
sfig1 = figure('Name', 'visviews.blockHistogramPlot: bar colors changed to red');
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

function testConstantAndNaNValues %#ok<DEFNU>
% Unit test visviews.blockHistogramPlot plot constant and NaN
fprintf('\nUnit tests for visviews.blockHistogramPlot plot method with constant and NaN values\n')

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
bp1 = visviews.blockHistogramPlot(sfig1, [], []);
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
bp2 = visviews.blockHistogramPlot(sfig2, [], []);
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
bp3 = visviews.blockHistogramPlot(sfig3, [], []);
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
bp4 = visviews.blockHistogramPlot(sfig4, [], []);
assertTrue(isvalid(bp4));
bp4.plot(testVD, thisFuncS, slice4);
gaps = bp4.getGaps();
bp4.reposition(gaps);
drawnow
delete(sfig1);
delete(sfig2);
delete(sfig3);
delete(sfig4);
