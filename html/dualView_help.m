%% visviews.dualView
% Create a two level-viewer with upper panel summaries and lower panel details
%
%% Syntax
%     visviews.dualView()
%     visviews.dualView('key1', 'value1', ....)
%     obj = visviews.dualView(...)
%
%% Description
%
% |visviews.dualView()| creates a summary/detail viewer divided into two
%    levels. The top portion contains multiple summary views organized 
%    by tabs. The bottom portion contains various detail panels, which 
%    display relatively small portions of the data. A user selects detail 
%    views by clicking a summary view. The user can configure the 
%    arrangement of viewing panels and how summary and detail panels link.
%
% |visviews.dualView('name1', 'value1', ....)| specifies optional parameter
%    name/value pairs:
%
% <html>
% <table>
% <thead><tr><td>Name</td><td>Value</td></tr></thead>
% <tr><td><tt>'VisData'</tt></td>
%      <td><tt>blockedData</tt> object or a 3D array of data</td></tr>
% <tr><td><tt>'Functions'</tt></td>
%      <td><tt>dataManager</tt>, structure, or cell array of 
%          initial functions</td></tr>
% <tr><td><tt>'Plots'</tt></td>
%      <td><tt>dataManager</tt>, structure, or cell array of 
%                     initial plots</td></tr>
% <tr><td><tt>'Properties'</tt></td>
%      <td><tt>dataManager</tt>, structure, or cell array of 
%                     initial properties</td></tr>
% </table>
% </html>
%
% |visviews.dualView| is configurable, resizable, and clickable. It
% is also a container for a cursor explorer.
%
%% Configurable properties
% The |visviews.dualView| has five configurable parameters: 
%
% |BlockName| specifies base name of the windows in the block summaries
%    for non-epoched data.
%
% |BlockSize| specifies the number of frames in a block for non-epoched
%    data (e.g., |'Window'|).
%
% |ElementName| specifies the base name of an element (e.g., |'Channel'|).
%
% |EpochName| specifies the base name of the windows in block summaries
%    for epoched data.
%
% |VisName| specifies the prefix used for the name on the figure window 
%    title bar.
%
%% Example 1
% Create a viewer to show some data

   data = random('exp', 2, [32, 1000, 20]); % Create some random data
   visviews.dualView('VisData', data); % View the data

%% Example 2
% Create a viewer and then set it to show some data

   bv = visviews.dualView();                % Create an empty viewer
   data = random('exp', 2, [32, 1000, 20]);
   testData = viscore.blockedData(data, 'Random exponential 32x1000x20');
   bv.setDataSource(testData);              % Set the viewer's data
   bv.reset(true, true, true);              % Reset the view to display

%% Example 3
% Create a viewer with only one tab

   f = visviews.dualView.getDefaultFunctions();
   data = random('normal', 0, 2, [32, 1000, 20]);
   testData = viscore.blockedData(data, 'Random normal 32x1000x20');
   bv = visviews.dualView('VisData', testData, 'Functions', f(1)); 
   
%% Notes
%
% * Many summaries supported by this viewer are window or epoch oriented.
% * Some displays treat epoched data differently than non-epoched data.
% * Epoched data may not be continuous and cannot be reblocked by
%     changing the block size.
%
%% Class documentation
% Execute the following in the MATLAB command window to view the class 
% documentation for |visviews.dualView|:
%
%    doc visviews.dualView
%
%% See also
% <eegbrowse_help.html |eegbrowse|>,
% <eegplugin_eegvis_help.html |eegplugin_eegvis|>, and
% <eegvis_help.html |eegvis|>
%
%% 
% Copyright 2011 Kay A. Robbins, University of Texas at San Antonio