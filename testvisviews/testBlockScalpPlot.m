function test_suite = testBlockScalpPlot %#ok<STOUT>
initTestSuite;

function testNormalConstructor %#ok<DEFNU>
% Unit test for visviews.blockScalpPlot constructor
fprintf('\nUnit tests for visviews.blockScalpPlot valid constructor\n');

fprintf('It should construct a valid element box plot when only parent passed\n');
sfig = figure('Name', 'Empty plot');
bp = visviews.blockScalpPlot(sfig, [], []);
assertTrue(isvalid(bp));
drawnow
delete(sfig);

function testBadConstructor %#ok<DEFNU>
% Unit test for visviews.blockScalpPlot invalid constructor
fprintf('\nUnit tests for visviews.blockScalpPlot invalid constructor parameters\n');

fprintf('It should throw an exception when no parameters are passed\n');
f = @() visviews.blockScalpPlot();
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when only one parameter is passed\n');
sfig = figure;
f = @() visviews.blockScalpPlot(sfig);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when only two parameters are passed\n');
f = @() visviews.blockScalpPlot(sfig, []);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when more than three parameters are passed\n');
f = @() visviews.blockScalpPlot(sfig, [], [], []);
assertExceptionThrown(f, 'MATLAB:maxrhs');
delete(sfig);

function testGetDefaultProperties %#ok<DEFNU>
% Unit test for visviews.blockScalpPlot getDefaultProperties
fprintf('\nUnit tests for visviews.blockScalpPlot getDefaultProperties\n');

fprintf('It should have a getDefaultProperties method that returns a structure\n');
s = visviews.blockScalpPlot.getDefaultProperties();
assertTrue(isa(s, 'struct'));

function testPlot %#ok<DEFNU>
% Unit test evisviews.blockScalpPlot plot
fprintf('\nUnit tests for visviews.blockScalpPlot plot method\n');

fprintf('It should produce a plot for identity slice\n');
sfig = figure('Name', 'Clumps of one element');
bp = visviews.blockScalpPlot(sfig, [], []);
assertTrue(isvalid(bp));
% Generate some data to plot
data = random('exp', 1, [32, 1000, 20]);
load chanlocs.mat;
testVD = viscore.blockedData(data, 'Rand1', 'ElementLocations', chanlocs);
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

fprintf('It should allow callbacks to be registered\n')
bp.registerCallbacks(bp);

fprintf('It should produce a plot for empty slice\n');
sfig1 = figure('Name', 'Empty slice');
bp = visviews.blockScalpPlot(sfig1, [], []);
assertTrue(isvalid(bp));
% Generate some data to plot
data = random('exp', 1, [32, 1000, 20]);
testVD = viscore.blockedData(data, 'Rand1', 'ElementLocations', chanlocs);
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


fprintf('It should produce a plot when not all blocks in slice\n');
testVD = viscore.blockedData(data, 'Rand1', 'ElementLocations', chanlocs);
defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
    viewTestClass.getDefaultFunctionsNoSqueeze());
slice2 = viscore.dataSlice('Slices', {':', ':', '6:8'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});

sfig2 = figure('Name', 'Slice with Windows 6-8');
bp = visviews.blockScalpPlot(sfig2, [], []);
assertTrue(isvalid(bp));
fMan = viscore.dataManager();
fMan.putObjects(defaults);
func = fMan.getEnabledObjects('block');
thisFunc = func{1};
thisFunc.setData(testVD);

bp.plot(testVD, thisFunc, slice2);
drawnow
gaps = bp.getGaps();
bp.reposition(gaps);

fprintf('It should produce a plot when not all channels in slice\n');
testVD = viscore.blockedData(data, 'Rand1', 'ElementLocations', chanlocs);
defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
    viewTestClass.getDefaultFunctionsNoSqueeze());
slice3 = viscore.dataSlice('Slices', {'2:10', ':', '4:7'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});

sfig3 = figure('Name', 'Slice with Channels(2:10) Windows 4-7');
bp = visviews.blockScalpPlot(sfig3, [], []);
assertTrue(isvalid(bp));
fMan = viscore.dataManager();
fMan.putObjects(defaults);
func = fMan.getEnabledObjects('block');
thisFunc = func{1};
thisFunc.setData(testVD);

bp.plot(testVD, thisFunc, slice3);
drawnow
gaps = bp.getGaps();
bp.reposition(gaps);
bp.registerCallbacks([]);
%delete(sfig)
%delete(sfig1)
%delete(sfig2)
%delete(sfit3)

function testRegisterCallbacks %#ok<DEFNU>
% Unit test evisviews.blockScalpPlot register callbacks
fprintf('\nUnit tests for visviews.blockScalpPlot register callbacks\n');
fprintf('It should produce respond to callbacks when not all channels in slice\n');
data = random('exp', 1, [32, 1000, 20]);
load chanlocs.mat;
testVD = viscore.blockedData(data, 'Rand1', 'ElementLocations', chanlocs);
defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
    viewTestClass.getDefaultFunctionsNoSqueeze());
