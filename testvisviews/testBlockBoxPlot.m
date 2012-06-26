function test_suite = testBlockBoxPlot %#ok<STOUT>
initTestSuite;

function testNormalConstructor %#ok<DEFNU>
% Unit test for visviews.blockBoxPlot constructor
fprintf('\nUnit tests for visviews.blockBoxPlot valid constructor\n');

fprintf('It should construct a valid block box plot when only parent passed\n');
sfig = figure('Name', 'Empty plot');
bp = visviews.blockBoxPlot(sfig, [], []);
assertTrue(isvalid(bp));
drawnow
delete(sfig);

function testInvalidConstructor %#ok<DEFNU>
% Unit test for visviews.blockboxplot bad constructor
fprintf('\nUnit tests for visviews.blockBoxPlot invalid constructor parameters\n');

fprintf('It should throw an exception when no parameters are passed\n');
f = @() visviews.blockBoxPlot();
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when only one parameter is passed\n');
sfig = figure;
f = @() visviews.blockBoxPlot(sfig);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when only two parameters are passed\n');
f = @() visviews.blockBoxPlot(sfig, []);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when more than three parameters are passed\n');
f = @() visviews.blockBoxPlot(sfig, [], [], []);
assertExceptionThrown(f, 'MATLAB:maxrhs');
delete(sfig);

function testGetDefaultProperties %#ok<DEFNU>
% Unit test for visviews.blockBoxPlot getDefaultProperties
fprintf('\nUnit tests for visviews.blockBoxPlot getDefaultProperties\n');

fprintf('It should have a getDefaultProperties method that returns a structure\n');
s = visviews.blockBoxPlot.getDefaultProperties();
assertTrue(isa(s, 'struct'));

function testPlot %#ok<DEFNU>
% Unit test visviews.blockBoxPlot plot
fprintf('\nUnit tests for visviews.blockBoxPlot plot method\n')

