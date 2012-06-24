function test_suite = testBlockImagePlot %#ok<STOUT>
% Unit tests for blockImagePlot
initTestSuite;

function values = setup %#ok<DEFNU>
load('EEGData.mat'); 
values.EEG = EEG;  
tEvents = EEG.event;
types = {tEvents.type}';
                                      % Convert to seconds since beginning
startTimes = (round(double(cell2mat({EEG.event.latency}))') - 1)./EEG.srate; 
values.event = struct('type', types, 'startTime', num2cell(startTimes), ...
    'certainty', ones(length(startTimes), 1));
values.random = random('exp', 2, [32, 1000, 20]);

load('EEGEpoch.mat'); 
values.EEGEpoch = EEGEpoch;

values.deleteFigures = true;

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test


function testNormalConstructor(values) %#ok<DEFNU>
% testSignalPlot unit test for visviews.blockImagePlot constructor
fprintf('\nUnit tests for visviews.blockImagePlot valid constructor\n');

fprintf('It should construct a valid block image plot when only parent passed')
sfig = figure('Name', 'Empty plot');
ip = visviews.blockImagePlot(sfig, [], []);
assertTrue(isvalid(ip));
drawnow
if values.deleteFigures
    delete(sfig);
end

function testBadConstructor(values) %#ok<DEFNU>
% Unit test for visviews.blockImagePlot bad constructor
fprintf('\nUnit tests for visviews.blockImagePlot invalid constructor parameters\n');

fprintf('It should throw an exception when no parameters are passed\n');
f = @() visviews.blockImagePlot();
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when only one parameter is passed\n');
sfig = figure;
f = @() visviews.blockImagePlot(sfig);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when only two parameters are passed\n');
f = @() visviews.blockImagePlot(sfig, []);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when more than three parameters are passed\n');
f = @() visviews.blockImagePlot(sfig, [], [], []);
assertExceptionThrown(f, 'MATLAB:maxrhs');
if values.deleteFigures
  delete(sfig);
end

function testPlot(values) %#ok<DEFNU>
% Unit test for visviews.blockImagePlot plot
fprintf('\nUnit tests for visviews.blockImagePlot plot method\n')
testVD = viscore.blockedData(values.EEG.data, 'Rand1', ...
    'SampleRate', values.EEG.srate);
defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
    viewTestClass.getDefaultFunctionsNoSqueeze());
fMan = viscore.dataManager();
fMan.putObjects(defaults);
func = fMan.getEnabledObjects('block');
thisFunc = func{1};

fprintf('It should produce a plot for identity slice\n');
sfig1 = figure('Name', 'Clumps of one window');
ip1 = visviews.blockImagePlot(sfig1, [], []);
assertTrue(isvalid(ip1));
slice1 = viscore.dataSlice('Slices', {':', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
ip1.plot(testVD, thisFunc, slice1);
drawnow
gaps = ip1.getGaps();
ip1.reposition(gaps);

fprintf('It should allow callbacks to be registered\n')
ip1.registerCallbacks(ip1);

fprintf('It should produce a plot for empty slice\n');
sfig2 = figure('Name', 'Empty slice');
ip2 = visviews.blockImagePlot(sfig2, [], []);
assertTrue(isvalid(ip2));
ip2.plot(testVD, thisFunc, []);
gaps = ip2.getGaps();
ip2.reposition(gaps);

fprintf('It should produce a plot for identity slice with groupings of 2\n');
sfig3 = figure('Name', 'Grouping of 2');
ip3 = visviews.blockImagePlot(sfig3, [], []);
assertTrue(isvalid(ip3));
ip3.ClumpFactor = 2;
ip3.plot(testVD, thisFunc, slice1);
gaps = ip3.getGaps();
ip3.reposition(gaps);

fprintf('It should produce a plot for identity slice with 1 group\n');
sfig4 = figure('Name', 'Group of one');
ip4 = visviews.blockImagePlot(sfig4, [], []);
assertTrue(isvalid(ip4));
ip4.ClumpFactor = 20;
ip4.plot(testVD, thisFunc, slice1);
gaps = ip4.getGaps();
ip4.reposition(gaps);

fprintf('It should produce a plot for identity slice with uneven grouping\n');
sfig5 = figure('Name', 'Uneven grouping');
ip5 = visviews.blockImagePlot(sfig5, [], []);
assertTrue(isvalid(ip5));
ip5.ClumpFactor = 3;
ip5.plot(testVD, thisFunc, slice1);
gaps = ip5.getGaps();
ip5.reposition(gaps);

fprintf('It should produce a plot for identity slice for small data sets\n');
% Generate some data to plot
data = random('exp', 1, [5, 1000, 4]);
testVD = viscore.blockedData(data, 'Rand1');
sfig6 = figure('Name', 'Uneven  small group');
ip6 = visviews.blockImagePlot(sfig6, [], []);
assertTrue(isvalid(ip6));
ip6.ClumpFactor = 7;
ip6.plot(testVD, thisFunc, slice1);
gaps = ip6.getGaps();
ip6.reposition(gaps);

fprintf('It should produce a plot for identity slice with 1 element\n');
% Generate some data to plot
data = random('exp', 1, [1, 1000, 20]);
testVD7 = viscore.blockedData(data, 'Rand1');
slice1 = viscore.dataSlice('Slices', {':', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
sfig7 = figure('Name', 'One element grouped by 3');
ip7 = visviews.blockImagePlot(sfig1, [], []);
assertTrue(isvalid(ip7));
ip7.ClumpFactor = 3;
ip7.plot(testVD7, thisFunc, slice1);
gaps = ip7.getGaps();
ip7.reposition(gaps);

drawnow
if values.deleteFigures
    delete(sfig1);
    delete(sfig2);
    delete(sfig3);
    delete(sfig4);
    delete(sfig5);
    delete(sfig6);
    delete(sfig7);
end

function testPlotSlice(values) %#ok<DEFNU>
% Unit test visviews.blockImagePlot plot  with nonempy slice
fprintf('\nUnit tests for visviews.blockImagePlot plot method with slice\n')
testVD = viscore.blockedData(values.EEG.data, 'Rand1', ...
    'SampleRate', values.EEG.srate);
defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
    viewTestClass.getDefaultFunctionsNoSqueeze());
fMan = viscore.dataManager();
fMan.putObjects(defaults);
func = fMan.getEnabledObjects('block');
thisFunc = func{1};

fprintf('It should produce a plot for a slice of windows at beginning\n');
sfig1 = figure('Name', 'Slice of windows at beginning');
ip1 = visviews.blockImagePlot(sfig1, [], []);
assertTrue(isvalid(ip1));
slice1 = viscore.dataSlice('Slices', {':', ':', '1:10'}, ...
         'DimNames', {'Channel', 'Sample', 'Window'});
ip1.plot(testVD, thisFunc, slice1);
gaps = ip1.getGaps();
ip1.reposition(gaps);

fprintf('It should produce a plot for a slice of windows in the middle\n');
sfig2 = figure('Name', 'Slice of windows in middle');
ip2 = visviews.blockImagePlot(sfig2, [], []);
assertTrue(isvalid(ip2));
slice2 = viscore.dataSlice('Slices', {':', ':', '4:9'}, ...
         'DimNames', {'Channel', 'Sample', 'Window'});
ip2.plot(testVD, thisFunc, slice2);
gaps = ip2.getGaps();
ip2.reposition(gaps);

fprintf('It should produce a plot for a slice of windows that falls off the end\n');
sfig3 = figure('Name', 'Slice of windows off the end');
ip3 = visviews.blockImagePlot(sfig3, [], []);
assertTrue(isvalid(ip3));
slice3 = viscore.dataSlice('Slices', {':', ':', '15:21'}, ...
         'DimNames', {'Channel', 'Sample', 'Window'});
ip3.plot(testVD, thisFunc, slice3);
gaps = ip3.getGaps();
ip3.reposition(gaps);

fprintf('It should produce a plot for a slice of windows at beginning (even)\n');

sfig4 = figure('Name', 'Slice of windows at beginning with clump factor 2');
ip4 = visviews.blockImagePlot(sfig4, [], []);
assertTrue(isvalid(ip4));
slice4 = viscore.dataSlice('Slices', {':', ':', '1:10'}, ...
         'DimNames', {'Channel', 'Sample', 'Window'});
ip4.ClumpFactor = 2;
ip4.plot(testVD, thisFunc, slice4);
gaps = ip4.getGaps();
ip4.reposition(gaps);

fprintf('It should produce a plot for a slice of windows uneven at end\n');
sfig5 = figure('Name', 'Slice of windows at end with clump factor 3');
ip5 = visviews.blockImagePlot(sfig5, [], []);
assertTrue(isvalid(ip5));
slice5 = viscore.dataSlice('Slices', {':', ':', '14:20'}, ...
         'DimNames', {'Channel', 'Sample', 'Window'});
ip5.ClumpFactor = 3;
ip5.plot(testVD, thisFunc, slice5);
gaps = ip5.getGaps();
ip5.reposition(gaps);


fprintf('It should produce a plot for a slice of windows in one clump\n');
sfig6 = figure('Name', 'Slice of 2 windows with clump factor 3');
ip6 = visviews.blockImagePlot(sfig6, [], []);
assertTrue(isvalid(ip6));
slice6 = viscore.dataSlice('Slices', {':', ':', '14:15'}, ...
         'DimNames', {'Channel', 'Sample', 'Window'});
ip6.ClumpFactor = 3;
ip6.plot(testVD, thisFunc, slice6);
gaps = ip6.getGaps();
ip6.reposition(gaps);

fprintf('It should produce a valid plot for one value\n');
sfig7 = figure('Name', 'One value');
ip7 = visviews.blockImagePlot(sfig7, [], []);
assertTrue(isvalid(ip7));
ip7.ClumpFactor = 20;
slice7 = viscore.dataSlice('Slices', {'3', ':', '2'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
ip7.plot(testVD, thisFunc, slice7);
gaps = ip7.getGaps();
ip7.reposition(gaps);
drawnow
if values.deleteFigures
    delete(sfig1);
    delete(sfig2);
    delete(sfig3);
    delete(sfig4);
    delete(sfig5);
    delete(sfig6);
    delete(sfig7);
end

function testConstantAndNaNValues(values) %#ok<DEFNU>
% Unit test visviews.blockImagePlot plot constant and NaN
fprintf('\nUnit tests for visviews.blockImagePlot plot method with constant and NaN values\n')

% Set up the functions
defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
    viewTestClass.getDefaultFunctions());
fMan = viscore.dataManager();
fMan.putObjects(defaults);
func = fMan.getEnabledObjects('block');
thisFuncK = func{1};
thisFuncS = func{2};
data = zeros([32, 1000, 20]);
testVD = viscore.blockedData(data, 'All zeros');
slice = viscore.dataSlice('Slices', {':', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});

fprintf('It should produce a plot for when all of the values are 0\n');
sfig1 = figure('Name', 'All zero values');
ip1 = visviews.blockImagePlot(sfig1, [], []);
assertTrue(isvalid(ip1));
ip1.plot(testVD, thisFuncS, slice);
gaps = ip1.getGaps();
ip1.reposition(gaps);

fprintf('It should produce a plot for when data is zero, funcs NaNs\n');
sfig2 = figure('Name', 'Data zero, func NaN');
ip2 = visviews.blockImagePlot(sfig2, [], []);
assertTrue(isvalid(ip2));
ip2.plot(testVD, thisFuncK, slice);
gaps = ip2.getGaps();
ip2.reposition(gaps);

fprintf('It should produce a plot for when data is NaNs, funcs NaNs\n');
data3 = NaN([32, 1000, 20]);
testVD3 = viscore.blockedData(data3, 'Data NaN');
sfig3 = figure('Name', 'Data NaNs');
ip3 = visviews.blockImagePlot(sfig3, [], []);
assertTrue(isvalid(ip3));
ip3.plot(testVD3, thisFuncS, slice);
gaps = ip3.getGaps();
ip3.reposition(gaps);
drawnow

% Data slice empty
fprintf('It should produce empty axes when data slice is empty (---see warning)\n');
data = zeros(5, 1);
testVD4 = viscore.blockedData(data, 'Data empty');
slice4 = viscore.dataSlice('Slices', {'6', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
sfig4 = figure('Name', 'Data slice is empty');
ip4 = visviews.blockImagePlot(sfig4, [], []);
assertTrue(isvalid(ip4));
ip4.plot(testVD4, thisFuncS, slice4);
gaps = ip4.getGaps();
ip4.reposition(gaps);

drawnow
if values.deleteFigures
    delete(sfig1);
    delete(sfig2);
    delete(sfig3);
    delete(sfig4);
end

function testSettingStructure(values) %#ok<DEFNU>
% Unit test for visviews.blockImagePlot getDefaultProperties
fprintf('\nUnit tests for visviews.blockImagePlot interaction with settings structure\n');

fprintf('It should have a getDefaultProperties method that returns a structure\n');
s = visviews.blockImagePlot.getDefaultProperties();
assertTrue(isa(s, 'struct'));

fprintf('It should allow a key in the instructor\n');
sfig1 = figure('Name', 'Test of the settings structure');
ipKey = 'Block image';
ip1 = visviews.blockImagePlot(sfig1, [], ipKey);
assertTrue(isvalid(ip1));
pConf = ip1.getConfigObj();
assertTrue(isa(pConf, 'visprops.configurableObj'));
assertTrue(strcmp(ipKey, pConf.getObjectID()));

fprintf('It should allow configuration and lookup by key\n')
% Create and set the data manager
pMan = viscore.dataManager();
visprops.configurableObj.updateManager(pMan, {pConf});  
ip1.updateProperties(pMan);

% Change the background color to blue through the property manager
cObj = pMan.getObject(ipKey);
assertTrue(isa(cObj, 'visprops.configurableObj'));
s = cObj.getStructure();
% s(1).Value = [0, 0, 1];
cObj.setStructure(s);
ip1.updateProperties(pMan);

testVD = viscore.blockedData(values.EEG.data, 'EEG', 'SampleRate', ...
    values.EEG.srate);
defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
    viewTestClass.getDefaultFunctionsNoSqueeze());
fMan = viscore.dataManager();
fMan.putObjects(defaults);
func = fMan.getEnabledObjects('');
thisFunc = func{1};
thisFunc.setData(testVD);
slice = viscore.dataSlice('Slices', {':', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
ip1.plot(testVD, thisFunc, slice);
gaps = ip1.getGaps();
ip1.reposition(gaps);

drawnow
if values.deleteFigures
    delete(sfig1);
end
