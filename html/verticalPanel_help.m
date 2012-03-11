%% visviews.verticalPanel
% Create a grid of vertically arranged resizable panels 
%
%% Syntax
%     visviews.verticalPanel(parent, manager, key)
%     obj = visviews.verticalPanel(parent, manager, key)
%
%% Description
% |visviews.verticalPanel(parent, manager, key)| creates a grid of 
% vertically arranged resizable panels. 
%
% The |parent| is a graphics handle to the container for this plot. The
% |manager| is an |viscore.dataManager| object containing managed objects
% for the configurable properties of this object, and |key| is a string
% identifying this object in the property manager GUI.
% 
% |obj = verticalPanel(parent, manager, key)| returns a
% handle to a newly recreated vertical panel.
%
% 
% |visviews.verticalPanel| is configurable, resizable, clickable, and 
% cursor explorable. 
%
%% Example
% Create a vertical panel that holds two detail views of random data
   hf = figure('Name', 'Vertical panel example');
   vp = visviews.verticalPanel(hf, [], []);
   
   % Set up the plots
   plots = visviews.plotObj.createObjects( ...
           'visviews.plotObj', visviews.dualView.getDefaultPlots(), []);
   plots = plots(5:6);
   man = viscore.dataManager();
   vp.reset(man, plots);
   
   % Set up some data and plot
   vdata = viscore.blockedData(random('exp', 2, [32, 1000, 20]), 'Random');
   keyfun = @(x) x.('ShortName');
   funs = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
             visfuncs.functionObj.getDefaultFunctions(), keyfun);
   slice1 = viscore.dataSlice('Slices', {':', ':', '3'}, ...
    'DimNames', {'Channel', 'Sample', 'Window'});
   vp.plot(vdata, funs{1}, slice1);
   
   % Reformat the margins
   gaps = vp.getGaps();
   vp.reposition(gaps);

%% Notes
%
% * If |manager| is empty, the class defaults are used to initialize.
% * If |key| is empty, the class name is used to identify in GUI
% configuration.
%
%% Class documentation
% Execute the following in the MATLAB command window to view the class 
% documentation for |visviews.verticalPanel|:
%
%    doc visviews.verticalPanel
%
%% See also
% <axesPanel_help.html |visviews.axesPanel|>,
% <clickable_help.html |visviews.clickable|>, 
% <configurable_help.html |visprops.configurable|>,
% <cursorExplorable_help.html |visviews.cursorExplorable|>,
% <horizontalPanel_help.html |visviews.horizontalPanel|>, and
% <resizable_help.html |visviews.resizable|> 
%
%% 
% Copyright 2011 Kay A. Robbins, University of Texas at San Antonio