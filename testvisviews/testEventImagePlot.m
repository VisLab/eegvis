function test_suite = testEventImagePlot %#ok<STOUT>
% Unit tests for eventImagePlot
initTestSuite;

function values = setup %#ok<DEFNU>
load('EEG.mat'); 
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

load('EEGArtifact.mat'); 
values.EEGArtifact = EEGArtifact;
load('ArtifactEvents.mat');
values.artifactEvents = artifactEvents;
values.deleteFigures = false;

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testNormalConstructor(values) %#ok<DEFNU>
% testSignalPlot unit test for visviews.eventImagePlot constructor
fprintf('\nUnit tests for visviews.eventImagePlot valid constructor\n');

fprintf('It should construct a valid event image plot when only parent passed\n')
sfig = figure('Name', 'Empty plot');
ip = visviews.eventImagePlot(sfig, [], []);
assertTrue(isvalid(ip));
drawnow
if values.deleteFigures
  delete(sfig);
end

function testBadConstructor(values) %#ok<DEFNU>
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
if values.deleteFigures
  delete(sfig);
end

function testPlot(values) %#ok<DEFNU>
% Unit test for visviews.eventImagePlot plot
fprintf('\nUnit tests for visviews.eventImagePlot plot method\n')
testVD = viscore.blockedData(values.EEG.data, 'Rand1', ...
    'Events', values.event, 'SampleRate', values.EEG.srate, 'BlockSize', 1000);
defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
    viewTestClass.getDefaultFunctionsNoSqueeze());
fMan = viscore.dataManager();
fMan.putObjects(defaults);
func = fMan.getEnabledObjects('block');
thisFunc = func{1};
fprintf('It should it should produce a plot with events\n');
sfig1 = figure('Name', 'Basic event plot');
ep1 = visviews.eventImagePlot(sfig1, [], []);
assertTrue(isvalid(ep1));


numBlocks = ceil(size(values.EEG.data, 2)/1000);
ev = testVD.getEvents();
counts = ev.getEventCounts(1, numBlocks, 0);
assertVectorsAlmostEqual(size(counts), ...
    [length(ev.getUniqueTypes()) + 1, numBlocks]);

