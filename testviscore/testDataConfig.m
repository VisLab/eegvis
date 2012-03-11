function test_suite = testDataConfig %#ok<STOUT>
% Unit tests for viscore.dataConfig
initTestSuite;

function testConstructor %#ok<DEFNU>
% Unit test for viscore.dataConfig constructor getInstance
fprintf('\nUnit tests for viscore.dataConfig valid constructor\n');

fprintf('It should create a valid object when a selector and title are passed to constructor\n');
title = 'test figure';
sel = viscore.dataSelector('viscore.dataConfig');
bfc = viscore.dataConfig(sel, title); 
drawnow
assertTrue(isvalid(bfc));
delete(bfc);

function testConfigFromVariables %#ok<DEFNU>
% Unit test for viscore.dataConfig load and save
fprintf('\nUnit tests for viscore.dataConfig getting and setting configuration\n');
fprintf('It should get and set the configuration\n');
title = 'test get/set figure';
sel = viscore.dataSelector('viscore.dataConfig');
bfc = dataConfigTestClass(sel, title); 
drawnow
assertTrue(isvalid(bfc));
objList = bfc.getCurrentManager().getObjects();
fprintf('It should make a configuration structure for each managed object\n');
for k = 1:length(objList)
    s = objList{k}.getConfiguration();
    assertTrue(isa(s, 'struct'));
end
delete(bfc);