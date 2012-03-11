%% eegbrowse
% GUI for selecting files for visualization
%
%% Syntax
%     eegbrowse()
%     eegbrowse('key1', 'value1', ....)
%     obj = eegbrowse(...)
%
%% Description
% |eegbrowse()| opens a GUI for selecting files for visualization. 
% Currently |eegbrowse| only works for EEGLAB |.set| files, but support 
% for additional formats should be available soon. To use:
%
% * Move to a directory containing EEG files
% * Click on a file name to choose a file.  
%
%
% |eegbrowse('name1', 'value1', ...)| specifies optional parameter
%    name/value pairs:
%
% <html>
% <table>
% <thead><tr><td>Name</td><td>Value</td></tr></thead>
% <tr><td><tt>'FileName'</tt></td>
%      <td>name of an initial data file to be read in</td></tr>
% <tr><td><tt>'FilePath'</tt></td>
%      <td>path of the initial data file to be read</td></tr>
% <tr><td><tt>'Functions'</tt></td>
%      <td>manager, structure array, or cell array of initial summary functions</td></tr>
% <tr><td><tt>'Plots'</tt></td>
%      <td>manager, structure array, or cell array of visualizations to use</td></tr>
% <tr><td><tt>'Properties'</tt></td>
%      <td>manager or cell array specifying defaults for public properties</td></tr>
% <tr><td><tt>'Title'</tt></td>
%      <td>string displayed on the figure window title bar</td></tr>
% <tr><td><tt>'UseEEGLab'</tt></td>
%      <td>if true, start eeglab if necessary when data set loaded</td></tr>
% </table>
% </html>
%
%
% |obj = eegbrowse(...)| returns a handle to the created GUI.
%
%
% |eegbrowse| is configurable and resizable.
%
%% eegbrowse GUI operation
%
% <html>
% <table>
% <thead>
% <tr><td>Component</td> <td>Action</td></tr></thead>
% <tr><td><tt>Browse</tt></td> <td>Push this button to display a modal file 
%                      chooser for selecting a directory containing 
%                     EEG <tt>.set</tt> files. After the chooser displays a 
%                     list of files, click on one to visualize or
%                     load into the workspace.</td></tr>
% <tr><td><tt>Open</tt></td> <td>Push this button to load the currently 
%                     selected file into an <tt>EEG</tt> structure in the 
%                     base workspace and to update <tt>ALLEEG</tt> and <tt>ALLCOM</tt> 
%                     for EEGLAB.</td></tr>
% <tr><td><tt>Functions</tt></td> <td>Push this button to display a GUI for
%                     configuring the summary functions to use in 
%                     subsequent visualizations.  These
%                     changes do not affect the current
%                     visualization, but rather <tt>eegbrowse</tt> uses
%                     them in creating the next visualization.</td></tr>
% <tr><td><tt>Plots</tt></td> <td>Push this button to display a GUI for
%                     configuring which visualization panels to use
%                     in subsequent visualizatons. These
%                     changes do not affect the current
%                     visualization, but rather <tt>eegbrowse</tt> uses
%                     them in creating the next visualization.</td></tr>
% <tr><td><tt>Properties</tt></td> <td>Push this button to display a property
%                     manager GUI for setting the public properties
%                     of <tt>eegbrowse</tt> as well as the default public
%                     properties of the visualization panels used in
%                     subsequent visualizations.</td></tr>
% <tr><td><tt>Properties</tt></td> <td>Push this button to display a property
%                     manager GUI for setting the public properties
%                     of <tt>eegbrowse</tt> as well as the default public
%                     properties of the visualization panels used in
%                     subsequent visualizations.</td></tr>
% <tr><td><tt>Load</tt></td> <td>Push this button to display a modal
%                     file browser for loading a saved configuration
%                     into <tt>eegbrowse</tt>. The configuration 
%                     should be in the format described for
%                     <tt>Save</tt>.
%                     <p>If <tt>vars.configuration.funs</tt> is non empty,
%                     it replaces the current list of summary functions
%                     for subsequent visualizations.</p> 
%                     <p>If <tt>vars.configuration.plots</tt> is non empty,
%                     it replaces the current list of visualization
%                     panels.</p>
%                     <p>If <tt>vars.configuration.props</tt> is non empty,
%                     it replaces the current values of the configurable
%                     properties of <tt>eegbrowse</tt> as well as the
%                     default values of the configurable public properties
%                     of the visualization panels in subsequent
%                     visualizations.</p></td></tr>
% <tr><td><tt>Save</tt></td> <td>Push this button to display a modal
%                     file browser for saving an <tt>eegbrowse</tt>
%                     configuration structure <tt>vars</tt>. The fields
%                     of the <tt>vars</tt> structure are:
%                     <ul>
%                     <li><tt>vars.date</tt></li>
%                     <li><tt>vars.class</tt> (in this case
%                     <tt>eegbrowse</tt>)</li>
%                     <li><tt>vars.configuration.funcs</tt></li>
%                     <li><tt>vars.configuration.plots</tt></li>
%                     <li><tt>vars.configuration.props</tt></li>
%                     </td></tr>
% <tr><td><tt>Load workspace</tt></td> <td>Check this box to load the selected file
%                     into the base workspace and update <tt>ALLEEG</tt> and
%                     <tt>ALLCOM</tt> each time the user clicks a file name. If
%                     the checkbox is unchecked (the default), do not
%                     update the workspace when a file name is clicked.</td></tr>
% <tr><td><tt>Preview</tt></td> <td>Check this box to display a visualization when
%                     a file name is clicked. If the checkbox is unchecked,
%                     a visualization is not displayed.</td></tr>
% <tr><td><tt>New figure</tt></td> <td>Check this box to create a new figure window
%                     for each visualization. This checkbox has not effect
%                     if <tt>Preview</tt> is unchecked.</td></tr>
% </table>
% </html>
%
%% Configurable properties
% The |eegbrowse| has one configurable public property: 
%
% |title| String displayed on the figure window title bar.
%
%% Example
% Create a browser for previewing EEG files

    eegbrowse('FilePath', 'M:\NeuroErgonomicsData\Attention Shift',  ...
              'Title', 'Browsing data');
%% Notes
% 
% * |eegbrowse| can be run either as a function in MATLAB or as a
% plugin for EEGLab.
%
%% Class documentation
% Execute the following in the MATLAB command window to view the class 
% documentation for |eegbrowse|:
%
%    doc eegbrowse
%
%% See also
% <dualView_help.html |visviews.dualView|>,
% <eegplugin_eegvis_help.html |eegplugin_eegvis|>, and
% <eegvis_help.html |eegvis|>
%
%% 
% Copyright 2011 Kay A. Robbins, University of Texas at San Antonio