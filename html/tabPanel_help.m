%% visviews.tabPanel
% Create a tabbed panel for holding multiple summary views
%
%% Syntax
%     visviews.tabPanel(parent, manager, key)
%     obj = visviews.tabPanel(parent, manager, key)
%
%% Description
% |visviews.tabPanel(parent, manager, key)| creates a tabbed panel in which 
% each tab contains horizontally arranged resizable panels. 
%
% The |parent| is a graphics handle to the container for this plot. The
% |manager| is an |viscore.dataManager| object containing managed objects
% for the configurable properties of this object, and |key| is a string
% identifying this object in the property manager GUI.
% 
% |obj = tabPanel(parent, manager, key)| returns a
% handle to a newly recreated tab panel.
%
% 
% |visviews.tabPanel| is configurable, resizable, clickable, and 
% cursor explorable. 
%
%% Example
% Create a tab panel holding 3 summary views
   hf = figure('Name', 'Repositions the panel');
   tp = visviews.tabPanel(hf, [], []);
   
   % Set up the plots
   plots = visviews.plotObj.createObjects( ...
           'visviews.plotObj', visviews.dualView.getDefaultPlots(), []);
   plots = plots(1:3);
   man = viscore.dataManager();
   
   % Set up some data and plot
   vdata = viscore.blockedData(random('exp', 2, [32, 1000, 20]), 'Random');
   funs = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
                           visfuncs.functionObj.getDefaultFunctions(), []);
   slice1 = viscore.dataSlice('Slices', {':', ':', ':'}, ...
                              'DimNames', {'Channel', 'Sample', 'Window'});
   tp.setFunctions(funs);
   
   tp.reset(man, plots);
   tp.plot(vdata, slice1);
   
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
% documentation for |visviews.tabPanel|:
%
%    doc visviews.tabPanel
%
%% See also
% <axesPanel_help.html |visviews.axesPanel|>,
% <clickable_help.html |visviews.clickable|>, 
% <configurable_help.html |visprops.configurable|>,
% <cursorExplorable_help.html |visviews.cursorExplorable|>, 
% <horizontalPanel_help.html |visviews.horizontalPanel|>,
% <resizable_help.html |visviews.resizable|>, and 
% <verticalPanel_help.html |visviews.verticalPanel|> 
%

%% 
% Copyright 2011 Kay A. Robbins, University of Texas at San Antonio