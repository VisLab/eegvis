%% visviews.horizontalPanel
% Create a grid of horizontally arranged resizable panels 
%
%% Syntax
%     visviews.horizontalPanel(parent, manager, key)
%     obj = visviews.horizontalPanel(parent, manager, key)
%
%% Description
% |visviews.horizontalPanel(parent, manager, key)| creates a grid of 
% horizontally arranged resizable panels. 
%
% The |parent| is a graphics handle to the container for this plot. The
% |manager| is an |viscore.dataManager| object containing managed objects
% for the configurable properties of this object, and |key| is a string
% identifying this object in the property manager GUI.
% 
% |obj = horizontalPanel(parent, manager, key)| returns a
% handle to a newly recreated horizontal panel.
%
% 
% |visviews.horizontalPanel| is configurable, resizable, clickable, and 
% cursor explorable. 
%
%% Example
% Create a horizontal panel containing 3 summary visualizations
   hf = figure('Name', 'Repositions the panel');
   tp = visviews.horizontalPanel(hf, [], []);
   
   % Set up the plots
   plots = visviews.plotObj.createObjects( ...
           'visviews.plotObj', visviews.dualView.getDefaultPlots(), []);
   plots = plots(1:3);
   man = viscore.dataManager();
   tp.reset(man, plots);
   
   % Set up some data and plot
   vdata = viscore.blockedData(random('exp', 2, [32, 1000, 20]), 'Random');
   funs = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
                           visfuncs.functionObj.getDefaultFunctions());
   slice1 = viscore.dataSlice('Slices', {':', ':', ':'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
   tp.plot(vdata, funs{1}, slice1);
   
   % Reformat the margins
   gaps = tp.getGaps();
   tp.reposition(gaps);

%% Notes
%
% * If |manager| is empty, the class defaults are used to initialize.
% * If |key| is empty, the class name is used to identify in GUI
% configuration.
%
%% Class documentation
% Execute the following in the MATLAB command window to view the class 
% documentation for |visviews.horizontalPanel|:
%
%    doc visviews.horizontalPanel
%
%% See also
% <axesPanel_help.html |visviews.axesPanel|>,
% <clickable_help.html |visviews.clickable|>, 
% <configurable_help.html |visprops.configurable|>,
% <cursorExplorable_help.html |visviews.cursorExplorable|>, 
% <resizable_help.html |visviews.resizable|>, 
% <tabPanel_help.html |visviews.tabPanel|>, and 
% <verticalPanel_help.html |visviews.verticalPanel|> 
%

%% 
% Copyright 2011 Kay A. Robbins, University of Texas at San Antonio