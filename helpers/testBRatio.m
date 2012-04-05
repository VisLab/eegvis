function test_suite = testBRatio  %#ok<STOUT>
% Unit tests for bRatio
initTestSuite;

function testNormalCall %#ok<DEFNU>
% Unit test for bRatio normal call
fprintf('\nUnit tests for bRatio normal call different types of parameters\n');

data = random('normal', 0, 1, [32, 1000, 20]);
fprintf('It should generate a ratio array of the right size\n');
ratio = bRatio(data, 128, [1, 128], [1, 128]);
theMean = mean(data, 2);
assertVectorsAlmostEqual(size(ratio), size(theMean));

fprintf('It should generate value close to 1 for entire range\n');
assertVectorsAlmostEqual(ratio, repmat(1.0, size(ratio)));

fprintf('It should generate a ratio array of right size when fBand not everything\n');
ratio = bRatio(data, 128, [8, 12], [1, 128]);
assertVectorsAlmostEqual(size(ratio), size(theMean));

fprintf('It should generate a ratio array of right size when fBand and bBand not everything\n');
ratio = bRatio(data, 128, [8, 12], [12.1, 30]);
assertVectorsAlmostEqual(size(ratio), size(theMean));

fprintf('It should generate a ratio array when the botBand is empty\n')
ratio = bRatio(data, 128, [8, 12], []);
assertVectorsAlmostEqual(size(ratio), size(theMean));

fprintf('It should generate a ratio of zero when values have no overlap\n');
ratio = bRatio(data, 128, [129, 256], []);
assertVectorsAlmostEqual(size(ratio), size(theMean));
assertVectorsAlmostEqual(ratio, zeros(size(theMean)));

fprintf('If bottom band doesn''t overlap, it prints a warning and set ratio to 0\n');
ratio = bRatio(data, 128, [8, 12], [128, 256]);
assertVectorsAlmostEqual(size(ratio), size(theMean));
assertVectorsAlmostEqual(ratio, zeros(size(theMean)));

function testNormalCallDataSizes %#ok<DEFNU>
% Unit test for bRatio normal call for different data sizes
fprintf('\nUnit tests for bRatio normal call different data sizes\n');

data = random('normal', 0, 1, [32, 1000, 20, 5]);
fprintf('It should generate a ratio array of the right size for 4D array\n');
ratio = bRatio(data, 128, [7, 12], [1, 128]);
theMean = mean(data, 2);
assertVectorsAlmostEqual(size(ratio), size(theMean));

data = random('normal', 0, 1, [32, 1000, 20]);
fprintf('It should generate a ratio array of the right size for 3D array\n');
ratio = bRatio(data, 128, [7, 12], [1, 128]);
theMean = mean(data, 2);
assertVectorsAlmostEqual(size(ratio), size(theMean));

data = random('normal', 0, 1, [32, 1000, 20]);
fprintf('It should generate a ratio array of the right size for 3D array\n');
ratio = bRatio(data, 128, [7, 12], [1, 128]);
theMean = mean(data, 2);
assertVectorsAlmostEqual(size(ratio), size(theMean));

data = random('normal', 0, 1, [32, 1, 45]);
fprintf('It should generate a ratio array of the right size for 3D array, one sample\n');
ratio = bRatio(data, 128, [7, 12], [1, 128]);
theMean = mean(data, 2);
assertVectorsAlmostEqual(size(ratio), size(theMean));

data = random('normal', 0, 1, [32, 1]);
fprintf('It should generate a ratio array of the right size for a column vector\n');
ratio = bRatio(data, 128, [7, 12], [1, 128]);
theMean = mean(data, 2);
assertVectorsAlmostEqual(size(ratio), size(theMean));

data = random('normal', 0, 1, [1, 38]);
fprintf('It should generate a ratio array of the right size for a row vector\n');
ratio = bRatio(data, 128, [7, 12], [1, 128]);
theMean = mean(data, 2);
assertVectorsAlmostEqual(size(ratio), size(theMean));

data = 3;
fprintf('It should generate a ratio array of the right size for a value\n');
ratio = bRatio(data, 128, [7, 12], [1, 128]);
theMean = mean(data, 2);
assertVectorsAlmostEqual(size(ratio), size(theMean));

function testBadCalls %#ok<DEFNU>
%Unit test for bRatio bad parameters
fprintf('\nUnit tests for bRatio bad parameters\n');

fprintf('It should throw an exception when no parameters are passed\n');
f = @() bRatio();
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when only one parameter is passed\n');
data = random('normal', 0, 1, [32, 1000, 20]);
f = @() bRatio(data);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when only two parameters are passed\n');
data = random('normal', 0, 1, [32, 1000, 20]);
f = @() bRatio(data, 128);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when only three parameters are passed\n');
data = random('normal', 0, 1, [32, 1000, 20]);
f = @() bRatio(data, 128, [12, 80]);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when top band is empty\n');
f = @()bRatio(data, 128, [], []);
assertAltExceptionThrown(f, {'MATLAB:badsubscript'});

fprintf('It should throw an exception when top band is single value\n');
f = @()bRatio(data, 128, 3, []);
assertAltExceptionThrown(f, {'MATLAB:badsubscript'});

fprintf('It should throw an exception when bottom band is single value\n');
f = @()bRatio(data, 128, [3,4], 10);
assertAltExceptionThrown(f, {'MATLAB:badsubscript'});

function testDisplayInPlot %#ok<DEFNU>
%Unit test for bRatio displaying in a plot

fprintf('\nUnit tests for summary with plot\n');

% Specify the function in a standard structure (could add to defaults)
fStruct = struct( ...
     'Enabled',         {true}, ...
     'Category',        {'block'}, ...
     'DisplayName',     {'Alpha/Beta SIR'}, ...
     'ShortName',       {'A/B'}, ...
     'Definition',      {'@(x) (bRatio(x, 128, [8, 12], [12.1, 30]))'}, ...
     'ThresholdType',   {'z score'}, ...
     'ThresholdScope',  {'global'}, ...
     'ThresholdLevels', {3}, ...
     'ThresholdColors', {[1, 0, 0]}, ...
     'BackgroundColor', {[0.7, 0.7, 0.7]}, ...
     'Description',    {'Alpha spectral intensity ratio (element, block)' ...
                });
% Create the function object needed for display            
defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', fStruct);
       
% Create some data with channel locations to show scalp plot
data = random('exp', 1, [32, 1000, 20]);
load chanlocs.mat;
testVD = viscore.blockedData(data, 'Rand1', 'ElementLocations', chanlocs);
thisFunc = defaults{1};
thisFunc.setData(testVD);
slice1 = viscore.dataSlice('Slices', {':', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});

% Create a block scalp plot of the summary
fprintf('It should provide values for a block scalp plot\n');
sfig1 = figure('Name', 'Block scalp plot of spectral intensity ratio');
sp = visviews.blockScalpPlot(sfig1, [], []);
assertTrue(isvalid(sp));
sp.InterpolationMethod = 'linear';
sp.plot(testVD, thisFunc, slice1);
drawnow
gaps = sp.getGaps();
sp.reposition(gaps);

% Create a block box plot of the summary
fprintf('It should provide values for a block box plot \n');
sfig2 = figure('Name', 'Block box plot of spectral intensity ratio');
bp = visviews.blockBoxPlot(sfig2, [], []);
bp.plot(testVD, thisFunc, slice1);
drawnow
gaps = bp.getGaps();
bp.reposition(gaps);