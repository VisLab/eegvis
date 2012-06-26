function test_suite = testEventStackedPlot %#ok<STOUT>
% Unit tests for visviews.stackedEventPlot
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
load('ArtifactLabels.mat');
values.artifactEvents = artifactEvents;
values.deleteFigures = false;

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testNormalConstructor(values) %#ok<DEFNU>
% testEventStackedPlot unit test for visviews.stackedEventPlot constructor
fprintf('\nUnit tests for visviews.stackedEventPlot valid constructor\n');

fprintf('It should construct a valid stacked event plot when only parent passed')
sfig = figure('Name', 'Creates a panel when only parent is passed');
sp = visviews.eventStackedPlot(sfig, [], []);
assertTrue(isvalid(sp));
drawnow
if values.deleteFigures
  delete(sfig);
end

function testBadConstructor(values) %#ok<DEFNU>
% testEventStackedPlot unit test for eventStackedPlot constructor
fprintf('\nUnit tests for visviews.eventStackedPlot invalid constructor parameters\n');

fprintf('It should throw an exception when no paramters are passed\n');
f = @() visviews.eventStackedPlot();
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when only one parameter is passed\n');
sfig = figure('Name', 'Invalid constructor');
f = @() visviews.eventStackedPlot(sfig);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when only two parameters are passed\n');
f = @() visviews.eventStackedPlot(sfig, []);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when more than three parameters are passed\n');
f = @() visviews.eventStackedPlot(sfig, [], [], []);
assertExceptionThrown(f, 'MATLAB:maxrhs');

if values.deleteFigures
  delete(sfig);
end

function testPlot(values) %#ok<DEFNU>
% Unit test visviews.eventStackedPlot plot
fprintf('\nUnit tests for visviews.eventStackedPlot plot method\n')

testVD1 = viscore.blockedData(values.EEG.data, 'EEG', ...
    'SampleRate', values.EEG.srate, 'Events', values.event);
keyfun = @(x) x.('ShortName');
defFuns= visfuncs.functionObj.createObjects( ...
    'visfuncs.functionObj', viewTestClass.getDefaultFunctions(), keyfun);
