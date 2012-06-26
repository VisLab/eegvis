function test_suite = testBlockBoxPlot %#ok<STOUT>
initTestSuite;

function values = setup %#ok<DEFNU>
defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
    viewTestClass.getDefaultFunctionsNoSqueeze());
fMan = viscore.dataManager();
fMan.putObjects(defaults);
func = fMan.getEnabledObjects('block');
values.fun = func{1};
values.slice = viscore.dataSlice('Slices', {':', ':', ':'}, ...
        'DimNames', {'Channel', 'Sample', 'Window'});
load('EEG.mat'); 
values.bData = viscore.blockedData(EEG.data, 'EEG', ...
    'SampleRate', EEG.srate);    
values.deleteFigures = false;

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testNormalConstructor(values) %#ok<DEFNU>
% Unit test for visviews.blockBoxPlot constructor
fprintf('\nUnit tests for visviews.blockBoxPlot valid constructor\n');

fprintf('It should construct a valid block box plot when only parent passed\n');
sfig = figure('Name', 'Empty plot');
bp = visviews.blockBoxPlot(sfig, [], []);
assertTrue(isvalid(bp));

drawnow
if values.deleteFigures
  delete(sfig);
end

function testInvalidConstructor(values) %#ok<DEFNU>
% Unit test for visviews.blockboxplot bad constructor
fprintf('\nUnit tests for visviews.blockBoxPlot invalid constructor parameters\n');

fprintf('It should throw an exception when no parameters are passed\n');
f = @() visviews.blockBoxPlot();
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when only one parameter is passed\n');
sfig = figure;
f = @() visviews.blockBoxPlot(sfig);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when only two parameters are passed\n');
f = @() visviews.blockBoxPlot(sfig, []);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when more than three parameters are passed\n');
f = @() visviews.blockBoxPlot(sfig, [], [], []);
assertExceptionThrown(f, 'MATLAB:maxrhs');
if values.deleteFigures
  delete(sfig);
end

function testPlot(values) %#ok<DEFNU>
% Unit test visviews.blockBoxPlot plot
fprintf('\nUnit tests for visviews.blockBoxPlot plot method\n')

fprintf('It should produce a plot for identity slice\n');
sfig1 = figure('Name', 'Clumps of one window');
bp1 = visviews.blockBoxPlot(sfig1, [], []);
assertTrue(isvalid(bp1));
bp1.plot(values.bData, values.fun, values.slice);
gaps = bp1.getGaps();
bp1.reposition(gaps);
fprintf('It should allow callbacks to be registered for clumps of one window\n')
bp1.registerCallbacks([]);

fprintf('It should produce a correct slice for clumps of one window\n');
dslice = bp1.getClumpSlice(1);
s = dslice.getParameters(3);
assertTrue(strcmp(s{1}, '1:32'))
assertTrue(strcmp(s{2}, ':'))
assertTrue(strcmp(s{3}, '1'))
dslice = bp1.getClumpSlice(31);
s = dslice.getParameters(3);
assertTrue(strcmp(s{1}, '1:32'))
assertTrue(strcmp(s{2}, ':'))
assertTrue(strcmp(s{3}, '31'))

fprintf('It should produce a plot for empty slice\n');
sfig2 = figure('Name', 'Empty slice');
bp2 = visviews.blockBoxPlot(sfig2, [], []);
assertTrue(isvalid(bp2));
bp2.plot(values.bData, values.fun, []);
gaps = bp2.getGaps();
bp2.reposition(gaps);

fprintf('It should produce a correct slice when initial slice is empty\n');
dslice1 = bp2.getClumpSlice(1);
s = dslice1.getParameters(3);
assertTrue(strcmp(s{1}, '1:32'))
assertTrue(strcmp(s{2}, ':'))
assertTrue(strcmp(s{3}, '1'))

fprintf('It should produce a plot for identity slice with groupings of 2\n');
sfig3 = figure('Name', 'Grouping of 2');
bp3 = visviews.blockBoxPlot(sfig3, [], []);
assertTrue(isvalid(bp3));
bp3.ClumpSize = 2;
bp1.plot(values.bData, values.fun, values.slice);
gaps = bp3.getGaps();
bp3.reposition(gaps);

