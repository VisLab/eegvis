function test_suite = testDualView %#ok<STOUT>
% Unit tests for dualView
initTestSuite;

function testNormalConstructor %#ok<DEFNU>
% Unit test for normal dualView normal constructor
fprintf('\nUnit test for visviews.dualView normal constructor\n');

fprintf('It should produce an empty plot when constructor has no arguments\n')
bv0 = visviews.dualView();
drawnow
assertTrue(isvalid(bv0));

fprintf('It should plot data when blockedData is in the constructor\n')
data = random('exp', 2, [32, 1000, 20]);
testVD = viscore.blockedData(data, 'Testing data passed in constructor');
bv1 = visviews.dualView('VisData', testVD);
drawnow
assertTrue(isvalid(bv1));
keys = bv1.getSourceMapKeys();
fprintf('\nSources:\n');
for k = 1:length(keys)
    visviews.clickable.printStructure(bv1.getSourceMap(keys{k}));
end
fprintf('\nUnmapped sources:\n')
uKeys = bv1.getUnmappedKeys();
for k = 1:length(uKeys)
    fprintf('%s: \n', uKeys{k} );
    values = bv1.getUnmapped(uKeys{k});
    for j = 1:length(values)
      s = bv1.getSourceMap(values{j});
      visviews.clickable.printStructure(s);  
    end
end

fprintf('It should produce a valid plot when a Plots argument with linked summary is passed\n');
pS = viewTestClass.getDefaultPlotsLinkedSummary();
assertEqual(length(pS), 4);
testVD2 = viscore.blockedData(data, 'Testing data and plots passed in constructor');
bv2 = visviews.dualView('VisData', testVD2, 'Plots', pS);
drawnow
assertTrue(isvalid(bv2));
keys = bv2.getSourceMapKeys();
fprintf('\nSources:\n');
for k = 1:length(keys)
    visviews.clickable.printStructure(bv2.getSourceMap(keys{k}));
end
fprintf('\nUnmapped sources:\n')
uKeys = bv2.getUnmappedKeys();
for k = 1:length(uKeys)
    fprintf('%s: \n', uKeys{k} );
    values = bv2.getUnmapped(uKeys{k});
    for j = 1:length(values)
      s = bv2.getSourceMap(values{j});
      visviews.clickable.printStructure(s);  
    end
end

fprintf('It should produce a valid plot when a Plots argument with unlinked summary is passed\n');
pS = viewTestClass.getDefaultPlotsUnlinkedSummary();
assertEqual(length(pS), 4);
testVD3 = viscore.blockedData(data, 'Testing with unlinked summary plots passed in constructor');
bv3 = visviews.dualView('VisData', testVD3, 'Plots', pS);
drawnow
assertTrue(isvalid(bv3));
keys = bv3.getSourceMapKeys();
fprintf('\nSources:\n');
for k = 1:length(keys)
    visviews.clickable.printStructure(bv3.getSourceMap(keys{k}));
end
fprintf('\nUnmapped sources:\n')
uKeys = bv3.getUnmappedKeys();
for k = 1:length(uKeys)
    fprintf('%s: \n', uKeys{k} );
    values = bv3.getUnmapped(uKeys{k});
    for j = 1:length(values)
      s = bv3.getSourceMap(values{j});
      visviews.clickable.printStructure(s);  
    end
end

fprintf('It should create a graph when the Functions parameter is passed to constructor\n');
f = visviews.dualView.getDefaultFunctions();
testVD4 = viscore.blockedData(data, 'Testing data and function structure passed in constructor');
bv4 = visviews.dualView('VisData', testVD4, 'Functions', f); 
drawnow
assertTrue(isvalid(bv4));

