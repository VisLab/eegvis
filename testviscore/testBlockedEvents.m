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
  
  fprintf('It should return an event count array of the correct size\n');
  startTimes = ed1.getStartTimes();
  numBlocks = ceil(max(startTimes)/ed1.getBlockTime());
  
  counts = ed1.getEventCounts(1, numBlocks);
  assertEqual(size(counts, 1), length(ed1.getUniqueTypes()));
  assertEqual(size(counts, 2), numBlocks);
  
  fprintf('It should return a cell array when called with one index\n');
  types = ed1.getUniqueTypes(2);
  assertTrue(iscell(types));
  assertEqual(length(types), 1);

  function testGetEventStructure(values) %#ok<DEFNU>
  % Unit test for viscore.blockedEvents getEventStructure
  eventNew = viscore.blockedEvents.getEEGTimes(values.EEG);
  assertTrue(isequal(eventNew, values.event));
  
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
      
   