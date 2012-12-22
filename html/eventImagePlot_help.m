%% visviews.eventImagePlot
% Display event type vs block or clump as an image
%
%% Syntax
%     visviews.eventImagePlot(parent, manager, key)
%     obj = visviews.eventImagePlot(parent, manager, key)
%
%% Description
% |visviews.eventImagePlot(parent, manager, key)| displays the 
% counts of events as an image (event × clump), 
% with pixel color representing the number of events. 
% The y-axis corresponds to event types and 
% the x-axis corresponds to time (e.g., window or clump number).
%
% The parent is a graphics handle to the container for this plot. The
% manager is an |viscore.dataManager| object containing managed objects
% for the configurable properties of this object, and key is a string
% identifying this object in the property manager GUI.
% 
%
% |obj = visviews.eventImagePlot(parent, manager, key)| returns a handle to
% the newly created object.
%
% |visviews.eventImagePlot| is configurable, resizable, clickable, and cursor explorable.
%
%% Configurable properties
% The |visviews.eventImagePlot| has eight configurable parameters: 
%
% |Background| specifies the color of the pixels that are below the
%   lowest threshold level.
%
% |CertaintyThreshold| is a number between 0 and 1 inclusively, specifying a
% certainty threshold for displaying events. Events whose certainty is
% below the threshold will be ignored in the display. This feature is
% useful for displaying computed events such as classification labels
% because the user can choose to display only those events that are
% likely to have happened. By defaults, events have a certainty value
% of 1, meaning that there is not doubt that they occurred, while a
% certainty value of 0 means that there is no certainty that they
% occurred. Set the certainty threshold to 0 to include all events,
% regardless of certainty. 
%
% |ClumpSize| specifies the number of consecutive windows or epochs 
% represented by each pixel column. When the |ClumpSize| is one (the default), 
% each pixel column represents its own window. If |ClumpSize| is greater than 
% one, each pixel column represents several consecutive blocks. 
% Users can trade-off clump size versus block size to see different 
% representations of the data.
%
% |ColorLevels| is a vector of threshold counts. Event counts below the
% lowest level are displayed in the background color, while events
% above the highest level are displayed at the highest color map color.
% Intermediate counts are displayed by color k if:
% |ColorLevels(k) <= count < ColorLevels(k + 1)|
%
% |Colormap| is the name of one of the built in MATLAB colormaps. The
% color map used for the display is the background color, appended to
% map(n), where n is the number of levels specified by ColorLevels.
%
% |CombineMethod| specifies how to combine multiple blocks into a 
% single block to determine an overall block value. The value can be be
% |'max'|  (default), |'min'|, |'mean'|, |'median'| or |'sum'|. Detail plots use this 
% block value to determine slice colors. 
%
% For example, with 32 channels, a clump size of 3, a block size of 
% 1000 samples, the |eventImagePlot| delivers a slice representing 
% the events in 3 blocks. The detail plots use image plot's 
% |CombineMethod| to combine the blocks to get appropriate 
% colors for the slice.
%
% |IsClickable| is a boolean specifying whether this plot should respond to
% user mouse clicks when incorporated into a linkable figure. The
% default value is |true|.
%
% |LinkDetails| is a boolean specifying whether clicking this plot in a
% linkable figure should cause detail views to display the clicked
% slice. The default value is |true|.
%

%% Example 1: 
% Create an event image plot for the sample data

   % Read some eeg data and create a data object
   load('EEG.mat');  % Saved EEGLAB EEG data
   events = viscore.blockedEvents.getEEGTimes(EEG); % Extract the events
   testVD = viscore.blockedData(EEG.data, 'Sample EEG data', ...
         'SampleRate', EEG.srate, 'Events', events);

   % Create a kurtosis block function object
   funs = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
              visfuncs.functionObj.getDefaultFunctions());

   % Plot the block function
   sfig = figure('Name', 'Kurtosis for EEG data');
   ep = visviews.eventImagePlot(sfig, [], []);
   ep.plot(testVD, funs{1}, []);
   gaps = ep.getGaps();
   ep.reposition(gaps);

%% Example 2
% Create a block image plot of kurtosis of clumps of 3 windows 

    % Read in some EEG data
    load('EEG.mat');  % Saved EEGLAB EEG data
    events = viscore.blockedEvents.getEEGTimes(EEG);
    testVD = viscore.blockedData(EEG.data, 'Sample EEG data', ...
         'SampleRate', EEG.srate, 'Events', events);
    funs = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
              visfuncs.functionObj.getDefaultFunctions());
    
    % Plot the block function, adjusting the margins
    sfig = figure('Name', 'Kurtosis for 32 exponentially distributed channels');
    ep = visviews.eventImagePlot(sfig, [], []);
    ep.ClumpSize = 3;
    ep.plot(testVD, funs{1}, []);
    gaps = ep.getGaps();
    ep.reposition(gaps);
    

%% Notes
%
% * If the |manager| parameter is empty, the class defaults are used to
% initialize.
% * If the |key| parameter is empty, the class name is used to identify in
% GUI configuration.
% * Choose a neutral background color to emphasize important blocks.
%
%% Class documentation
% Execute the following in the MATLAB command window to view the class 
% documentation for |visviews.eventImagePlot|:
%
%    doc visviews.eventImagePlot
%
%% See also
% <axesPanel_help.html |visviews.axesPanel|>,
% <blockImagePlot_help.html |visviews.blockImagePlot|>, 
% <clickable_help.html |visviews.clickable|>, 
% <configurable_help.html |visprops.configurable|>,
% <cursorExplorable_help.html |visviews.cursorExplorable|>, 
% <resizable_help.html |visviews.resizable|> 
%

%% 
% Copyright 2012 Kay A. Robbins, University of Texas at San Antonio