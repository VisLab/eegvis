function test_suite = testClickable %#ok<STOUT>
% Unit tests for visviews.clickable
initTestSuite;

function testConstuctor %#ok<DEFNU>
% Unit test for visviews.clickable normal constructor
fprintf('\nUnit tests for visviews.clickable normal constructor\n');

fprintf('It should construct a valid object for a constructor with no arguments\n')
cl = visviews.clickable();
assertTrue(isobject(cl));
sources = cl.getSourceMapKeys();
fprintf('It should have no sources when constructed with no arguments\n');
assertTrue(isempty(sources));
fprintf('It should have LinkDetails true when constructed with no arguments\n');
assertTrue(cl.LinkDetails);
fprintf('It should have IsClickable true when constructed with no arguments\n');
assertTrue(cl.IsClickable);
fprintf('It should have empty maps when constructed with no arguments\n');
keys = cl.getSourceMapKeys();
assertTrue(isempty(keys));
keys = cl.getUnmappedKeys();
assertTrue(isempty(keys));

function testInvalidConstructor %#ok<DEFNU>
% Unit test for visviews.clickable invalid constructor
fprintf('\nUnit tests for visviews.clickable invalid constructor parameters\n');

fprintf('It should throw an exception when an empty array passed to constructor\n');
f = @() visviews.clickable([]);
assertExceptionThrown(f, 'MATLAB:maxrhs');


function testClear %#ok<DEFNU>
% Unit test for visviews.clickable invalid constructor
fprintf('\nUnit tests for visviews.clickable clear method\n');

fprintf('It should clear the source map\n')
obj = visviews.clickable();
obj.clearClickable();
keys = obj.getSourceMapKeys();
assertTrue(isempty(keys));

function testPutUnmapped %#ok<DEFNU>
fprintf('\nUnit tests for visviews.clickable putUnmapped\n');

fprintf('It should allow clickable objects to be unmapped\n');
obj = visviews.clickable();
x1 = visviews.clickable();
x2 = visviews.clickable();
x3 = visviews.clickable();
obj.putUnmapped('apples', x1);
obj.putUnmapped('grapes', x2);
obj.putUnmapped('apples', x3);
m = obj.getUnmapped('apples');
assertTrue(~isempty(m));
assertTrue(isa(m, 'cell'));
assertEqual(length(m), 2);
assertEqual(m{1}, x1);
assertEqual(m{2}, x3);
m1 = obj.getUnmapped('grapes');
assertTrue(~isempty(m1));
assertTrue(isa(m1, 'cell'));
assertEqual(length(m1), 1);
assertEqual(m1{1}, x2);

