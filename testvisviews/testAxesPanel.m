function test_suite = testAxesPanel %#ok<STOUT>
initTestSuite;

function values = setup %#ok<DEFNU>
values.deleteFigures = true;

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testNormalConstructor(values) %#ok<DEFNU>
% unit test for axesPanel constructor
fprintf('\nUnit tests for visviews.axesPanel valid constructor\n');

fprintf('It should create a valid object when constructor called with figure argument\n');
fig1 = figure('Name', 'AxesPanel normal constructor');
ap1 = visviews.axesPanel(fig1);
assertTrue(isvalid(ap1));

drawnow
if values.deleteFigures
  delete(fig1);
end

function testGetPixelHitPosition(values) %#ok<DEFNU>
% Unit test for visviews.axesPanel getPixelHitPosition 
fprintf('\nUnit tests for the visviews.axesPanel getPixelHitPosition\n');
fprintf('It should give the correct panel width and height when getPixelHitPosition is called\n')
fig1 = figure('Name', 'AxesPanel height and width with getPixelHitPosition');
ap1 = visviews.axesPanel(fig1);
ap1.reposition([10, 20, 30, 40]);
assertTrue(isvalid(ap1));
drawnow
hPosition = ap1.getPixelHitPosition();
set(ap1.MainAxes, 'Units', 'pixels',  'ActivePositionProperty', 'Position');
p = get(ap1.MainAxes, 'Position');
assertVectorsAlmostEqual(hPosition(3:4), p(3:4)); % Corner Off by 2 pixels? ......

drawnow
if values.deleteFigures
  delete(fig1);
end

function testGetDataCoordinates(values) %#ok<DEFNU>
% Unit test for visviews.axesPanel getDataCoordinates
fprintf('\nUnit tests for the visviews.axesPanel getDataCoordinates method\n');
fprintf('It should give the right x and y coordinates for point inside panel\n');
fig1 = figure('Name', 'AxesPanel getDataCoordinates');
ap1 = visviews.axesPanel(fig1);
ap1.reposition([10, 30, 30, 40]);
assertTrue(isvalid(ap1));
p = ap1.getPixelHitPosition();  
set(ap1.MainAxes, 'XLim', [0, 10], 'YLim', [3, 5]);
[x, y, Insidex, Insidey] = ...
    ap1.getDataCoordinates( [p(1) + p(3)/2, p(2) + p(4)/2]);
assertTrue(Insidex);
assertTrue(Insidey);
assertElementsAlmostEqual(x, 5);
assertElementsAlmostEqual(y, 4);
fprintf('It should correctly indicate pixel positions outside axes\n');
[x, y, Insidex, Insidey] = ...
    ap1.getDataCoordinates( [p(1) - 2, p(2) - 1]);
assertFalse(Insidex);
assertFalse(Insidey);
assertTrue(x < 0 || y < 0)

drawnow
if values.deleteFigures
  delete(fig1);
end

function testGetGaps(values) %#ok<DEFNU>
% Unit test for visviews.axesPanel getGaps method
fprintf('\nUnit tests for the viewviews.axesPanel getGaps method\n');
fprintf('It should return the correct gaps after repositioning\n');
fig1 = figure('Name', 'AxesPanel testing repositioning after resetting gaps');
ap1 = visviews.axesPanel(fig1);
gaps = getGaps(ap1);
assertEqual(length(gaps), 4);
ap1.reposition(gaps);
newGaps = getGaps(ap1);
assertVectorsAlmostEqual(newGaps , gaps);
ap1.YString = 'Apples';
ap1.XString = 'Bananas';
newGaps1 = getGaps(ap1);
ap1.reposition(newGaps1);
newGaps2 = getGaps(ap1);
assertVectorsAlmostEqual(newGaps1, newGaps2);

fprintf('It should return the correct gaps when there is no y label\n');
fig2 = figure('Name', 'AxesPanel testing repositioning with no y label');
ap2 = visviews.axesPanel(fig2);
gaps = getGaps(ap2);
assertEqual(length(gaps), 4);
ap2.reposition(gaps);
newGaps = getGaps(ap2);
assertVectorsAlmostEqual(newGaps , gaps);
ap2.YString = '';
ap2.XString = 'Bananas';
newGaps1 = getGaps(ap2);
ap2.reposition(newGaps1);
newGaps2 = getGaps(ap2);
assertVectorsAlmostEqual(newGaps1, newGaps2);

drawnow
if values.deleteFigures
  delete(fig1);
  delete(fig2);
end