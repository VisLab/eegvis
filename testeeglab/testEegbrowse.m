function test_suite = testEegbrowse %#ok<STOUT>
% Unit tests for eegbrowse
initTestSuite;

function testNormalConstructor %#ok<DEFNU>
% Unit test for eegbrowse constructor
fprintf('\nUnit tests for eegbrowse valid constructor\n');

fprintf('It should create a valid browser when no arguments are passed\n');
bv = eegbrowse();
drawnow
assertTrue(isvalid(bv));

fprintf('It should create a valid browser when a title is passed passed\n');
bv1 = eegbrowse('Title', 'Passing a title');
drawnow
assertTrue(isvalid(bv1));

fprintf('It should create a valid browser when a file name is passed for ''FileName'' in the constructor\n');
fileName = 'sample.set';
bv2 = eegbrowse('FileName', fileName, 'Title', 'Passing file name and title');
drawnow
assertTrue(isempty(bv2.FileName));

fprintf('It should create a valid browser when a file path is passed for ''FilePath'' in the constructor\n');
filePath = pwd;
bv3 = eegbrowse('FilePath', filePath, 'Title', 'Passing file path and title'); 
drawnow
assertTrue(isvalid(bv3));
fprintf('It should use the file path parameter if the path is valid\n');
assertTrue(strcmpi(filePath, bv2.FilePath));

fprintf('It should ignore the file name parameter if it is invalid\n');
fileName = 'x 2x';
bv4 = eegbrowse('FileName', fileName, 'Title', 'Passing bad file name and title');
assertFalse(strcmpi(bv4.FileName, fileName))

fprintf('It should create a valid browser when both a file name and a file path are passed to the constructor\n');
aname = which('testeegBrowse');
pos = strfind(aname, filesep);
filePath = [aname(1:pos(end)) 'testdata'];
fileName = 'eeglab_data.set';
bv5 = eegbrowse('FilePath', filePath, 'FileName', fileName, 'Title', 'File name, file path and title');
drawnow
assertTrue(isvalid(bv5));

fprintf('It should ignore the file path constructor argument if it is invalid\n');
filePath = './xxy';
bv6 = eegbrowse('FilePath', filePath, 'Title', 'Ignores invalid file paths on construction');
assertFalse(strcmpi(bv6.FilePath, filePath))

fprintf('It should create a valid browser when a title parameter is passed for ''Title'' in the constructor\n');
testTitle = 'Test title';
bv7 = eegbrowse('Title', testTitle);
drawnow
assertTrue(isvalid(bv7));
fprintf('It should use the title parameter as the name of the GUI window\n');
x = get(bv7.ConFig, 'Name');
assertTrue(strcmpi(x, testTitle))

fprintf('It should create a valid browser when a functions structure is passed for ''Functions'' in the constructor\n');
f = eegbrowse.getDefaultFunctions();
bv8 = eegbrowse('Functions', f, 'Title', 'Function structure and title passed'); 
drawnow
assertTrue(isvalid(bv8));

fprintf('It should produce a valid browser when a function manager is passed for ''Functions'' in the constructor\n');
fMan = viscore.dataManager();
fMan.putObjects(visfuncs.functionObj.createObjects('visfuncs.functionObj', f));
bv9 = eegbrowse('Functions', fMan, 'Title', 'Function manager and title passed'); 
drawnow
assertTrue(isvalid(bv9));

fprintf('It should create a valid browser when a functions object list is passed for ''Plots'' in the constructor\n');
fns = visfuncs.functionObj.createObjects('visfuncs.functionObj', f);
bv10 = eegbrowse('Functions', fns, 'Title', 'Function object list and title passed'); 
drawnow
assertTrue(isvalid(bv10));

fprintf('It should create a valid browser when a plot structure is passed for ''Plots'' in the constructor\n');
p = eegbrowse.getDefaultPlots();
bv11 = eegbrowse('Plots', p, 'Title', 'Plot structure and title passed'); 
assertTrue(isvalid(bv11));
drawnow

fprintf('It should create a valid browser when a plots object list is passed for ''Plots'' in the constructor\n');
pls = visviews.plotObj.createObjects('visviews.plotObj', p);
assertEqual(length(p), length(pls));
bv12 = eegbrowse('Plots', pls, 'Title', 'Plot object list and title passed'); 
assertTrue(isvalid(bv12));
drawnow
fprintf('It should have the right number of plot objects\n');
x = bv12.PlotSelect.getObjects();
assertTrue(~isempty(x));
assertEqual(length(x), length(pls));

fprintf('It should create a valid browser when a plot manager is passed for ''Plots'' in the constructor\n');
pMan = viscore.dataManager();
pMan.putObjects(pls);
bv13 = eegbrowse('Plots', pMan, 'Title', 'Plot manager and title passed'); 
drawnow
assertTrue(isvalid(bv13));
fprintf('It should have the right number of configurable objects\n');
conObjs = bv13.getConfigurableObjs();
assertEqual(length(conObjs), length(pls) + 2);

fprintf('It should create a valid browser when a configurable object is passed for ''Properties'' in the constructor\n');
testSettings = viscore.dataManager();
s = viewTestClass.getDefaultProperties();
s(1).Value = 'ABC';
confObj = visprops.configurableObj('visviews.dualView', s, 'visviews.dualView');
testSettings.putObject('visviews.dualView', confObj); 
bv14 = eegbrowse('Properties', testSettings, 'Title', 'Properties and title passed');
assertTrue(isvalid(bv14));
drawnow
nSettings = bv14.PropSelect.getObject('visviews.dualView');
assertTrue(isa(nSettings, 'visprops.configurableObj'));
sNew = nSettings.getStructure();
assertEqual(length(sNew), 5);
assertTrue(strcmp(sNew(1).Value, 'ABC'));

fprintf('It should ignore non configurable objects when a cell array of configurable objects is passed for ''Properties'' in the constructor\n'); 
sNext = visviews.blockBoxPlot.getDefaultProperties();
confObj2 = visprops.configurableObj('Block box', sNext, 'visviews.blockBoxPlot');
propList = {confObj, 'Test it', confObj2};
bv15 = eegbrowse('Properties', propList, 'Title', 'Ignores non configurable objects on property parameter ');
objs = bv15.PropSelect.getObjects();
assertEqual(length(objs), 8);

fprintf('It should create a valid browser when the ''UseEEGLab'' parameter to the constructor is true\n');
%eeglab()  % See if EEGLAB was already running
aname = which('eeglab');
pos = strfind(aname, filesep);
filePath = [aname(1:pos(end)) 'sample_data'];
fileName = 'eeglab_data.set';
bv16 = eegbrowse('FilePath', filePath, 'FileName', fileName, ...
              'UseEEGLab', true, 'Title', 'Understands when eeglab is running');
drawnow
assertTrue(isvalid(bv16));


delete(bv);
delete(bv1);
delete(bv2);
delete(bv3);
delete(bv4);
delete(bv5);
delete(bv6);
delete(bv7);
delete(bv8);
delete(bv9);
delete(bv10);
delete(bv11);
delete(bv12);
delete(bv13);
delete(bv14);
delete(bv15);
delete(bv16);

