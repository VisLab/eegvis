function test_suite = testEventData %#ok<STOUT>
% Unit tests for eventData
initTestSuite;

function testNormalConstructor %#ok<DEFNU>
% Unit test for eventData normal constructor
fprintf('\nUnit tests for viscore.eventData valid constructor\n');

fprintf('It should construct a valid event set from valid events\n');
load('EEGData.mat');  %
tEvents = EEG.event;
types = {tEvents.type}';
startTimes = cell2mat({tEvents.latency})';

vd = viscore.eventData(types, startTimes);
assertTrue(isvalid(vd));


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


