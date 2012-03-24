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