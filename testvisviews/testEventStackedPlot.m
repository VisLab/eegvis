function test_suite = testEventStackedPlot %#ok<STOUT>
% Unit tests for visviews.stackedEventPlot
initTestSuite;

% function testNormalConstructor %#ok<DEFNU>
% % testEventStackedPlot unit test for visviews.stackedEventPlot constructor
% fprintf('\nUnit tests for visviews.stackedEventPlot valid constructor\n');
% 
% fprintf('It should construct a valid stacked event plot when only parent passed')
% sfig = figure('Name', 'Creates a panel when only parent is passed');
% sp = visviews.eventStackedPlot(sfig, [], []);
% assertTrue(isvalid(sp));
% drawnow
% delete(sfig);
% 
% function testBadConstructor %#ok<DEFNU>
% % testEventStackedPlot unit test for eventStackedPlot constructor
% fprintf('\nUnit tests for visviews.eventStackedPlot invalid constructor parameters\n');
% 
% fprintf('It should throw an exception when no paramters are passed\n');
% f = @() visviews.eventStackedPlot();
% assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});
% 
% fprintf('It should throw an exception when only one parameter is passed\n');
% sfig = figure('Name', 'Invalid constructor');
% f = @() visviews.eventStackedPlot(sfig);
% assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});
% 
% fprintf('It should throw an exception when only two parameters are passed\n');
% f = @() visviews.eventStackedPlot(sfig, []);
% assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});
% 
% 
% fprintf('It should throw an exception when more than three parameters are passed\n');
% f = @() visviews.eventStackedPlot(sfig, [], [], []);
% assertExceptionThrown(f, 'MATLAB:maxrhs');
% delete(sfig);
% 
% function testGetDefaultProperties %#ok<DEFNU>
% % Unit test for visviews.eventStackedPlot getDefaultProperties
% fprintf('\nUnit tests for visviews.eventStackedPlot getDefaultProperties\n');
% fprintf('It should have a getDefaultProperties method that returns a structure\n');
% s = visviews.eventStackedPlot.getDefaultProperties();
% assertTrue(isa(s, 'struct'));

function testPlot %#ok<DEFNU>
% Unit test visviews.eventStackedPlot plot
fprintf('\nUnit tests for visviews.eventStackedPlot plot method\n')
% Read the sample data for testing
load('EEGData.mat');  %
tEvents = EEG.event;
types = {tEvents.type}';
startTimes = cell2mat({tEvents.latency})'; % Convert to seconds

ed1 = viscore.eventData(types, startTimes, 'BlockSize', 1000, ...
    'SampleRate', 128);
testVD = viscore.blockedData(EEG.data, 'EEG', 'Events', ed1);
keyfun = @(x) x.('ShortName');
defFuns= visfuncs.functionObj.createObjects( ...
    'visfuncs.functionObj', viewTestClass.getDefaultFunctions(), keyfun);
