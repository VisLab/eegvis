function test_suite = testDualView %#ok<STOUT>
% Unit tests for dualView
initTestSuite;

function values = setup %#ok<DEFNU>
load('EEG.mat');
values.EEG = EEG;
values.hdf5File = regexprep(which('EEG.mat'), 'EEG.mat$', 'EEG.hdf5');
hdf5AllZerosFile = regexprep(which('EEG.mat'), 'EEG.mat$', 'AllZeros.hdf5');
hdf5NaNFile = regexprep(which('EEG.mat'), 'EEG.mat$', 'NaN.hdf5');
hdf5EmptySliceFile = regexprep(which('EEG.mat'), 'EEG.mat$', 'EmptySlice.hdf5');
load('EEG.mat'); 
values.bData = viscore.memoryData(EEG.data, 'EEG', ...
    'SampleRate', EEG.srate);
values.hdf5Data = viscore.hdf5Data(EEG.data, 'EEG', hdf5File, ...
    'SampleRate', EEG.srate);
values.hdf5AllZerosData = viscore.hdf5Data(zeros([32, 1000, 20]), ...
    'All zeros', hdf5AllZerosFile);
values.hdf5NaNData = viscore.hdf5Data(NaN([32, 1000, 20]),'Data NaN', ...
    hdf5NaNFile);
values.hdf5EmptySliceData = viscore.hdf5Data(zeros(5, 1), 'Data empty', ...
    hdf5EmptySliceFile);
