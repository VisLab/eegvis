function test_suite = testFunctionObj %#ok<STOUT>
% Unit tests for visfuncs.functionObj
initTestSuite;

function testConstuctor %#ok<DEFNU>
% Unit test for visfuncs.functionObj for normal constructor
fprintf('\nUnit tests for visfuncs.functionObj valid constructor no parameters\n');
       
fprintf('It should construct a valid function when constructor has no parameters\n');
bf = visfuncs.functionObj([], []);
assertTrue(isvalid(bf));
bf.printObject();

function testGetDefaultFunctions  %#ok<DEFNU>
% Unit test set visfuncs.functionObj getDefaultFunctions
fprintf('\nUnit tests for visfuncs.functionObj getDefaultFunctions\n');

fprintf('It should have default functions\n');
fStruct = functionTestClass.getDefaultFunctionsNoSqueeze();
assertTrue(~isempty(fStruct))

fprintf('Default functions should be specified as structures\n')
assertTrue(isa(fStruct, 'struct'));

function testGetDefaultFields %#ok<DEFNU>
% Unit test set visfuncs.functionObj getDefaultFields
fprintf('\nUnit tests for visfuncs.functionObj getDefaultFields\n');

fprintf('It should have default fields\n');
dFields = visfuncs.functionObj.getDefaultFields();
assertTrue(~isempty(dFields));
assertTrue(isa(dFields, 'cell'));

function testGetBlockValues %#ok<DEFNU>
% Unit test set visfuncs.functionObj getBlockValues
fprintf('\nUnit tests for visfuncs.functionObj getBlockValues method\n');

fprintf('It should use dimension 2 to block the data\n')
fs = functionTestClass.getDefaultFunctionsNoSqueeze();
bf = visfuncs.functionObj([], fs(1));
fprintf('\nOriginal object:\n');
bf.printObject();
assertVectorsAlmostEqual(bf.getDataSize(), 0)
data = random('exp', 1, [32, 1000, 20]);
testVD = viscore.blockedData(data, 'Rand1');
bf.setData(testVD);
[x, y, z] = bf.getDataSize();
assertElementsAlmostEqual(x, 32);
assertElementsAlmostEqual(y, 1000);
assertElementsAlmostEqual(z, 20);
bValues = bf.getBlockValues();
assertVectorsAlmostEqual(size(bValues), [32, 20]);

function testClone %#ok<DEFNU>
% Unit test for functionObj for clone
fprintf('\nUnit tests for visfuncs.functionObj clone method\n');

fprintf('It should clone a valid visfuncs.functionObj\n');
fs = functionTestClass.getDefaultFunctionsNoSqueeze();
bf = visfuncs.functionObj([], fs(1));
fprintf('\nOriginal object:\n');
bf.printObject();
nBf = bf.clone();
fprintf('\nCloned object:\n');
nBf.printObject();
assertTrue(isvalid(nBf));

fprintf('It should clone a distinct object\n')
assertTrue(bf ~= nBf);

fprintf('Changing clone should not change original object\n');
nBf.setValue(1, 'DisplayName', 'Blech');
fprintf('\nOriginal object after set:\n');
bf.printObject();
fprintf('\nCloned object after set:\n');
nBf.printObject();
nValue = nBf.getValue(1, 'DisplayName');
assertEqual(strcmpi(nValue, 'Blech'), true);

function testCreateObjects %#ok<DEFNU>
% Unit test for visfuncs.functionObj for static createObjects
fprintf('\nUnit tests for visfuncs.functionObj static createObject method\n');

fprintf('It should return a cell array  with one functionObj object by default\n');
bfs = visfuncs.functionObj.createObjects('visfuncs.functionObj', [], []);
assertTrue(isa(bfs, 'cell'))
assertTrue(isa(bfs{1}, 'visfuncs.functionObj'))
assertEqual(length(bfs), 1);

fprintf('It should return a functionObj for each item in structure argument\n');
bs = functionTestClass.getDefaultFunctionsNoSqueeze();
bfs1 = viscore.managedObj.createObjects( 'visfuncs.functionObj', bs, []);
assertTrue(isa(bfs1, 'cell'))
assertEqual(length(bfs1), length(bs));


function testGetDefinition %#ok<DEFNU>
% Unit test for visfuncs.functionObj for getDefinition
fprintf('\nUnit tests for visfuncs.functionObj getDefinition:\n');

