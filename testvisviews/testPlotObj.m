function test_suite = testPlotObj %#ok<STOUT>
% Unit tests for plotObj
initTestSuite;

function testConstuctor %#ok<DEFNU>
% Unit test for visviews.plotObject normal constructor
fprintf('\nUnit tests for visviews.plotObject valid constructor\n');

fprintf('It should construct a valid plotObj when two empty arguments are passed\n');
         
bf = visviews.plotObj([], []);
assertTrue(isvalid(bf));
bf.printObject();


function testGetDefaultFields %#ok<DEFNU>
% Unit test for visviews.plotObj getDefaultFields
fprintf('\nUnit tests for visviews.plotObj getDefaultFields\n');

fprintf('It should have a getDefaultProperties method that returns a list of default fields\n');
dFields = visviews.plotObj.getDefaultFields();
assertEqual(length(dFields), 7);

function testGetDefinition %#ok<DEFNU>
% Unit test for visviews.plotObj getDefinition
fprintf('\nUnit tests for visviews.plotObj getDefinition\n');

fprintf('It should have a getDefinition method that returns a string\n');
pls = viewTestClass.getDefaultPlots();
bf = visviews.plotObj([], pls(1));
def = bf.getDefinition();
assertTrue(strcmp(def, 'visviews.blockImagePlot'));

function testClone %#ok<DEFNU>
% Unit test for visviews.plotObj clone
fprintf('\nUnit tests for visviews.plotObj clone\n');

fprintf('It should clone a valid object\n');
pls = viewTestClass.getDefaultPlots();
bf = visviews.plotObj([], pls(1));

nBf = bf.clone();
assertTrue(isvalid(nBf));
fprintf('It should create a cloned object with the same values as the original object\n');
fprintf('\nCloned object:\n');
nBf.printObject();
fprintf('\nOriginal object:\n');
bf.printObject();

nBf.setValue(1, 'DisplayName', 'Blech');
fprintf('\nOriginal object after set:\n');
bf.printObject();
fprintf('\nCloned object after set:\n');
nBf.printObject();
nValue = nBf.getValue(1, 'DisplayName');
assertEqual(strcmpi(nValue, 'Blech'), true);

function testCreateObjects %#ok<DEFNU>
% Unit test for visviews.plotObj static createObjects method
fprintf('\nUnit tests for visviews.plotObj static createObjects method\n');

fprintf('It should create a cell array of valid objects\n');
bfs = visviews.plotObj.createObjects('visviews.plotObj', []);
assertTrue(isa(bfs, 'cell'))
assertEqual(length(bfs), 1);
pls1 = viewTestClass.getDefaultPlots();
bfs1 = visviews.plotObj.createObjects('visviews.plotObj',  pls1);
assertTrue(isa(bfs1, 'cell'))
assertEqual(length(bfs1), length(pls1));

function testCreateConfigurableObj %#ok<DEFNU>
% Unit test for visviews.plotObj static createConfigurableObj method
fprintf('\nUnit tests for visviews.plotObj static createConfigurableObj method\n');

fprintf('It should create a cell array of valid objects\n');
pls = viewTestClass.getDefaultPlots();
bfs = visviews.plotObj.createObjects('visviews.plotObj',  pls);
bfsList = visviews.plotObj.createConfigurableObjs(bfs);
assertEqual(length(bfs), length(bfsList));
assertEqual(length(bfs), length(pls));
assertTrue(strcmpi(bfs{1}.getDisplayName(), bfsList{1}.CategoryModifier) == 1)

fprintf('It should create objects that have the right key\n');
ps = viscore.dataSelector('visviews.plotConfig');
pMan = ps.getManager();
basePls = viewTestClass.getDefaultPlots();
numPlots = length(basePls);
pls = visviews.plotObj.createObjects('visviews.plotObj', basePls);
pMan.putObjects(pls);
pConfPlot = ps.getObjects();
pConf = visviews.plotObj.createConfigurableObjs(pConfPlot);
assertEqual(length(pConf), numPlots);
key1 = pConf{1}.getObjectID();
assertTrue(strcmp(key1, 'Block box'));

function testGetSources %#ok<DEFNU>
% Unit test for visviews.plotObj getSources method
fprintf('\nUnit tests for visviews.plotObj getSources method\n');

fprintf('It should get the correct sources\n');
pls = viewTestClass.getDefaultPlots();
bfs = visviews.plotObj.createObjects('visviews.plotObj',  pls);
y = bfs{1}.getSources();
assertTrue(isempty(y));
y = bfs{2}.getSources();
assertEqual(length(y), 1);
assertTrue(strcmpi(y{1}, 'block image'));
y = bfs{3}.getSources();
assertEqual(length(y), 2);
assertTrue(strcmpi(y{1}, 'block image'));
assertTrue(strcmpi(y{2}, 'element box')); 
% Test empty source
y = bfs{4}.getSources();
assertEqual(length(y), 0);
assertTrue(isempty(y));
% Test leading blanks extra commas
y = bfs{5}.getSources();
assertEqual(length(y), 2);
assertTrue(strcmpi(y{1}, 'master'));
assertTrue(strcmpi(y{2}, 'element box')); 

fprintf('It should get a cell array of sources\n')
pls = viewTestClass.getPlotsBlockImageMultipleLinked();
bfs = visviews.plotObj.createObjects('visviews.plotObj',  pls);
y = bfs{4}.getSources();
assertEqual(length(y), 2);
assertTrue(strcmpi('Block box', y{1}));
assertTrue(strcmpi('Block box1', y{2}));