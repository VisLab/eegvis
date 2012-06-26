function test_suite = testTableTestObj %#ok<STOUT>
% Unit tests for tableTestObj
initTestSuite;

function values = setup %#ok<DEFNU>
values = [];

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testConstuctor(values) %#ok<DEFNU>
% Unit test for tableTestObj for normal constructor
fprintf('\nUnit tests for tableTestObject:\n');

fprintf('It should behave like a managed object\n');

fprintf('It should create a valid object when the two constructor parameters are empty\n');
bf = tableTestObj([], []);
assertTrue(isvalid(bf));
bf.printObject();

fStruct = tableTestObj.getDefaults();
assertTrue(length(fStruct) == 2);

fprintf('It should have defaults with the right number of fields\n');
dFields = tableTestObj.getDefaultFields();
assertEqual(length(dFields), 6);

fprintf('It should have defaults with a valid definition\n');
fs = tableTestObj.getDefaults();
bf = tableTestObj([], fs(1));
def = bf.getDefinition();
assertTrue(strcmp(def, 'visviews.blockImagePlot'));

fprintf('It should clone an object which is distinct, but has the same values\n');
fs = tableTestObj.getDefaults();    
bf = tableTestObj([], fs(1));
fprintf('\nOriginal object:\n');
bf.printObject();
nBf = bf.clone();
fprintf('\nCloned object:\n');
nBf.printObject();
assertTrue(isvalid(nBf));
nBf.setValue(1, 'DisplayName', 'Blech');
fprintf('\nOriginal object after set:\n');
bf.printObject();
fprintf('\nCloned object after set:\n');
nBf.printObject();
nValue = nBf.getValue(1, 'DisplayName');
assertEqual(strcmpi(nValue, 'Blech'), true);

fprintf('It should create a cell array of objects for an empty array of structures\n');
keyfun = @(x) {x.('DisplayName')};
bfs = tableTestObj.createObjects('viscore.managedObj', [], keyfun);
assertTrue(isa(bfs, 'cell'))
assertEqual(length(bfs), 1);
fprintf('It should create a cell array of objects for a valid array of structures\n');
bfs1 = tableTestObj.createObjects( 'viscore.managedObj', ...
                                tableTestObj.getDefaults(), keyfun);
assertTrue(isa(bfs1, 'cell'))
assertEqual(length(bfs1), 2);

