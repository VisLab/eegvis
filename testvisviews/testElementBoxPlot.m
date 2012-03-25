function test_suite = testElementBoxPlot %#ok<STOUT>
initTestSuite;

function testNormalConstructor %#ok<DEFNU>
% Unit test for visviews.elementBoxPlot constructor
fprintf('\nUnit tests for visviews.elementBoxPlot valid constructor\n');

fprintf('It should construct a valid element box plot when only parent passed\n');
sfig = figure('Name', 'Empty plot');
bp = visviews.elementBoxPlot(sfig, [], []);
assertTrue(isvalid(bp));
drawnow
delete(sfig);

function testBadConstructor %#ok<DEFNU>
% Unit test for visviews.elementBoxPlot invalid constructor
fprintf('\nUnit tests for visviews.elementBoxPlot invalid constructor parameters\n');

fprintf('It should throw an exception when no parameters are passed\n');
f = @() visviews.elementBoxPlot();
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when only one parameter is passed\n');
sfig = figure;
f = @() visviews.elementBoxPlot(sfig);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when only two parameters are passed\n');
f = @() visviews.elementBoxPlot(sfig, []);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when more than three parameters are passed\n');
f = @() visviews.elementBoxPlot(sfig, [], [], []);
assertExceptionThrown(f, 'MATLAB:maxrhs');
delete(sfig);

function testGetDefaultProperties %#ok<DEFNU>
% Unit test for visviews.elementBoxPlot getDefaultProperties
fprintf('\nUnit tests for visviews.elementBoxPlot getDefaultProperties\n');

fprintf('It should have a getDefaultProperties method that returns a structure\n');
s = visviews.elementBoxPlot.getDefaultProperties();
assertTrue(isa(s, 'struct'));

function testPlot %#ok<DEFNU>
% Unit test evisviews.elementBoxPlot plot
fprintf('\nUnit tests for visviews.elementBoxPlot plot method\n');

fprintf('It should produce a plot for identity slice\n');
sfig = figure('Name', 'Clumps of one element');
bp = visviews.elementBoxPlot(sfig, [], []);
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
    'DimNames', {'Channel', 'Sample', 'Kurtosis'});
bp.plot(testVD, thisFunc, slice1);
drawnow
gaps = bp.getGaps();
bp.reposition(gaps);
fprintf('It should allow callbacks to be registered\n')
bp.registerCallbacks([]);

fprintf('It should produce a plot for empty slice\n');
sfig1 = figure('Name', 'Empty slice');
bp = visviews.elementBoxPlot(sfig1, [], []);
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
bp.plot(testVD, thisFunc, []);
drawnow
gaps = bp.getGaps();
bp.reposition(gaps);


fprintf('It should produce a plot when channels divided into an even number of groups\n');
% Generate some data to plot
data = random('exp', 1, [32, 1000, 20]);
testVD = viscore.blockedData(data, 'Rand1');
defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
    viewTestClass.getDefaultFunctionsNoSqueeze());
