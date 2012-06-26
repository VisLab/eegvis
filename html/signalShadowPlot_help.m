%% visviews.shadowSignalPlot
% Display element or window signals using shadow outline
%
%% Syntax
%     visviews.shadowSignalPlot(parent, manager, key)
%     obj = visviews.shadowSignalPlot(parent, manager, key)
%
%% Description
% |obj = visviews.shadowSignalPlot(parent, manager, key)| presents a 
% compact summary of multiple signals over a fixed period. The 
% shadow signal plot shows an envelope of the signals as a gray shadow. 
% All signals fall within this shadow. The plot only displays individual 
% signals designated as outliers for some time points. The shadow 
% signal plot uses the signal z score at each time point to determine 
% outliers. By default, outliers are those signals whose amplitude 
% has a z score of at least three at some point in time. 
%
% The |parent| is a graphics handle to the container for this plot. The
% |manager| is an |viscore.dataManager| object containing managed objects
% for the configurable properties of this object, and |key| is a string
% identifying this object in the property manager GUI.
% 
% 
% |obj = visviews.shadowSignalPlot(parent, manager, key)| returns a handle to
% the newly created object.
%
% |visviews.shadowSignalPlot| is configurable, resizable, and cursor explorable.
%
% The shadow signal plot changes the labeling of the horizontal axis 
% depending on whether the display is for epoched data or not. For window 
% slices of non-epoched data, the plot uses the sampling rate to 
% calculate the actual time in seconds corresponding to the data. 
% For channel slices of non-epoched data, the plot labels the horizontal 
% axis with the duration of the slice in seconds starting from zero. 
% For window or channel slices of epoched data, the plot labels the 
% horizontal axis using the epoch times in ms of the samples within 
% the epoch. The plot always labels the horizontal axis with the window 
% number (or range of windows numbers) of the corresponding slice.
%
% Clicking one of the signals causes it to become the selected signal. 
% The object displays the selected signal using a wider line and 
% adds an indicator identifying the selected line to the label on the 
% vertical axis. Selecting a signal causes dependent views to update 
% their values. Unselect a signal by clicking in an empty part of 
% the plot area.

%% Configurable properties
% The |visviews.shadowSignalPlot| has seven configurable parameters: 
%
% |CombineMethod| specifies how to combine multiple blocks 
% when displaying a clumped slice.  The value can be 
% |'max'|, |'min'|, |'mean'|, |'median'|, or |'none'| (the default). 
%
% |CutoffScore| specifies the size of the z-score cutoff for outliers. 
%
% |RangeType| specifies the direction of outliers from the mean. A
% value of |'both'| (the default) indicates that outliers can occur in either direction 
% from the mean, while |'upper'| and |'lower'| indicate outliers 
% occur only above or below the mean, respectively.
%
% |RemoveMean| is a boolean flag specifiying whether to remove the 
% the individual channel means for the data before trimming or plotting.
%
% |ShowMean| is a boolean flag indicating whether to show the mean signal
% on the graph. If |true| (the default), the plot displays the signal mean 
% as a dark gray line.
%
% |ShowStd| is a boolean flag indicating whether to show the standard
% deviation of the signal on the graph. If |true| (the default), 
% the plot displays the signal standard deviation using light gray lines
% to mark the distance above and below the mean at each time point.
%
% |SignalLabel| is a string specifying the units for the y-axis.
%
% |TrimPercent| is a numerical value specifying the percentage of extreme
% points to remove from the window before plotting. If the percentage is 
% t, the largest t/2 percentage and the smallest t/2 percentage of the
% data points are removed (over all elements or channels). The signal
% scale is calculated relative to the trimmed signal and all of the
% signals are clipped at the trim cutoff before plotting.
%
%% Example  
% Create a shadow signal plot for random sinusoidal signals

    % Create a sinusoidal data set with random amplitude and phase 
    nSamples = 1000;
    nChans = 32;
    a = repmat(10*rand(nChans, 1), 1, nSamples);
    p = repmat(pi*rand(nChans, 1), 1, nSamples);
    x = repmat(linspace(0, 1, nSamples), nChans, 1);
    data = 0.01*random('normal', 0, 1, [nChans, nSamples]) + ...
      a.*cos(2*pi*x + p);
    data(1, :) = 2*data(1, :);  % Make first signal bigber
    testVD = viscore.blockedData(data, 'Cosine');

    % Create a block function and a slice
    defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
               visfuncs.functionObj.getDefaultFunctions());
    thisFunc = defaults{1};
    thisSlice = viscore.dataSlice('Slices', {':', ':', '1'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
 
    % Create the figure and plot the data, adjusting the margins
    sfig = figure('Name', 'Plot with smoothed signals');
    sp = visviews.signalShadowPlot(sfig, [], []);
    sp.CutoffScore = 2.0;
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
% documentation for |visviews.shadowSignalPlot|:
%
%    doc visviews.shadowSignalPlot
%

%% See also
% <axesPanel_help.html |visviews.axesPanel|>,
% <clickable_help.html |visviews.clickable|>, 
% <configurable_help.html |visprops.configurable|>,
% <cursorExplorable_help.html |visviews.cursorExplorable|>, 
% <resizable_help.html |visviews.resizable|>, and
% <stackedSignalPlot_help.html |visviews.stackedSignalPlot|>
%

%% 
% Copyright 2011 Kay A. Robbins, University of Texas at San Antonio