slice1 = viscore.dataSlice('Slices', {':', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
ep1.plot(testVD, thisFunc, slice1);
drawnow
gaps = ep1.getGaps();
ep1.reposition(gaps);

fprintf('It should produce a plot for empty slice\n');
sfig2 = figure('Name', 'Empty slice');
ep2 = visviews.eventImagePlot(sfig2, [], []);
assertTrue(isvalid(ep2));

ep2.plot(testVD, thisFunc, []);
drawnow
gaps = ep2.getGaps();
ep2.reposition(gaps);

fprintf('It should produce a plot for identity slice with groupings of 2\n');
% Generate some data to plot with and without grouping
slice3 = viscore.dataSlice('Slices', {':', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
sfig3 = figure('Name', 'Ungrouped data to compare with grouping of 2');
ep3 = visviews.eventImagePlot(sfig3, [], []);
assertTrue(isvalid(ep3));
ep3.plot(testVD, thisFunc, slice3);
drawnow
gaps = ep3.getGaps();
ep3.reposition(gaps);

sfig4 = figure('Name', 'Grouping of 2');
ep4 = visviews.eventImagePlot(sfig4, [], []);
assertTrue(isvalid(ep4));
ep4.ClumpSize = 2;
ep4.plot(testVD, thisFunc, slice1);
drawnow
gaps = ep4.getGaps();
ep4.reposition(gaps);

fprintf('It should produce a plot for identity slice with 1 group\n');
sfig5 = figure('Name', 'Group of one');
ep5 = visviews.eventImagePlot(sfig5, [], []);
assertTrue(isvalid(ep5));
ep5.ClumpSize = 20;
ep5.plot(testVD, thisFunc, slice1);
drawnow
gaps = ep5.getGaps();
ep5.reposition(gaps);

fprintf('It should produce a plot for identity slice with uneven grouping\n');
% Generate some data to plot
sfig6 = figure('Name', 'Ungrouped group to compare with uneven grouping');
ep6 = visviews.eventImagePlot(sfig6, [], []);
assertTrue(isvalid(ep6));
ep6.ClumpSize = 3;
ep6.plot(testVD, thisFunc, slice1);
gaps = ep6.getGaps();
ep6.reposition(gaps);

fprintf('It should produce a plot for identity slice for small grouping with uneven grouping\n');
slice7 = viscore.dataSlice('Slices', {':', ':', '5:9'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
sfig7 = figure('Name', 'Ungrouped comparison for uneven  small group');
ep7 = visviews.eventImagePlot(sfig7, [], []);
assertTrue(isvalid(ep7));
ep7.ClumpSize = 4;
ep7.plot(testVD, thisFunc, slice7);
gaps = ep7.getGaps();
ep7.reposition(gaps);

fprintf('It should produce a plot for slice with 1 element and 1 block\n');
% Generate some data to plot
slice8 = viscore.dataSlice('Slices', {'32', ':', '5'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
% test blockBoxPlot plot
sfig8 = figure('Name', 'One element grouped by 3');
ep8 = visviews.eventImagePlot(sfig8, [], []);
assertTrue(isvalid(ep8));
ep8.ClumpSize = 3;
ep8.plot(testVD, thisFunc, slice8);
drawnow
gaps = ep8.getGaps();
ep8.reposition(gaps);

fprintf('It should produce a plot for a slice of windows at beginning\n');
sfig9 = figure('Name', 'Slice of windows at beginning');
ep9 = visviews.eventImagePlot(sfig9, [], []);
assertTrue(isvalid(ep9));
slice9 = viscore.dataSlice('Slices', {':', ':', '1:10'}, ...
         'DimNames', {'Channel', 'Sample', 'Window'});
ep9.plot(testVD, thisFunc, slice9);
gaps = ep9.getGaps();
ep9.reposition(gaps);

fprintf('It should produce a plot for a slice of windows that falls off the end\n');
sfig10 = figure('Name', 'Slice of windows off the end');
ep10 = visviews.eventImagePlot(sfig10, [], []);
assertTrue(isvalid(ep10));
slice10 = viscore.dataSlice('Slices', {':', ':', '25:34'}, ...
         'DimNames', {'Channel', 'Sample', 'Window'});
ep10.plot(testVD, thisFunc, slice10);
gaps = ep10.getGaps();
ep10.reposition(gaps);

fprintf('It should produce a plot for a slice of windows in one clump\n');
sfig11 = figure('Name', 'Slice of 2 windows with clump factor 3');
ep11 = visviews.eventImagePlot(sfig11, [], []);
assertTrue(isvalid(ep11));
slice11 = viscore.dataSlice('Slices', {':', ':', '14:15'}, ...
         'DimNames', {'Channel', 'Sample', 'Window'});
ep11.ClumpSize = 3;
ep11.plot(testVD, thisFunc, slice11);
gaps = ep11.getGaps();
ep11.reposition(gaps);

fprintf('It should plot the artifact data with labeled data\n');
sfig12 = figure('Name', 'Artifact plot');
ep12 = visviews.eventImagePlot(sfig12, [], []);
assertTrue(isvalid(ep12));

testVD12 = viscore.blockedData(values.EEGArtifact.data, 'Artifact', ...
    'Events', values.artifactEvents, ...
    'SampleRate', values.EEGArtifact.srate, 'BlockSize', 1000);
numBlocks = ceil(size(values.EEGArtifact.data, 2)/1000);
ev12 = testVD12.getEvents();
counts = ev12.getEventCounts(1, numBlocks, 0);
assertVectorsAlmostEqual(size(counts), ...
    [length(ev12.getUniqueTypes()) + 1, numBlocks]);
ep12.plot(testVD12, thisFunc, slice1);
gaps = ep12.getGaps();
ep12.reposition(gaps);
drawnow
if values.deleteFigures
    delete(sfig1);
    delete(sfig2);
    delete(sfig3);
    delete(sfig4);
    delete(sfig5);
    delete(sfig6);
    delete(sfig7);
    delete(sfig8);
    delete(sfig9);
    delete(sfig10);
    delete(sfig11);
    delete(sfig12);
end

function testConstantAndNaNValues(values) %#ok<DEFNU>
% Unit test visviews.eventImagePlot plot constant and NaN
fprintf('\nUnit tests for visviews.eventImagePlot plot method with constant and NaN values\n')

% Set up the functions
defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
    viewTestClass.getDefaultFunctions());
fMan = viscore.dataManager();
fMan.putObjects(defaults);
func = fMan.getEnabledObjects('block');
thisFuncK = func{1};
thisFuncS = func{2};

% No events
fprintf('It should produce a plot for when there are no events\n');
testVD1 = viscore.blockedData(values.EEG.data, 'Rand1', ...
    'SampleRate', values.EEG.srate, 'BlockSize', 1000);
slice1 = viscore.dataSlice('Slices', {':', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
sfig1 = figure('Name', 'All zero values');
ep1 = visviews.eventImagePlot(sfig1, [], []);
assertTrue(isvalid(ep1));
ep1.plot(testVD1, thisFuncS, slice1);
gaps = ep1.getGaps();
ep1.reposition(gaps);
drawnow

% Data zeros, function NaN
fprintf('It should produce a plot for when there is no function\n');
data = zeros([32, 1000, 20]);
testVD = viscore.blockedData(data, 'Data zeros, func NaN');
slice2 = viscore.dataSlice('Slices', {':', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
sfig2 = figure('Name', 'Data zero, func NaN');
bp2 = visviews.eventImagePlot(sfig2, [], []);
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
bp3 = visviews.eventImagePlot(sfig3, [], []);
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
bp4 = visviews.eventImagePlot(sfig4, [], []);
assertTrue(isvalid(bp4));
bp4.plot(testVD, thisFuncS, slice4);
gaps = bp4.getGaps();
bp4.reposition(gaps);
drawnow
if values.deleteFigures
    delete(sfig1);
    delete(sfig2);
    delete(sfig3);
    delete(sfig4);
end


function testSettingStructure(values) %#ok<DEFNU>
% Unit test for visviews.eventImagePlot getDefaultProperties
fprintf('\nUnit tests for visviews.eventImagePlot interaction with settings structure\n');

fprintf('It should have a getDefaultProperties method that returns a structure\n');
s = visviews.eventImagePlot.getDefaultProperties();
assertTrue(isa(s, 'struct'));

fprintf('It should allow a key in the structure\n');
sfig1 = figure('Name', 'Test of the settings structure');
ipKey = 'Event image';
ep1 = visviews.eventImagePlot(sfig1, [], ipKey);
assertTrue(isvalid(ep1));
pConf = ep1.getConfigObj();
assertTrue(isa(pConf, 'visprops.configurableObj'));
assertTrue(strcmp(ipKey, pConf.getObjectID()));

fprintf('It should allow configuration and lookup by key\n')
% Create and set the data manager
pMan = viscore.dataManager();
visprops.configurableObj.updateManager(pMan, {pConf});  
ep1.updateProperties(pMan);

% Change the background color to blue through the property manager
cObj = pMan.getObject(ipKey);
assertTrue(isa(cObj, 'visprops.configurableObj'));
s = cObj.getStructure();
% s(1).Value = [0, 0, 1];
cObj.setStructure(s);
ep1.updateProperties(pMan);

% Generate some data to plot
testVD = viscore.blockedData(values.EEG.data, 'Rand1', ...
    'Events', values.event, 'SampleRate', values.EEG.srate, 'BlockSize', 1000);
defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
    viewTestClass.getDefaultFunctionsNoSqueeze());
fMan = viscore.dataManager();
fMan.putObjects(defaults);
func = fMan.getEnabledObjects('block');
thisFunc = func{1};
slice1 = viscore.dataSlice('Slices', {':', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
ep1.plot(testVD, thisFunc, slice1);
gaps = ep1.getGaps();
ep1.reposition(gaps);
drawnow
if values.deleteFigures
   delete(sfig1);
end

