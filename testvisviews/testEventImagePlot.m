function test_suite = testEventImagePlot %#ok<STOUT>
% Unit tests for eventImagePlot
initTestSuite;

function testNormalConstructor %#ok<DEFNU>
% testSignalPlot unit test for visviews.eventImagePlot constructor
fprintf('\nUnit tests for visviews.eventImagePlot valid constructor\n');

fprintf('It should construct a valid event image plot when only parent passed\n')
sfig = figure('Name', 'Empty plot');
ip = visviews.eventImagePlot(sfig, [], []);
assertTrue(isvalid(ip));
drawnow
delete(sfig);

function testBadConstructor %#ok<DEFNU>
% Unit test for visviews.eventImagePlot bad constructor
fprintf('\nUnit tests for visviews.eventImagePlot invalid constructor parameters\n');

fprintf('It should throw an exception when no parameters are passed\n');
f = @() visviews.eventImagePlot();
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when only one parameter is passed\n');
sfig = figure;
f = @() visviews.eventImagePlot(sfig);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when only two parameters are passed\n');
f = @() visviews.eventImagePlot(sfig, []);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when more than three parameters are passed\n');
f = @() visviews.eventImagePlot(sfig, [], [], []);
assertExceptionThrown(f, 'MATLAB:maxrhs');
delete(sfig);

function testGetDefaultProperties %#ok<DEFNU>
% Unit test for visviews.eventImagePlot getDefaultProperties
fprintf('\nUnit tests for visviews.eventImagePlot getDefaultProperties\n');

fprintf('It should have a getDefaultProperties method that returns a structure\n');
s = visviews.eventImagePlot.getDefaultProperties();
assertTrue(isa(s, 'struct'));

function testPlot %#ok<DEFNU>
% Unit test for visviews.eventImagePlot plot
fprintf('\nUnit tests for visviews.eventImagePlot plot method\n')

fprintf('It should produce an empty plot when there are no events\n');
sfig = figure('Name', 'Empty plot - no events');
ep = visviews.eventImagePlot(sfig, [], []);
assertTrue(isvalid(ep));

% Generate some data to plot
data = random('exp', 1, [32, 1000, 20]);
testVD = viscore.blockedData(data, 'Rand1');
defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
    viewTestClass.getDefaultFunctionsNoSqueeze());
fMan = viscore.dataManager();
fMan.putObjects(defaults);
func = fMan.getEnabledObjects('block');
thisFunc = func{1};
slice1 = viscore.dataSlice('Slices', {':', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
ep.plot(testVD, thisFunc, slice1);
drawnow
gaps = ep.getGaps();
ep.reposition(gaps);

fprintf('It should produce a plot for identity slice with events\n');
sfig = figure('Name', 'Plot with two events');
ep = visviews.eventImagePlot(sfig, [], []);
assertTrue(isvalid(ep));


% fprintf('It should produce a plot for identity slice\n');

% sfig = figure('Name', 'Clumps of one window');
% ip = visviews.eventImagePlot(sfig, [], []);
% assertTrue(isvalid(ip));
% % Generate some data to plot
% data = random('exp', 1, [32, 1000, 20]);
% testVD = viscore.blockedData(data, 'Rand1');
% defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
%     viewTestClass.getDefaultFunctionsNoSqueeze());
% fMan = viscore.dataManager();
% fMan.putObjects(defaults);
% func = fMan.getEnabledObjects('block');
% thisFunc = func{1};
% slice1 = viscore.dataSlice('Slices', {':', ':', ':'}, ...
%     'DimNames', {'Channel', 'Sample', 'Window'});
% ip.plot(testVD, thisFunc, slice1);
% drawnow
% gaps = ip.getGaps();
% ip.reposition(gaps);
% fprintf('It should allow callbacks to be registered\n')
% ip.registerCallbacks(ip);
% 
% fprintf('It should produce a plot for empty slice\n');
% sfig1 = figure('Name', 'Empty slice');
% bp = visviews.eventImagePlot(sfig1, [], []);
% assertTrue(isvalid(bp));
% % Generate some data to plot
% data = random('exp', 1, [32, 1000, 20]);
% testVD = viscore.blockedData(data, 'Rand1');
% defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
%     viewTestClass.getDefaultFunctionsNoSqueeze());
% fMan = viscore.dataManager();
% fMan.putObjects(defaults);
% func = fMan.getEnabledObjects('block');
% thisFunc = func{1};
% thisFunc.setData(testVD);
% bp.plot(testVD, thisFunc, []);
% drawnow
% gaps = bp.getGaps();
% bp.reposition(gaps);
% delete(sfig);
% delete(sfig1);
% 

