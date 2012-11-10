function test_suite = testDualView %#ok<STOUT>
% Unit tests for dualView
initTestSuite;

function values = setup %#ok<DEFNU>
load('EEG.mat');
values.EEG = EEG;
tEvents = EEG.event;
types = {tEvents.type}';
% Convert to seconds since beginning
startTimes = (round(double(cell2mat({EEG.event.latency}))') - 1)./EEG.srate;
values.event = struct('type', types, 'time', num2cell(startTimes), ...
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

% function testNormalConstructor(values) %#ok<DEFNU>
% % Unit test for normal dualView normal constructor
% fprintf('\nUnit test for visviews.dualView normal constructor\n');
% 
% fprintf('It should produce an empty plot when constructor has no arguments\n')
% bv0 = visviews.dualView();
% drawnow
% assertTrue(isvalid(bv0));
% 
% fprintf('It should plot data when blockedData is in the constructor\n')
% 
% testVD1 = viscore.blockedData(values.random, 'Testing data passed in constructor');
% bv1 = visviews.dualView('VisData', testVD1);
% drawnow
% assertTrue(isvalid(bv1));
% keys = bv1.getSourceMapKeys();
% fprintf('\nSources:\n');
% for k = 1:length(keys)
%     visviews.clickable.printStructure(bv1.getSourceMap(keys{k}));
% end
% fprintf('\nUnmapped sources:\n')
% uKeys = bv1.getUnmappedKeys();
% for k = 1:length(uKeys)
%     fprintf('%s: \n', uKeys{k} );
%     kvalues = bv1.getUnmapped(uKeys{k});
%     for j = 1:length(kvalues)
%         s = bv1.getSourceMap(kvalues{j});
%         visviews.clickable.printStructure(s);
%     end
% end
% 
% fprintf('It should produce a valid plot when a Plots argument with linked summary is passed\n');
% pS = viewTestClass.getDefaultPlotsLinkedSummary();
% assertEqual(length(pS), 4);
% load chanlocs.mat;
% testVD2 = viscore.blockedData(values.random, 'Testing data and plots passed in constructor', ...
%     'ElementLocations', chanlocs);
% bv2 = visviews.dualView('VisData', testVD2, 'Plots', pS);
% drawnow
% assertTrue(isvalid(bv2));
% keys = bv2.getSourceMapKeys();
% fprintf('\nSources:\n');
% for k = 1:length(keys)
%     visviews.clickable.printStructure(bv2.getSourceMap(keys{k}));
% end
% fprintf('\nUnmapped sources:\n')
% uKeys = bv2.getUnmappedKeys();
% for k = 1:length(uKeys)
%     fprintf('%s: \n', uKeys{k} );
%     kvalues = bv2.getUnmapped(uKeys{k});
%     for j = 1:length(kvalues)
%         s = bv2.getSourceMap(kvalues{j});
%         visviews.clickable.printStructure(s);
%     end
% end
% 
% fprintf('It should produce a valid plot when a Plots argument with unlinked summary is passed\n');
% pS = viewTestClass.getDefaultPlotsUnlinkedSummary();
% assertEqual(length(pS), 4);
% testVD3 = viscore.blockedData(values.random, 'Testing with unlinked summary plots passed in constructor');
% bv3 = visviews.dualView('VisData', testVD3, 'Plots', pS);
% drawnow
% assertTrue(isvalid(bv3));
% keys = bv3.getSourceMapKeys();
% fprintf('\nSources:\n');
% for k = 1:length(keys)
%     visviews.clickable.printStructure(bv3.getSourceMap(keys{k}));
% end
% fprintf('\nUnmapped sources:\n')
% uKeys = bv3.getUnmappedKeys();
% for k = 1:length(uKeys)
%     fprintf('%s: \n', uKeys{k} );
%     kvalues = bv3.getUnmapped(uKeys{k});
%     for j = 1:length(kvalues)
%         s = bv3.getSourceMap(kvalues{j});
%         visviews.clickable.printStructure(s);
%     end
% end
% 
% fprintf('It should create a graph when the Functions parameter is passed to constructor\n');
% f = visviews.dualView.getDefaultFunctions();
% testVD4 = viscore.blockedData(values.EEG.data, 'Testing data and function structure passed in constructor');
% bv4 = visviews.dualView('VisData', testVD4, 'Functions', f);
% drawnow
% assertTrue(isvalid(bv4));
% 
% f = visviews.dualView.getDefaultFunctions();
% fMan = viscore.dataManager();
% fMan.putObjects(visfuncs.functionObj.createObjects('visfuncs.functionObj', f));
% testVD5 = viscore.blockedData(values.EEG.data, 'Testing data and function manager passed in constructor');
% bv5 = visviews.dualView('VisData', testVD5, 'Functions', fMan);
% drawnow
% assertTrue(isvalid(bv5));
% f = visviews.dualView.getDefaultFunctions();
% fns = visfuncs.functionObj.createObjects('visfuncs.functionObj', f);
% testVD6 = viscore.blockedData(values.EEG.data, 'Testing data and list of function objects passed in constructor');
% bv6 = visviews.dualView('VisData', testVD6, 'Functions', fns);
% drawnow
% assertTrue(isvalid(bv6));
% if values.deleteFigures
%     delete(bv0)
%     delete(bv1)
%     delete(bv2)
%     delete(bv3)
%     delete(bv4)
%     delete(bv5)
%     delete(bv6)
% end
% 
% function testLinkageBoxPlot(values) %#ok<DEFNU>
% % Unit test for normal dualView normal constructor
% fprintf('\nUnit test for visviews.dualView for testing box plot linkage\n');
% testVD1 = viscore.blockedData(values.EEG.data, 'Box plot linkage');
% fprintf('It should produce a valid plot when blockboxplots are linked\n');
% pS = viewTestClass.getDefaultPlotsBlockBoxPlotLinked();
% assertEqual(length(pS), 4);
% bv1 = visviews.dualView('VisData', testVD1, 'Plots', pS');
% drawnow
% assertTrue(isvalid(bv1));
% keys = bv1.getSourceMapKeys();
% fprintf('\nSources:\n');
% for k = 1:length(keys)
%     visviews.clickable.printStructure(bv1.getSourceMap(keys{k}));
% end
% fprintf('\nUnmapped sources:\n')
% uKeys = bv1.getUnmappedKeys();
% for k = 1:length(uKeys)
%     fprintf('%s: \n', uKeys{k} );
%     kvalues = bv1.getUnmapped(uKeys{k});
%     for j = 1:length(kvalues)
%         s = bv1.getSourceMap(kvalues{j});
%         visviews.clickable.printStructure(s);
%     end
% end
% 
% fprintf('It should produce a valid plot when a imageBoxplot is linked to a boxBoxPlot\n');
% testVD2 = viscore.blockedData(values.EEG.data, 'Image plot linkage');
% 
% pS = viewTestClass.getDefaultPlotsBlockImagePlotLinked();
% assertEqual(length(pS), 5);
% bv2 = visviews.dualView('VisData', testVD2, 'Plots', pS');
% drawnow
% assertTrue(isvalid(bv2));
% keys = bv2.getSourceMapKeys();
% fprintf('\nSources:\n');
% for k = 1:length(keys)
%     visviews.clickable.printStructure(bv2.getSourceMap(keys{k}));
% end
% fprintf('\nUnmapped sources:\n')
% uKeys = bv2.getUnmappedKeys();
% for k = 1:length(uKeys)
%     fprintf('%s: \n', uKeys{k} );
%     kvalues = bv2.getUnmapped(uKeys{k});
%     for j = 1:length(kvalues)
%         s = bv2.getSourceMap(kvalues{j});
%         visviews.clickable.printStructure(s);
%     end
% end
% 
% fprintf('It should produce a valid plot when a imageBoxplot is linked to two boxBoxPlots\n');
% pS = viewTestClass.getPlotsBlockImageMultipleLinked();
% assertEqual(length(pS), 5);
% load chanlocs.mat;
% testVD3 = viscore.blockedData(values.EEG.data, 'Image plot linking two different box plots', ...
%     'ElementLocations', chanlocs);
% bv3 = visviews.dualView('VisData', testVD3, 'Plots', pS');
% drawnow
% assertTrue(isvalid(bv3));
% keys = bv3.getSourceMapKeys();
% fprintf('\nSources:\n');
% for k = 1:length(keys)
%     visviews.clickable.printStructure(bv3.getSourceMap(keys{k}));
% end
% fprintf('\nUnmapped sources:\n')
% uKeys = bv3.getUnmappedKeys();
% for k = 1:length(uKeys)
%     fprintf('%s: \n', uKeys{k} );
%     kvalues = bv3.getUnmapped(uKeys{k});
%     for j = 1:length(kvalues)
%         s = bv3.getSourceMap(kvalues{j});
%         visviews.clickable.printStructure(s);
%     end
% end
% 
% if values.deleteFigures
%     delete(bv1);
%     delete(bv2);
%     delete(bv3);
% end

function testSpecializedPlot(values) %#ok<DEFNU>
% Unit test for visviews.dualView specialized plots
fprintf('\nUnit test for visviews.dualView specialized plots\n');
fprintf('It should produce a valid plot when a blockScalpPlot is used\n');
pS = viewTestClass.getDefaultPlotsScalp();
assertEqual(length(pS), 8);
testVD1 = viscore.blockedData(values.EEG.data, 'Shows block scalp plot', ...
    'ElementLocations', values.EEG.chanlocs);
bv1 = visviews.dualView('VisData', testVD1, 'Plots', pS');
assertTrue(isvalid(bv1));
drawnow

% fprintf('It should produce a valid plot when only details are used\n');
% pS = viewTestClass.getDefaultPlotsDetailOnly();
% assertEqual(length(pS), 2);
% testVD2 = viscore.blockedData(values.EEG.data, 'Shows details only');
% bv2 = visviews.dualView('VisData', testVD2, 'Plots', pS');
% assertTrue(isvalid(bv2));
% drawnow
% 
% fprintf('It should produce a valid plot when only summaries are used\n');
% pS = viewTestClass.getDefaultPlotsSummaryOnly();
% assertEqual(length(pS), 3);
% testVD3 = viscore.blockedData(values.EEG.data, 'Shows summary only');
% bv3 = visviews.dualView('VisData', testVD3, 'Plots', pS');
% assertTrue(isvalid(bv3));
% drawnow
% 
% fprintf('It should produce a valid plot when two shadow plots are used\n');
% pS = viewTestClass.getDefaultPlotsTwoShadowPlots();
% assertEqual(length(pS), 6);
% testVD4 = viscore.blockedData(values.EEG.data, 'Shows two shadow plots');
% bv4 = visviews.dualView('VisData', testVD4, 'Plots', pS');
% assertTrue(isvalid(bv4));
% drawnow
% 
% fprintf('It should produce a valid plot when one summary and two details are used\n');
% f = viewTestClass.getDefaultOneFunction();
% fns = visfuncs.functionObj.createObjects('visfuncs.functionObj', f);
% assertEqual(length(fns), 1);
% pS = viewTestClass.getDefaultPlotsOneSummaryTwoDetails();
% assertEqual(length(pS), 3);
% testVD5 = viscore.blockedData(values.EEG.data, 'One summary two details');
% bv5 = visviews.dualView('VisData', testVD5, 'Plots', pS', 'Functions', fns);
% assertTrue(isvalid(bv5));
% drawnow
% 
% if values.deleteFigures
%     delete(bv1);
%     delete(bv2);
%     delete(bv3);
%     delete(bv4);
%     delete(bv5);
% end
% 
% function testConstantAndNaNValues(values) %#ok<DEFNU>
% % Unit test visviews.dualView constant and NaN
% fprintf('\nUnit tests for visviews.dualView with constant and NaN values\n')
% 
% % All zeros
% fprintf('It should produce a plot for when all of the values are 0\n');
% testVD1 = viscore.blockedData(values.EEG.data, 'All zeros');
% bv1 = visviews.dualView('VisData', testVD1);
% assertTrue(isvalid(bv1));
% drawnow
% 
% % Data zeros, function NaN
% fprintf('It should produce a plot for when data is zero, funcs NaNs --warnings\n');
% data = zeros([32, 1000, 20]);
% testVD2 = viscore.blockedData(data, 'Data zeros, func NaN');
% bv2 =  visviews.dualView('VisData', testVD2);
% assertTrue(isvalid(bv2));
% drawnow
% 
% % Data NaN
% fprintf('It should produce a plot for when data NaNs, funcs NaNs --warnings\n');
% data = NaN([32, 1000, 20]);
% testVD3 = viscore.blockedData(data, 'Data NaN');
% bv3 =  visviews.dualView('VisData', testVD3);
% assertTrue(isvalid(bv3));
% drawnow
% 
% % Data slice empty
% fprintf('It should produce empty axes when data slice is empty --warnings\n');
% data = zeros(5, 1);
% testVD4 = viscore.blockedData(data, 'Data empty');
% bv4 =  visviews.dualView('VisData', testVD4);
% assertTrue(isvalid(bv4));
% drawnow
% 
% if values.deleteFigures
%     delete(bv1);
%     delete(bv2);
%     delete(bv3);
%     delete(bv4);
% end
% 
function testEventPlots(values) %#ok<DEFNU>
% Unit test for event plots
fprintf('\nUnit test for visviews.dualView for event plots\n');
fprintf('It should produce a valid figure when events are displayed\n');
pS = viewTestClass.getDefaultPlotsWithEvents();
assertEqual(length(pS), 10);
testVD1 = viscore.blockedData(values.EEG.data, 'EEGLABsample', ...
    'Events', values.event, ...
    'BlockSize', 1000, 'SampleRate', values.EEG.srate);
bv1 = visviews.dualView('VisData', testVD1, 'Plots', pS');
assertTrue(isvalid(bv1));
drawnow

fprintf('It should produce a valid figure for artifacts with VEP events\n');
pS = viewTestClass.getDefaultPlotsWithEvents();
assertEqual(length(pS), 10);
events = viscore.blockedEvents.getEEGTimes(values.EEGArtifact);
testVD2 = viscore.blockedData(values.EEGArtifact.data, ...
    'Artifact (VEP events)', 'Events', events, ...
    'BlockSize', 1000, 'SampleRate', values.EEGArtifact.srate);
bv2 = visviews.dualView('VisData', testVD2, 'Plots', pS');
assertTrue(isvalid(bv2));
drawnow

fprintf('It should produce a valid figure for artifacts with artifact events\n');
pS = viewTestClass.getDefaultPlotsWithEvents();
assertEqual(length(pS), 10);
testVD3 = viscore.blockedData(values.EEGArtifact.data, ...
    'Artifact (Artifact events)', 'Events', values.artifactEvents, ...
    'BlockSize', 1000, 'SampleRate', values.EEGArtifact.srate);
bv3 = visviews.dualView('VisData', testVD3, 'Plots', pS');
assertTrue(isvalid(bv3));
drawnow

fprintf('It should produce a valid figure for epoched data\n');
pS = viewTestClass.getDefaultPlotsWithEvents();
assertEqual(length(pS), 10);
[events, estarts, escales] = viscore.blockedEvents.getEEGTimes(values.EEGEpoch);
testVD4 = viscore.blockedData(values.EEGEpoch.data, 'Epoched', 'Events', events, ...
    'SampleRate', values.EEGEpoch.srate, 'BlockStartTimes', estarts, ...
    'BlockTimeScale', escales, 'Epoched', true);
bv4 = visviews.dualView('VisData', testVD4, 'Plots', pS');
assertTrue(isvalid(bv4));
drawnow

if values.deleteFigures
   delete(bv1)
   delete(bv2)
   delete(bv3)
   delete(bv4)
end