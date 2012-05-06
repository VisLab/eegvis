%% viscore.blockedData
% Manages a data array for visualization

%% Syntax
%     viscore.blockedData(data, dataID)
%     viscore.blockedData(data, dataID, 'key1', 'value1', ...)
%     obj = viscore.blockedData(...)
%
%% Description
%
% |viscore.blockedData(data, dataID)| creates a data object for the
% visualization. The |data| parameter is an array, and the |dataID| is
% a string identifying the data. This ID is used as part of visualization
% titles. 
%
% Blocked data objects can be reshaped or reblocked along a specified 
% dimension called the |BlockDim|. A summary function such as standard
% deviation or kurtosis is applied along this dimension to provide a
% summary of the function.
%
%
% |viscore.blockedData(data, dataID, 'key1', 'value1', ...)| specifies 
% optional name/value parameter pairs:
%
% <html>
% <table>
% <thead><tr><td>Name</td><td>Value</td></tr></thead>
% <tr><td><tt>'SampleRate'</tt></td>
%      <td>sampling rate in Hz for data (defaults to 1)</td></tr>
% <tr><td><tt>'BlockSize'</tt></td>
%      <td>window size for reblocking the data</td></tr>
% <tr><td><tt>'BlockDim'</tt></td>
%      <td>array dimension for reblocking (defaults to 2)</td></tr>
% <tr><td><tt>'ElementLocations'</tt></td>
%      <td>structure of element (channel) locations</td></tr>
% <tr><td><tt>'Epoched'</tt></td>
%      <td>if true, data is epoched and can't be reblocked</td></tr>
% <tr><td><tt>'EpochStartTimes'</tt></td>
%      <td>if data is epoched, times in seconds of epoch beginnings</td></tr>
% <tr><td><tt>'EpochTimes'</tt></td>
%      <td>if data is epoched, times corresponding to epoch samples</td></tr>
% <tr><td><tt>'Events'</tt></td>
%      <td>eventData object if this data has events</td></tr> 
% <tr><td><tt>'PadValue'</tt></td>
%      <td>numeric value to pad uneven blocks (defaults to 0)</td></tr>
% </table>
% </html>
%
%
% |obj = viscore.blockedData(...)| returns a handle to the newly created
% object.
%

%% Example 1
% Create a blocked data object for a random array
   data = random('normal', 0, 1, [32, 1000, 20]);
   bd = viscore.blockedData(data, 'Normal(0, 1)');

%% Example 2
% Reblock a data object in blocks of 500 frames
   data = random('normal', 0, 1, [32, 1000, 20]);
   bd = viscore.blockedData(data, 'Normal(0, 1)');
   bd.reblock(500);
   [rows, cols, blks] = bd.getDataSize();
   
%% Notes
%
% * Data that is initially epoched cannot be reblocked.
% * An empty sampling rate implies that the data is not sampled at a fixed 
%  sampling rate. This feature will be supported in the future in a child class.
% * This data object has a version ID that changes each time the data
% is modified. The version ID enables functions to know whether
% to recompute their values.
% * The BlockDim is set in the constructor and later changes do not affect
%    the blocking.
%
%% Class documentation
% Execute the following in the MATLAB command window to view the class 
% documentation for |viscore.blockedData|:
%
%    doc viscore.blockedData
%
%% See also
% <dataSlice_help.html |viscore.dataSlice|> and
% <dualView_help.html |visviews.dualView|>
%
%% 
% Copyright 2011 Kay A. Robbins, University of Texas at San Antonio