fprintf('It should produce a plot for identity slice with 1 group\n');
sfig4 = figure('Name', 'Group of one');
bp4 = visviews.blockBoxPlot(sfig4, [], []);
assertTrue(isvalid(bp4));
bp4.ClumpSize = 20;
bp4.plot(values.bData, values.fun, values.slice);
gaps = bp4.getGaps();
bp4.reposition(gaps);

fprintf('It should produce a valid plot for one value\n');
sfig5 = figure('Name', 'One value');
bp5 = visviews.blockBoxPlot(sfig5, [], []);
assertTrue(isvalid(bp5));
bp5.ClumpSize = 20;
slice5 = viscore.dataSlice('Slices', {'3', ':', '2'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
bp5.plot(values.bData, values.fun, slice5);
gaps = bp5.getGaps();
bp5.reposition(gaps);

% Set up the data
data = repmat([1, 1, 1, 2, 2, 2, 3], [5, 1, 4]);
data = permute(data, [1, 3, 2]);
testVD6 = viscore.blockedData(data, 'Specific values');
fprintf('It should produce a plot for identity slice with uneven grouping\n');
sfig6 = figure('Name', 'No grouping to compare with specific values');
bp6 = visviews.blockBoxPlot(sfig6, [], []);
assertTrue(isvalid(bp6));
bp6.plot(testVD6, values.fun, values.slice);
gaps = bp6.getGaps();
bp6.reposition(gaps);

sfig7 = figure('Name', 'Grouping with specific values');
bp7 = visviews.blockBoxPlot(sfig7, [], []);
assertTrue(isvalid(bp7));
bp7.ClumpSize = 3;
bp7.plot(testVD6, values.fun, values.slice);
gaps = bp7.getGaps();
bp7.reposition(gaps);

fprintf('It should produce a plot for data with large standard deviation\n');
data8 = random('normal', 0.0, 10000.0, [40, 1000, 215]);
bData8 = viscore.blockedData(data8, 'Random normal large std');
sfig8 = figure('Name', 'Data with large standard deviation');
bp8 = visviews.blockBoxPlot(sfig8, [], []);
assertTrue(isvalid(bp8));
bp8.plot(bData8, values.fun, values.slice);
gaps = bp8.getGaps();
bp8.reposition(gaps);

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
end

function testPlotSlice(values) %#ok<DEFNU>
% Unit test visviews.blockBoxPlot plot  with nonempy slice
fprintf('\nUnit tests for visviews.blockBoxPlot plot method with slice\n')

sfig1 = figure('Name', 'Slice of windows at beginning');
bp1 = visviews.blockBoxPlot(sfig1, [], []);
assertTrue(isvalid(bp1));
slice1 = viscore.dataSlice('Slices', {':', ':', '1:10'}, ...
         'DimNames', {'Channel', 'Sample', 'Window'});
bp1.plot(values.bData, values.fun, slice1);
gaps = bp1.getGaps();
bp1.reposition(gaps);

fprintf('It should produce a plot for a slice of windows in the middle\n');
sfig2 = figure('Name', 'Slice of windows in middle');
bp2 = visviews.blockBoxPlot(sfig2, [], []);
assertTrue(isvalid(bp2));
slice2 = viscore.dataSlice('Slices', {':', ':', '4:9'}, ...
         'DimNames', {'Channel', 'Sample', 'Window'});
bp2.plot(values.bData, values.fun, slice2);
gaps = bp2.getGaps();
bp2.reposition(gaps);

fprintf('It should produce a plot for single point\n');
sfig3 = figure('Name', 'Elements 14 and Window 4');
bp3 = visviews.blockBoxPlot(sfig3, [], []);
assertTrue(isvalid(bp3));
slice3 = viscore.dataSlice('Slices', {'14', ':', '4'}, ...
         'DimNames', {'Channel', 'Sample', 'Window'});
bp3.plot(values.bData, values.fun, slice3);
gaps = bp3.getGaps();
bp3.reposition(gaps);

fprintf('It should produce a plot for a slice of windows that falls off the end\n');
sfig4 = figure('Name', 'Slice of windows off the end');
bp4 = visviews.blockBoxPlot(sfig4, [], []);
assertTrue(isvalid(bp4));
slice4 = viscore.dataSlice('Slices', {':', ':', '27:32'}, ...
         'DimNames', {'Channel', 'Sample', 'Window'});
bp4.plot(values.bData, values.fun, slice4);
gaps = bp4.getGaps();
bp4.reposition(gaps);

fprintf('It should produce a plot for subset of elements and a slice of windows that falls off the end\n');
sfig5 = figure('Name', 'Elements 14:18 with slice of windows off the end');
bp5 = visviews.blockBoxPlot(sfig5, [], []);
assertTrue(isvalid(bp5));
slice5 = viscore.dataSlice('Slices', {'14:18', ':', '27:32'}, ...
         'DimNames', {'Channel', 'Sample', 'Window'});
bp5.plot(values.bData, values.fun, slice5);
gaps = bp5.getGaps();
bp5.reposition(gaps);

drawnow
if values.deleteFigures
    delete(sfig1);
    delete(sfig2);
    delete(sfig3);
    delete(sfig4);
    delete(sfig5);
end

function testPlotSliceClumped(values) %#ok<DEFNU>
%Unit test visviews.blockBoxPlot plot with nonempy slice and clumping
fprintf('\nUnit tests for visviews.blockBoxPlot plot method with slice and clumps\n')

fprintf('It should produce a plot for a slice of windows at beginning (even)\n');

sfig1 = figure('Name', 'Slice of windows at beginning with clump factor 2');
bp1 = visviews.blockBoxPlot(sfig1, [], []);
assertTrue(isvalid(bp1));
slice1 = viscore.dataSlice('Slices', {':', ':', '1:10'}, ...
         'DimNames', {'Channel', 'Sample', 'Window'});
bp1.ClumpSize = 2;
bp1.plot(values.bData, values.fun, slice1);
gaps = bp1.getGaps();
bp1.reposition(gaps);

fprintf('It should produce a plot for a slice of windows in one clump\n');
sfig2 = figure('Name', 'Slice of 2 windows with clump factor 3');
bp2 = visviews.blockBoxPlot(sfig2, [], []);
assertTrue(isvalid(bp2));
slice2 = viscore.dataSlice('Slices', {':', ':', '14:15'}, ...
         'DimNames', {'Channel', 'Sample', 'Window'});
bp2.ClumpSize = 3;
bp2.plot(values.bData, values.fun, slice2);
gaps = bp2.getGaps();
bp2.reposition(gaps);

fprintf('It should produce a plot for a slice of windows uneven at end\n');
sfig3 = figure('Name', 'Slice of windows at end with clump factor 3');
bp3 = visviews.blockBoxPlot(sfig3, [], []);
assertTrue(isvalid(bp3));
slice3 = viscore.dataSlice('Slices', {':', ':', '27:31'}, ...
         'DimNames', {'Channel', 'Sample', 'Window'});
bp3.ClumpSize = 3;
bp3.plot(values.bData, values.fun, slice3);
gaps = bp3.getGaps();
bp3.reposition(gaps);

fprintf('It should produce a plot for subset of elements and a slice of clumps uneven at end\n');
sfig4 = figure('Name', 'Elements 14:18 with slice of clumps uneven at the end');
bp4 = visviews.blockBoxPlot(sfig4, [], []);
assertTrue(isvalid(bp4));
slice4 = viscore.dataSlice('Slices', {'14:18', ':', '27:32'}, ...
         'DimNames', {'Channel', 'Sample', 'Window'});
bp4.ClumpSize = 3;
bp4.plot(values.bData, values.fun, slice4);
gaps = bp4.getGaps();
bp4.reposition(gaps);

fprintf('It should produce a plot for one element and a slice of clumps uneven at end\n');
sfig5 = figure('Name', 'Element 3 with slice of clumps uneven at the end');
bp5 = visviews.blockBoxPlot(sfig5, [], []);
assertTrue(isvalid(bp5));
slice5 = viscore.dataSlice('Slices', {'3', ':', '27:31'}, ...
         'DimNames', {'Channel', 'Sample', 'Window'});
bp5.ClumpSize = 3;
bp5.plot(values.bData, values.fun, slice5);
gaps = bp5.getGaps();
bp5.reposition(gaps);

if values.deleteFigures
    delete(sfig1);
    delete(sfig2);
    delete(sfig3);
    delete(sfig4);
    delete(sfig5);
end

function testGetClumpSlice(values) %#ok<DEFNU>
%Unit test visviews.blockBoxPlot getClumpSlice
fprintf('\nUnit tests for visviews.blockBoxPlot getClumpSlice\n')

sfig1 = figure('Name', 'Full range unclumped');
bp1 = visviews.blockBoxPlot(sfig1, [], []);
assertTrue(isvalid(bp1));
bp1.plot(values.bData, values.fun, []);
gaps = bp1.getGaps();
bp1.reposition(gaps);

fprintf('It should produce the correct slice when plotting full range\n');
ds1 = bp1.getClumpSlice(1);
ds2 = bp1.getClumpSlice(31);
slices1 = ds1.getParameters(3);
slices2 = ds2.getParameters(3);
assertTrue(strcmp(slices1{1}, '1:32'));
assertTrue(strcmp(slices2{1}, '1:32'));
assertTrue(strcmp(slices1{3}, '1'));
assertTrue(strcmp(slices2{3}, '31'));

fprintf('It should produce an empty slice when clump factor is out of range\n');
ds3 = bp1.getClumpSlice(0);
assertTrue(isempty(ds3));
ds4 = bp1.getClumpSlice(32);
assertTrue(isempty(ds4));

fprintf('It should produce an empty slice when clump factor has changed without replotting\n');
bp1.ClumpSize = 3;
ds1 = bp1.getClumpSlice(1);
assertTrue(isempty(ds1));


fprintf('It should produce a correct slice with a clump factor\n');
bp1.ClumpSize = 3;
bp1.plot(values.bData, values.fun, []);
gaps = bp1.getGaps();
bp1.reposition(gaps);
ds1 = bp1.getClumpSlice(1);
ds2 = bp1.getClumpSlice(3);
ds3 = bp1.getClumpSlice(7);
ds4 = bp1.getClumpSlice(11);
ds5 = bp1.getClumpSlice(12);
assertTrue(isempty(ds5));
slices1 = ds1.getParameters(3);
slices2 = ds2.getParameters(3);
slices3 = ds3.getParameters(3);
slices4 = ds4.getParameters(3);
assertTrue(strcmp(slices1{1}, '1:32'));
assertTrue(strcmp(slices2{1}, '1:32'));
assertTrue(strcmp(slices3{1}, '1:32'));
assertTrue(strcmp(slices4{1}, '1:32'));
assertTrue(strcmp(slices1{3}, '1:3'));
assertTrue(strcmp(slices2{3}, '7:9'));
assertTrue(strcmp(slices3{3}, '19:21'));
assertTrue(strcmp(slices4{3}, '31:31'));

fprintf('It should produce a correct slice with an unclumped a middle slice\n')
bp1.ClumpSize  = 1;
plotSlice = viscore.dataSlice('Slices', {'7:18', ':', '12:15'}, ...
         'DimNames', {'Channel', 'Sample', 'Window'});
bp1.plot(values.bData, values.fun, plotSlice);
gaps = bp1.getGaps();
bp1.reposition(gaps);

ds1 = bp1.getClumpSlice(1);
ds2 = bp1.getClumpSlice(3);
ds3 = bp1.getClumpSlice(4);
ds4 = bp1.getClumpSlice(20);
slices1 = ds1.getParameters(3);
slices2 = ds2.getParameters(3);
slices3 = ds3.getParameters(3);
assertTrue(strcmp(slices1{1}, '7:18'));
assertTrue(strcmp(slices2{1}, '7:18'));
assertTrue(strcmp(slices3{1}, '7:18'));
assertTrue(strcmp(slices1{3}, '12'));
assertTrue(strcmp(slices2{3}, '14'));
assertTrue(strcmp(slices3{3}, '15'));
assertTrue(isempty(ds4));

fprintf('It should produce a correct slice with an clumped a middle slice\n')
bp1.ClumpSize  = 3;
plotSlice = viscore.dataSlice('Slices', {'7:18', ':', '2:15'}, ...
         'DimNames', {'Channel', 'Sample', 'Window'});
bp1.plot(values.bData, values.fun, plotSlice);
gaps = bp1.getGaps();
bp1.reposition(gaps);

ds1 = bp1.getClumpSlice(1);
ds2 = bp1.getClumpSlice(3);
ds3 = bp1.getClumpSlice(5);
ds4 = bp1.getClumpSlice(20);
slices1 = ds1.getParameters(3);
slices2 = ds2.getParameters(3);
slices3 = ds3.getParameters(3);
assertTrue(strcmp(slices1{1}, '7:18'));
assertTrue(strcmp(slices2{1}, '7:18'));
assertTrue(strcmp(slices3{1}, '7:18'));
assertTrue(strcmp(slices1{3}, '2:4'));
assertTrue(strcmp(slices2{3}, '8:10'));
assertTrue(strcmp(slices3{3}, '14:15'));
assertTrue(isempty(ds4));

if values.deleteFigures
 delete(sfig1)
end

function testConstantAndNaNValues(values) %#ok<DEFNU>
% Unit test visviews.blockBoxPlot plot constant and NaN
fprintf('\nUnit tests for visviews.blockBoxPlot plot method with constant and NaN values\n')

% All zeros
fprintf('It should produce a plot for when all of the values are 0\n');
data = zeros([32, 1000, 20]);
testVD1 = viscore.blockedData(data, 'All zeros');
sfig1 = figure('Name', 'All zero values');
bp1 = visviews.blockBoxPlot(sfig1, [], []);
assertTrue(isvalid(bp1));
bp1.plot(testVD1, values.fun, values.slice);
gaps = bp1.getGaps();
bp1.reposition(gaps);

% Data zeros, function NaN
fprintf('It should produce a plot for when data is zero, funcs empty (---see warning)\n');
sfig2 = figure('Name', 'Data zero, func NaN');
bp2 = visviews.blockBoxPlot(sfig2, [], []);
assertTrue(isvalid(bp2));
bp2.plot(testVD1, [], values.slice);
gaps = bp2.getGaps();
bp2.reposition(gaps);

% Data NaN
fprintf('It should produce a plot for when data is zero, funcs NaNs (---see warning)\n');
data = NaN([32, 1000, 20]);
testVD3 = viscore.blockedData(data, 'Data NaN');
sfig3 = figure('Name', 'Data NaNs');
bp3 = visviews.blockBoxPlot(sfig3, [], []);
assertTrue(isvalid(bp3));
bp3.plot(testVD3, values.fun, values.slice);
gaps = bp3.getGaps();
bp3.reposition(gaps);

% Data slice empty
fprintf('It should produce empty axes when data slice is empty (---see warning)\n');
data = zeros(5, 1);
testVD4 = viscore.blockedData(data, 'Data empty');
slice4 = viscore.dataSlice('Slices', {'6', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
sfig4 = figure('Name', 'Data slice is empty');
bp4 = visviews.blockBoxPlot(sfig4, [], []);
assertTrue(isvalid(bp4));
bp4.plot(testVD4, values.fun, slice4);
gaps = bp4.getGaps();
bp4.reposition(gaps);

drawnow
if values.deleteFigures
    delete(sfig1);
    delete(sfig2);
    delete(sfig3);
    delete(sfig4);
end

function testGetDefaultProperties(values) %#ok<INUSD,DEFNU>
% Unit test for visviews.blockBoxPlot getDefaultProperties
fprintf('\nUnit tests for visviews.blockBoxPlot getDefaultProperties\n');

fprintf('It should have a getDefaultProperties method that returns a structure\n');
s = visviews.blockBoxPlot.getDefaultProperties();
assertTrue(isa(s, 'struct'));

