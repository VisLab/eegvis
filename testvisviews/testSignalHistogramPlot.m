function test_suite = testSignalHistogramPlot %#ok<STOUT>
% Unit tests for signalHistogramPlot
initTestSuite;

function testNormalConstructor %#ok<DEFNU>
% testSignalPlot unit test for signalHistogramPlot constructor
fprintf('\nUnit tests for visviews.stackedSignalPlot valid constructor\n');

fprintf('It should construct a valid stacked signal plot when only parent passed\n')
sfig = figure('Name', 'Constructs a panel when only parent passed');
ip = visviews.signalHistogramPlot(sfig, [], []);
assertTrue(isvalid(ip));
drawnow
delete(sfig);

function testBadConstructor %#ok<DEFNU>
% testSignalPlot unit test for signalHistogramPlot constructor
fprintf('\nUnit tests for visviews.stackedSignalPlot invalid constructor parameters\n');

fprintf('It should throw an exception when no paramters are passed\n');
f = @() visviews.signalHistogramPlot();
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when only one parameter is passed\n');
sfig = figure('Name', 'Invalid constructor');
f = @() visviews.signalHistogramPlot(sfig);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when only two parameters are passed\n');
f = @() visviews.signalHistogramPlot(sfig, []);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when more than three parameters are passed\n');
f = @() visviews.signalHistogramPlot(sfig, [], [], []);
assertExceptionThrown(f, 'MATLAB:maxrhs');
delete(sfig);


function testplot %#ok<DEFNU>
% test signalHistogramPlot plot
fprintf('\nUnit tests for visviews.stackedSignalPlot invalid constructor parameters\n');

fprintf('It should produce a plot for a slice along dimension 3\n');
sfig = figure;
sp = visviews.signalHistogramPlot(sfig, [], []);
assertTrue(isvalid(sp));
% Generate some data to plot
data = random('normal', 0, 1, [32, 1000, 20]);
testVD = viscore.blockedData(data, 'Rand1');
keyfun = @(x) x.('ShortName');
defFuns= visfuncs.functionObj.createObjects( ...
    'visfuncs.functionObj', viewTestClass.getDefaultFunctions(), keyfun);
slice1 = viscore.dataSlice('Slices', {':', ':', '1'});
sp.plot(testVD, defFuns{1}, slice1);
gaps = sp.getGaps();
sp.reposition(gaps);
drawnow
%delete(sfig);

fprintf('It should produce a plot for a slice along dimension 1\n');
sfig1 = figure('Name', 'visviews.signalHistogramPlot test plot slice element');
sp1 = visviews.signalHistogramPlot(sfig1, [], []);
slice2 = viscore.dataSlice('Slices', {'1', ':', ':'});
sp1.plot(testVD, defFuns{1}, slice2);
gaps = sp1.getGaps();
sp1.reposition(gaps);
drawnow
delete(sfig);
%delete(sfig1);