fprintf('It should have a string definition\n');
fs = functionTestClass.getDefaultFunctionsNoSqueeze();   
bf = visfuncs.functionObj([], fs(1));
fprintf('\nOriginal object:\n');
bf.printObject();
def = bf.getDefinition();
fprintf('Definition: %s\n', def);
assertTrue(ischar(def));


function testGetBlockValuesSlice %#ok<DEFNU>
% Unit test for visfuncs.functionObj for getBlockValuesSlice
fprintf('\nUnit tests for visfuncs.functionObj getBlockValuesSlice :\n');

fprintf('It should return 1 value for each element when blocks are sliced\n');
fs = functionTestClass.getDefaultFunctionsNoSqueeze();
      
bf = visfuncs.functionObj([], fs(1));
fprintf('\nOriginal object:\n');
bf.printObject();
data = random('exp', 1, [32, 1000, 20]);
testVD = viscore.blockedData(data, 'Rand1');
bf.setData(testVD);
dSlice1 = viscore.dataSlice('Slices', {':', ':', '3'});
[values, sValues] = bf.getBlockValuesSlice(dSlice1);
assertEqual(size(values), [32, 1]);
bValues = bf.getBlockValues();
assertVectorsAlmostEqual(values, bValues(:, 3));
assertVectorsAlmostEqual(sValues, [1, 3, 1]);

fprintf('It should return 1 value for each block when elements are sliced\n');
dSlice2 = viscore.dataSlice('Slices', {'5', ':', ':'});
[values, sValues] = bf.getBlockValuesSlice(dSlice2);
assertVectorsAlmostEqual(size(values), [1, 20]);
assertVectorsAlmostEqual(values, bValues(5, :));
assertVectorsAlmostEqual(sValues, [5, 1, 1]);

fprintf('It should return a single value when data is 2D and slice is by element\n');
fs = functionTestClass.getDefaultFunctionsNoSqueeze();
bf = visfuncs.functionObj([], fs(1));
fprintf('\nOriginal object:\n');
bf.printObject();
data = random('exp', 1, [32, 1000]);
testVD = viscore.blockedData(data, 'Rand1');
bf.setData(testVD);
[x, y, z] = bf.getDataSize();
assertElementsAlmostEqual(x, 32);
assertElementsAlmostEqual(y, 1000);
assertElementsAlmostEqual(z, 1);
bValues = bf.getBlockValues();
assertVectorsAlmostEqual(size(bValues),  [32 1]);
dSlice1 = viscore.dataSlice('Slices', {'2', ':', ':'});
[values, sValues] = bf.getBlockValuesSlice(dSlice1);
assertEqual(size(values, 1), 1);
assertEqual(size(values, 2), 1);
assertVectorsAlmostEqual(values, bValues(2, :));
assertVectorsAlmostEqual(sValues, [2, 1, 1]);

function testGetBlockValuesSliceOneElement %#ok<DEFNU>
% Unit test for visfuncs.functionObj for getBlockValuesSlice
fprintf('\nUnit tests for visfuncs.functionObj getBlockValuesSlice when data has one element:\n');

data = random('exp', 1, [1, 1000, 20]);
testVD = viscore.blockedData(data, 'Rand1');
fs = functionTestClass.getDefaultFunctionsNoSqueeze();  
bf = visfuncs.functionObj([], fs(1));
bf.setData(testVD);
fprintf('\nOriginal object:\n');
bf.printObject();

fprintf('It should return 1 value when blocks are sliced\n');
dSlice1 = viscore.dataSlice('Slices', {':', ':', '3'});
[values, sValues] = bf.getBlockValuesSlice(dSlice1);
assertEqual(size(values), [1, 1]);
bValues = bf.getBlockValues();
assertVectorsAlmostEqual(values, bValues(:, 3));
assertVectorsAlmostEqual(sValues, [1, 3, 1]);


fprintf('It should return 1 value for each block when elements are sliced\n');
dSlice2 = viscore.dataSlice('Slices', {'1', ':', ':'});
[values, sValues] = bf.getBlockValuesSlice(dSlice2);
assertVectorsAlmostEqual(size(values), [1, 20]);
assertVectorsAlmostEqual(values, bValues(1, :));
assertVectorsAlmostEqual(sValues, [1, 1, 1]);

