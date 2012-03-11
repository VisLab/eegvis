function test_suite = testPop_eegvis %#ok<STOUT>
% Unit tests for pop_eegvis
initTestSuite;

function  testNormalConstructor %#ok<DEFNU>
% Unit test for pop_eegvis constructor
fprintf('\nUnit tests for pop_eegvis valid constructor\n');

fprintf('It creates a valid visualization when passed an EEG structure\n');

eeglab('redraw');

p = which('eeglab.m');
a = strfind(p, 'eeglab.m');
p = [p(1:a-2) filesep 'sample_data'];
dfile = 'eeglab_data.set';
EEG = pop_loadset('filename', dfile, 'filepath', p);
EEGOUT = pop_eegvis(EEG);
assertEqual(EEG, EEGOUT);



