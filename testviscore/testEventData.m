function test_suite = testEventData %#ok<STOUT>
% Unit tests for eventData
initTestSuite;

function testNormalConstructor %#ok<DEFNU>
% Unit test for eventData normal constructor
fprintf('\nUnit tests for viscore.eventData valid constructor\n');

fprintf('It should construct a valid event set from set of types and start times\n');
load('EEGData.mat');  %
tEvents = EEG.event;
types = {tEvents.type}';
startTimes = cell2mat({tEvents.latency})';

vd = viscore.eventData(types, startTimes);
assertTrue(isvalid(vd));
fprintf('The event start times should match the input start times\n');
assertVectorsAlmostEqual(startTimes, vd.getStartTimes());
fprintf('The default end times should match the start times\n')
assertVectorsAlmostEqual(startTimes, vd.getEndTimes());
fprintf('The default block size should be 1\n');
assertElementsAlmostEqual(vd.getBlockSize(), 1);
fprintf('The default sampling rate should be 1Hz\n');
assertElementsAlmostEqual(vd.getSamplingRate(), 1);

endTimes = startTimes + 2;
vd1 = viscore.eventData(types, startTimes, endTimes);
fprintf('When event times are passed, the end times should agree\n');
assertTrue(isvalid(vd1));
assertVectorsAlmostEqual(startTimes, vd1.getStartTimes());
assertVectorsAlmostEqual(endTimes, vd1.getEndTimes());


function testBadConstructor %#ok<DEFNU>
% Unit test for viscore.eventData bad constructor
fprintf('\nUnit tests for viscore.eventData invalid constructor parameters\n');

fprintf('It should throw an exception when no parameters are passed\n');
f = @() viscore.eventData();
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when only one parameter is passed\n');
data = random('normal', 0, 1, [32, 1000, 20]);
f = @() viscore.eventData(data);
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});


