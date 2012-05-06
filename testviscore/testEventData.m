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
startTimes = cell2mat({tEvents.latency})'./1000; % Convert to seconds

ed1 = viscore.eventData(types, startTimes);
assertTrue(isvalid(ed1));
fprintf('The event start times should match the input start times\n');
assertVectorsAlmostEqual(startTimes, ed1.getStartTimes());
fprintf('The default end times should match the start times\n')
assertVectorsAlmostEqual(startTimes, ed1.getEndTimes());
fprintf('The default block size should be 1\n');
assertElementsAlmostEqual(ed1.getBlockSize(), 1);
fprintf('The default sampling rate should be 1Hz\n');
assertElementsAlmostEqual(ed1.getSamplingRate(), 1);
fprintf('The default maximum time is the longest event end time\n');
assertElementsAlmostEqual(ed1.getMaxTime(), max(startTimes));

endTimes = startTimes + 2;
ed2 = viscore.eventData(types, startTimes, endTimes);
fprintf('When event end times are passed, the object end times should agree\n');
assertTrue(isvalid(ed2));
assertVectorsAlmostEqual(startTimes, ed2.getStartTimes());
assertVectorsAlmostEqual(endTimes, ed2.getEndTimes());

fprintf('When the sampling rate is passed, the object sampling rate should agree\n');
ed3 = viscore.eventData(types, startTimes, 'SamplingRate', EEG.srate);
assertTrue(isvalid(ed3));
assertElementsAlmostEqual(EEG.srate, ed3.getSamplingRate());

fprintf('When the block size is passed, the object block size should agree\n');
ed4 = viscore.eventData(types, startTimes, 'SamplingRate', EEG.srate, ...
                        'BlockSize', 1000);
assertTrue(isvalid(ed4));
assertElementsAlmostEqual(1000, ed4.getBlockSize());

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

function testUniqueTypes %#ok<DEFNU>
% Unit test for viscore.eventData handling unique event types
fprintf('\nUnit tests for viscore.eventData handling of unique event types\n');

fprintf('It should return the correct unique event types:\n');
load('EEGData.mat');  %
tEvents = EEG.event;
types = {tEvents.type}';
startTimes = cell2mat({tEvents.latency})'./1000;

ed1 = viscore.eventData(types, startTimes);
assertTrue(isvalid(ed1));
uTypes = ed1.getUniqueTypes();
originalUnique = unique(types);

assertEqual(length(uTypes), length(originalUnique));
for k = 1:length(uTypes)
    fprintf('---It should have event type: ''%s''\n', uTypes{k});
    assertEqual(sum(strcmpi(uTypes{k}, originalUnique)), 1);
end

function testBlockList %#ok<DEFNU>
% Unit test for viscore.eventData handling block list
fprintf('\nUnit tests for viscore.eventData handling of block list\n');

fprintf('It should return a blocklist of correct size:\n');
load('EEGData.mat');  %
tEvents = EEG.urevent;
types = {tEvents.type}';
startTimes = cell2mat({tEvents.latency})'./EEG.srate;

ed1 = viscore.eventData(types, startTimes, 'SamplingRate', EEG.srate, ...
    'BlockSize', 1000);
assertTrue(isvalid(ed1));
originalUnique = unique(types);
sTimes = ed1.getStartTimes();
blockTime = 1000/EEG.srate;
numberBlocks = ceil(ed1.getMaxTime()/blockTime);
assertEqual(numberBlocks, 31);
bList = ed1.getBlockList();
assertEqual(length(bList), numberBlocks);
bTimes = (0:(numberBlocks - 1)) * blockTime;
for k = 1:length(bList)
    indices = find(bTimes(k) <= sTimes & sTimes < bTimes(k) + blockTime);
    fprintf('---Block %g should have %g events\n', k, length(indices)); 
    assertEqual(length(indices), length(bList{k}));
end