slice1 = viscore.dataSlice('Slices', {'2:10', ':', '4:7'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});

sfig1 = figure('Name', 'Slice with Channels(2:10) Windows 4-7');
bp = visviews.blockScalpPlot(sfig1, [], []);
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
bp.registerCallbacks([]);


function testSetBackgroundColor %#ok<DEFNU>
% Unit test evisviews.blockScalpPlot setBackgroundColor
fprintf('\nUnit tests for visviews.blockScalpPlot to set background color\n');
fprintf('It should correctly set the background color when it changes\n');
data = random('exp', 1, [32, 1000, 20]);
load chanlocs.mat;
testVD = viscore.blockedData(data, 'Rand1', 'ElementLocations', chanlocs);
defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
    viewTestClass.getDefaultFunctionsNoSqueeze());
slice1 = viscore.dataSlice('Slices', {'2:10', ':', '4:7'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});

sfig1 = figure('Name', 'Slice with Channels(2:10) Windows 4-7');
bp = visviews.blockScalpPlot(sfig1, [], []);
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
bp.setBackgroundColor([1, 0, 0]);
bp.plot(testVD, thisFunc, slice1);
drawnow
bp.registerCallbacks([]);


function testConstantAndNaNValues %#ok<DEFNU>
% Unit test visviews.blockScalpPlot plot constant and NaN
fprintf('\nUnit tests for visviews.blockScalpPlot plot method with constant and NaN values\n')

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
bp1 = visviews.blockScalpPlot(sfig1, [], []);
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
bp2 = visviews.blockScalpPlot(sfig2, [], []);
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
bp3 = visviews.blockScalpPlot(sfig3, [], []);
assertTrue(isvalid(bp3));
bp3.plot(testVD, thisFuncS, slice3);
gaps = bp3.getGaps();
bp3.reposition(gaps);
drawnow

% Data slice empty
fprintf('It should produce empty axes when data slice is empty\n');
data = zeros(5, 1);
testVD = viscore.blockedData(data, 'Data empty');
slice4 = viscore.dataSlice('Slices', {'6', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
sfig4 = figure('Name', 'Data slice is empty');
bp4 = visviews.blockScalpPlot(sfig4, [], []);
assertTrue(isvalid(bp4));
bp4.plot(testVD, thisFuncS, slice4);
gaps = bp4.getGaps();
bp4.reposition(gaps);
drawnow
% delete(sfig1);
% delete(sfig2);
% delete(sfig3);
% delete(sfig4);

function testPlotInterpolationMethod %#ok<DEFNU>
% Unit test evisviews.blockScalpPlot plot
fprintf('\nUnit tests for visviews.blockScalpPlot plot interpolation method\n');

fprintf('It should produce a plot different interpolation methods\n');
% Generate some data to plot
data = random('exp', 1, [32, 1000, 20]);
load chanlocs.mat;
testVD = viscore.blockedData(data, 'Rand1', 'ElementLocations', chanlocs);
defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
    viewTestClass.getDefaultFunctionsNoSqueeze());
fMan = viscore.dataManager();
fMan.putObjects(defaults);
func = fMan.getEnabledObjects('block');
thisFunc = func{1};
thisFunc.setData(testVD);
slice1 = viscore.dataSlice('Slices', {':', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});

sfig = figure('Name', 'Interpolation v4 (default)');
bp = visviews.blockScalpPlot(sfig, [], []);
assertTrue(isvalid(bp));
assertTrue(strcmp(bp.InterpolationMethod, 'v4'));
bp.plot(testVD, thisFunc, slice1);
drawnow
gaps = bp.getGaps();
bp.reposition(gaps);

sfig1 = figure('Name', 'Interpolation linear');
bp1 = visviews.blockScalpPlot(sfig1, [], []);
assertTrue(isvalid(bp1));
bp1.InterpolationMethod = 'linear';
bp1.plot(testVD, thisFunc, slice1);
drawnow
gaps = bp1.getGaps();
bp1.reposition(gaps);


sfig2 = figure('Name', 'Interpolation cubic');
bp2 = visviews.blockScalpPlot(sfig2, [], []);
assertTrue(isvalid(bp2));
bp2.InterpolationMethod = 'cubic';
bp2.plot(testVD, thisFunc, slice1);
drawnow
gaps = bp2.getGaps();
bp2.reposition(gaps);

sfig3 = figure('Name', 'Interpolation nearest');
bp3 = visviews.blockScalpPlot(sfig3, [], []);
assertTrue(isvalid(bp3));
bp3.InterpolationMethod = 'nearest';
bp3.plot(testVD, thisFunc, slice1);
drawnow
gaps = bp3.getGaps();
bp3.reposition(gaps);

%delete(sfig)
%delete(sfig1)
%delete(sfig2)
%delete(sfig3)