f = visviews.dualView.getDefaultFunctions();
fMan = viscore.dataManager();
fMan.putObjects(visfuncs.functionObj.createObjects('visfuncs.functionObj', f));
testVD5 = viscore.blockedData(data, 'Testing data and function manager passed in constructor');
bv5 = visviews.dualView('VisData', testVD5, 'Functions', fMan); 
drawnow
assertTrue(isvalid(bv5));
f = visviews.dualView.getDefaultFunctions();
fns = visfuncs.functionObj.createObjects('visfuncs.functionObj', f);
testVD6 = viscore.blockedData(data, 'Testing data and list of function objects passed in constructor');
bv6 = visviews.dualView('VisData', testVD6, 'Functions', fns); 
drawnow
assertTrue(isvalid(bv6));
delete(bv0)
delete(bv1)
delete(bv2)
delete(bv3)
delete(bv4)
delete(bv5)
delete(bv6)

function testLinkageBoxPlot %#ok<DEFNU>
% Unit test for normal dualView normal constructor
fprintf('\nUnit test for visviews.dualView for testing box plot linkage\n');
data = random('exp', 2, [32, 1000, 20]);
testVD = viscore.blockedData(data, 'Box plot linkage');
fprintf('It should produce a valid plot when blockboxplots are linked\n');
pS = viewTestClass.getDefaultPlotsBlockBoxPlotLinked();
assertEqual(length(pS), 4);
bv3 = visviews.dualView('VisData', testVD, 'Plots', pS');
drawnow
assertTrue(isvalid(bv3));
keys = bv3.getSourceMapKeys();
fprintf('\nSources:\n');
for k = 1:length(keys)
    visviews.clickable.printStructure(bv3.getSourceMap(keys{k}));
end
fprintf('\nUnmapped sources:\n')
uKeys = bv3.getUnmappedKeys();
for k = 1:length(uKeys)
    fprintf('%s: \n', uKeys{k} );
    values = bv3.getUnmapped(uKeys{k});
    for j = 1:length(values)
      s = bv3.getSourceMap(values{j});
      visviews.clickable.printStructure(s);  
    end
end
delete(bv3)

function testLinkageImagePlot %#ok<DEFNU>
% Unit test for normal dualView normal constructor
fprintf('\nUnit test for visviews.dualView for testing block image plot linkage\n');
data = random('exp', 2, [32, 1000, 20]);
testVD = viscore.blockedData(data, 'Image plot linkage');
fprintf('It should produce a valid plot when a imageBoxplot is linked to a boxBoxPlot\n');
pS = viewTestClass.getDefaultPlotsBlockImagePlotLinked();
assertEqual(length(pS), 5);
bv3 = visviews.dualView('VisData', testVD, 'Plots', pS');
drawnow
assertTrue(isvalid(bv3));
keys = bv3.getSourceMapKeys();
fprintf('\nSources:\n');
for k = 1:length(keys)
    visviews.clickable.printStructure(bv3.getSourceMap(keys{k}));
end
fprintf('\nUnmapped sources:\n')
uKeys = bv3.getUnmappedKeys();
for k = 1:length(uKeys)
    fprintf('%s: \n', uKeys{k} );
    values = bv3.getUnmapped(uKeys{k});
    for j = 1:length(values)
      s = bv3.getSourceMap(values{j});
      visviews.clickable.printStructure(s);  
    end
end

fprintf('It should produce a valid plot when a imageBoxplot is linked to two boxBoxPlots\n');
pS = viewTestClass.getPlotsBlockImageMultipleLinked();
assertEqual(length(pS), 5);
testVD4 = viscore.blockedData(data, 'Image plot linking two different box plots');
bv4 = visviews.dualView('VisData', testVD4, 'Plots', pS');
drawnow
assertTrue(isvalid(bv4));
keys = bv4.getSourceMapKeys();
fprintf('\nSources:\n');
for k = 1:length(keys)
    visviews.clickable.printStructure(bv4.getSourceMap(keys{k}));
end
fprintf('\nUnmapped sources:\n')
uKeys = bv4.getUnmappedKeys();
for k = 1:length(uKeys)
    fprintf('%s: \n', uKeys{k} );
    values = bv4.getUnmapped(uKeys{k});
    for j = 1:length(values)
      s = bv4.getSourceMap(values{j});
      visviews.clickable.printStructure(s);  
    end
end
delete(bv3)
delete(bv4)