tEvents = EEG.event;
types = {tEvents.type}';
% Convert to seconds since beginning
startTimes = (round(double(cell2mat({EEG.event.latency}))') - 1)./EEG.srate;
values.event = struct('type', types, 'time', num2cell(startTimes), ...
    'certainty', ones(length(startTimes), 1));
load('RANDOM.mat', 'randomdualview1');
values.random = randomdualview1;
load('EEGEpoch.mat');
values.EEGEpoch = EEGEpoch;
values.hdf5EpochFile = regexprep(which('EEG.mat'), 'EEG.mat$', 'EEGEpoch.hdf5');

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
% testVD1 = viscore.memoryData(values.random, 'Testing data passed in constructor');
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
% testVD2 = viscore.memoryData(values.random, 'Testing data and plots passed in constructor', ...
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
% testVD3 = viscore.memoryData(values.random, 'Testing with unlinked summary plots passed in constructor');
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
% testVD4 = viscore.memoryData(values.EEG.data, 'Testing data and function structure passed in constructor');
% bv4 = visviews.dualView('VisData', testVD4, 'Functions', f);
% drawnow
% assertTrue(isvalid(bv4));
% 
% f = visviews.dualView.getDefaultFunctions();
% fMan = viscore.dataManager();
% fMan.putObjects(visfuncs.functionObj.createObjects('visfuncs.functionObj', f));
% testVD5 = viscore.memoryData(values.EEG.data, 'Testing data and function manager passed in constructor');
% bv5 = visviews.dualView('VisData', testVD5, 'Functions', fMan);
% drawnow
% assertTrue(isvalid(bv5));
% f = visviews.dualView.getDefaultFunctions();
% fns = visfuncs.functionObj.createObjects('visfuncs.functionObj', f);
% testVD6 = viscore.memoryData(values.EEG.data, 'Testing data and list of function objects passed in constructor');
% bv6 = visviews.dualView('VisData', testVD6, 'Functions', fns);
% drawnow
% assertTrue(isvalid(bv6));
% if values.deleteFigures
%     delete(bv0);
%     delete(bv1);
%     delete(bv2);
%     delete(bv3);
%     delete(bv4);
%     delete(bv5);
%     delete(bv6);
% end
% 
% function testNormalConstructorHDF5(values) %#ok<DEFNU>
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
% hdf5File1 = regexprep(which('EEG.mat'), 'EEG.mat$', 'testDualViewNormalConstructor1.hdf5');
% 
% testVD1 = viscore.hdf5Data(values.random, 'Testing data passed in constructor', hdf5File1);
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
% testVD2 = viscore.hdf5Data(values.random, 'Testing data and plots passed in constructor', ...
%     hdf5File1, 'ElementLocations', chanlocs);
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
% testVD3 = viscore.hdf5Data(values.random, 'Testing with unlinked summary plots passed in constructor', hdf5File1);
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
% testVD4 = viscore.hdf5Data(values.EEG.data, 'Testing data and function structure passed in constructor', values.hdf5File);
% bv4 = visviews.dualView('VisData', testVD4, 'Functions', f);
% drawnow
% assertTrue(isvalid(bv4));
% 
% f = visviews.dualView.getDefaultFunctions();
% fMan = viscore.dataManager();
% fMan.putObjects(visfuncs.functionObj.createObjects('visfuncs.functionObj', f));
% testVD5 = viscore.hdf5Data(values.EEG.data, 'Testing data and function manager passed in constructor', values.hdf5File);
% bv5 = visviews.dualView('VisData', testVD5, 'Functions', fMan);
% drawnow
% assertTrue(isvalid(bv5));
% f = visviews.dualView.getDefaultFunctions();
% fns = visfuncs.functionObj.createObjects('visfuncs.functionObj', f);
% testVD6 = viscore.hdf5Data(values.EEG.data, 'Testing data and list of function objects passed in constructor', values.hdf5File);
% bv6 = visviews.dualView('VisData', testVD6, 'Functions', fns);
% drawnow
% assertTrue(isvalid(bv6));
% if values.deleteFigures
%     delete(bv0);
%     delete(bv1);
%     delete(bv2);
%     delete(bv3);
%     delete(bv4);
%     delete(bv5);
%     delete(bv6);
%     delete(hdf5File1);
% end

% function testLinkageBoxPlot(values) %#ok<DEFNU>
% % Unit test for normal dualView normal constructor
% fprintf('\nUnit test for visviews.dualView for testing box plot linkage\n');
% testVD1 = viscore.memoryData(values.EEG.data, 'Box plot linkage');
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
% testVD2 = viscore.memoryData(values.EEG.data, 'Image plot linkage');
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
% testVD3 = viscore.memoryData(values.EEG.data, 'Image plot linking two different box plots', ...
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
% 
% function testLinkageBoxPlotHDF5(values) %#ok<DEFNU>
% % Unit test for normal dualView normal constructor
% fprintf('\nUnit test for visviews.dualView for testing box plot linkage\n');
% testVD1 = viscore.hdf5Data(values.EEG.data, 'Box plot linkage', values.hdf5File);
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
% testVD2 = viscore.hdf5Data(values.EEG.data, 'Image plot linkage', values.hdf5File);
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
% testVD3 = viscore.hdf5Data(values.EEG.data, 'Image plot linking two different box plots', ...
%     values.hdf5File, 'ElementLocations', chanlocs);
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


% function testSpecializedPlot(values) %#ok<DEFNU>
% % Unit test for visviews.dualView specialized plots
% fprintf('\nUnit test for visviews.dualView specialized plots\n');
% fprintf('It should produce a valid plot when a blockScalpPlot is used with one function\n');
% pS = viewTestClass.getDefaultPlotsScalpShort();
% fS = viewTestClass.getOneEnabledFunction();
% assertEqual(length(pS), 8);
% testVD1 = viscore.memoryData(values.EEG.data, 'Shows block scalp plot', ...
%     'ElementLocations', values.EEG.chanlocs);
% bv1 = visviews.dualView('VisData', testVD1, 'Plots', pS', 'Functions', fS);
% assertTrue(isvalid(bv1));
% drawnow
% 
% fprintf('\nUnit test for visviews.dualView specialized plots\n');
% fprintf('It should produce a valid plot when a blockScalpPlot is used with defaults\n');
% pS = viewTestClass.getDefaultPlotsScalp();
% fS = viewTestClass.getDefaultFunctions();
% assertEqual(length(pS), 8);
% testVD2 = viscore.memoryData(values.EEG.data, 'Shows block scalp plot', ...
%     'ElementLocations', values.EEG.chanlocs);
% bv2 = visviews.dualView('VisData', testVD2, 'Plots', pS', 'Functions', fS);
% assertTrue(isvalid(bv2));
% drawnow
% 
% fprintf('It should produce a valid plot when only details are used\n');
% pS = viewTestClass.getDefaultPlotsDetailOnly();
% assertEqual(length(pS), 2);
% testVD3 = viscore.memoryData(values.EEG.data, 'Shows details only');
% bv3 = visviews.dualView('VisData', testVD3, 'Plots', pS');
% assertTrue(isvalid(bv3));
% drawnow
% 
% fprintf('It should produce a valid plot when only summaries are used\n');
% pS = viewTestClass.getDefaultPlotsSummaryOnly();
% assertEqual(length(pS), 3);
% testVD4 = viscore.memoryData(values.EEG.data, 'Shows summary only');
% bv4 = visviews.dualView('VisData', testVD4, 'Plots', pS');
% assertTrue(isvalid(bv4));
% drawnow
% 
% fprintf('It should produce a valid plot when two shadow plots are used\n');
% pS = viewTestClass.getDefaultPlotsTwoShadowPlots();
% assertEqual(length(pS), 6);
% testVD5 = viscore.memoryData(values.EEG.data, 'Shows two shadow plots');
% bv5 = visviews.dualView('VisData', testVD5, 'Plots', pS');
% assertTrue(isvalid(bv5));
% drawnow
% 
% fprintf('It should produce a valid plot when one summary and two details are used\n');
% f = viewTestClass.getDefaultOneFunction();
% fns = visfuncs.functionObj.createObjects('visfuncs.functionObj', f);
% assertEqual(length(fns), 1);
% pS = viewTestClass.getDefaultPlotsOneSummaryTwoDetails();
% assertEqual(length(pS), 3);
% testVD6 = viscore.memoryData(values.EEG.data, 'One summary two details');
% bv6 = visviews.dualView('VisData', testVD6, 'Plots', pS', 'Functions', fns);
% assertTrue(isvalid(bv6));
% drawnow
% 
% if values.deleteFigures
%     delete(bv1);
%     delete(bv2);
%     delete(bv3);
%     delete(bv4);
%     delete(bv5);
%     delete(bv6);
% end
% 
% 
% function testSpecializedPlotHDF5(values) %#ok<DEFNU>
% % Unit test for visviews.dualView specialized plots
% fprintf('\nUnit test for visviews.dualView specialized plots\n');
% fprintf('It should produce a valid plot when a blockScalpPlot is used with one function\n');
% pS = viewTestClass.getDefaultPlotsScalpShort();
% fS = viewTestClass.getOneEnabledFunction();
% assertEqual(length(pS), 8);
% testVD1 = viscore.hdf5Data(values.EEG.data, 'Shows block scalp plot', ...
%     values.hdf5File, 'ElementLocations', values.EEG.chanlocs);
% bv1 = visviews.dualView('VisData', testVD1, 'Plots', pS', 'Functions', fS);
% assertTrue(isvalid(bv1));
% drawnow
% 
% fprintf('\nUnit test for visviews.dualView specialized plots\n');
% fprintf('It should produce a valid plot when a blockScalpPlot is used with defaults\n');
% pS = viewTestClass.getDefaultPlotsScalp();
% fS = viewTestClass.getDefaultFunctions();
% assertEqual(length(pS), 8);
% testVD2 = viscore.hdf5Data(values.EEG.data, 'Shows block scalp plot', ...
%     values.hdf5File, 'ElementLocations', values.EEG.chanlocs);
% bv2 = visviews.dualView('VisData', testVD2, 'Plots', pS', 'Functions', fS);
% assertTrue(isvalid(bv2));
% drawnow
% 
% fprintf('It should produce a valid plot when only details are used\n');
% pS = viewTestClass.getDefaultPlotsDetailOnly();
% assertEqual(length(pS), 2);
% testVD3 = viscore.hdf5Data(values.EEG.data, 'Shows details only', values.hdf5File);
% bv3 = visviews.dualView('VisData', testVD3, 'Plots', pS');
% assertTrue(isvalid(bv3));
% drawnow
% 
% fprintf('It should produce a valid plot when only summaries are used\n');
% pS = viewTestClass.getDefaultPlotsSummaryOnly();
% assertEqual(length(pS), 3);
% testVD4 = viscore.hdf5Data(values.EEG.data, 'Shows summary only', values.hdf5File);
% bv4 = visviews.dualView('VisData', testVD4, 'Plots', pS');
% assertTrue(isvalid(bv4));
% drawnow
% 
% fprintf('It should produce a valid plot when two shadow plots are used\n');
% pS = viewTestClass.getDefaultPlotsTwoShadowPlots();
% assertEqual(length(pS), 6);
% testVD5 = viscore.hdf5Data(values.EEG.data, 'Shows two shadow plots', values.hdf5File);
% bv5 = visviews.dualView('VisData', testVD5, 'Plots', pS');
% assertTrue(isvalid(bv5));
% drawnow
% 
% fprintf('It should produce a valid plot when one summary and two details are used\n');
% f = viewTestClass.getDefaultOneFunction();
% fns = visfuncs.functionObj.createObjects('visfuncs.functionObj', f);
% assertEqual(length(fns), 1);
% pS = viewTestClass.getDefaultPlotsOneSummaryTwoDetails();
% assertEqual(length(pS), 3);
% testVD6 = viscore.hdf5Data(values.EEG.data, 'One summary two details', values.hdf5File);
% bv6 = visviews.dualView('VisData', testVD6, 'Plots', pS', 'Functions', fns);
% assertTrue(isvalid(bv6));
% drawnow
% 
% if values.deleteFigures
%     delete(bv1);
%     delete(bv2);
%     delete(bv3);
%     delete(bv4);
%     delete(bv5);
%     delete(bv6);
% end


function testConstantAndNaNValues(values) %#ok<DEFNU>
% Unit test visviews.dualView constant and NaN
fprintf('\nUnit tests for visviews.dualView with constant and NaN values\n')

% All zeros
fprintf('It should produce a plot for when all of the values are 0\n');
testVD1 = viscore.memoryData(values.EEG.data, 'All zeros');
bv1 = visviews.dualView('VisData', testVD1);
assertTrue(isvalid(bv1));
drawnow

% Data zeros, function NaN
fprintf('It should produce a plot for when data is zero, funcs NaNs --warnings\n');
data = zeros([32, 1000, 20]);
testVD2 = viscore.memoryData(data, 'Data zeros, func NaN');
bv2 =  visviews.dualView('VisData', testVD2);
assertTrue(isvalid(bv2));
drawnow

% Data NaN
fprintf('It should produce a plot for when data NaNs, funcs NaNs --warnings\n');
data = NaN([32, 1000, 20]);
testVD3 = viscore.memoryData(data, 'Data NaN');
bv3 =  visviews.dualView('VisData', testVD3);
assertTrue(isvalid(bv3));
drawnow

% Data slice empty
fprintf('It should produce empty axes when data slice is empty --warnings\n');
data = zeros(5, 1);
testVD4 = viscore.memoryData(data, 'Data empty');
bv4 =  visviews.dualView('VisData', testVD4);
assertTrue(isvalid(bv4));
drawnow

if values.deleteFigures
    delete(bv1);
    delete(bv2);
    delete(bv3);
    delete(bv4);
end

function testConstantAndNaNValuesHDF5(values) %#ok<DEFNU>
% Unit test visviews.dualView constant and NaN
fprintf('\nUnit tests for visviews.dualView with constant and NaN values\n')

% All zeros
fprintf('It should produce a plot for when all of the values are 0\n');
bv1 = visviews.dualView('VisData', values.hdf5AllZerosData);
assertTrue(isvalid(bv1));
drawnow

% Data zeros, function NaN
fprintf('It should produce a plot for when data is zero, funcs NaNs --warnings\n');
bv2 =  visviews.dualView('VisData', values.hdf5AllZerosData);
assertTrue(isvalid(bv2));
drawnow

% Data NaN
fprintf('It should produce a plot for when data NaNs, funcs NaNs --warnings\n');
bv3 =  visviews.dualView('VisData', values.hdf5NaNData);
assertTrue(isvalid(bv3));
drawnow

% Data slice empty
fprintf('It should produce empty axes when data slice is empty --warnings\n');
bv4 =  visviews.dualView('VisData', values.hdf5EmptySliceData);
assertTrue(isvalid(bv4));
drawnow

if values.deleteFigures
    delete(bv1);
    delete(bv2);
    delete(bv3);
    delete(bv4);
end


% 
% function testEventPlots(values) %#ok<DEFNU>
% %Unit test for event plots
% fprintf('\nUnit test for visviews.dualView for event plots\n');
% fprintf('It should produce a valid figure when events are displayed\n');
% pS = viewTestClass.getDefaultPlotsWithEvents();
% assertEqual(length(pS), 10);
% testVD1 = viscore.memoryData(values.EEG.data, 'EEGLABsample', ...
%     'Events', values.event, 'ElementLocations', values.EEG.chanlocs, ...
%     'BlockSize', 1000, 'SampleRate', values.EEG.srate);
% bv1 = visviews.dualView('VisData', testVD1, 'Plots', pS');
% assertTrue(isvalid(bv1));
% drawnow
% 
% fprintf('It should produce a valid figure for epoched data\n');
% pS = viewTestClass.getDefaultPlotsWithEvents();
% assertEqual(length(pS), 10);
% [events, estarts, escales] = viscore.blockedEvents.getEEGTimes(values.EEGEpoch);
% testVD2 = viscore.memoryData(values.EEGEpoch.data, 'Epoched', 'Events', events, ...
%      'ElementLocations', values.EEGEpoch.chanlocs, ...
%     'SampleRate', values.EEGEpoch.srate, 'BlockStartTimes', estarts, ...
%     'BlockTimeScale', escales, 'Epoched', true);
% bv2 = visviews.dualView('VisData', testVD2, 'Plots', pS');
% assertTrue(isvalid(bv2));
% drawnow
% 
% if values.deleteFigures
%    delete(bv1)
%    delete(bv2)
% end

% function testEventPlotsHDF5(values) %#ok<DEFNU>
% %Unit test for event plots
% fprintf('\nUnit test for visviews.dualView for event plots\n');
% fprintf('It should produce a valid figure when events are displayed\n');
% pS = viewTestClass.getDefaultPlotsWithEvents();
% assertEqual(length(pS), 10);
% testVD1 = viscore.hdf5Data(values.EEG.data, 'EEGLABsample', values.hdf5File, ...
%     'Events', values.event, 'ElementLocations', values.EEG.chanlocs, ...
%     'BlockSize', 1000, 'SampleRate', values.EEG.srate);
% bv1 = visviews.dualView('VisData', testVD1, 'Plots', pS');
% assertTrue(isvalid(bv1));
% drawnow
% 
% fprintf('It should produce a valid figure for epoched data\n');
% pS = viewTestClass.getDefaultPlotsWithEvents();
% assertEqual(length(pS), 10);
% [events, estarts, escales] = viscore.blockedEvents.getEEGTimes(values.EEGEpoch);
% testVD2 = viscore.hdf5Data(values.EEGEpoch.data, 'Epoched', values.hdf5EpochFile, 'Events', events, ...
%      'ElementLocations', values.EEGEpoch.chanlocs, ...
%     'SampleRate', values.EEGEpoch.srate, 'BlockStartTimes', estarts, ...
%     'BlockTimeScale', escales, 'Epoched', true);
% bv2 = visviews.dualView('VisData', testVD2, 'Plots', pS');
% assertTrue(isvalid(bv2));
% drawnow
% 
% if values.deleteFigures
%    delete(bv1)
%    delete(bv2)
% end