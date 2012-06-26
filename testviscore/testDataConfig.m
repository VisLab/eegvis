function test_suite = testDataConfig %#ok<STOUT>
% Unit tests for viscore.dataConfig
initTestSuite;

function values = setup %#ok<DEFNU>
values.sel = viscore.dataSelector('viscore.dataConfig');
values.deleteFigures = true;

function teardown(values) %#ok<DEFNU>
% Function executed after each test


function testConstructor(values) %#ok<DEFNU>
% Unit test for viscore.dataConfig constructor getInstance
fprintf('\nUnit tests for viscore.dataConfig valid constructor\n');

fprintf('It should create a valid object when a selector and title are passed to constructor\n');
bfc = viscore.dataConfig(values.sel, 'test of title'); 
drawnow
assertTrue(isvalid(bfc));

if values.deleteFigures
    delete(bfc);
end

function testConfigFromVariables(values) %#ok<DEFNU>
% Unit test for viscore.dataConfig load and save
fprintf('\nUnit tests for viscore.dataConfig getting and setting configuration\n');
fprintf('It should get and set the configuration\n');
bfc = dataConfigTestClass(values.sel, 'test get/set figure'); 
drawnow
assertTrue(isvalid(bfc));
objList = bfc.getCurrentManager().getObjects();
fprintf('It should make a configuration structure for each managed object\n');
for k = 1:length(objList)
    s = objList{k}.getConfiguration();
    assertTrue(isa(s, 'struct'));
end

if values.deleteFigures
    delete(bfc);
end