fprintf('It should return a single value when data is 2D and slice is by element\n');
data = random('exp', 1, [32, 1000]);
testVD = viscore.blockedData(data, 'Rand1');
bf.setData(testVD);
[x, y, z] = bf.getDataSize();
assertElementsAlmostEqual(x, 32);
assertElementsAlmostEqual(y, 1000);
assertElementsAlmostEqual(z, 1);
bValues = bf.getBlockValues();
assertVectorsAlmostEqual(size(bValues),  [32 1]);
dSlice1 = viscore.dataSlice('Slices', {'2', ':', ':'});
[values, sValues] = bf.getBlockValuesSlice(dSlice1);
assertEqual(size(values, 1), 1);
assertEqual(size(values, 2), 1);
assertVectorsAlmostEqual(values, bValues(2, :));
assertVectorsAlmostEqual(sValues, [2, 1, 1]);

function testGetBlockColorsSlice %#ok<DEFNU>
% Unit test for visfuncs.functionObj for getSliceColors
fprintf('\nUnit tests for visfuncs.functionObj getBlockColorsSlice :\n');

fprintf('It should return a color for each element when blocks are sliced\n');
fs = functionTestClass.getDefaultFunctions();
      
bf = visfuncs.functionObj([], fs(1));
fprintf('\nOriginal object:\n');
bf.printObject();
data = random('exp', 1, [32, 1000, 20]);
testVD = viscore.blockedData(data, 'Rand1');
bf.setData(testVD);
[x, y, z] = bf.getDataSize();
assertElementsAlmostEqual(x, 32);
assertElementsAlmostEqual(y, 1000);
assertElementsAlmostEqual(z, 20);
bValues = bf.getBlockValues();
assertVectorsAlmostEqual(size(bValues), [32, 20]);
dSlice1 = viscore.dataSlice('Slices', {':', ':', '3'});
colors1 = bf.getBlockColorsSlice(dSlice1);
assertVectorsAlmostEqual(size(colors1), [32, 1, 3]);

fprintf('It should return a color for each block when elements are sliced\n');
dSlice2 = viscore.dataSlice('Slices', {'5', ':', ':'});
colors2 = bf.getBlockColorsSlice(dSlice2);
assertVectorsAlmostEqual(size(colors2), [1, 20, 3]);


fprintf('It should return colors for the entire function when slice is empty\n');
colors3 = bf.getBlockColorsSlice([]);
assertVectorsAlmostEqual(size(colors3), [32, 20, 3]);

fprintf('It should return empty when slice is out of range on blocks\n');
dSlice3 = viscore.dataSlice('Slices', {':', ':', '22'});
colors = bf.getBlockColorsSlice(dSlice3);
assertTrue(isempty(colors));

fprintf('It should return empty when slice is out of range on elements\n');
dSlice3 = viscore.dataSlice('Slices', {'45:58', ':', ':'});
colors = bf.getBlockColorsSlice(dSlice3);
assertTrue(isempty(colors));

function testSetData %#ok<DEFNU>
% Unit test for visfuncs.functionObj for setData
fprintf('\nUnit tests for visfuncs.functionObj setData\n');

fprintf('It should set the function values when setData is called\n');
fs = functionTestClass.getDefaultFunctions();
bf = visfuncs.functionObj([], fs(1));
fprintf('\nOriginal object:\n');
bf.printObject();
data = random('exp', 1, [32, 1000, 20]);
testVD = viscore.blockedData(data, 'Rand1');
bf.setData(testVD);
[e, s, b] = bf.getDataSize();
assertEqual(e, size(data, 1));
assertEqual(s, size(data, 2));
assertEqual(b, size(data, 3));
values = bf.getBlockValues();
assertEqual(size(values, 1), size(data, 1));

fprintf('It should reset the data and functions when data reblocked\n');
fprintf('----------Needs to be revisited--------------------\n');
testVD.reblock(500);
bf.setData(testVD);
testVD.reblock(1000);
bf.setData(testVD);

function testGetThresholdLevels %#ok<DEFNU>
% Unit test for functionObj for getThresholdLevels
fprintf('\nUnit tests for visfuncs.functionObj getThresholdLevels :\n');

fprintf('By default threshold levels just contain 3 (zScore > 3)\n');
fs = functionTestClass.getDefaultFunctions();
      
bf1 = visfuncs.functionObj([], fs(1));
fprintf('\nOriginal object:\n');
bf1.printObject();
levels = bf1.getThresholdLevels();
assertElementsAlmostEqual(levels, 3);
