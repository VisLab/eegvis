function test_suite = testBlockedEvents %#ok<STOUT>
% Unit tests for blockedEvents
initTestSuite;

function values = setup %#ok<DEFNU>
load('EEG.mat');
values.EEG = EEG;
tEvents = EEG.event;
types = {tEvents.type}';
% Convert to seconds since beginning
startTimes = (round(double(cell2mat({EEG.event.latency}))') - 1)./EEG.srate;
values.event = struct('type', types, 'startTime', num2cell(startTimes), ...
'certainty', ones(length(startTimes), 1));
load('EEGEpoch.mat');
values.EEGEpoch = EEGEpoch;
load('ArtifactEvents.mat');
values.artifactEvents = artifactEvents;

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testNormalConstructor(values) %#ok<DEFNU>
% Unit test for blockedEvents normal constructor
fprintf('\nUnit tests for viscore.blockedEvents valid constructor\n');

fprintf('It should construct a valid event set from set of types and start times\n');
ed1 = viscore.blockedEvents(values.event);
assertTrue(isvalid(ed1));
fprintf('The start times be greater than or equal to 0\n');
assertTrue(sum(ed1.getStartTimes() < 0) == 0);
fprintf('The default block time should be correct\n');
assertEqual(ed1.getBlockTime, 1);
fprintf('It should return the correct unique event types:\n');
uTypes = ed1.getUniqueTypes();
originalUnique = unique({values.event.type});
assertEqual(length(uTypes), length(originalUnique));
for k = 1:length(uTypes)
fprintf('---It should have event type: ''%s''\n', uTypes{k});
assertEqual(sum(strcmpi(uTypes{k}, originalUnique)), 1);
end

fprintf('It should work when the block time that is not the default:\n');
blockTime = 1000/128;
ed2 = viscore.blockedEvents(values.event, 'BlockTime', blockTime);
assertTrue(isvalid(ed2));
sTimes = ed2.getStartTimes();
fprintf('It should have the right number of blocks\n');
assertEqual(ed2.getNumberBlocks(), 31);
bList = ed2.getBlockList();
assertEqual(length(bList), ed2.getNumberBlocks());
bTimes = (0:(ed1.getNumberBlocks() - 1)) * blockTime;
for k = 1:length(bList)
indices = find(bTimes(k) <= sTimes & sTimes < bTimes(k) + blockTime)';
fprintf('---Block %g should have %g events\n', k, length(indices));
assertEqual(length(indices), length(bList{k}));
assertVectorsAlmostEqual(indices, bList{k});
end

fprintf('It should have the right indices associated with each block\n');
for k = 1:length(bList)
indices = find(bTimes(k) <= sTimes & sTimes < bTimes(k) + blockTime);
fprintf('---Block %g should have %g events\n', k, length(indices));
assertVectorsAlmostEqual(indices, ed2.getBlocks(k, k));
end

function testBadConstructor(values) %#ok<INUSD,DEFNU>
% Unit test for viscore.blockedEvents bad constructor
fprintf('\nUnit tests for viscore.blockedEvents invalid constructor parameters\n');

fprintf('It should throw an exception when no parameters are passed\n');
f = @() viscore.blockedEvents();
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when a non structure event parameter is passed\n');
f = @() viscore.blockedEvents(3);
assertAltExceptionThrown(f, {'MATLAB:InputParser:ArgumentFailedValidation'});

function testWithEpochData(values) %#ok<DEFNU>
% Unit test for viscore.blockedEvents with epoched data
fprintf('\nUnit tests for viscore.blockedEvents getBlockList with epoched data\n');
[events, startTimes, timeScale] = viscore.blockedEvents.getEEGTimes(values.EEGEpoch);
assertEqual(length(startTimes), size(values.EEGEpoch.data, 3));
assertEqual(length(timeScale), size(values.EEGEpoch.data, 2));
assertTrue(isstruct(events));

bTime  = size(values.EEGEpoch.data, 2)./values.EEGEpoch.srate;
ev = viscore.blockedEvents(events, 'BlockTime', bTime, ...
'BlockStartTimes', startTimes);
blockList = ev.getBlockList();
fprintf('It should have the correct block list for point events\n');
assertEqual(length(startTimes), length(blockList));
epochs = values.EEGEpoch.epoch;
for k = 1:length(startTimes)
fprintf('---Epoch %g should have %g events\n', k, length(epochs(k).event));
assertTrue(isequal(blockList{k}, epochs(k).event));
end
fprintf('The event start times should place them in right epochs\n');
epTimes = ev.getBlockStartTimes();
evTimes = ev.getStartTimes();
bTime = ev.getBlockTime();
for k = 1:length(epTimes)
nEvents = length(epochs(k).event);
fprintf('---Epoch %g should have %g events: [', k, nEvents);
fprintf(' %g', values.EEGEpoch.epoch(k).event);
fprintf('] has [');
count = 0;
myEvents = zeros(1, nEvents);
for j = 1:length(evTimes);
    if epTimes(k) <= evTimes(j) && ...
            evTimes(j) <= epTimes(k) + bTime && ...
            ev.getEventBlocks{j} == k
        count = count + 1;
        myEvents(count) = j;
    end
end
fprintf(' %g', myEvents)
fprintf(']\n');
assertEqual(nEvents, count);
assertTrue(isequal(values.EEGEpoch.epoch(k).event, myEvents));
end

function testGetMethods(values) %#ok<DEFNU>
% Unit test for viscore.blockedEvents getStartTimes
fprintf('\nUnit tests for viscore.blockedEvents getStartTimes\n');
ed1 = viscore.blockedEvents(values.event);
fprintf('It should return all start times when called with 1 argument\n');
sTimes = ed1.getStartTimes();
assertTrue(length(sTimes) == length(values.event));
fprintf('It should return the right number of start times when called with 2 arguments\n');
sTimes = ed1.getStartTimes(1:6);
assertTrue(length(sTimes) == 6);

fprintf('It should return all type numbers when called with 1 argument\n');
tNums = ed1.getTypeNumbers();
assertTrue(length(tNums) == length(values.event));
fprintf('It should return the right number of type numbers when called with 2 arguments\n');
tNums = ed1.getTypeNumbers(1:6);
assertTrue(length(tNums) == 6);

fprintf('It should return all types when called with 1 argument\n');
types = ed1.getTypes();
assertTrue(length(types) == length(values.event));
fprintf('It should return the right number of type numbers when called with 2 arguments\n');
types = ed1.getTypes(1:6);
assertTrue(length(types) == 6);
t = {values.event.type}';
for k = 1:length(types)
    assertTrue(strcmpi(t{k}, types{k}));
end

fprintf('It should return a cell array of unique types when called with one index\n');
types = ed1.getUniqueTypes(2);
assertTrue(iscell(types));
assertEqual(length(types), 1);

fprintf('It should return an event count array of the correct size\n');
startTimes = ed1.getStartTimes();
numBlocks = ceil(max(startTimes)/ed1.getBlockTime());

counts = ed1.getEventCounts(1, numBlocks, 0);
assertEqual(size(counts, 1), length(ed1.getUniqueTypes()) + 1);
assertEqual(size(counts, 2), numBlocks);
fprintf('There should be no uncertain events when threshold is 0\n');
assertTrue(sum(counts(end, :)) == 0);
fprintf('The number of events in each block should be correct\n');
blockSum = sum(counts);
bList = ed1.getBlockList();
for k = 1:numBlocks
    assertElementsAlmostEqual(blockSum(k), length(bList{k}));
end
fprintf('The total counts for each type of event should be correct\n');
bCounts = ed1.getEventBlocks();
typeCounts = sum(counts, 2); % Compute the sum of events of each type
uTypes = ed1.getUniqueTypes();
types = ed1.getTypeNumbers();
events = 1:length(types);
for k = 1: length(uTypes);
    tEvents = events(types == k); % Pick out the events of the type
    tcount = 0;
    for j = 1:length(tEvents)
        tcount = tcount + length(bCounts{tEvents(j)});
    end
    assertElementsAlmostEqual(typeCounts(k), tcount);  
end
counts = ed1.getEventCounts(1, numBlocks, 2);
assertEqual(size(counts, 1), length(ed1.getUniqueTypes()) + 1);
assertEqual(size(counts, 2), numBlocks);
fprintf('All the events should be uncertain when threshold is 2\n');
assertTrue(sum(counts(end, :)) == ed1.getNumberEvents());

fprintf('It should work with artifact events with uncertainty\n');
ed2 = viscore.blockedEvents(values.artifactEvents);
fprintf('It should return an artifact event count array of correct size for artifact events\n');
startTimes = ed2.getStartTimes();
numBlocks = ceil(max(startTimes)/ed2.getBlockTime());

counts = ed2.getEventCounts(1, numBlocks, 0);
assertEqual(size(counts, 1), length(ed2.getUniqueTypes()) + 1);
assertEqual(size(counts, 2), numBlocks);
fprintf('There should be no uncertain artifact events when threshold is 0\n');
assertTrue(sum(counts(end, :)) == 0);
fprintf('The number of artifact events in each block should be correct\n');
blockSum = sum(counts);
bList = ed2.getBlockList();
for k = 1:numBlocks
    assertElementsAlmostEqual(blockSum(k), length(bList{k}));
end
fprintf('The total counts for each type of artifact event should be correct\n');
bCounts = ed2.getEventBlocks();
typeCounts = sum(counts, 2); % Compute the sum of events of each type
uTypes = ed2.getUniqueTypes();
types = ed2.getTypeNumbers();
events = 1:length(types);
for k = 1: length(uTypes);
    tEvents = events(types == k); % Pick out the events of the type
    tcount = 0;
    for j = 1:length(tEvents)
        tcount = tcount + length(bCounts{tEvents(j)});
    end
    assertElementsAlmostEqual(typeCounts(k), tcount);  
end
counts2 = ed2.getEventCounts(1, numBlocks, 2);
assertEqual(size(counts2, 1), length(ed2.getUniqueTypes()) + 1);
assertEqual(size(counts2, 2), numBlocks);
fprintf('All the artifact events should be uncertain when threshold is 2\n');
assertTrue(sum(counts2(end, :)) == ed2.getNumberEvents());

fprintf('It should have the correct counts when the threshold is 0.5\n');
countsp5 = ed2.getEventCounts(1, numBlocks, 0.5);
assertEqual(size(countsp5, 1), length(ed2.getUniqueTypes()) + 1);
assertEqual(size(countsp5, 2), numBlocks);
fprintf('There should be the correct number of uncertain artifact events when threshold is 0.5\n');
certainties = ed2.getCertainty();  % This test assumes one block/event
assertTrue(sum(countsp5(end, :)) == sum(certainties < 0.5));
fprintf('The number of artifact events in each block should be correct\n');
blockSum = sum(countsp5(1:end-1, :));
bList = ed2.getBlockList();
for k = 1:numBlocks
    certain = sum(certainties(bList{k}) >= 0.5);
    assertElementsAlmostEqual(blockSum(k), certain);
end
fprintf('It should get the correct counts when the start block is not 1\n');
countStart2 = ed2.getEventCounts(2, 5, 0.5);
assertEqual(size(countStart2, 1), length(ed2.getUniqueTypes()) + 1);
assertEqual(size(countStart2, 2), 4);

function testGetEventStructure(values) %#ok<DEFNU>
% Unit test for viscore.blockedEvents getEventStructure
eventNew = viscore.blockedEvents.getEEGTimes(values.EEG);
assertTrue(isequal(eventNew, values.event));

