function test_suite = testEventData %#ok<STOUT>
% Unit tests for eventData
initTestSuite;

function event = setup %#ok<DEFNU>
load('EEGData.mat');  %
tEvents = EEG.event;
types = {tEvents.type}';
                                      % Convert to seconds since beginning
startTimes = (round(double(cell2mat({EEG.event.latency}))') - 1)./EEG.srate; 
endTimes = startTimes + 1/EEG.srate;
event = struct('type', types, 'startTime', num2cell(startTimes), ...
    'endTime', num2cell(endTimes));

function teardown(event) %#ok<INUSD,DEFNU>
% Function executed after each test

function testNormalConstructor(event) %#ok<DEFNU>
% Unit test for eventData normal constructor
fprintf('\nUnit tests for viscore.eventData valid constructor\n');

fprintf('It should construct a valid event set from set of types and start times\n');
ed1 = viscore.eventData(event);
assertTrue(isvalid(ed1));
fprintf('The start times be greater than or equal to 0\n');
assertTrue(sum(ed1.getStartTimes() < 0) == 0);
fprintf('The end times be greater than 0\n');
assertTrue(sum(ed1.getEndTimes() <= 0) == 0);
fprintf('The block time should be correct\n');


function testBadConstructor(event) %#ok<INUSD,DEFNU>
% Unit test for viscore.eventData bad constructor
fprintf('\nUnit tests for viscore.eventData invalid constructor parameters\n');

fprintf('It should throw an exception when no parameters are passed\n');
f = @() viscore.eventData();
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should throw an exception when a non structure event parameter is passed\n');
f = @() viscore.eventData(3);
assertAltExceptionThrown(f, {'MATLAB:InputParser:ArgumentFailedValidation'});

function testUniqueTypes(event) %#ok<DEFNU>
% Unit test for viscore.eventData handling unique event types
fprintf('\nUnit tests for viscore.eventData handling of unique event types\n');

fprintf('It should return the correct unique event types:\n');
ed1 = viscore.eventData(event);
assertTrue(isvalid(ed1));
uTypes = ed1.getUniqueTypes();
originalUnique = unique({event.type});

assertEqual(length(uTypes), length(originalUnique));
for k = 1:length(uTypes)
    fprintf('---It should have event type: ''%s''\n', uTypes{k});
    assertEqual(sum(strcmpi(uTypes{k}, originalUnique)), 1);
end

function testBlockList(event) %#ok<DEFNU>
% Unit test for viscore.eventData handling block list
fprintf('\nUnit tests for viscore.eventData handling of block list\n');

fprintf('It should return a blocklist of correct size:\n');
blockTime = 1000/128;
ed1 = viscore.eventData(event, 'BlockTime', blockTime);
assertTrue(isvalid(ed1));
sTimes = ed1.getStartTimes();
fprintf('It should have the right number of blocks\n');
assertEqual(ed1.getNumberBlocks(), 31);
bList = ed1.getBlockList();
assertEqual(length(bList), ed1.getNumberBlocks());
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
    assertVectorsAlmostEqual(indices, ed1.getBlocks(k, k));
end

function testGetStartTimes(event) %#ok<DEFNU>
% Unit test for viscore.eventData getStartTimes
  fprintf('\nUnit tests for viscore.eventData getStartTimes\n');
  ed1 = viscore.eventData(event);
  fprintf('It should return all start times when called with 1 argument\n');
  sTimes = ed1.getStartTimes();
  assertTrue(length(sTimes) == length(event));
  fprintf('It should return the right number of start times when called with 2 arguments\n');
  sTimes = ed1.getStartTimes(1:6);
  assertTrue(length(sTimes) == 6);
  
function testGetEndTimes(event) %#ok<DEFNU>
% Unit test for viscore.eventData getEndTimes
  fprintf('\nUnit tests for viscore.eventData getEndTimes\n');
  ed1 = viscore.eventData(event);
  fprintf('It should return all end times when called with 1 argument\n');
  eTimes = ed1.getEndTimes();
  assertTrue(length(eTimes) == length(event));
  fprintf('It should return the right number of end times when called with 2 arguments\n');
  eTimes = ed1.getEndTimes(1:6);
  assertTrue(length(eTimes) == 6);
  
function testGetTypeNumbers(event) %#ok<DEFNU>
% Unit test for viscore.eventData getTypeNumbers
  fprintf('\nUnit tests for viscore.eventData getTypeNumbers\n');
  ed1 = viscore.eventData(event);
  fprintf('It should return all type numbers when called with 1 argument\n');
  tNums = ed1.getTypeNumbers();
  assertTrue(length(tNums) == length(event));
  fprintf('It should return the right number of type numbers when called with 2 arguments\n');
  tNums = ed1.getTypeNumbers(1:6);
  assertTrue(length(tNums) == 6);
  
function testGetTypes(event) %#ok<DEFNU>
% Unit test for viscore.eventData getTypes
  fprintf('\nUnit tests for viscore.eventData getTypes\n');
  ed1 = viscore.eventData(event);
  fprintf('It should return all types when called with 1 argument\n');
  types = ed1.getTypes();
  assertTrue(length(types) == length(event));
  fprintf('It should return the right number of type numbers when called with 2 arguments\n');
  types = ed1.getTypes(1:6);
  assertTrue(length(types) == 6);
  t = {event.type}';
  for k = 1:length(types)
      assertTrue(strcmpi(t{k}, types{k}));
  end
  
  function testGetEventCounts(event) %#ok<DEFNU>
% Unit test for viscore.eventData getEventCounts
  fprintf('\nUnit tests for viscore.eventData getEventCounts\n');
  ed1 = viscore.eventData(event, 'BlockTime', 1000/128);
  fprintf('It should return an event count array of the correct size\n');
  endTimes = ed1.getEndTimes();
  numBlocks = ceil(max(endTimes)/ed1.getBlockTime());
  
  counts = ed1.getEventCounts(1, numBlocks);
  assertEqual(size(counts, 1), length(ed1.getUniqueTypes()));
  assertEqual(size(counts, 2), numBlocks);

  function testGetEventStructure(event) %#ok<DEFNU>
  % Unit test for viscore.eventData getEventStructure
  load('EEGData.mat');  %
  eventNew = viscore.eventData.getEventStructure(EEG);
  assertTrue(isequal(eventNew, event));
  
  function testEpochTimes(event) %#ok<INUSD,DEFNU>
  % Unit test for viscore.eventData getEventStructure
  load('EEGEpoch.mat');  %
  [startTimes, timeScale] = viscore.blockedData.getEpochTimes(EEGEpoch);
  assertEqual(length(startTimes), size(EEGEpoch.data, 3));
  assertEqual(length(timeScale), size(EEGEpoch.data, 2));
          
  function testArtifactData(event) %#ok<DEFNU>
% Unit test for viscore.eventData getEventCounts 
  load('ArtifactEvents.mat');
  ev = viscore.eventData(event, 'BlockTime', 1000/256);
  assertEqual(length(event), length(ev.getEndTimes()));
  
  function testEpochData(event) %#ok<DEFNU>
  % Unit test for viscore.eventData getEventCounts 
  load('EEGEpoch.mat');
  bTime  = size(EEGEpoch.data, 2)./EEGEpoch.srate;
  startTimes = viscore.blockedData.getEpochTimes(EEGEpoch);
  ev = viscore.eventData(event, 'BlockTime', bTime, ...
      'BlockStartTimes', startTimes);
  