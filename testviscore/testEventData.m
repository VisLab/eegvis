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
startTimes = cell2mat({tEvents.latency})'; % Convert to seconds

ed1 = viscore.eventData(types, startTimes);
assertTrue(isvalid(ed1));
fprintf('The event start times should match the input start times\n');
assertVectorsAlmostEqual(startTimes, ed1.getStartTimes());
fprintf('The default end times should be one more sample than start times\n')
assertVectorsAlmostEqual(startTimes + 1, ed1.getEndTimes());
fprintf('The default block size should be 1\n');
assertElementsAlmostEqual(ed1.getBlockSize(), 1);
fprintf('The default sampling rate should be 1Hz\n');
assertElementsAlmostEqual(ed1.getSampleRate(), 1);
fprintf('The number of blocks should be correct\n');
assertEqual(ed1.getNumberBlocks(), 30307);


endTimes = startTimes + 2;
ed2 = viscore.eventData(types, startTimes, endTimes);
fprintf('When event end times are passed, the object end times should agree\n');
assertTrue(isvalid(ed2));
assertVectorsAlmostEqual(startTimes, ed2.getStartTimes());
assertVectorsAlmostEqual(endTimes, ed2.getEndTimes());


fprintf('When the sampling rate is passed and block size are passed, the object sampling rate should agree\n');
startTimes = startTimes./EEG.srate;
ed3 = viscore.eventData(types, startTimes, 'SampleRate', EEG.srate, ...
                         'BlockSize', 1000);
assertTrue(isvalid(ed3));
fprintf('The sampling rate should be correct\n');
assertElementsAlmostEqual(EEG.srate, ed3.getSampleRate());
fprintf('The number of blocks should be correct\n');
assertEqual(ed3.getNumberBlocks(), 31);
fprintf('The blocksize should be correct\n');
assertElementsAlmostEqual(1000, ed3.getBlockSize());

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
tEvents = EEG.event;
types = {tEvents.type}';
startTimes =cell2mat({tEvents.latency}')./EEG.srate;
blockSize = 1000;
ed1 = viscore.eventData(types, startTimes, 'SampleRate', EEG.srate, ...
    'BlockSize', blockSize);
assertTrue(isvalid(ed1));
sTimes = ed1.getStartTimes();
fprintf('It should have the right number of blocks\n');
assertEqual(ed1.getNumberBlocks(), 31);
bList = ed1.getBlockList();
assertEqual(length(bList), ed1.getNumberBlocks());
blockTime = blockSize./EEG.srate;
bTimes = (0:(ed1.getNumberBlocks() - 1)) * blockTime;
for k = 1:length(bList)
    indices = find(bTimes(k) <= sTimes & sTimes < bTimes(k) + blockTime)';
    fprintf('---Block %g should have %g events\n', k, length(indices)); 
    assertEqual(length(indices), length(bList{k}));
    assertVectorsAlmostEqual(indices, bList{k});
end

fprintf('It should have the right indices associated with each block\n');
for k = 1:length(bList)
    indices = find(bTimes(k) <= sTimes & sTimes < bTimes(k) + blockTime)';
    fprintf('---Block %g should have %g events\n', k, length(indices)); 
    assertVectorsAlmostEqual(indices, ed1.getBlock(k, k));
end


function testGetEventSlice %#ok<DEFNU>
% Unit test for viscore.eventData slice
fprintf('\nUnit tests for viscore.eventData handling of block list\n');

% load('EEGData.mat');  %
% tEvents = EEG.event;
% types = {tEvents.type}';
% startTimes = (1:10:length(types))';
% endTimes = startTimes + 5;
% blockSize = 1000;
% ed1 = viscore.eventData(types, startTimes, 'EndTimes', endTimes, ...
%         'SampleRate', EEG.srate, 'BlockSize', blockSize);
% assertTrue(isvalid(ed1));
% ds = viscore.dataSlice('Slices', {':', ':', '3'});
% [selected, limits] = ed1.getEventSlice(ds);