fprintf('It should produce a plot for identity slice\n');
sfig = figure('Name', 'Clumps of one window');
bp = visviews.blockBoxPlot(sfig, [], []);
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
slice1 = viscore.dataSlice('Slices', {':', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
bp.plot(testVD, thisFunc, slice1);
drawnow
gaps = bp.getGaps();
bp.reposition(gaps);
fprintf('It should allow callbacks to be registered for clumps of one window\n')
bp.registerCallbacks(bp);

fprintf('It should produce a correct slice for clumps of one window\n');
dslice = bp.getClumpSlice(1);
s = dslice.getParameters(3);
assertTrue(strcmp(s{1}, '1:32'))
assertTrue(strcmp(s{2}, ':'))
assertTrue(strcmp(s{3}, '1'))
dslice = bp.getClumpSlice(20);
s = dslice.getParameters(3);
assertTrue(strcmp(s{1}, '1:32'))
assertTrue(strcmp(s{2}, ':'))
assertTrue(strcmp(s{3}, '20'))

fprintf('It should produce a plot for empty slice\n');
sfig1 = figure('Name', 'Empty slice');
bp1 = visviews.blockBoxPlot(sfig1, [], []);
assertTrue(isvalid(bp1));
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
bp1.plot(testVD, thisFunc, []);
drawnow
gaps = bp1.getGaps();
bp1.reposition(gaps);

fprintf('It should produce a correct slice when initial slice is empty\n');
dslice1 = bp1.getClumpSlice(1);
s = dslice1.getParameters(3);
assertTrue(strcmp(s{1}, '1:32'))
assertTrue(strcmp(s{2}, ':'))
assertTrue(strcmp(s{3}, '1'))
delete(sfig);
delete(sfig1);


function testPlotEvenGrouping %#ok<DEFNU>
% Unit test visviews.blockBoxPlot plot even grouping of windows
fprintf('\nUnit tests for visviews.blockBoxPlot plot method with even grouping\n')

fprintf('It should produce a plot for identity slice with groupings of 2\n');
% test blockBoxPlot plot

% Generate some data to plot
data = random('exp', 1, [32, 1000, 20]);
testVD = viscore.blockedData(data, 'Rand1');
slice1 = viscore.dataSlice('Slices', {':', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
    viewTestClass.getDefaultFunctionsNoSqueeze());

sfig = figure('Name', 'No grouping to compare with grouping of 2');
bp = visviews.blockBoxPlot(sfig, [], []);
assertTrue(isvalid(bp));
fMan = viscore.dataManager();
fMan.putObjects(defaults);
func = fMan.getEnabledObjects('block');
thisFunc = func{1};
thisFunc.setData(testVD);
bp.plot(testVD, thisFunc, slice1);
drawnow
gaps = bp.getGaps();
bp.reposition(gaps);
sfig1 = figure('Name', 'Grouping of 2');
bp1 = visviews.blockBoxPlot(sfig1, [], []);
assertTrue(isvalid(bp1));
fMan = viscore.dataManager();
fMan.putObjects(defaults);
func = fMan.getEnabledObjects('block');
thisFunc = func{1};
thisFunc.setData(testVD);
bp1.ClumpSize = 2;
bp1.plot(testVD, thisFunc, slice1);
drawnow
gaps = bp1.getGaps();
bp1.reposition(gaps);
delete(sfig);
delete(sfig1);

function testPlotOneGroup %#ok<DEFNU>
% Unit test of visviews.blockBoxPlot for one group of windows
fprintf('\nUnit tests for visviews.blockBoxPlot plot method one group\n')
fprintf('It should produce a plot for identity slice with 1 group\n');
% test blockBoxPlot plot
sfig = figure('Name', 'Group of one');
bp = visviews.blockBoxPlot(sfig, [], []);
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
bp.ClumpSize = 20;
slice1 = viscore.dataSlice('Slices', {':', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
bp.plot(testVD, thisFunc, slice1);
drawnow
gaps = bp.getGaps();
bp.reposition(gaps);
delete(sfig);

function testPlotOneValue %#ok<DEFNU>
% Unit test of visviews.blockBoxPlot for a single value
fprintf('\nUnit tests for visviews.blockBoxPlot plot method one value\n')
fprintf('It should produce a valid plot for one value\n');
% test blockBoxPlot plot
sfig = figure('Name', 'One value');
bp = visviews.blockBoxPlot(sfig, [], []);
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
bp.ClumpSize = 20;
slice1 = viscore.dataSlice('Slices', {'3', ':', '2'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
bp.plot(testVD, thisFunc, slice1);
drawnow
gaps = bp.getGaps();
bp.reposition(gaps);
delete(sfig);

function testUnevenGroupingSpecificValues %#ok<DEFNU>
% Unit test visviews.blockBoxPlot plot uneven grouping of windows
fprintf('\nUnit tests for visviews.blockBoxPlot plot method uneven grouping specific values\n')

% Set up the data
data = repmat([1, 1, 1, 2, 2, 2, 3], [5, 1, 4]);
data = permute(data, [1, 3, 2]);
testVD = viscore.blockedData(data, 'Specific values');
defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
    viewTestClass.getDefaultFunctionsSpecificValues());
slice1 = viscore.dataSlice('Slices', {':', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
fprintf('It should produce a plot for identity slice with uneven grouping\n');

sfig = figure('Name', 'No grouping to compare with specific values');
bp = visviews.blockBoxPlot(sfig, [], []);
assertTrue(isvalid(bp));
fMan = viscore.dataManager();
fMan.putObjects(defaults);
func = fMan.getEnabledObjects('block');
thisFunc = func{1};
thisFunc.setData(testVD);

bp.plot(testVD, thisFunc, slice1);
gaps = bp.getGaps();
bp.reposition(gaps);
drawnow

sfig1 = figure('Name', 'Grouping with specific values');
bp1 = visviews.blockBoxPlot(sfig1, [], []);
assertTrue(isvalid(bp1));
fMan = viscore.dataManager();
fMan.putObjects(defaults);
func = fMan.getEnabledObjects('block');
thisFunc = func{1};
thisFunc.setData(testVD);
bp1.ClumpSize = 3;

bp1.plot(testVD, thisFunc, slice1);
gaps = bp1.getGaps();
bp1.reposition(gaps);
drawnow
delete(sfig);
delete(sfig1);

function testPlotSlice %#ok<DEFNU>
% Unit test visviews.blockBoxPlot plot  with nonempy slice
fprintf('\nUnit tests for visviews.blockBoxPlot plot method with slice\n')

% Set up the data
data = random('exp', 1, [32, 1000, 20]);
testVD = viscore.blockedData(data, 'Rand1');
defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
    viewTestClass.getDefaultFunctionsNoSqueeze());
fMan = viscore.dataManager();
fMan.putObjects(defaults);
func = fMan.getEnabledObjects('block');
thisFunc = func{1};
thisFunc.setData(testVD);


fprintf('It should produce a plot for a slice of windows at beginning\n');

sfig = figure('Name', 'Empty slice plot for comparison');
bp = visviews.blockBoxPlot(sfig, [], []);
assertTrue(isvalid(bp));
bp.plot(testVD, thisFunc, []);
gaps = bp.getGaps();
bp.reposition(gaps);

sfig1 = figure('Name', 'Slice of windows at beginning');
bp1 = visviews.blockBoxPlot(sfig1, [], []);
assertTrue(isvalid(bp1));
slice1 = viscore.dataSlice('Slices', {':', ':', '1:10'}, ...
         'DimNames', {'Channel', 'Sample', 'Window'});
bp1.plot(testVD, thisFunc, slice1);
gaps = bp1.getGaps();
bp1.reposition(gaps);
drawnow

fprintf('It should produce a plot for a slice of windows in the middle\n');
sfig2 = figure('Name', 'Slice of windows in middle');
bp2 = visviews.blockBoxPlot(sfig2, [], []);
assertTrue(isvalid(bp2));
slice2 = viscore.dataSlice('Slices', {':', ':', '4:9'}, ...
         'DimNames', {'Channel', 'Sample', 'Window'});
bp2.plot(testVD, thisFunc, slice2);
gaps = bp2.getGaps();
bp2.reposition(gaps);
drawnow

fprintf('It should produce a plot for a slice of windows that falls off the end\n');
sfig3 = figure('Name', 'Slice of windows off the end');
bp3 = visviews.blockBoxPlot(sfig3, [], []);
assertTrue(isvalid(bp3));
slice3 = viscore.dataSlice('Slices', {':', ':', '15:21'}, ...
         'DimNames', {'Channel', 'Sample', 'Window'});
bp3.plot(testVD, thisFunc, slice3);
gaps = bp3.getGaps();
bp3.reposition(gaps);
drawnow

fprintf('It should produce a plot for subset of elements and a slice of windows that falls off the end\n');
sfig4 = figure('Name', 'Elements 14:18 with slice of windows off the end');
bp4 = visviews.blockBoxPlot(sfig4, [], []);
assertTrue(isvalid(bp4));
slice4 = viscore.dataSlice('Slices', {'14:18', ':', '15:21'}, ...
         'DimNames', {'Channel', 'Sample', 'Window'});
bp4.plot(testVD, thisFunc, slice4);
gaps = bp4.getGaps();
bp4.reposition(gaps);
drawnow

fprintf('It should produce a plot for single point\n');
sfig5 = figure('Name', 'Elements 14 and Window 4');
bp5 = visviews.blockBoxPlot(sfig5, [], []);
assertTrue(isvalid(bp5));
slice5 = viscore.dataSlice('Slices', {'14', ':', '4'}, ...
         'DimNames', {'Channel', 'Sample', 'Window'});
bp5.plot(testVD, thisFunc, slice5);
gaps = bp5.getGaps();
bp5.reposition(gaps);
drawnow

delete(sfig);
delete(sfig1);
delete(sfig2);
delete(sfig3);
delete(sfig4);
delete(sfig5);


function testPlotSliceClumped %#ok<DEFNU>
%Unit test visviews.blockBoxPlot plot with nonempy slice and clumping
fprintf('\nUnit tests for visviews.blockBoxPlot plot method with slice and clumps\n')

% Set up the data
data = random('exp', 1, [32, 1000, 20]);
testVD = viscore.blockedData(data, 'Rand1');
defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
    viewTestClass.getDefaultFunctionsNoSqueeze());
fMan = viscore.dataManager();
fMan.putObjects(defaults);
func = fMan.getEnabledObjects('block');
thisFunc = func{1};
thisFunc.setData(testVD);

sfig = figure('Name', 'Empty slice plot for comparison');
bp = visviews.blockBoxPlot(sfig, [], []);
assertTrue(isvalid(bp));
bp.plot(testVD, thisFunc, []);
gaps = bp.getGaps();
bp.reposition(gaps);

fprintf('It should produce a plot for a slice of windows at beginning (even)\n');

sfig1 = figure('Name', 'Slice of windows at beginning with clump factor 2');
bp1 = visviews.blockBoxPlot(sfig1, [], []);
assertTrue(isvalid(bp1));
slice1 = viscore.dataSlice('Slices', {':', ':', '1:10'}, ...
         'DimNames', {'Channel', 'Sample', 'Window'});
bp1.ClumpSize = 2;
bp1.plot(testVD, thisFunc, slice1);
gaps = bp1.getGaps();
bp1.reposition(gaps);
drawnow

fprintf('It should produce a plot for a slice of windows in one clump\n');

sfig2 = figure('Name', 'Slice of 2 windows with clump factor 3');
bp2 = visviews.blockBoxPlot(sfig2, [], []);
assertTrue(isvalid(bp2));
slice2 = viscore.dataSlice('Slices', {':', ':', '14:15'}, ...
         'DimNames', {'Channel', 'Sample', 'Window'});
bp2.ClumpSize = 3;
bp2.plot(testVD, thisFunc, slice2);
gaps = bp2.getGaps();
bp2.reposition(gaps);
drawnow


fprintf('It should produce a plot for a slice of windows uneven at end\n');

sfig3 = figure('Name', 'Slice of windows at end with clump factor 3');
bp3 = visviews.blockBoxPlot(sfig3, [], []);
assertTrue(isvalid(bp3));
slice3 = viscore.dataSlice('Slices', {':', ':', '14:20'}, ...
         'DimNames', {'Channel', 'Sample', 'Window'});
bp3.ClumpSize = 3;
bp3.plot(testVD, thisFunc, slice3);
gaps = bp3.getGaps();
bp3.reposition(gaps);
drawnow

fprintf('It should produce a plot for subset of elements and a slice of clumps uneven at end\n');
sfig4 = figure('Name', 'Elements 14:18 with slice of clumps uneven at the end');
bp4 = visviews.blockBoxPlot(sfig4, [], []);
assertTrue(isvalid(bp4));
slice4 = viscore.dataSlice('Slices', {'14:18', ':', '14:20'}, ...
         'DimNames', {'Channel', 'Sample', 'Window'});
bp4.ClumpSize = 3;
bp4.plot(testVD, thisFunc, slice4);
gaps = bp4.getGaps();
bp4.reposition(gaps);
drawnow

fprintf('It should produce a plot for one elements and a slice of clumps uneven at end\n');
sfig5 = figure('Name', 'Element 3 with slice of clumps uneven at the end');
bp5 = visviews.blockBoxPlot(sfig5, [], []);
assertTrue(isvalid(bp5));
slice5 = viscore.dataSlice('Slices', {'3', ':', '14:20'}, ...
         'DimNames', {'Channel', 'Sample', 'Window'});
bp5.ClumpSize = 3;
bp5.plot(testVD, thisFunc, slice5);
gaps = bp5.getGaps();
bp5.reposition(gaps);
drawnow

delete(sfig);
delete(sfig1);
delete(sfig2);
delete(sfig3);
delete(sfig4);
delete(sfig5);

function testLargeStandardDeviation %#ok<DEFNU>
%Unit test visviews.blockBoxPlot plot large data sets
fprintf('\nUnit tests for visviews.blockBoxPlot plot method large data sets\n')

fprintf('It should produce a plot for data with large standard deviation\n');
% Set up the data
data = random('normal', 0.0, 10000.0, [40, 1000, 215]);
testVD1 = viscore.blockedData(data, 'Random normal large std');
defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
    viewTestClass.getDefaultFunctionsNoSqueeze());
fMan = viscore.dataManager();
fMan.putObjects(defaults);
func = fMan.getEnabledObjects('block');
thisFunc = func{2};
thisFunc.setData(testVD1);


sfig1 = figure('Name', 'Data with large standard deviation');
bp1 = visviews.blockBoxPlot(sfig1, [], []);
assertTrue(isvalid(bp1));
slice1 = viscore.dataSlice('Slices', {':', ':', ':'}, ...
         'DimNames', {'Channel', 'Sample', 'Window'});
bp1.ClumpSize = 1;
bp1.plot(testVD1, thisFunc, slice1);
gaps = bp1.getGaps();
bp1.reposition(gaps);
drawnow

delete(sfig1)

function testGetClumpSlice %#ok<DEFNU>
%Unit test visviews.blockBoxPlot getClumpSlice
fprintf('\nUnit tests for visviews.blockBoxPlot getClumpSlice\n')

% Set up the data
data = random('exp', 1, [32, 1000, 20]);
testVD = viscore.blockedData(data, 'Rand1');
defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
    viewTestClass.getDefaultFunctionsNoSqueeze());
fMan = viscore.dataManager();
fMan.putObjects(defaults);
func = fMan.getEnabledObjects('block');
thisFunc = func{1};
thisFunc.setData(testVD);

sfig = figure('Name', 'Full range unclumped');
bp = visviews.blockBoxPlot(sfig, [], []);
assertTrue(isvalid(bp));
bp.plot(testVD, thisFunc, []);
gaps = bp.getGaps();
bp.reposition(gaps);

fprintf('It should produce the correct slice when plotting full range\n');
ds1 = bp.getClumpSlice(1);
ds2 = bp.getClumpSlice(20);
slices1 = ds1.getParameters(3);
slices2 = ds2.getParameters(3);
assertTrue(strcmp(slices1{1}, '1:32'));
assertTrue(strcmp(slices2{1}, '1:32'));
assertTrue(strcmp(slices1{3}, '1'));
assertTrue(strcmp(slices2{3}, '20'));

fprintf('It should produce an empty slice when clump factor is out of range\n');
ds3 = bp.getClumpSlice(0);
assertTrue(isempty(ds3));
ds4 = bp.getClumpSlice(21);
assertTrue(isempty(ds4));

fprintf('It should produce an empty slice when clump factor has changed without replotting\n');
bp.ClumpSize = 3;
ds1 = bp.getClumpSlice(1);
assertTrue(isempty(ds1));


fprintf('It should produce a correct slice with a clump factor\n');
bp.ClumpSize = 3;
bp.plot(testVD, thisFunc, []);
gaps = bp.getGaps();
bp.reposition(gaps);
ds1 = bp.getClumpSlice(1);
ds2 = bp.getClumpSlice(3);
ds3 = bp.getClumpSlice(7);
ds4 = bp.getClumpSlice(20);
assertTrue(isempty(ds4));
slices1 = ds1.getParameters(3);
slices2 = ds2.getParameters(3);
slices3 = ds3.getParameters(3);
assertTrue(strcmp(slices1{1}, '1:32'));
assertTrue(strcmp(slices2{1}, '1:32'));
assertTrue(strcmp(slices3{1}, '1:32'));
assertTrue(strcmp(slices1{3}, '1:3'));
assertTrue(strcmp(slices2{3}, '7:9'));
assertTrue(strcmp(slices3{3}, '19:20'));

fprintf('It should produce a correct slice with an unclumped a middle slice\n')
bp.ClumpSize  = 1;
plotSlice = viscore.dataSlice('Slices', {'7:18', ':', '12:15'}, ...
         'DimNames', {'Channel', 'Sample', 'Window'});
bp.plot(testVD, thisFunc, plotSlice);
gaps = bp.getGaps();
bp.reposition(gaps);

ds1 = bp.getClumpSlice(1);
ds2 = bp.getClumpSlice(3);
ds3 = bp.getClumpSlice(4);
ds4 = bp.getClumpSlice(20);
slices1 = ds1.getParameters(3);
slices2 = ds2.getParameters(3);
slices3 = ds3.getParameters(3);
assertTrue(strcmp(slices1{1}, '7:18'));
assertTrue(strcmp(slices2{1}, '7:18'));
assertTrue(strcmp(slices3{1}, '7:18'));
assertTrue(strcmp(slices1{3}, '12'));
assertTrue(strcmp(slices2{3}, '14'));
assertTrue(strcmp(slices3{3}, '15'));
assertTrue(isempty(ds4));

fprintf('It should produce a correct slice with an clumped a middle slice\n')
bp.ClumpSize  = 3;
plotSlice = viscore.dataSlice('Slices', {'7:18', ':', '2:15'}, ...
         'DimNames', {'Channel', 'Sample', 'Window'});
bp.plot(testVD, thisFunc, plotSlice);
gaps = bp.getGaps();
bp.reposition(gaps);

ds1 = bp.getClumpSlice(1);
ds2 = bp.getClumpSlice(3);
ds3 = bp.getClumpSlice(5);
ds4 = bp.getClumpSlice(20);
slices1 = ds1.getParameters(3);
slices2 = ds2.getParameters(3);
slices3 = ds3.getParameters(3);
assertTrue(strcmp(slices1{1}, '7:18'));
assertTrue(strcmp(slices2{1}, '7:18'));
assertTrue(strcmp(slices3{1}, '7:18'));
assertTrue(strcmp(slices1{3}, '2:4'));
assertTrue(strcmp(slices2{3}, '8:10'));
assertTrue(strcmp(slices3{3}, '14:15'));
assertTrue(isempty(ds4));

delete(sfig)

function testConstantAndNaNValues %#ok<DEFNU>
% Unit test visviews.blockBoxPlot plot constant and NaN
fprintf('\nUnit tests for visviews.blockBoxPlot plot method with constant and NaN values\n')

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
bp1 = visviews.blockBoxPlot(sfig1, [], []);
assertTrue(isvalid(bp1));
bp1.plot(testVD, thisFuncS, slice1);
gaps = bp1.getGaps();
bp1.reposition(gaps);
drawnow

% Data zeros, function NaN
fprintf('It should produce a plot for when data is zero, funcs NaNs (---see warning)\n');
data = zeros([32, 1000, 20]);
testVD = viscore.blockedData(data, 'Data zeros, func NaN');
slice2 = viscore.dataSlice('Slices', {':', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
sfig2 = figure('Name', 'Data zero, func NaN');
bp2 = visviews.blockBoxPlot(sfig2, [], []);
assertTrue(isvalid(bp2));
bp2.plot(testVD, thisFuncK, slice2);
gaps = bp2.getGaps();
bp2.reposition(gaps);
drawnow

% Data NaN
fprintf('It should produce a plot for when data is zero, funcs NaNs (---see warning)\n');
data = NaN([32, 1000, 20]);
testVD = viscore.blockedData(data, 'Data NaN');
slice3 = viscore.dataSlice('Slices', {':', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
sfig3 = figure('Name', 'Data NaNs');
bp3 = visviews.blockBoxPlot(sfig3, [], []);
assertTrue(isvalid(bp3));
bp3.plot(testVD, thisFuncS, slice3);
gaps = bp3.getGaps();
bp3.reposition(gaps);
drawnow

% Data slice empty
fprintf('It should produce empty axes when data slice is empty (---see warning)\n');
data = zeros(5, 1);
testVD = viscore.blockedData(data, 'Data empty');
slice4 = viscore.dataSlice('Slices', {'6', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
sfig4 = figure('Name', 'Data slice is empty');
bp4 = visviews.blockBoxPlot(sfig4, [], []);
assertTrue(isvalid(bp4));
bp4.plot(testVD, thisFuncS, slice4);
gaps = bp4.getGaps();
bp4.reposition(gaps);
drawnow
delete(sfig1);
delete(sfig2);
delete(sfig3);
delete(sfig4);