% function testSettingStructure %#ok<DEFNU>
% % Unit test for visviews.eventImagePlot getDefaultProperties
% fprintf('\nUnit tests for visviews.eventImagePlot interaction with settings structure\n');
% 
% fprintf('It should allow a key in the instructor\n');
% sfig = figure('Name', 'Test of the settings structure');
% ipKey = 'Block image';
% ip = visviews.eventImagePlot(sfig, [], ipKey);
% assertTrue(isvalid(ip));
% pConf = ip.getConfigObj();
% assertTrue(isa(pConf, 'visprops.configurableObj'));
% assertTrue(strcmp(ipKey, pConf.getObjectID()));
% 
% fprintf('It should allow configuration and lookup by key\n')
% % Create and set the data manager
% pMan = viscore.dataManager();
% visprops.configurableObj.updateManager(pMan, {pConf});  
% ip.updateProperties(pMan);
% 
% % Change the background color to blue through the property manager
% cObj = pMan.getObject(ipKey);
% assertTrue(isa(cObj, 'visprops.configurableObj'));
% s = cObj.getStructure();
% % s(1).Value = [0, 0, 1];
% cObj.setStructure(s);
% ip.updateProperties(pMan);
% 
% % Generate some data to plot
% data = random('exp', 1, [32, 1000, 20]);
% testVD = viscore.blockedData(data, 'Rand1');
% defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
%     viewTestClass.getDefaultFunctionsNoSqueeze());
% fMan = viscore.dataManager();
% fMan.putObjects(defaults);
% func = fMan.getEnabledObjects('');
% thisFunc = func{1};
% thisFunc.setData(testVD);
% slice1 = viscore.dataSlice('Slices', {':', ':', ':'}, ...
%     'DimNames', {'Channel', 'Sample', 'Window'});
% ip.plot(testVD, thisFunc, slice1);
% gaps = ip.getGaps();
% ip.reposition(gaps);
% drawnow
% ip.registerCallbacks(ip);
% delete(sfig);
% 
% function testPlotEvenGrouping %#ok<DEFNU>
% % Unit test visviews.eventImagePlot plot even grouping
% fprintf('\nUnit tests for visviews.eventImagePlot plot method with even grouping\n')
% 
% fprintf('It should produce a plot for identity slice with groupings of 2\n');
% % Generate some data to plot with and without grouping
% data = random('exp', 1, [32, 1000, 20]);
% testVD = viscore.blockedData(data, 'Rand1');
% slice1 = viscore.dataSlice('Slices', {':', ':', ':'}, ...
%     'DimNames', {'Channel', 'Sample', 'Window'});
% sfig = figure('Name', 'Ungrouped data to compare with grouping of 2');
% bp = visviews.eventImagePlot(sfig, [], []);
% assertTrue(isvalid(bp));
% 
% defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
%     viewTestClass.getDefaultFunctionsNoSqueeze());
% fMan = viscore.dataManager();
% fMan.putObjects(defaults);
% func = fMan.getEnabledObjects('block');
% thisFunc = func{1};
% thisFunc.setData(testVD);
% bp.plot(testVD, thisFunc, slice1);
% drawnow
% gaps = bp.getGaps();
% bp.reposition(gaps);
% sfig1 = figure('Name', 'Grouping of 2');
% bp1 = visviews.eventImagePlot(sfig1, [], []);
% assertTrue(isvalid(bp1));
% % Generate some data to plot
% defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
%     viewTestClass.getDefaultFunctions());
% fMan = viscore.dataManager();
% fMan.putObjects(defaults);
% func = fMan.getEnabledObjects('block');
% thisFunc = func{1};
% thisFunc.setData(testVD);
% bp1.ClumpFactor = 2;
% 
% bp1.plot(testVD, thisFunc, slice1);
% drawnow
% gaps = bp1.getGaps();
% bp1.reposition(gaps);
% delete(sfig);
% delete(sfig1);
% 
% function testPlotOneGroup %#ok<DEFNU>
% % Unit test of visviews.eventImagePlot for one group of windows
% fprintf('\nUnit tests for visviews.eventImagePlot plot method one group\n')
% fprintf('It should produce a plot for identity slice with 1 group\n');
% 
% % Generate some data to plot
% data = random('exp', 1, [32, 1000, 20]);
% testVD = viscore.blockedData(data, 'Rand1');
% slice1 = viscore.dataSlice('Slices', {':', ':', ':'}, ...
%     'DimNames', {'Channel', 'Sample', 'Window'});
% % test blockBoxPlot plot
% sfig = figure('Name', 'Ungrouped for comparison with a group of one');
% bp = visviews.eventImagePlot(sfig, [], []);
% assertTrue(isvalid(bp));
% defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
%     viewTestClass.getDefaultFunctionsNoSqueeze());
% fMan = viscore.dataManager();
% fMan.putObjects(defaults);
% func = fMan.getEnabledObjects('block');
% thisFunc = func{1};
% thisFunc.setData(testVD);
% bp.plot(testVD, thisFunc, slice1);
% drawnow
% gaps = bp.getGaps();
% bp.reposition(gaps);
% 
% sfig1 = figure('Name', 'Group of one');
% bp1 = visviews.eventImagePlot(sfig1, [], []);
% assertTrue(isvalid(bp1));
% defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
%     viewTestClass.getDefaultFunctionsNoSqueeze());
% fMan = viscore.dataManager();
% fMan.putObjects(defaults);
% func = fMan.getEnabledObjects('block');
% thisFunc = func{1};
% thisFunc.setData(testVD);
% bp1.ClumpFactor = 20;
% 
% bp1.plot(testVD, thisFunc, slice1);
% drawnow
% gaps = bp1.getGaps();
% bp1.reposition(gaps);
% delete(sfig);
% delete(sfig1)
% 
% function testUnevenGrouping %#ok<DEFNU>
% % Unit test visviews.eventImagePlot plot uneven grouping of windows
% fprintf('\nUnit tests for visviews.eventImagePlot plot method uneven grouping\n')
% fprintf('It should produce a plot for identity slice with uneven grouping\n');
% % Generate some data to plot
% data = random('exp', 1, [32, 1000, 20]);
% testVD = viscore.blockedData(data, 'Rand1');
% slice1 = viscore.dataSlice('Slices', {':', ':', ':'}, ...
%     'DimNames', {'Channel', 'Sample', 'Window'});
% sfig = figure('Name', 'Ungrouped group to compare with uneven grouping');
% bp = visviews.eventImagePlot(sfig, [], []);
% assertTrue(isvalid(bp));
% 
% defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
%     viewTestClass.getDefaultFunctionsNoSqueeze());
% fMan = viscore.dataManager();
% fMan.putObjects(defaults);
% func = fMan.getEnabledObjects('block');
% thisFunc = func{1};
% thisFunc.setData(testVD);
% 
% bp.plot(testVD, thisFunc, slice1);
% gaps = bp.getGaps();
% bp.reposition(gaps);
% drawnow
% sfig1 = figure('Name', 'Corresponding uneven grouping');
% bp1 = visviews.eventImagePlot(sfig1, [], []);
% assertTrue(isvalid(bp1));
% bp1.ClumpFactor = 3;
% 
% bp1.plot(testVD, thisFunc, slice1);
% gaps = bp1.getGaps();
% bp1.reposition(gaps);
% drawnow
% delete(sfig);
% delete(sfig1)
% 
% function testSmallDataSize %#ok<DEFNU>
% % test visviews.eventImagePlot plot uneven grouping of elements
% fprintf('\nUnit tests for visviews.eventImagePlot plot method uneven grouping\n')
% fprintf('It should produce a plot for identity slice with uneven grouping\n');
% 
% % Generate some data to plot
% data = random('exp', 1, [5, 1000, 4]);
% testVD = viscore.blockedData(data, 'Rand1');
% slice1 = viscore.dataSlice('Slices', {':', ':', ':'}, ...
%     'DimNames', {'Channel', 'Sample', 'Window'});
% sfig = figure('Name', 'Ungrouped comparison for uneven  small group');
% bp = visviews.eventImagePlot(sfig, [], []);
% assertTrue(isvalid(bp));
% 
% defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
%     viewTestClass.getDefaultFunctionsNoSqueeze());
% fMan = viscore.dataManager();
% fMan.putObjects(defaults);
% func = fMan.getEnabledObjects('block');
% thisFunc = func{1};
% thisFunc.setData(testVD);
% 
% bp.plot(testVD, thisFunc, slice1);
% gaps = bp.getGaps();
% bp.reposition(gaps);
% drawnow
% 
% sfig1 = figure('Name', 'Uneven  small group');
% bp1 = visviews.eventImagePlot(sfig1, [], []);
% assertTrue(isvalid(bp1));
% 
% defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
%     viewTestClass.getDefaultFunctionsNoSqueeze());
% fMan = viscore.dataManager();
% fMan.putObjects(defaults);
% func = fMan.getEnabledObjects('block');
% thisFunc = func{1};
% thisFunc.setData(testVD);
% bp1.ClumpFactor = 3;
% 
% bp1.plot(testVD, thisFunc, slice1);
% gaps = bp1.getGaps();
% bp1.reposition(gaps);
% drawnow
% delete(sfig);
% delete(sfig1);
% 
% function testPlotOneElementUnevenGroup %#ok<DEFNU>
% % Unit test of visviews.eventImagePlot for one group of windows
% fprintf('\nUnit tests for visviews.eventImagePlot plot method one element\n')
% fprintf('It should produce a plot for identity slice with 1 element\n');
% 
% % Generate some data to plot
% data = random('exp', 1, [1, 1000, 20]);
% testVD = viscore.blockedData(data, 'Rand1');
% slice1 = viscore.dataSlice('Slices', {':', ':', ':'}, ...
%     'DimNames', {'Channel', 'Sample', 'Window'});
% % test blockBoxPlot plot
% sfig = figure('Name', 'Single element comparison with uneven group');
% bp = visviews.eventImagePlot(sfig, [], []);
% assertTrue(isvalid(bp));
% defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
%     viewTestClass.getDefaultFunctionsNoSqueeze());
% fMan = viscore.dataManager();
% fMan.putObjects(defaults);
% func = fMan.getEnabledObjects('block');
% thisFunc = func{1};
% thisFunc.setData(testVD);
% bp.plot(testVD, thisFunc, slice1);
% drawnow
% gaps = bp.getGaps();
% bp.reposition(gaps);
% 
% sfig1 = figure('Name', 'One element grouped by 3');
% bp1 = visviews.eventImagePlot(sfig1, [], []);
% assertTrue(isvalid(bp1));
% bp1.ClumpFactor = 3;
% 
% bp1.plot(testVD, thisFunc, slice1);
% drawnow
% gaps = bp1.getGaps();
% bp1.reposition(gaps);
% delete(sfig);
% delete(sfig1);
% 
% function testPlotSlice %#ok<DEFNU>
% % Unit test visviews.eventImagePlot plot  with nonempy slice
% fprintf('\nUnit tests for visviews.eventImagePlot plot method with slice\n')
% 
% % Set up the data
% data = random('exp', 1, [32, 1000, 20]);
% testVD = viscore.blockedData(data, 'Rand1');
% defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
%     viewTestClass.getDefaultFunctionsNoSqueeze());
% fMan = viscore.dataManager();
% fMan.putObjects(defaults);
% func = fMan.getEnabledObjects('block');
% thisFunc = func{1};
% thisFunc.setData(testVD);
% 
% 
% fprintf('It should produce a plot for a slice of windows at beginning\n');
% 
% sfig = figure('Name', 'Empty slice plot for comparison');
% bp = visviews.eventImagePlot(sfig, [], []);
% assertTrue(isvalid(bp));
% bp.plot(testVD, thisFunc, []);
% gaps = bp.getGaps();
% bp.reposition(gaps);
% 
% sfig1 = figure('Name', 'Slice of windows at beginning');
% bp1 = visviews.eventImagePlot(sfig1, [], []);
% assertTrue(isvalid(bp1));
% slice1 = viscore.dataSlice('Slices', {':', ':', '1:10'}, ...
%          'DimNames', {'Channel', 'Sample', 'Window'});
% bp1.plot(testVD, thisFunc, slice1);
% gaps = bp1.getGaps();
% bp1.reposition(gaps);
% drawnow
% 
% fprintf('It should produce a plot for a slice of windows in the middle\n');
% sfig2 = figure('Name', 'Slice of windows in middle');
% bp2 = visviews.eventImagePlot(sfig2, [], []);
% assertTrue(isvalid(bp2));
% slice2 = viscore.dataSlice('Slices', {':', ':', '4:9'}, ...
%          'DimNames', {'Channel', 'Sample', 'Window'});
% bp2.plot(testVD, thisFunc, slice2);
% gaps = bp2.getGaps();
% bp2.reposition(gaps);
% drawnow
% 
% fprintf('It should produce a plot for a slice of windows that falls off the end\n');
% sfig3 = figure('Name', 'Slice of windows off the end');
% bp3 = visviews.eventImagePlot(sfig3, [], []);
% assertTrue(isvalid(bp3));
% slice3 = viscore.dataSlice('Slices', {':', ':', '15:21'}, ...
%          'DimNames', {'Channel', 'Sample', 'Window'});
% bp3.plot(testVD, thisFunc, slice3);
% gaps = bp3.getGaps();
% bp3.reposition(gaps);
% drawnow
% 
% delete(sfig);
% delete(sfig1);
% delete(sfig2);
% delete(sfig3);
% 
% function testPlotSliceClumped %#ok<DEFNU>
% %Unit test visviews.eventImagePlot plot with nonempy slice and clumping
% fprintf('\nUnit tests for visviews.eventImagePlot plot method with slice and clumps\n')
% 
% % Set up the data
% data = random('exp', 1, [32, 1000, 20]);
% testVD = viscore.blockedData(data, 'Rand1');
% defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
%     viewTestClass.getDefaultFunctionsNoSqueeze());
% fMan = viscore.dataManager();
% fMan.putObjects(defaults);
% func = fMan.getEnabledObjects('block');
% thisFunc = func{1};
% thisFunc.setData(testVD);
% 
% sfig = figure('Name', 'Empty slice plot for comparison');
% bp = visviews.eventImagePlot(sfig, [], []);
% assertTrue(isvalid(bp));
% bp.plot(testVD, thisFunc, []);
% gaps = bp.getGaps();
% bp.reposition(gaps);
% 
% fprintf('It should produce a plot for a slice of windows at beginning (even)\n');
% 
% sfig1 = figure('Name', 'Slice of windows at beginning with clump factor 2');
% bp1 = visviews.eventImagePlot(sfig1, [], []);
% assertTrue(isvalid(bp1));
% slice1 = viscore.dataSlice('Slices', {':', ':', '1:10'}, ...
%          'DimNames', {'Channel', 'Sample', 'Window'});
% bp1.ClumpFactor = 2;
% bp1.plot(testVD, thisFunc, slice1);
% gaps = bp1.getGaps();
% bp1.reposition(gaps);
% drawnow
% 
% fprintf('It should produce a plot for a slice of windows uneven at end\n');
% 
% sfig2 = figure('Name', 'Slice of windows at end with clump factor 3');
% bp2 = visviews.eventImagePlot(sfig2, [], []);
% assertTrue(isvalid(bp2));
% slice2 = viscore.dataSlice('Slices', {':', ':', '14:20'}, ...
%          'DimNames', {'Channel', 'Sample', 'Window'});
% bp2.ClumpFactor = 3;
% bp2.plot(testVD, thisFunc, slice2);
% gaps = bp2.getGaps();
% bp2.reposition(gaps);
% drawnow
% 
% fprintf('It should produce a plot for a slice of windows in one clump\n');
% 
% sfig3 = figure('Name', 'Slice of 2 windows with clump factor 3');
% bp3 = visviews.eventImagePlot(sfig3, [], []);
% assertTrue(isvalid(bp3));
% slice3 = viscore.dataSlice('Slices', {':', ':', '14:15'}, ...
%          'DimNames', {'Channel', 'Sample', 'Window'});
% bp3.ClumpFactor = 3;
% bp3.plot(testVD, thisFunc, slice3);
% gaps = bp3.getGaps();
% bp3.reposition(gaps);
% drawnow
% 
% delete(sfig);
% delete(sfig1);
% delete(sfig2);
% delete(sfig3);
% 
% function testPlotOneValue %#ok<DEFNU>
% % Unit test of visviews.eventImagePlot for a single value
% fprintf('\nUnit tests for visviews.eventImagePlot plot method one value\n')
% fprintf('It should produce a valid plot for one value\n');
% % test blockBoxPlot plot
% sfig = figure('Name', 'One value');
% bp = visviews.eventImagePlot(sfig, [], []);
% assertTrue(isvalid(bp));
% % Generate some data to plot
% data = random('exp', 1, [32, 1000, 20]);
% testVD = viscore.blockedData(data, 'Rand1');
% defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
%     viewTestClass.getDefaultFunctionsNoSqueeze());
% fMan = viscore.dataManager();
% fMan.putObjects(defaults);
% func = fMan.getEnabledObjects('block');
% thisFunc = func{1};
% thisFunc.setData(testVD);
% bp.ClumpFactor = 20;
% slice1 = viscore.dataSlice('Slices', {'3', ':', '2'}, ...
%     'DimNames', {'Channel', 'Sample', 'Window'});
% bp.plot(testVD, thisFunc, slice1);
% drawnow
% gaps = bp.getGaps();
% bp.reposition(gaps);
% delete(sfig);
% 
% 
% function testGetClumpSlice %#ok<DEFNU>
% % Unit test of visviews.eventImagePlot for getClumpSlice
% fprintf('\nUnit tests for visviews.eventImagePlot getClumpSlice\n')
% fprintf('It should produce the correct slice for a full plot\n');
% % test blockBoxPlot plot
% sfig = figure('Name', 'Get clump slice');
% bp = visviews.eventImagePlot(sfig, [], []);
% assertTrue(isvalid(bp));
% % Generate some data to plot
% data = random('exp', 1, [32, 1000, 20]);
% testVD = viscore.blockedData(data, 'Rand1');
% defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
%     viewTestClass.getDefaultFunctionsNoSqueeze());
% fMan = viscore.dataManager();
% fMan.putObjects(defaults);
% func = fMan.getEnabledObjects('block');
% thisFunc = func{1};
% thisFunc.setData(testVD);
% bp.ClumpFactor = 20;
% slice1 = viscore.dataSlice('Slices', {':', ':', ':'}, ...
%     'DimNames', {'Channel', 'Sample', 'Window'});
% bp.plot(testVD, thisFunc, slice1);
% drawnow
% gaps = bp.getGaps();
% bp.reposition(gaps);
% 
% delete(sfig);
% 
% function testConstantAndNaNValues %#ok<DEFNU>
% % Unit test visviews.eventImagePlot plot constant and NaN
% fprintf('\nUnit tests for visviews.eventImagePlot plot method with constant and NaN values\n')
% 
% % Set up the functions
% defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
%     viewTestClass.getDefaultFunctions());
% fMan = viscore.dataManager();
% fMan.putObjects(defaults);
% func = fMan.getEnabledObjects('block');
% thisFuncK = func{1};
% thisFuncS = func{2};
% 
% % All zeros
% fprintf('It should produce a plot for when all of the values are 0\n');
% data = zeros([32, 1000, 20]);
% testVD = viscore.blockedData(data, 'All zeros');
% slice1 = viscore.dataSlice('Slices', {':', ':', ':'}, ...
%     'DimNames', {'Channel', 'Sample', 'Window'});
% sfig1 = figure('Name', 'All zero values');
% bp1 = visviews.eventImagePlot(sfig1, [], []);
% assertTrue(isvalid(bp1));
% bp1.plot(testVD, thisFuncS, slice1);
% gaps = bp1.getGaps();
% bp1.reposition(gaps);
% drawnow
% 
% % Data zeros, function NaN
% fprintf('It should produce a plot for when data is zero, funcs NaNs\n');
% data = zeros([32, 1000, 20]);
% testVD = viscore.blockedData(data, 'Data zeros, func NaN');
% slice2 = viscore.dataSlice('Slices', {':', ':', ':'}, ...
%     'DimNames', {'Channel', 'Sample', 'Window'});
% sfig2 = figure('Name', 'Data zero, func NaN');
% bp2 = visviews.eventImagePlot(sfig2, [], []);
% assertTrue(isvalid(bp2));
% bp2.plot(testVD, thisFuncK, slice2);
% gaps = bp2.getGaps();
% bp2.reposition(gaps);
% drawnow
% 
% % Data NaN
% fprintf('It should produce a plot for when data is zero, funcs NaNs\n');
% data = NaN([32, 1000, 20]);
% testVD = viscore.blockedData(data, 'Data NaN');
% slice3 = viscore.dataSlice('Slices', {':', ':', ':'}, ...
%     'DimNames', {'Channel', 'Sample', 'Window'});
% sfig3 = figure('Name', 'Data NaNs');
% bp3 = visviews.eventImagePlot(sfig3, [], []);
% assertTrue(isvalid(bp3));
% bp3.plot(testVD, thisFuncS, slice3);
% gaps = bp3.getGaps();
% bp3.reposition(gaps);
% drawnow
% 
% % Data slice empty
% fprintf('It should produce empty axes when data slice is empty\n');
% data = zeros(5, 1);
% testVD = viscore.blockedData(data, 'Data empty');
% slice4 = viscore.dataSlice('Slices', {'6', ':', ':'}, ...
%     'DimNames', {'Channel', 'Sample', 'Window'});
% sfig4 = figure('Name', 'Data slice is empty');
% bp4 = visviews.eventImagePlot(sfig4, [], []);
% assertTrue(isvalid(bp4));
% bp4.plot(testVD, thisFuncS, slice4);
% gaps = bp4.getGaps();
% bp4.reposition(gaps);
% drawnow
% % delete(sfig1);
% % delete(sfig2);
% % delete(sfig3);
% % delete(sfig4);
