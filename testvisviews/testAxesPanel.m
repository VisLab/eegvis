function test_suite = testAxesPanel %#ok<STOUT>
initTestSuite;

function testNormalConstructor %#ok<DEFNU>
% unit test for axesPanel constructor
fprintf('\nUnit tests for visviews.axesPanel valid constructor\n');

fprintf('It should create a valid object when constructor called with figure argument\n');
sfig = figure('Name', 'AxesPanel normal constructor');
ap = visviews.axesPanel(sfig);
assertTrue(isvalid(ap));
drawnow
delete(sfig);


function testGetPixelHitPosition %#ok<DEFNU>
% Unit test for visviews.axesPanel getPixelHitPosition 
fprintf('\nUnit tests for the visviews.axesPanel getPixelHitPosition\n');
fprintf('It should give the correct panel width and height when getPixelHitPosition is called\n')
sfig = figure('Name', 'AxesPanel height and width with getPixelHitPosition');
ap = visviews.axesPanel(sfig);
ap.reposition([10, 20, 30, 40]);
assertTrue(isvalid(ap));
drawnow
hPosition = ap.getPixelHitPosition();
set(ap.MainAxes, 'Units', 'pixels',  'ActivePositionProperty', 'Position');
p = get(ap.MainAxes, 'Position');
assertVectorsAlmostEqual(hPosition(3:4), p(3:4)); % Corner Off by 2 pixels? ......
delete(sfig);

function testGetDataCoordinates %#ok<DEFNU>
% Unit test for visviews.axesPanel getDataCoordinates
fprintf('\nUnit tests for the visviews.axesPanel getDataCoordinates method\n');
fprintf('It should give the right x and y coordinates for point inside panel\n');
sfig = figure('Name', 'AxesPanel getDataCoordinates');
ap = visviews.axesPanel(sfig);
ap.reposition([10, 30, 30, 40]);
assertTrue(isvalid(ap));
drawnow
p = ap.getPixelHitPosition();  
set(ap.MainAxes, 'XLim', [0, 10], 'YLim', [3, 5]);
[x, y, Insidex, Insidey] = ...
    ap.getDataCoordinates( [p(1) + p(3)/2, p(2) + p(4)/2]);
assertTrue(Insidex);
assertTrue(Insidey);
assertElementsAlmostEqual(x, 5);
assertElementsAlmostEqual(y, 4);
fprintf('It should correctly indicate pixel positions outside axes\n');
[x, y, Insidex, Insidey] = ...
    ap.getDataCoordinates( [p(1) - 2, p(2) - 1]);
assertFalse(Insidex);
assertFalse(Insidey);
assertTrue(x < 0 || y < 0)
delete(sfig)

function testGetGaps %#ok<DEFNU>
% Unit test for visviews.axesPanel getGaps method
fprintf('\nUnit tests for the viewviews.axesPanel getGaps method\n');
fprintf('It should return the correct gaps after repositioning\n');
sfig = figure('Name', 'AxesPanel testing repositioning after resetting gaps');
ap = visviews.axesPanel(sfig);
gaps = getGaps(ap);
assertEqual(length(gaps), 4);

ap.reposition(gaps);
newGaps = getGaps(ap);
assertVectorsAlmostEqual(newGaps , gaps);
ap.YString = 'Apples';
ap.XString = 'Bananas';
newGaps1 = getGaps(ap);
ap.reposition(newGaps1);
newGaps2 = getGaps(ap);
assertVectorsAlmostEqual(newGaps1, newGaps2);

fprintf('It should return the correct gaps when there is no y label\n');
sfig1 = figure('Name', 'AxesPanel testing repositioning with no y label');
ap = visviews.axesPanel(sfig1);
gaps = getGaps(ap);
assertEqual(length(gaps), 4);

ap.reposition(gaps);
newGaps = getGaps(ap);
assertVectorsAlmostEqual(newGaps , gaps);
ap.YString = '';
ap.XString = 'Bananas';
newGaps1 = getGaps(ap);
ap.reposition(newGaps1);
newGaps2 = getGaps(ap);
assertVectorsAlmostEqual(newGaps1, newGaps2);
delete(sfig)
delete(sfig1)