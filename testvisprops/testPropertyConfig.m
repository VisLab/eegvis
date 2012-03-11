function test_suite = testPropertyConfig %#ok<STOUT>
% Unit tests for visprops.PropertyConfiguration
initTestSuite;

function testNormalConstructor %#ok<DEFNU>
% Unit test for visprops.propertyConfig valid constructor
fprintf('\nUnit tests for visprops.propertyConfig invalid constructor\n');

fprintf('It should create a GUI when passed a selector and a title\n');
title = 'test figure';
mtc = propertyTestClass();
bfc = visprops.propertyConfig(mtc.PropSelect, title); 
drawnow

fprintf('It should create a GUI when categories are set\n');
title = 'Testing categories';
theName = 'propertyTestClass|A name';
settings = propertyTestClass.getDefaultProperties();
assertEqual(length(settings), 11);
mySelector = viscore.dataSelector('visprops.propertyConfig');
settings(1).Category = [settings(1).Category ':' settings(1).DisplayName];
theProps = viscore.managedObj(theName, settings);
mySelector.putObject(theName, theProps);
bfc1 = visprops.propertyConfig(mySelector, title);  
drawnow

fprintf('It should create a GUI when the selector of a configurable object is passed in the constructor\n');
title = 'Testing configurableOb';
ctc = configurableTestClass();
mySelector = ctc.PropSelect;
bfc2 = visprops.propertyConfig(mySelector, title);  
drawnow

fprintf('It should create a GUI when the selector of a configurable object has a category modifier\n');
title = 'Testing configurableOb with category modifier';
ctc = configurableTestClass();
configObj = ctc.getConfigObj();
configObj.CategoryModifier = 'my key';
mySelector = ctc.PropSelect;
bfc3 = visprops.propertyConfig(mySelector, title);  
drawnow
delete(bfc);
delete(bfc1);
delete(bfc2);
delete(bfc3);


