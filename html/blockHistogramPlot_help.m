%% visviews.blockHistogramPlot
% Display histogram and boxplot of block function value
%
%% Syntax
%     visviews.blockHistogramPlot(parent, manager, key)
%     obj = visviews.blockHistogramPlot(parent, manager, key)
%
%% Description
% |obj = visviews.blockHistogramPlot(parent, manager, key)| displays a 
% histogram of the summary values along with an aligned horizontal
% box plot to give two views of the data.
%
% The |parent| is a graphics handle to the container for this plot. The
% |manager| is an |viscore.dataManager| object containing managed objects
% for the configurable properties of this object, and |key| is a string
% identifying this object in the property manager GUI.
% 
% |obj = visviews.blockHistogramPlot(parent, manager, key)| returns a handle to
% the newly created object.
%
% |visviews.blockHistogramPlot| is configurable, resizable, clickable, and 
% cursor explorable.
%
%% Configurable properties
% The |visviews.blockHistogramPlot| has two configurable properties: 
%
% |HistogramColor| is a 1 x 3 color vector giving the color of the 
% histogram bars. The default color is light gray.
%
% |NumberBins| specifies the number of bins in the histogram. The
% default number of bins is 20.
%
% The visualization is not linkable or clickable.
%

%% Example 
% Create a histogram summary of kurtosis of 32 exponentially distributed channels

    % Generate some data to plot
    data = random('exp', 1, [32, 1000, 20]);
    testVD = viscore.blockedData(data, 'Exponenitally distributed');
    
    % Create a kurtosis block function object
    funs = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
               visfuncs.functionObj.getDefaultFunctions());

    % Plot the block function, adjusting the margins
    sfig = figure('Name', 'Kurtosis for 32 exponentially distributed channels');
    bp = visviews.blockHistogramPlot(sfig, [], []);
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
% documentation for |visviews.blockHistogramPlot|:
%
%    doc visviews.blockHistogramPlot
%
%% See also
% <axesPanel_help.html |visviews.axesPanel|>,
% <blockBoxPlot_help.html |visviews.blockBoxPlot|>, 
% <clickable_help.html |visviews.clickable|>, 
% <configurable_help.html |visprops.configurable|>,
% <elementBoxPlot_help.html |visviews.elementBoxPlot|>, and
% <resizable_help.html |visviews.resizable|> 
%

%% 
% Copyright 2011 Kay A. Robbins, University of Texas at San Antonio