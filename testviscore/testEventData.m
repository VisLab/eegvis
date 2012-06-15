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
assertElementsAlmostEqual(ed1.getBlockTime(), 1);
% fprintf('The end times should be greater than the start times\n')
% assertVectorsAlmostEqual(startTimes + 1, ed1.getEndTimes());
% fprintf('The default block size should be 1\n');
% assertElementsAlmostEqual(ed1.getBlockSize(), 1);
% fprintf('The default sampling rate should be 1Hz\n');
% assertElementsAlmostEqual(ed1.getSampleRate(), 1);
% fprintf('The number of blocks should be correct\n');
% assertEqual(ed1.getNumberBlocks(), 30307);

% 
% endTimes = startTimes + 2;
% ed2 = viscore.eventData(types, startTimes, endTimes);
% fprintf('When event end times are passed, the object end times should agree\n');
% assertTrue(isvalid(ed2));
% assertVectorsAlmostEqual(startTimes, ed2.getStartTimes());
% assertVectorsAlmostEqual(endTimes, ed2.getEndTimes());


% fprintf('When the sampling rate is passed and block size are passed, the object sampling rate should agree\n');
% startTimes = startTimes./EEG.srate;
% ed3 = viscore.eventData(types, startTimes, 'SampleRate', EEG.srate, ...
%                          'BlockSize', 1000);
% assertTrue(isvalid(ed3));
% fprintf('The sampling rate should be correct\n');
% assertElementsAlmostEqual(EEG.srate, ed3.getSampleRate());
% fprintf('The number of blocks should be correct\n');
% assertEqual(ed3.getNumberBlocks(), 31);
% fprintf('The blocksize should be correct\n');
% assertElementsAlmostEqual(1000, ed3.getBlockSize());

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
    indices = find(bTimes(k) <= sTimes & sTimes < bTimes(k) + blockTime)';
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

  function testArtifactData(event) %#ok<DEFNU>
% Unit test for viscore.eventData getEventCounts 
  load('ArtifactEvents.mat');
  ev = viscore.eventData(event, 'BlockTime', 1000/256);
  
% function testGetEventSlice %#ok<DEFNU>
% % Unit test for viscore.eventData slice
% fprintf('\nUnit tests for viscore.eventData handling of block list\n');
% 
% % load('EEGData.mat');  %
% % tEvents = EEG.event;
% % types = {tEvents.type}';
% % startTimes = (1:10:length(types))';
% % endTimes = startTimes + 5;
% % blockSize = 1000;
% % ed1 = viscore.eventData(types, startTimes, 'EndTimes', endTimes, ...
% %         'SampleRate', EEG.srate, 'BlockSize', blockSize);
% % assertTrue(isvalid(ed1));
% % ds = viscore.dataSlice('Slices', {':', ':', '3'});
% % [selected, limits] = ed1.getEventSlice(ds);
