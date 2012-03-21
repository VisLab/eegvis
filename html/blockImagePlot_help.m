%% visviews.blockImagePlot
% Display element vs block values as an image
%
%% Syntax
%     visviews.blockImagePlot(parent, manager, key)
%     obj = visviews.blockImabePlot(parent, manager, key)
%
%% Description
% |obj = visviews.blockImagePlot(parent, manager, key)| displays the 
% values of a summarizing function as an image (elements × clump), 
% with pixel color representing the value of the function. 
% The y-axis corresponds to elements (e.g., channels) and 
% the x-axis corresponds to time (e.g., window or clump number).  
% 
% The |parent| is a graphics handle to the container for this plot. The
% |manager| is an |viscore.dataManager| object containing managed objects
% for the configurable properties of this object, and |key| is a string
% identifying this object in the property manager GUI.
% 
%
% |obj = visviews.blockImagePlot(parent, manager, key)| returns a handle to
% the newly created object.
%
% |visviews.blockImagePlot| is configurable, resizable, clickable, and cursor explorable.
%
%% Configurable properties
% The |visviews.blockImagePlot| has four configurable parameters: 
%
% |ClumpFactor| specifies the number of consecutive windows or epochs 
% represented by each pixel column. When the |ClumpFactor| is one (the default), 
% each pixel column represents its own window. If |ClumpFactor| is greater than 
% one, each pixel column represents several consecutive blocks. 
% Users can trade-off clump size versus block size to see different 
% representations of the data.
%
% |CombineMethod| specifies how to combine multiple blocks into a 
% single block to determine an overall block value. The value can be be
% |'max'|  (default), |'min'|, |'mean'|, or  |'median'|. Detail plots use this 
% block value to determine slice colors. 
%
% For example, with 32 channels, a clump size of 3, a block size of 
% 1000 samples, the blockImagePlot delivers a slice representing 
% 32×1000×3 worth of data. A detail plot such as |signalStackedPlot| 
% combines this data based on its own |CombineMethod| property, 
% say by taking the mean to plot 32×1000 data points on 32 line graphs. 
% However, we would like to use line colors for the signals based 
% on the block function values in the image plot. The detail plots use 
% image plot's |CombineMethod| to combine the blocks to get appropriate 
% colors for the slice. 
%
% Usually signal plots combine signals using mean or median, while 
% summary plots such as |blockBoxPlot| use the max, although users may 
% choose other combinations.
%
% |IsClickable| is a boolean specifying whether this plot should respond to
% user mouse clicks when incorporated into a linkable figure. The
% default value is |true|.
%
% |LinkDetails| is a boolean specifying whether clicking this plot in a
% linkable figure should cause detail views to display the clicked
% slice. The default value is |true|.
%

%% Example 1
% Create a block image plot of kurtosis of 32 exponentially distributed channels

    % Create a block box plot
    sfig = figure('Name', 'Kurtosis for 32 exponentially distributed channels');
    bp = visviews.blockImagePlot(sfig, [], []);

    % Generate some data to plot
    data = random('exp', 1, [32, 1000, 20]);
    testVD = viscore.blockedData(data, 'Exponenitally distributed');
    
    % Create a kurtosis block function object
    defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
               visfuncs.functionObj.getDefaultFunctions());
    thisFunc = defaults{1};
    thisFunc.setData(testVD);
    
    % Plot the block function
    bp.plot(testVD, thisFunc, []);
   
    % Adjust the margins
    gaps = bp.getGaps();
    bp.reposition(gaps);

    
%% Example 2
% Create a block image plot of kurtosis of clumps of 3 windows 

    % Create a block box plot
    sfig = figure('Name', 'Kurtosis for 32 exponentially distributed channels');
    bp = visviews.blockImagePlot(sfig, [], []);
    bp.ClumpFactor = 3;

    % Generate some data to plot
    data = random('exp', 1, [32, 1000, 20]);
    testVD = viscore.blockedData(data, 'Exponenitally distributed');
    
    % Create a kurtosis block function object
    defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
               visfuncs.functionObj.getDefaultFunctions());
    thisFunc = defaults{1};
    
    % Plot the block function
    bp.plot(testVD, thisFunc, []);
   
    % Adjust the margins
    gaps = bp.getGaps();
    bp.reposition(gaps);
    

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
% documentation for |visviews.blockImagePlot|:
%
%    doc visviews.blockImagePlot
%
%% See also
% <axesPanel_help.html |visviews.axesPanel|>,
% <blockBoxPlot_help.html |visviews.blockBoxPlot|>, 
% <clickable_help.html |visviews.clickable|>, 
% <configurable_help.html |visprops.configurable|>,
% <cursorExplorable_help.html |visviews.cursorExplorable|>, 
% <elementBoxPlot_help.html |visviews.elementBoxPlot|>, and
% <resizable_help.html |visviews.resizable|> 
%

%% 
% Copyright 2011 Kay A. Robbins, University of Texas at San Antonio