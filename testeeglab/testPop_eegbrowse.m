function test_suite = testPop_eegbrowse %#ok<STOUT>
% Unit tests for pop_eegbrowse
initTestSuite;

function testNormalConstructor %#ok<DEFNU>
% Unit test for pop_eegbrowse constructor
fprintf('\nUnit tests for pop_eegbrowse valid constructor\n');

fprintf('It should open a browser and an eeglab if not already open\n');

eeglab('redraw');
eeglabfig = gcf;

p = which('eeglab.m');
a = strfind(p, 'eeglab.m');
p = [p(1:a-2) filesep 'sample_data'];
dfile = 'eeglab_data.set';
EEG = pop_loadset('filename', dfile, 'filepath', p);
pop_eegbrowse();
delete(eeglabfig);


function testInvalidConstructor %#ok<DEFNU>
% Unit test for pop_eegbrowse bad constructor
fprintf('\nUnit tests for pop_eegbrowse invalid constructor parameters\n');

fprintf('It should throw an exception called with two parameters\n');
p = which('eeglab.m');
a = strfind(p, 'eeglab.m');
p = [p(1:a-2) filesep 'sample_data'];
dfile = 'eeglab_data.set';
EEG = pop_loadset('filename', dfile, 'filepath', p);
f = @()pop_eegbrowse(EEG, false);
assertExceptionThrown(f, 'MATLAB:TooManyInputs')

