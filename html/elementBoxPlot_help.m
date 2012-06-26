%% visviews.elementBoxPlot
% Display a boxplot of block function values by element
%
%% Syntax
%     visviews.elementBoxPlot(parent, manager, key)
%     obj = visviews.elementBoxPlot(parent, manager, key)
%
%% Description
% |obj = visviews.elementBoxPlot(parent, manager, key)| displays a series of 
% horizontal box plots using a compressed style. The element box plot 
% displays the distribution of values of a summarizing function for 
% each element (e.g., channel)  as a horizontal box plot. 
% 
% The |parent| is a graphics handle to the container for this plot. The
% |manager| is an |viscore.dataManager| object containing managed objects
% for the configurable properties of this object, and |key| is a string
% identifying this object in the property manager GUI.
% 
% |obj = visviews.elementBoxPlot(parent, manager, key)| returns a handle to
% the newly created object.
%
% |visviews.elementBoxPlot| is configurable, resizable, clickable, and cursor explorable.
%
%% Configurable properties
% The |visviews.elementBoxPlot| has five configurable parameters: 
%
% |BoxColors| provides a list of colors used to alternate through in 
% displaying the boxes. For data with lots of clumps, the 
% boxes appear highly compressed due to limited viewing space and 
% alternating colors help users distinguish the individual boxes. The
% default is |[0.7, 0.7, 0.7; 1, 0, 1]|.
%
% |ClumpFactor| specifies the number of consecutive elements 
% represented by each box. When the |ClumpFactor| is one (the default), 
% each box represents a single window or epoch. If |ClumpFactor| is greater than 
% one, each box represents several consecutive elements. 
%
% |CombineMethod| specifies how to combine multiple elements into a 
% single group to determine an overall block value. The value can be 
% |'max'|  (default), |'min'|, |'mean'|, or  |'median'|. Detail plots use this 
% block value to determine slice colors. 
%
% For example, with 128 channels, a clump size of 3, a block size of 
% 1000 samples, and 20 windows, the |elementBoxPlot| delivers a slice representing 
% 3×1000×20 worth of data. A detail plot such as |signalStackedPlot| 
% combines this data based on its own |CombineMethod| property, 
% say by taking the mean to plot 20×1000 data points on 20 line graphs. 
% However, we would like to use line colors for the signals based 
% on the block function values in the box plot. The detail plots use 
% box plot's |CombineMethod| to combine the blocks to get appropriate 
% colors for the slice. 
%
% Usually signal plots combine signals using mean or median, while 
% summary plots such as |elementBoxPlot| use the max, although users may 
% choose other combinations.
%
% |IsClickable| boolean specifying whether this plot should respond to
% user mouse clicks when incorporated into a linkable figure. The
% default value is |true|.
%
% |LinkDetails| boolean specifying whether clicking this plot in a
% linkable figure should cause detail views to display the clicked
% slice. The default value is |true|.
%


%% Example 1
% Create an element boxplot of kurtosis for EEG data

    % Read some eeg data to display
    load('EEG.mat');  % Saved EEGLAB EEG data
    testVD = viscore.blockedData(EEG.data, 'Sample EEG data', ...
         'SampleRate', EEG.srate);
   
    % Create a kurtosis block function object
    funs = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
               visfuncs.functionObj.getDefaultFunctions());
    
    % Plot the block function, adjusting margins for display
    sfig = figure('Name', 'Kurtosis for EEG data');
    bp = visviews.elementBoxPlot(sfig, [], []);
    bp.plot(testVD, funs{1}, []);
    gaps = bp.getGaps();
    bp.reposition(gaps);

    
%% Example 2
% Create an element boxplot of kurtosis of clumps of 3 windows 

    % Generate some data to plot
    data = random('exp', 1, [32, 1000, 20]);
    testVD = viscore.blockedData(data, 'Exponenitally distributed');
    
    % Create a kurtosis block function object
    funs = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
               visfuncs.functionObj.getDefaultFunctions());
    
    % Plot the block function, adjusting margins for display
    sfig = figure('Name', 'Kurtosis for 32 exponentially distributed channels');
    bp = visviews.elementBoxPlot(sfig, [], []);
    bp.ClumpSize = 3;
    bp.plot(testVD, funs{1}, []);
    gaps = bp.getGaps();
    bp.reposition(gaps);
    

%% Notes
%
% * If |manager| is empty, the class defaults are used to initialize.
% * If |key| is empty, the class name is used to identify in GUI
% configuration.
%
%% Class documentation
% Execute the following in the MATLAB command window to view the class 
% documentation for |visviews.elementBoxPlot|:
%
%    doc visviews.elementBoxPlot
%
%% See also
% <axesPanel_help.html |visviews.axesPanel|>,
% <blockBoxPlot_help.html |visviews.blockBoxPlot|>, 
% <blockImagePlot_help.html |visviews.blockImagePlot|>, 
% <clickable_help.html |visviews.clickable|>, 
% <configurable_help.html |visprops.configurable|>,
% <cursorExplorable_help.html |visviews.cursorExplorable|>, and
% <resizable_help.html |visviews.resizable|> 
%


%% 
% Copyright 2011 Kay A. Robbins, University of Texas at San Antonio