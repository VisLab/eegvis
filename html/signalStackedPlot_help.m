%% visviews.stackedSignalPlot
% Display stacked view of individual element or window signals
%
%% Syntax
%     visviews.stackedSignalPlot(parent, manager, key)
%     obj = visviews.stackedSignalPlot(parent, manager, key)

%% Description
% |obj = visviews.stackedSignalPlot(parent, manager, key)| shows each 
% member of a slice of signals offset vertically, with the lowest numbered 
% member at the top and the highest number slice at the bottom. 
% The stacked signal plot can show three possible slices: by channel, 
% by sample, or by window. Plotting by window is the most traditional display. 
% 
% The |parent| is a graphics handle to the container for this plot. The
% |manager| is an |viscore.dataManager| object containing managed objects
% for the configurable properties of this object, and |key| is a string
% identifying this object in the property manager GUI.
% 
%
% |obj = visviews.stackedSignalPlot(parent, manager, key)| returns a handle to
% the newly created object.
%
% |visviews.stackedSignalPlot| is configurable, resizable, and cursor explorable.
%

%% Configurable properties
% The |visviews.stackedSignalPlot| has five configurable parameters: 
%
% |ClippingOn| is a boolean, which if true causes the individual signals
% to be truncated so that they appear inside the axes. 
%
% |CombineMethod| specifies how to combine multiple blocks 
% when displaying a clumped slice.  The value can be 
% |'max'|, |'min'|, |'mean'|, |'median'|, or |'none'| (the default). 
%
% |RemoveMean| is a boolean flag specifiying whether to remove the 
% the individual channel means for the data before trimming or plotting.
%
% |SignalLabel| is a string identifying the units of the signal. 
%
% |SignalScale| is a numerical factor specifying the vertical spacing of the
% individual line plots. The spacing is |SignalScale| times the 10%
% trimmed mean of the standard deviation of the data.
%
% |TrimPercent| is a numerical value specifying the percentage of extreme
% points to remove from the window before plotting. If the percentage is 
% t, the largest t/2 percentage and the smallest t/2 percentage of the
% data points are removed (over all elements or channels). The signal
% scale is calculated relative to the trimmed signal and all of the
% signals are clipped at the trim cutoff before plotting.
%

%% Example 
% Create a stacked signal plot for random signals

    % Create a sinusoidal data set with random amplitude and phase 
    data = random('normal', 0, 1, [32, 1000, 20]);
    testVD = viscore.blockedData(data, 'Rand1');

    % Create a block function and a slice
    defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
               visfuncs.functionObj.getDefaultFunctions());
    thisFunc = defaults{1};
    thisSlice = viscore.dataSlice('Slices', {':', ':', '1'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
 
    % Create the figure and plot the data
    sfig  = figure('Name', 'Stacked signal plot with random data');
    sp = visviews.signalStackedPlot(sfig, [], []);
    sp.SignalScale = 2.0;
    sp.plot(testVD, thisFunc, thisSlice);
   
    % Adjust the margins
    gaps = sp.getGaps();
    sp.reposition(gaps);

%% Notes
%
% * If |manager| is empty, the class defaults are used to initialize
% * If |key| is empty, the class name is used to identify in GUI configuration
% * The plot calculates the spacing as the signal scale times the
% 10% trimmed mean of the standard deviations of the signal. That is,
% the standard deviation of each plot is calculated. Then the lower
% and upper 5% of the values are removed and the mean standard
% deviation is computed. This value is multiplied by the signal scale
% to determine the plot spacing.
%
%% Class documentation
% Execute the following in the MATLAB command window to view the class 
% documentation for |visviews.stackedSignalPlot|:
%
%    doc visviews.stackedSignalPlot
%
%% See also
% <clickable_help.html |visviews.clickable|>, 
% <configurable_help.html |visprops.configurable|>, 
% <cursorExplorable_help.html |visviews.cursorExplorable|>, 
% <resizable_help.html |visviews.resizable|>, and
% <shadowSignalPlot_help.html |visviews.shadowSignalPlot|>
%

%% 
% Copyright 2011 Kay A. Robbins, University of Texas at San Antonio