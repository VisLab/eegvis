function test_suite = testPop_eegbrowse %#ok<STOUT>
% Unit tests for pop_eegbrowse
initTestSuite;

function values = setup %#ok<DEFNU>
p = which('eeglab.m');
a = strfind(p, 'eeglab.m');
values.p = [p(1:a-2) filesep 'sample_data'];
values.dfile = 'eeglab_data.set';
values.deleteFigures = true;

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testNormalConstructor(values) %#ok<DEFNU>
% Unit test for pop_eegbrowse constructor
fprintf('\nUnit tests for pop_eegbrowse valid constructor\n');

fprintf('It should open a browser if not already open\n');
pop_eegbrowse();
h = findobj('Parent', 0, '-and', 'Tag', 'EEGLAB:EEGBrowseFileMenu');
assertEqual(length(h), 1);
pop_eegbrowse();
h = findobj('Parent', 0, '-and', 'Tag', 'EEGLAB:EEGBrowseFileMenu');
assertEqual(length(h), 1);
if values.deleteFigures && ~isempty(h) && ishandle(h)
        delete(h);
end

function testInvalidConstructor(values) %#ok<DEFNU>
% Unit test for pop_eegbrowse bad constructor
fprintf('\nUnit tests for pop_eegbrowse invalid constructor parameters\n');

fprintf('It should throw an exception when called with two parameters\n');

EEG = pop_loadset('filename', values.dfile, 'filepath', values.p);
f = @()pop_eegbrowse(EEG, false);
assertExceptionThrown(f, 'MATLAB:TooManyInputs')

