%% visviews.eventStackedPlot
% Display stacked view of individual events
%
%% Syntax
%     visviews.eventStackedPlot(parent, manager, key)
%     obj = visviews.eventStackedPlot(parent, manager, key)
%
%% Description
% |obj = visviews.eventStackedPlot(parent, manager, key)| shows each 
% member of a slice of events offset vertically, with the lowest numbered 
% member at the top and the highest number slice at the bottom. 
% The stacked event plot shows individual events as a function of time.
% When a single time window, or group of time windows from a block-type
% plot is the source (slice along dimension 3), the windows are
% displayed consecutively and the event types are stacked vertically.
% When multiple time windows from an element-type plot (slice along
% dimension 1) then windows are stacked vertically and all event types
% are collapsed.  Multiple epoch displays also stack windows
% vertically.
%
% The |parent| is a graphics handle to the container for this plot. The
% |manager| is an |viscore.dataManager| object containing managed objects
% for the configurable properties of this object, and |key| is a string
% identifying this object in the property manager GUI.
% 
% 
% |obj = visviews.eventStackedPlot(parent, manager, key)| returns a handle to
% the newly created object.
%
% |visviews.eventStackedPlot| is configurable, resizable, and cursor explorable.
%

%% Configurable properties
% The |visviews.eventStackedPlot| has five configurable parameters: 
%
% |CertaintyThreshold| is a number between 0 and 1 inclusively, specifying a
% certainty threshold for displaying events. Events whose certainty is
% below the threshold will be ignored in the display. This feature is
% useful for displaying computed events such as classification labels
% because the user can choose to display only those events that are
% likely to have happened. By defaults, events have a certainty value
% of 1, meaning that there is not doubt that they occurred, while a
% certainty value of 0 means that there is no certainty that they
% occurred. Set the certainty threshold to 1 to include all events,
% regardless of certainty. 
%
% |ColorCertain| is a 3-element row vector specifying the edge color 
% for markers designating events whose certainty value is above
% the certainty treshold.
%
% |ColorUncertain| is a 3-element row vector specifying the edge color 
% for markers designating events whose certainty values is less
% than or equal to the certainty threshold.
%
% |ColorSelected| is a 3-element row vector specifying the face color 
%     for a marker designating an event that has been selected.
%
% |ColorUnselected| is a 3-element row vector specifying the face color 
%     for markers designating events not currently selected.
%
% |CombineMethod| specifies how to combine multiple blocks 
%               when displaying a clumped slice.  The value can be 
%               |'max'|, |'min'|, |'mean'|, |'median'|, or 
%               |'none'| (the default). 
%
%% Example  
% Create a stacked event plot for EEG data
  % Load the sample EEG structure
  load('EEGData.mat');
  
  events = viscore.eventData.getEEGTimes(EEG);
  testVD = viscore.blockedData(data, 'Rand1', 'SampleRate', EEG.srate, ...
            'Events', events);

  % Create a block function and a slice
  defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
             visfuncs.functionObj.getDefaultFunctions());
  thisFunc = defaults{1};
  thisSlice = viscore.dataSlice('Slices', {':', ':', '1'}, ...
              'DimNames', {'Channel', 'Sample', 'Window'});

  % Create the figure and plot the data, adjusting the margins
  sfig  = figure('Name', 'Stacked event plot for EEG');
  sp = visviews.eventStackedPlot(sfig, [], []);
  sp.plot(testVD, thisFunc, thisSlice);
  gaps = sp.getGaps();
  sp.reposition(gaps);

%% Notes
%
% * If |manager| is empty, the class defaults are used to initialize
% * If |key| is empty, the class name is used to identify in GUI configuration
% *  Mean removal is done before trimming
%
%% Class documentation
% Execute the following in the MATLAB command window to view the class 
% documentation for |visviews.eventStackedPlot|:
%
%    doc visviews.eventStackedPlot
%

%% See also
% <axesPanel_help.html |visviews.axesPanel|>,
% <clickable_help.html |visviews.clickable|>, 
% <configurable_help.html |visprops.configurable|>,
% <cursorExplorable_help.html |visviews.cursorExplorable|>, 
% <eventImagePlot_help.html |visviews.eventImagePlot|>,
% <resizable_help.html |visviews.resizable|>, and
% <stackedSignalPlot_help.html |visviews.stackedSignalPlot|>
%

%% 
% Copyright 2012 Kay A. Robbins, University of Texas at San Antonio