slice1 = viscore.dataSlice('Slices', {':', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
fprintf('It should produce a plot for identity slice with groupings of 2\n');
sfig2 = figure('Name', 'No grouping for comparison with grouping of 2');
bp = visviews.elementBoxPlot(sfig2, [], []);
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


sfig3 = figure('Name', 'Grouping of 2');
bp1 = visviews.elementBoxPlot(sfig3, [], []);
assertTrue(isvalid(bp1));
fMan = viscore.dataManager();
fMan.putObjects(defaults);
func = fMan.getEnabledObjects('block');
thisFunc = func{1};
thisFunc.setData(testVD);
bp1.ClumpFactor = 2;
bp1.plot(testVD, thisFunc, slice1);
drawnow
gaps = bp1.getGaps();
bp1.reposition(gaps);


fprintf('It should produce a plot for identity slice with 1 group\n');
sfig4 = figure('Name', 'Group of one');
bp = visviews.elementBoxPlot(sfig4, [], []);
assertTrue(isvalid(bp));
% Generate some data to plot
data = random('exp', 1, [32, 1000, 20]);
testVD = viscore.blockedData(data, 'Rand1');
defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
    viewTestClass.getDefaultFunctions());
fMan = viscore.dataManager();
fMan.putObjects(defaults);
func = fMan.getEnabledObjects('block');
thisFunc = func{1};
thisFunc.setData(testVD);
bp.ClumpFactor = 32;
slice1 = viscore.dataSlice('Slices', {':', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
bp.plot(testVD, thisFunc, slice1);
drawnow
gaps = bp.getGaps();
bp.reposition(gaps);

fprintf('It should produce a plot for an uneven grouping of channels\n');
% Generate some data to plot
data = random('exp', 1, [32, 1000, 20]);
testVD = viscore.blockedData(data, 'Rand1');
defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
    viewTestClass.getDefaultFunctions());
slice1 = viscore.dataSlice('Slices', {':', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
fprintf('It should produce a plot for identity slice with uneven grouping\n');
sfig5 = figure('Name', 'Ungrouped to compare with uneven grouping');
bp = visviews.elementBoxPlot(sfig5, [], []);
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

sfig6 = figure('Name', 'Uneven grouping');
bp1 = visviews.elementBoxPlot(sfig6, [], []);
assertTrue(isvalid(bp));
fMan = viscore.dataManager();
fMan.putObjects(defaults);
func = fMan.getEnabledObjects('block');
thisFunc = func{1};
thisFunc.setData(testVD);
bp1.ClumpFactor = 3;

bp1.plot(testVD, thisFunc, slice1);
gaps = bp1.getGaps();
bp1.reposition(gaps);

delete(sfig);
delete(sfig1);
delete(sfig2);
delete(sfig3);
delete(sfig4);
delete(sfig5);
delete(sfig6);

function testPlotSlice %#ok<DEFNU>
% Unit test visviews.blockBoxPlot plot  with nonempy slice
fprintf('\nUnit tests for visviews.elementBoxPlot plot method with slice\n')

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


fprintf('It should produce a plot for a slice of elements at beginning\n');

sfig = figure('Name', 'Empty slice plot for comparison');
bp = visviews.elementBoxPlot(sfig, [], []);
assertTrue(isvalid(bp));
bp.plot(testVD, thisFunc, []);
gaps = bp.getGaps();
bp.reposition(gaps);

sfig1 = figure('Name', 'Slice of element at beginning');
bp1 = visviews.elementBoxPlot(sfig1, [], []);
assertTrue(isvalid(bp1));
slice1 = viscore.dataSlice('Slices', {'1:10', ':', ':'}, ...
         'DimNames', {'Channel', 'Sample', 'Window'});
bp1.plot(testVD, thisFunc, slice1);
gaps = bp1.getGaps();
bp1.reposition(gaps);
drawnow

fprintf('It should produce a plot for a slice of elements in the middle\n');
sfig2 = figure('Name', 'Slice of elements in middle');
bp2 = visviews.elementBoxPlot(sfig2, [], []);
assertTrue(isvalid(bp2));
slice2 = viscore.dataSlice('Slices', {'4:9', ':', ':'}, ...
         'DimNames', {'Channel', 'Sample', 'Window'});
bp2.plot(testVD, thisFunc, slice2);
gaps = bp2.getGaps();
bp2.reposition(gaps);
drawnow

fprintf('It should produce a plot for a slice of windows that falls off the end\n');
sfig3 = figure('Name', 'Slice of windows off the end');
bp3 = visviews.elementBoxPlot(sfig3, [], []);
assertTrue(isvalid(bp3));
slice3 = viscore.dataSlice('Slices', {'15:21', ':', ':'}, ...
         'DimNames', {'Channel', 'Sample', 'Window'});
bp3.plot(testVD, thisFunc, slice3);
gaps = bp3.getGaps();
bp3.reposition(gaps);
drawnow

fprintf('It should produce a plot for an empty slice\n');

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

sfig4 = figure('Name', 'Empty slice plot for comparison');
bp = visviews.elementBoxPlot(sfig4, [], []);
assertTrue(isvalid(bp));
bp.plot(testVD, thisFunc, []);
gaps = bp.getGaps();
bp.reposition(gaps);

fprintf('It should produce a plot for a slice of elements at beginning (even clump)\n');

sfig5 = figure('Name', 'Slice of elements at beginning with clump factor 2');
bp1 = visviews.elementBoxPlot(sfig5, [], []);
assertTrue(isvalid(bp1));
slice1 = viscore.dataSlice('Slices', {'1:10', ':', ':'}, ...
         'DimNames', {'Channel', 'Sample', 'Window'});
bp1.ClumpFactor = 2;
bp1.plot(testVD, thisFunc, slice1);
gaps = bp1.getGaps();
bp1.reposition(gaps);
drawnow

fprintf('It should produce a plot for a slice of elements uneven at end\n');

sfig6 = figure('Name', 'Slice of elements at end with clump factor 3');
bp2 = visviews.elementBoxPlot(sfig6, [], []);
assertTrue(isvalid(bp2));
slice2 = viscore.dataSlice('Slices', {'14:20', ':', ':'}, ...
         'DimNames', {'Channel', 'Sample', 'Window'});
bp2.ClumpFactor = 3;
bp2.plot(testVD, thisFunc, slice2);
gaps = bp2.getGaps();
bp2.reposition(gaps);
drawnow

fprintf('It should produce a plot for a slice of elements in one clump\n');

sfig7 = figure('Name', 'Slice of 2 elements with clump factor 3');
bp3 = visviews.elementBoxPlot(sfig7, [], []);
assertTrue(isvalid(bp3));
slice3 = viscore.dataSlice('Slices', {'14:15', ':', ':'}, ...
         'DimNames', {'Channel', 'Sample', 'Window'});
bp3.ClumpFactor = 3;
bp3.plot(testVD, thisFunc, slice3);
gaps = bp3.getGaps();
bp3.reposition(gaps);
drawnow

fprintf('It should produce a plot for subset of elements and a slice of clumps uneven at end\n');
sfig4 = figure('Name', 'Elements 14:18 with slice of clumps uneven at the end');
bp4 = visviews.elementBoxPlot(sfig4, [], []);
assertTrue(isvalid(bp4));
slice4 = viscore.dataSlice('Slices', {'14:18', ':', '14:20'}, ...
         'DimNames', {'Channel', 'Sample', 'Window'});
bp4.ClumpFactor = 3;
bp4.plot(testVD, thisFunc, slice4);
gaps = bp4.getGaps();
bp4.reposition(gaps);
drawnow

fprintf('It should produce a plot for one elements and clump factor 1\n');
sfig5 = figure('Name', 'Element 3 with clump factor 1 (single point)');
bp5 = visviews.elementBoxPlot(sfig5, [], []);
assertTrue(isvalid(bp5));
slice5 = viscore.dataSlice('Slices', {'3', ':', '14:20'}, ...
         'DimNames', {'Channel', 'Sample', 'Window'});
bp5.ClumpFactor = 1;
bp5.plot(testVD, thisFunc, slice5);
gaps = bp5.getGaps();
bp5.reposition(gaps);
drawnow

fprintf('It should produce a plot for single point\n');
sfig6 = figure('Name', 'Elements 14 and Window 4');
bp6 = visviews.elementBoxPlot(sfig6, [], []);
assertTrue(isvalid(bp6));
slice6 = viscore.dataSlice('Slices', {'14', ':', '4'}, ...
         'DimNames', {'Channel', 'Sample', 'Window'});
bp6.plot(testVD, thisFunc, slice6);
gaps = bp6.getGaps();
bp6.reposition(gaps);
drawnow

delete(sfig);
delete(sfig1);
delete(sfig2);
delete(sfig3);
delete(sfig4);
delete(sfig5);
delete(sfig6);

function testPlotOneValue %#ok<DEFNU>
% Unit test of visviews.elementBoxPlot for a single value
fprintf('\nUnit tests for visviews.elementBoxPlot plot method one value\n')
fprintf('It should produce a valid plot for one value\n');
% test blockBoxPlot plot
sfig = figure('Name', 'One value');
bp = visviews.elementBoxPlot(sfig, [], []);
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
bp.ClumpFactor = 20;
slice1 = viscore.dataSlice('Slices', {'3', ':', '2'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
bp.plot(testVD, thisFunc, slice1);
drawnow
gaps = bp.getGaps();
bp.reposition(gaps);
delete(sfig);

function testUnevenGroupingSpecificValues %#ok<DEFNU>
% Unit test visviews.elementBoxPlot plot uneven grouping of windows
fprintf('\nUnit tests for visviews.elementBoxPlot plot method uneven grouping specific values\n')

% Set up the data
data = repmat([1, 1, 1, 2, 2, 2, 3]', [1, 5, 4]);
testVD = viscore.blockedData(data, 'Specific values');
defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
    viewTestClass.getDefaultFunctionsSpecificValues());
slice1 = viscore.dataSlice('Slices', {':', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
fprintf('It should produce a plot for identity slice with uneven grouping\n');

sfig = figure('Name', 'No grouping to compare with specific values');
bp = visviews.elementBoxPlot(sfig, [], []);
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
bp1 = visviews.elementBoxPlot(sfig1, [], []);
assertTrue(isvalid(bp1));
fMan = viscore.dataManager();
fMan.putObjects(defaults);
func = fMan.getEnabledObjects('block');
thisFunc = func{1};
thisFunc.setData(testVD);
bp1.ClumpFactor = 3;

bp1.plot(testVD, thisFunc, slice1);
gaps = bp1.getGaps();
bp1.reposition(gaps);
drawnow
delete(sfig);
delete(sfig1);

function testGetClumpSlize %#ok<DEFNU>
%Unit test visviews.elementBoxPlot getClumpSlice
fprintf('\nUnit tests for visviews.elementBoxPlot getClumpSlice\n')

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
ep = visviews.elementBoxPlot(sfig, [], []);
assertTrue(isvalid(ep));
ep.plot(testVD, thisFunc, []);
gaps = ep.getGaps();
ep.reposition(gaps);

fprintf('It should produce the correct slice when plotting full range\n');
ds1 = ep.getClumpSlice(1);
ds2 = ep.getClumpSlice(32);
slices1 = ds1.getParameters(3);
slices2 = ds2.getParameters(3);
assertTrue(strcmp(slices1{1}, '1'));
assertTrue(strcmp(slices2{1}, '32'));
assertTrue(strcmp(slices1{3}, '1:20'));
assertTrue(strcmp(slices2{3}, '1:20'));

fprintf('It should produce an empty slice when clump factor is out of range\n');
ds3 = ep.getClumpSlice(0);
assertTrue(isempty(ds3));
ds4 = ep.getClumpSlice(33);
assertTrue(isempty(ds4));

fprintf('It should produce an empty slice when clump factor has changed without replotting\n');
ep.ClumpFactor = 3;
ds1 = ep.getClumpSlice(1);
assertTrue(isempty(ds1));


fprintf('It should produce a correct slice with a clump factor\n');
ep.ClumpFactor = 3;
ep.plot(testVD, thisFunc, []);
gaps = ep.getGaps();
ep.reposition(gaps);
ds1 = ep.getClumpSlice(1);
ds2 = ep.getClumpSlice(3);
ds3 = ep.getClumpSlice(11);
ds4 = ep.getClumpSlice(20);
assertTrue(isempty(ds4));
slices1 = ds1.getParameters(3);
slices2 = ds2.getParameters(3);
slices3 = ds3.getParameters(3);
assertTrue(strcmp(slices1{1}, '1:3'));
assertTrue(strcmp(slices2{1}, '7:9'));
assertTrue(strcmp(slices3{1}, '31:32'));
assertTrue(strcmp(slices1{3}, '1:20'));
assertTrue(strcmp(slices2{3}, '1:20'));
assertTrue(strcmp(slices3{3}, '1:20'));

fprintf('It should produce a correct slice with an unclumped a middle slice\n')
ep.ClumpFactor  = 1;
plotSlice = viscore.dataSlice('Slices', {'7:18', ':', '2:15'}, ...
         'DimNames', {'Channel', 'Sample', 'Window'});
ep.plot(testVD, thisFunc, plotSlice);
gaps = ep.getGaps();
ep.reposition(gaps);

ds1 = ep.getClumpSlice(1);
ds2 = ep.getClumpSlice(3);
ds3 = ep.getClumpSlice(11);
ds4 = ep.getClumpSlice(20);
slices1 = ds1.getParameters(3);
slices2 = ds2.getParameters(3);
slices3 = ds3.getParameters(3);
assertTrue(strcmp(slices1{1}, '7'));
assertTrue(strcmp(slices2{1}, '9'));
assertTrue(strcmp(slices3{1}, '17'));
assertTrue(strcmp(slices1{3}, '2:15'));
assertTrue(strcmp(slices2{3}, '2:15'));
assertTrue(strcmp(slices3{3}, '2:15'));
assertTrue(isempty(ds4));


fprintf('It should produce a correct slice with an clumped a middle slice\n')
ep.ClumpFactor  = 3;
plotSlice = viscore.dataSlice('Slices', {'7:17', ':', '2:15'}, ...
         'DimNames', {'Channel', 'Sample', 'Window'});
ep.plot(testVD, thisFunc, plotSlice);
gaps = ep.getGaps();
ep.reposition(gaps);

ds1 = ep.getClumpSlice(1);
ds2 = ep.getClumpSlice(3);
ds3 = ep.getClumpSlice(4);
ds4 = ep.getClumpSlice(20);
slices1 = ds1.getParameters(3);
slices2 = ds2.getParameters(3);
slices3 = ds3.getParameters(3);
assertTrue(strcmp(slices1{1}, '7:9'));
assertTrue(strcmp(slices2{1}, '13:15'));
assertTrue(strcmp(slices3{1}, '16:17'));
assertTrue(strcmp(slices1{3}, '2:15'));
assertTrue(strcmp(slices2{3}, '2:15'));
assertTrue(strcmp(slices3{3}, '2:15'));
assertTrue(isempty(ds4));
delete(sfig);

function testConstantAndNaNValues %#ok<DEFNU>
% Unit test visviews.elementBoxPlot plot constant and NaN
fprintf('\nUnit tests for visviews.elementBoxPlot plot method with constant and NaN values\n')

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
bp1 = visviews.elementBoxPlot(sfig1, [], []);
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
bp2 = visviews.elementBoxPlot(sfig2, [], []);
assertTrue(isvalid(bp2));
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
bp3 = visviews.elementBoxPlot(sfig3, [], []);
assertTrue(isvalid(bp3));
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
bp4 = visviews.elementBoxPlot(sfig4, [], []);
assertTrue(isvalid(bp4));
bp4.plot(testVD, thisFuncS, slice4);
gaps = bp4.getGaps();
bp4.reposition(gaps);
drawnow
delete(sfig1);
delete(sfig2);
delete(sfig3);
delete(sfig4);

