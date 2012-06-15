function test_suite = testDualView %#ok<STOUT>
% Unit tests for dualView
initTestSuite;

function values = setup %#ok<DEFNU>
load('EEGData.mat'); 
values.EEG = EEG;  
tEvents = EEG.event;
types = {tEvents.type}';
                                      % Convert to seconds since beginning
startTimes = (round(double(cell2mat({EEG.event.latency}))') - 1)./EEG.srate; 
endTimes = startTimes + 1/EEG.srate;
values.event = struct('type', types, 'startTime', num2cell(startTimes), ...
    'endTime', num2cell(endTimes));

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test


% function testNormalConstructor %#ok<DEFNU>
% % Unit test for normal dualView normal constructor
% fprintf('\nUnit test for visviews.dualView normal constructor\n');
% 
% fprintf('It should produce an empty plot when constructor has no arguments\n')
% bv0 = visviews.dualView();
% drawnow
% assertTrue(isvalid(bv0));
% 
% fprintf('It should plot data when blockedData is in the constructor\n')
% data = random('exp', 2, [32, 1000, 20]);
% 
% testVD1 = viscore.blockedData(data, 'Testing data passed in constructor');
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
%     values = bv1.getUnmapped(uKeys{k});
%     for j = 1:length(values)
%       s = bv1.getSourceMap(values{j});
%       visviews.clickable.printStructure(s);  
%     end
% end
% 
% fprintf('It should produce a valid plot when a Plots argument with linked summary is passed\n');
% pS = viewTestClass.getDefaultPlotsLinkedSummary();
% assertEqual(length(pS), 4);
% load chanlocs.mat;
% testVD2 = viscore.blockedData(data, 'Testing data and plots passed in constructor', ...
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
%     values = bv2.getUnmapped(uKeys{k});
%     for j = 1:length(values)
%       s = bv2.getSourceMap(values{j});
%       visviews.clickable.printStructure(s);  
%     end
% end
% 
% fprintf('It should produce a valid plot when a Plots argument with unlinked summary is passed\n');
% pS = viewTestClass.getDefaultPlotsUnlinkedSummary();
% assertEqual(length(pS), 4);
% testVD3 = viscore.blockedData(data, 'Testing with unlinked summary plots passed in constructor');
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
%     values = bv3.getUnmapped(uKeys{k});
%     for j = 1:length(values)
%       s = bv3.getSourceMap(values{j});
%       visviews.clickable.printStructure(s);  
%     end
% end
% 
% fprintf('It should create a graph when the Functions parameter is passed to constructor\n');
% f = visviews.dualView.getDefaultFunctions();
% testVD4 = viscore.blockedData(data, 'Testing data and function structure passed in constructor');
% bv4 = visviews.dualView('VisData', testVD4, 'Functions', f); 
% drawnow
% assertTrue(isvalid(bv4));
% 
% f = visviews.dualView.getDefaultFunctions();
% fMan = viscore.dataManager();
% fMan.putObjects(visfuncs.functionObj.createObjects('visfuncs.functionObj', f));
% testVD5 = viscore.blockedData(data, 'Testing data and function manager passed in constructor');
% bv5 = visviews.dualView('VisData', testVD5, 'Functions', fMan); 
% drawnow
% assertTrue(isvalid(bv5));
% f = visviews.dualView.getDefaultFunctions();
% fns = visfuncs.functionObj.createObjects('visfuncs.functionObj', f);
% testVD6 = viscore.blockedData(data, 'Testing data and list of function objects passed in constructor');
% bv6 = visviews.dualView('VisData', testVD6, 'Functions', fns); 
% drawnow
% assertTrue(isvalid(bv6));
% delete(bv0)
% delete(bv1)
% delete(bv2)
% delete(bv3)
% delete(bv4)
% delete(bv5)
% %delete(bv6)
% 
% function testLinkageBoxPlot %#ok<DEFNU>
% % Unit test for normal dualView normal constructor
% fprintf('\nUnit test for visviews.dualView for testing box plot linkage\n');
% data = random('exp', 2, [32, 1000, 20]);
% testVD = viscore.blockedData(data, 'Box plot linkage');
% fprintf('It should produce a valid plot when blockboxplots are linked\n');
% pS = viewTestClass.getDefaultPlotsBlockBoxPlotLinked();
% assertEqual(length(pS), 4);
% bv3 = visviews.dualView('VisData', testVD, 'Plots', pS');
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
%     values = bv3.getUnmapped(uKeys{k});
%     for j = 1:length(values)
%       s = bv3.getSourceMap(values{j});
%       visviews.clickable.printStructure(s);  
%     end
% end
% delete(bv3)
% 
% function testLinkageImagePlot %#ok<DEFNU>
% %Unit test for normal dualView normal constructor
% fprintf('\nUnit test for visviews.dualView for testing block image plot linkage\n');
% data = random('exp', 2, [32, 1000, 20]);
% testVD = viscore.blockedData(data, 'Image plot linkage');
% fprintf('It should produce a valid plot when a imageBoxplot is linked to a boxBoxPlot\n');
% pS = viewTestClass.getDefaultPlotsBlockImagePlotLinked();
% assertEqual(length(pS), 5);
% bv3 = visviews.dualView('VisData', testVD, 'Plots', pS');
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
%     values = bv3.getUnmapped(uKeys{k});
%     for j = 1:length(values)
%       s = bv3.getSourceMap(values{j});
%       visviews.clickable.printStructure(s);  
%     end
% end
% 
% fprintf('It should produce a valid plot when a imageBoxplot is linked to two boxBoxPlots\n');
% pS = viewTestClass.getPlotsBlockImageMultipleLinked();
% assertEqual(length(pS), 5);
% load chanlocs.mat;
% testVD4 = viscore.blockedData(data, 'Image plot linking two different box plots', ...
%     'ElementLocations', chanlocs);
% bv4 = visviews.dualView('VisData', testVD4, 'Plots', pS');
% drawnow
% assertTrue(isvalid(bv4));
% keys = bv4.getSourceMapKeys();
% fprintf('\nSources:\n');
% for k = 1:length(keys)
%     visviews.clickable.printStructure(bv4.getSourceMap(keys{k}));
% end
% fprintf('\nUnmapped sources:\n')
% uKeys = bv4.getUnmappedKeys();
% for k = 1:length(uKeys)
%     fprintf('%s: \n', uKeys{k} );
%     values = bv4.getUnmapped(uKeys{k});
%     for j = 1:length(values)
%       s = bv4.getSourceMap(values{j});
%       visviews.clickable.printStructure(s);  
%     end
% end
% 
% function testBlockScalpPlot %#ok<DEFNU>
% % Unit test for blockScalpPlot
% fprintf('\nUnit test for visviews.dualView for blockScalpPlot\n');
% fprintf('It should produce a valid plot when a blockScalpPlot is used\n');
% data = random('exp', 2, [32, 1000, 20]);
% pS = viewTestClass.getDefaultPlotsScalp();
% assertEqual(length(pS), 8);
% load chanlocs.mat;
% testVD1 = viscore.blockedData(data, 'Shows block scalp plot', ...
%     'ElementLocations', chanlocs);
% bv1 = visviews.dualView('VisData', testVD1, 'Plots', pS');
% assertTrue(isvalid(bv1));
% drawnow
% %delete(bv3)
% %delete(bv4)
% %delete(bv5)
% 
% 
% 
% function testDetailOnly %#ok<DEFNU>
% % Unit test for dualView when only detail plots are specified
% fprintf('\nUnit test for visviews.dualView for detail only plots\n');
% fprintf('It should produce a valid plot when only details are used\n');
% data = random('exp', 2, [32, 1000, 20]);
% pS = viewTestClass.getDefaultPlotsDetailOnly();
% assertEqual(length(pS), 2);
% testVD1 = viscore.blockedData(data, 'Shows details only');
% bv1 = visviews.dualView('VisData', testVD1, 'Plots', pS');
% drawnow
% delete(bv1)
% 
% function testSummaryOnly %#ok<DEFNU>
% % Unit test for dualView when only summary plots are specified
% fprintf('\nUnit test for visviews.dualView for summary only plots\n');
% fprintf('It should produce a valid plot when only summaries are used\n');
% data = random('exp', 2, [32, 1000, 20]);
% pS = viewTestClass.getDefaultPlotsSummaryOnly();
% assertEqual(length(pS), 3);
% testVD1 = viscore.blockedData(data, 'Shows summary only');
% bv1 = visviews.dualView('VisData', testVD1, 'Plots', pS');
% assertTrue(isvalid(bv1));
% drawnow
% %delete(bv1)
% 
% % function testTwoShadow %#ok<DEFNU>
% % Unit test for dualView when two shadow plots are specified
% fprintf('\nUnit test for visviews.dualView for two shadow plots\n');
% fprintf('It should produce a valid plot when two shadow plots are used\n');
% data = random('exp', 2, [32, 1000, 20]);
% pS = viewTestClass.getDefaultPlotsTwoShadowPlots();
% assertEqual(length(pS), 6);
% testVD1 = viscore.blockedData(data, 'Shows two shadow plots');
% bv1 = visviews.dualView('VisData', testVD1, 'Plots', pS');
% assertTrue(isvalid(bv1));
% drawnow
% %delete(bv1)
% 
% % function testOneSummaryTwoDetail %#ok<DEFNU>
% % Unit test for dualView one summary and two detail plots
% fprintf('\nUnit test for visviews.dualView for one summary and two details\n');
% fprintf('It should produce a valid plot when one summary and two details are used\n');
% data = random('exp', 2, [32, 1000, 20]);
% f = viewTestClass.getDefaultOneFunction();
% fns = visfuncs.functionObj.createObjects('visfuncs.functionObj', f);
% assertEqual(length(fns), 1);
% pS = viewTestClass.getDefaultPlotsOneSummaryTwoDetails();
% assertEqual(length(pS), 3);
% testVD1 = viscore.blockedData(data, 'One summary two details');
% bv1 = visviews.dualView('VisData', testVD1, 'Plots', pS', 'Functions', fns);
% assertTrue(isvalid(bv1));
% drawnow
% %delete(bv1)
% 
% function testConstantAndNaNValues %#ok<DEFNU>
% % Unit test visviews.dualView constant and NaN
% fprintf('\nUnit tests for visviews.dualView with constant and NaN values\n')
% 
% % All zeros
% fprintf('It should produce a plot for when all of the values are 0\n');
% data = zeros([32, 1000, 20]);
% testVD1 = viscore.blockedData(data, 'All zeros');
% bv1 = visviews.dualView('VisData', testVD1);
% assertTrue(isvalid(bv1));
% drawnow
% 
% % Data zeros, function NaN
% fprintf('It should produce a plot for when data is zero, funcs NaNs\n');
% data = zeros([32, 1000, 20]);
% testVD2 = viscore.blockedData(data, 'Data zeros, func NaN');
% bv2 =  visviews.dualView('VisData', testVD2);
% assertTrue(isvalid(bv2));
% drawnow
% 
% % Data NaN
% fprintf('It should produce a plot for when data is zero, funcs NaNs\n');
% data = NaN([32, 1000, 20]);
% testVD3 = viscore.blockedData(data, 'Data NaN');
% bv3 =  visviews.dualView('VisData', testVD3);
% assertTrue(isvalid(bv3));
% drawnow
% 
% % Data slice empty
% fprintf('It should produce empty axes when data slice is empty\n');
% data = zeros(5, 1);
% testVD4 = viscore.blockedData(data, 'Data empty');
% bv4 =  visviews.dualView('VisData', testVD4);
% assertTrue(isvalid(bv4));
% drawnow
% delete(bv1);
% delete(bv2);
% delete(bv3);
% delete(bv4);

function testEventPlots(values) %#ok<DEFNU>
% Unit test for event plots
fprintf('\nUnit test for visviews.dualView for event plots\n');
fprintf('It should produce a valid figure when events are displayed\n');
pS = viewTestClass.getDefaultPlotsWithEvents();
assertEqual(length(pS), 10);
ed1 = viscore.eventData(values.event, 'BlockTime', 1000/values.EEG.srate);
assertTrue(isvalid(ed1));
testVD1 = viscore.blockedData(values.EEG.data, 'EEGLABsample', 'Events', ed1, ...
    'BlockSize', 1000, 'SampleRate', values.EEG.srate);
bv1 = visviews.dualView('VisData', testVD1, 'Plots', pS');
assertTrue(isvalid(bv1));
drawnow

fprintf('It should produce a valid figure for artifacts\n');
pS = viewTestClass.getDefaultPlotsWithEvents();
assertEqual(length(pS), 10);
load('EEGArtifact.mat');
load('ArtifactEvents.mat');
ed2 = viscore.eventData(event, 'BlockTime', 1000/EEGArtifact.srate);
assertTrue(isvalid(ed2));
testVD2 = viscore.blockedData(EEGArtifact.data, 'Artifact', 'Events', ed2, ...
    'BlockSize', 1000, 'SampleRate', EEGArtifact.srate);
bv2 = visviews.dualView('VisData', testVD2, 'Plots', pS');
assertTrue(isvalid(bv2));
drawnow
%delete(bv1)
%delete(bv2)