slice1 = viscore.dataSlice('Slices', {':', ':', '1'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
fun = defFuns{1};
fprintf('It should produce a plot for a slice along dimension 3\n');
sfig = figure('Name', 'visviews.eventStackedPlot test plot slice window');
sp = visviews.eventStackedPlot(sfig, [], []);
sp.EventScale = 8.0;
assertTrue(isvalid(sp));

sp.plot(testVD, fun, slice1);
gaps = sp.getGaps();
sp.reposition(gaps);
drawnow


fprintf('It should allow callbacks to be registered\n')
sp.registerCallbacks([]);

% 
% fprintf('It should produce a plot when the data is epoched\n');
% testVD1 = viscore.blockedData(data, 'Rand1', 'Epoched', true, ...
%             'SampleRate', 250);
% assertTrue(testVD1.isEpoched())
% keyfun = @(x) x.('ShortName');
% defFuns= visfuncs.functionObj.createObjects( ...
%     'visfuncs.functionObj', viewTestClass.getDefaultFunctions(), keyfun);
% fun = defFuns{1};
% sfig1 = figure('Name', 'Plot when data is epoched\n');
% sp1 = visviews.eventStackedPlot(sfig1, [], []);
% assertTrue(testVD1.isEpoched())
% sp1.plot(testVD1, fun, slice1);
% gaps = sp1.getGaps();
% sp1.reposition(gaps);
% sp1.registerCallbacks([]);
% drawnow
% assertAlmostEqual(testVD1.EpochTimes, (0:999)*4);
% 
% fprintf('It should produce a plot for a slice along dimension 1\n');
% sfig2 = figure('Name', 'visviews.eventStackedPlot test plot slice element');
% sp2 = visviews.eventStackedPlot(sfig2, [], []);
% slice2 = viscore.dataSlice('Slices', {'1', ':', ':'}, 'CombineDim', 1, ...
%     'DimNames', {'Channel', 'Sample', 'Window'});
% sp2.plot(testVD, fun, slice2);
% gaps = sp2.getGaps();
% sp2.reposition(gaps);
% sp2.registerCallbacks([]);
% drawnow
% 
% fprintf('It should work when the event scale is small\n');
% sfig3 = figure('Name', 'visviews.eventStackedPlot test low event scale');
% sp3 = visviews.eventStackedPlot(sfig3, [], []);
% sp3.EventScale = 3.0;
% assertTrue(isvalid(sp3));
% % Generate some data to plot
% keyfun = @(x) x.('ShortName');
% defFuns= visfuncs.functionObj.createObjects( ...
%     'visfuncs.functionObj', viewTestClass.getDefaultFunctions(), keyfun);
% slice3 = viscore.dataSlice('Slices', {':', ':', '1'}, ...
%     'DimNames', {'Channel', 'Sample', 'Window'});
% fun = defFuns{1};
% sp3.plot(testVD, fun, slice3);
% gaps = sp3.getGaps();
% sp3.reposition(gaps);
% sp3.registerCallbacks([]);
% drawnow
% 
% fprintf('It should work when the event scale is large\n')
% sfig4 = figure('Name', 'visviews.eventStackedPlot test high event scale');
% sp4 = visviews.eventStackedPlot(sfig4, [], []);
% sp4.EventScale = 15;
% sp4.plot(testVD, fun, slice1);
% gaps = sp4.getGaps();
% sp4.reposition(gaps);
% sp4.registerCallbacks([]);
% drawnow
% 
% fprintf('It should plot smooth events\n');
% sfig5 = figure('Name', 'Plot with smoothed events');
% sp5 = visviews.eventStackedPlot(sfig5, [], []);
% assertTrue(isvalid(sp5));
% % Generate some data to plot
% nSamples = 1000;
% nChans = 32;
% x = linspace(0, 1, nSamples);
% 
% a = 10*rand(nChans, 1);
% p = pi*rand(nChans, 1);
% data5 = 0.01*random('normal', 0, 1, [nChans, nSamples]);
% for k = 1:nChans
%     data5(k, :) = data5(k, :) + a(k)*cos(2*pi*x + p(k));
% end
% data5(1, :) = 2*data5(1, :);
% testVD5 = viscore.blockedData(data5, 'Cosine');
% sp5.EventScale = 2.0;
% keyfun = @(x) x.('ShortName');
% defFuns= visfuncs.functionObj.createObjects( ...
%     'visfuncs.functionObj', viewTestClass.getDefaultFunctions(), keyfun);
% slice5 = viscore.dataSlice('Slices', {':', ':', '1'}, ...
%     'DimNames', {'Channel', 'Sample', 'Window'});
% fun = defFuns{1};
% sp5.plot(testVD5, fun, slice5);
% gaps = sp5.getGaps();
% sp5.reposition(gaps);
% sp5.registerCallbacks([]);
% drawnow
% 
% fprintf('It should plot smooth events with a trim percent\n');
% sfig6 = figure('Name', 'Plot with smoothed events with out of range event');
% sp6 = visviews.eventStackedPlot(sfig6, [], []);
% assertTrue(isvalid(sp3));
% % Generate some data to plot
% data6 = data5;
% data6(2,:) = 100*data6(2, :);
% testVD6 = viscore.blockedData(data6, 'Large Cosine');
% sp6.EventScale = 2.0;
% sp6.TrimPercent = 5;
% sp6.plot(testVD6, fun, slice3);
% gaps = sp6.getGaps();
% sp6.reposition(gaps);
% sp6.registerCallbacks([]);
% 
% fprintf('It should produce a plot for a clump of nonepoched windows sliced along dim 3 \n');
% sfig7 = figure('Name', 'Plot clump for slice along dimension 3, not epoched');
% sp7 = visviews.eventStackedPlot(sfig7, [], []);
% assertTrue(isvalid(sp7));
% % Generate some data to plot
% keyfun = @(x) x.('ShortName');
% defFuns= visfuncs.functionObj.createObjects( ...
%     'visfuncs.functionObj', viewTestClass.getDefaultFunctions(), keyfun);
% fun = defFuns{1};
% 
% testVD7 = viscore.blockedData(dataSmooth, 'Sinusoidal', 'Epoched', false);
% slice7 = viscore.dataSlice('Slices', {':', ':', '2:4'}, ...
%     'DimNames', {'Channel', 'Sample', 'Window'}, 'CombineDim', 3);
% sp7.plot(testVD7, fun, slice7);
% gaps = sp7.getGaps();
% sp7.reposition(gaps);
% sp7.registerCallbacks([]);
% drawnow
% 
% 
% fprintf('It should produce a single window plot for a clump of epoched windows sliced along dim 3 \n');
% sfig8 = figure('Name', 'Plot windows - clump for slice along dimension 3, epoched');
% sp8 = visviews.eventStackedPlot(sfig8, [], []);
% assertTrue(isvalid(sp8));
% % Generate some data to plot
% keyfun = @(x) x.('ShortName');
% defFuns= visfuncs.functionObj.createObjects( ...
%     'visfuncs.functionObj', viewTestClass.getDefaultFunctions(), keyfun);
% fun = defFuns{1};
% 
% testVD8 = viscore.blockedData(dataSmooth, 'Sinusoidal', ...
%     'Epoched', true, 'SampleRate', 256);
% slice8 = viscore.dataSlice('Slices', {':', ':', '4:8'}, ...
%     'DimNames', {'Channel', 'Sample', 'Window'}, 'CombineDim', 3);
% sp8.plot(testVD8, fun, slice8);
% gaps = sp8.getGaps();
% sp8.reposition(gaps);
% sp8.registerCallbacks([]);
% drawnow
% 
% fprintf('It should produce a single element plot for a clump of epoched windows sliced along dim 1 \n');
% sfig9 = figure('Name', 'Plot element - clump for slice along dimension 1, epoched');
% sp9 = visviews.eventStackedPlot(sfig9, [], []);
% assertTrue(isvalid(sp9));
% % Generate some data to plot
% keyfun = @(x) x.('ShortName');
% defFuns= visfuncs.functionObj.createObjects( ...
%     'visfuncs.functionObj', viewTestClass.getDefaultFunctions(), keyfun);
% fun = defFuns{1};
% 
% testVD9 = viscore.blockedData(dataSmooth, 'Sinusoidal', ...
%     'Epoched', true, 'SampleRate', 256);
% slice9 = viscore.dataSlice('Slices', {'4:8', ':', ':'}, ...
%     'DimNames', {'Channel', 'Sample', 'Window'}, 'CombineDim', 1);
% sp9.plot(testVD9, fun, slice9);
% gaps = sp9.getGaps();
% sp9.reposition(gaps);
% sp9.registerCallbacks([]);
% drawnow
% 
% delete(sfig);
% delete(sfig1);
% delete(sfig2);
% delete(sfig3);
% delete(sfig4);
% delete(sfig5);
% delete(sfig6);
% delete(sfig7);
% delete(sfig8);
% delete(sfig9);
% 
% function testSettingStructureScale %#ok<DEFNU>
% % test eventStackedPlot setting the scale
% fprintf('\nUnit tests for visviews.eventStackedPlot configuring Scale\n')
% 
% fprintf('It should allow the scale to be changed through the property manager\n')
% sfig = figure('Name', 'visviews.eventStackedPlot test settings structure scale');
% spKey = 'Stacked event';
% sp = visviews.eventStackedPlot(sfig, [], spKey);
% assertTrue(isvalid(sp));
% 
% 
% % check the underlying configurable object
% pConf = sp.getConfigObj();
% assertTrue(isa(pConf, 'visprops.configurableObj'));assertTrue(isa(pConf, 'visprops.configurableObj'));
% assertTrue(strcmp(spKey, pConf.getObjectID()));
% 
% % Create and set the data manager
% pMan = viscore.dataManager();
% visprops.configurableObj.updateManager(pMan, {pConf});  
% sp.updateProperties(pMan);
% assertElementsAlmostEqual(sp.EventScale, 3);
% 
% % Change the event scale to 10 through the property manager
% cObj = pMan.getObject(spKey);
% assertTrue(isa(cObj, 'visprops.configurableObj'));
% s = cObj.getStructure();
% s(1).Value = 10;
% cObj.setStructure(s);
% sp.updateProperties(pMan);
% assertElementsAlmostEqual(sp.EventScale, s(5).Value);
% 
% fprintf('It should still plot after scale has been changed\n')
% % Generate some data to plot
% data = random('normal', 0, 1, [32, 1000, 20]);
% testVD = viscore.blockedData(data, 'Rand1');
% keyfun = @(x) x.('ShortName');
% defFuns= visfuncs.functionObj.createObjects( ...
%     'visfuncs.functionObj', viewTestClass.getDefaultFunctions(), keyfun);
% slice1 = viscore.dataSlice('Slices', {':', ':', '1'}, ...
%     'DimNames', {'Channel', 'Sample', 'Window'});
% fun = defFuns{1};
% sp.plot(testVD, fun, slice1);
% gaps = sp.getGaps();
% sp.reposition(gaps);
% drawnow
% assertElementsAlmostEqual(sp.EventScale, s(5).Value);
% delete(sfig);
% 
% function testSettingStructureEventLabel %#ok<DEFNU>
% % test visviews.eventStackedPlot setting axes label
% fprintf('\nUnit tests for visviews.eventStackedPlot setting axis label\n')
% 
% fprintf('It should allow the scale to be changed through the property manager\n')
% sfig = figure('Name', 'visviews.eventStackedPlot test settings structure label');
% spKey = 'Stacked event';
% sp = visviews.eventStackedPlot(sfig, [], spKey);
% assertTrue(isvalid(sp));
% 
% % check the underlying configurable object
% pConf = sp.getConfigObj();
% assertTrue(isa(pConf, 'visprops.configurableObj'));
% assertTrue(strcmp(spKey, pConf.getObjectID()));
% 
% % Create and set the data manager
% pMan = viscore.dataManager();
% visprops.configurableObj.updateManager(pMan, {pConf});  
% sp.updateProperties(pMan);
% assertTrue(strcmp(sp.EventLabel, '{\mu}V'));
% 
% % Change the event scale to 10 through the property manager
% cObj = pMan.getObject(spKey);
% assertTrue(isa(cObj, 'visprops.configurableObj'));
% s = cObj.getStructure();
% s(2).Value = 'ABC';
% cObj.setStructure(s);
% sp.updateProperties(pMan);
% assertTrue(strcmp(sp.EventLabel, s(4).Value));
% 
% fprintf('It should still plot after label has been changed\n')
% % Generate some data to plot
% data = random('normal', 0, 1, [32, 1000, 20]);
% testVD = viscore.blockedData(data, 'Rand1');
% keyfun = @(x) x.('ShortName');
% defFuns= visfuncs.functionObj.createObjects( ...
%     'visfuncs.functionObj', viewTestClass.getDefaultFunctions(), keyfun);
% slice1 = viscore.dataSlice('Slices', {':', ':', '1'}, ...
%     'DimNames', {'Channel', 'Sample', 'Window'});
% fun = defFuns{1};
% sp.plot(testVD, fun, slice1);
% gaps = sp.getGaps();
% sp.reposition(gaps);
% drawnow
% assertTrue(strcmp(sp.EventLabel, s(4).Value));
% delete(sfig);
% 
% 
% function testConstantAndNaNValues %#ok<DEFNU>
% % Unit test visviews.eventShadowPlot plot constant and NaN
% fprintf('\nUnit tests for visviews.eventShadowPlot plot method with constant and NaN values\n')
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
% bp1 = visviews.eventStackedPlot(sfig1, [], []);
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
% bp2 = visviews.eventStackedPlot(sfig2, [], []);
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
% bp3 = visviews.eventStackedPlot(sfig3, [], []);
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
% bp4 = visviews.eventStackedPlot(sfig4, [], []);
% assertTrue(isvalid(bp4));
% bp4.plot(testVD, thisFuncS, slice4);
% gaps = bp4.getGaps();
% bp4.reposition(gaps);
% drawnow
% delete(sfig1);
% delete(sfig2);
% delete(sfig3);
% delete(sfig4);
% 