slice1 = viscore.dataSlice('Slices', {':', ':', '1'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
fun = defFuns{1};
fprintf('It should produce a plot for a slice along dimension 3 with 1 block\n');
sfig1 = figure('Name', 'visviews.eventStackedPlot test plot slice 1 window');
sp1 = visviews.eventStackedPlot(sfig1, [], []);
assertTrue(isvalid(sp1));
sp1.plot(testVD1, fun, slice1);
gaps = sp1.getGaps();
sp1.reposition(gaps);
drawnow

fprintf('It should allow callbacks to be registered\n')
sp1.registerCallbacks([]);

bstart = 1000/values.EEG.srate;
bend = 5*bstart;
fprintf(['It should produce a plot for a slice along dimension 3 with 4 blocks \n' ...
    '..... time scale should be ' num2str(bstart) ' to ' num2str(bend) '\n'] );
testVD2 = viscore.blockedData(values.EEG.data, 'EEG', ...
    'SampleRate', values.EEG.srate, 'Events', values.event);
slice2 = viscore.dataSlice('Slices', {':', ':', '2:5'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
sfig2 = figure('Name', ['visviews.eventStackedPlot plot slice 4 windows: ' ...
    num2str(bstart) ':' num2str(bend)]);
sp2 = visviews.eventStackedPlot(sfig2, [], []);
assertTrue(isvalid(sp2));
sp2.plot(testVD2, fun, slice2);
gaps = sp2.getGaps();
sp2.reposition(gaps);

fprintf('It should produce a plot for single epoch of data\n');
slice3 = viscore.dataSlice('Slices', {':', ':', '2'}, ...
    'DimNames', {'Channel', 'Sample', 'Epoch'});
sfig3 = figure('Name', 'visviews.eventStackedPlot 1 epoch (2)');
sp3 = visviews.eventStackedPlot(sfig3, [], []);
assertTrue(isvalid(sp3));
[event, epochStarts, epochScale] = viscore.blockedEvents.getEEGTimes(values.EEGEpoch);
testVD3 = viscore.blockedData(values.EEGEpoch.data, 'EEGEpoch', ...
    'SampleRate', values.EEGEpoch.srate, 'Events', event, ...
    'BlockStartTimes', epochStarts, 'BlockTimeScale', epochScale, ...
       'Epoched', true);
sp3.plot(testVD3, fun, slice3);
gaps = sp3.getGaps();
sp3.reposition(gaps);

fprintf('It should produce a plot for multiple epochs of data\n');
slice4 = viscore.dataSlice('Slices', {':', ':', '2:5'}, ...
    'DimNames', {'Channel', 'Sample', 'Epoch'});
sfig4 = figure('Name', 'visviews.eventStackedPlot 1 epoch (2:5)');
sp4 = visviews.eventStackedPlot(sfig4, [], []);
assertTrue(isvalid(sp4));
sp4.plot(testVD3, fun, slice4);
gaps = sp4.getGaps();
sp4.reposition(gaps);

fprintf('It should produce a plot a slice along dimension 1 when epoched\n');
slice5 = viscore.dataSlice('Slices', {'1', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Epoch'});
sfig5 = figure('Name', 'visviews.eventStackedPlot element 1');
sp5 = visviews.eventStackedPlot(sfig5, [], []);
assertTrue(isvalid(sp5));
sp5.plot(testVD3, fun, slice5);
gaps = sp5.getGaps();
sp5.reposition(gaps);

fprintf('It should produce a plot a slice along dimension 1 with multiple elements, when epoched\n');
slice5 = viscore.dataSlice('Slices', {'2:3', ':', '5:12'}, ...
    'DimNames', {'Channel', 'Sample', 'Epoch'}, 'CombineDim', 1);
sfig5 = figure('Name', 'visviews.eventStackedPlot element (epochs 5-12)');
sp5 = visviews.eventStackedPlot(sfig5, [], []);
assertTrue(isvalid(sp5));
sp5.plot(testVD3, fun, slice5);
gaps = sp5.getGaps();
sp5.reposition(gaps);

fprintf('It should produce a plot a slice along dimension 1 with multiple elements, when not epoched\n');
slice6 = viscore.dataSlice('Slices', {'2:3', ':', '5:12'}, ...
    'DimNames', {'Channel', 'Sample', 'Epoch'}, 'CombineDim', 1);
sfig6 = figure('Name', 'visviews.eventStackedPlot element (windows 5-12)');
sp6 = visviews.eventStackedPlot(sfig6, [], []);
assertTrue(isvalid(sp6));
sp6.plot(testVD1, fun, slice6);
gaps = sp6.getGaps();
sp6.reposition(gaps);
drawnow
if values.deleteFigures
    delete(sfig1);
    delete(sfig2);
    delete(sfig3);
    delete(sfig4);
    delete(sfig5);
    delete(sfig6);
end

function testPlotWithLabeledData(values) %#ok<DEFNU>
% Unit test visviews.eventStackedPlot plot with labeled data
fprintf('\nUnit tests for visviews.eventStackedPlot plot method with labeled data\n')

testVD1 = viscore.blockedData(values.EEGArtifact.data, 'EEG Artifact', ...
    'SampleRate', values.EEGArtifact.srate, 'Events', values.artifactEvents);
keyfun = @(x) x.('ShortName');
defFuns= visfuncs.functionObj.createObjects( ...
    'visfuncs.functionObj', viewTestClass.getDefaultFunctions(), keyfun);
slice1 = viscore.dataSlice('Slices', {':', ':', '1'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
fun = defFuns{1};
fprintf('It should produce a plot for a slice along dimension 3 with 1 block\n');
sfig1 = figure('Name', 'visviews.eventStackedPlot test plot artifact slice 1 window');
sp1 = visviews.eventStackedPlot(sfig1, [], []);
assertTrue(isvalid(sp1));
sp1.plot(testVD1, fun, slice1);
gaps = sp1.getGaps();
sp1.reposition(gaps);
drawnow
fprintf('It should allow callbacks to be registered\n')
sp1.registerCallbacks([]);

bstart = 1000/values.EEGArtifact.srate;
bend = 5*bstart;
fprintf(['It should produce a plot of artifacts for a slice along dimension 3 with 4 blocks \n' ...
    '..... time scale should be ' num2str(bstart) ' to ' num2str(bend) '\n'] );
slice2 = viscore.dataSlice('Slices', {':', ':', '2:5'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
sfig2 = figure('Name', ['visviews.eventStackedPlot plot artifacts slice 4 windows: ' ...
    num2str(bstart) ':' num2str(bend)]);
sp2 = visviews.eventStackedPlot(sfig2, [], []);
assertTrue(isvalid(sp2));

sp2.plot(testVD1, fun, slice2);
gaps = sp2.getGaps();
sp2.reposition(gaps);
drawnow


fprintf('It should produce a plot a slice along dimension 1 when not epoched\n');
slice3 = viscore.dataSlice('Slices', {'1', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Epoch'});
sfig3 = figure('Name', 'visviews.eventStackedPlot element 1');
sp3 = visviews.eventStackedPlot(sfig3, [], []);
assertTrue(isvalid(sp3));
sp3.plot(testVD1, fun, slice3);
gaps = sp3.getGaps();
sp3.reposition(gaps);
drawnow

fprintf('It should produce a plot a slice along dimension 1 with multiple elements, when not epoched\n');
slice4 = viscore.dataSlice('Slices', {'2:3', ':', '5:12'}, ...
    'DimNames', {'Channel', 'Sample', 'Epoch'}, 'CombineDim', 1);
sfig4 = figure('Name', 'visviews.eventStackedPlot element (epochs 5-12)');
sp4 = visviews.eventStackedPlot(sfig4, [], []);
assertTrue(isvalid(sp4));
sp4.plot(testVD1, fun, slice4);
gaps = sp4.getGaps();
sp4.reposition(gaps);
drawnow

if values.deleteFigures
    delete(sfig1);
    delete(sfig2);
    delete(sfig3);
    delete(sfig4);
end

function testPropertyStructure(values) %#ok<DEFNU>
%test eventStackedPlot property structure
fprintf('\nUnit tests for visviews.eventStackedPlot property structure\n');
fprintf('It should have a getDefaultProperties method that returns a structure\n');
s = visviews.eventStackedPlot.getDefaultProperties();
assertTrue(isa(s, 'struct'));

fprintf('It should allow threshold to be changed through the property manager\n')
sfig = figure('Name', 'visviews.eventStackedPlot test settings structure threshold');
spKey = 'Stacked event';
sp = visviews.eventStackedPlot(sfig, [], spKey);
assertTrue(isvalid(sp));

% check the underlying configurable object
pConf = sp.getConfigObj();
assertTrue(isa(pConf, 'visprops.configurableObj'));
assertTrue(isa(pConf, 'visprops.configurableObj'));
assertTrue(strcmp(spKey, pConf.getObjectID()));

% Create and set the data manager
pMan = viscore.dataManager();
visprops.configurableObj.updateManager(pMan, {pConf});  
sp.updateProperties(pMan);
assertElementsAlmostEqual(sp.CertaintyThreshold, 0.5);

% Change the event threshold through the property manager
cObj = pMan.getObject(spKey);
assertTrue(isa(cObj, 'visprops.configurableObj'));
s = cObj.getStructure();
s(1).Value = 1;
cObj.setStructure(s);
sp.updateProperties(pMan);
assertElementsAlmostEqual(sp.CertaintyThreshold, s(1).Value);

fprintf('It should still plot after threshold has been changed\n');
testVD = viscore.blockedData(values.EEG.data, 'EEG', ...
    'SampleRate', values.EEG.srate, 'Events', values.event);
keyfun = @(x) x.('ShortName');
defFuns= visfuncs.functionObj.createObjects( ...
    'visfuncs.functionObj', viewTestClass.getDefaultFunctions(), keyfun);
slice1 = viscore.dataSlice('Slices', {':', ':', '1'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
fun = defFuns{1};
sfig1 = figure('Name', 'visviews.eventStackedPlot test plot slice 1 window');
sp1 = visviews.eventStackedPlot(sfig1, [], []);
assertTrue(isvalid(sp1));
sp1.plot(testVD, fun, slice1);
gaps = sp1.getGaps();
sp1.reposition(gaps);
drawnow


function testConstantAndNaNValues(values) %#ok<DEFNU>
% Unit test visviews.eventStackedPlot plot constant and NaN
fprintf('\nUnit tests for visviews.eventStackedPlot plot method with constant and NaN values\n')

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
bp1 = visviews.eventStackedPlot(sfig1, [], []);
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
bp2 = visviews.eventStackedPlot(sfig2, [], []);
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
bp3 = visviews.eventStackedPlot(sfig3, [], []);
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
bp4 = visviews.eventStackedPlot(sfig4, [], []);
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

