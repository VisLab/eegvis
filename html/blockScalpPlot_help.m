%% visviews.blockScalpPlot
% Display scalp map of blocked function values by element
%
%% Syntax
%     visviews.blockScalpPlot(parent, manager, key)
%     obj = visviews.blockScalpPlot(parent, manager, key)
%
%% Description
% |obj = visviews.blockScalpPlot(parent, manager, key)| displays a scalp map
% of combined block function values for a specified slice of time.
% The display includes a contour map of the combined values over the
% time and either points, labels, or numbers identifying the positions
% of the elements. The block scalp plot assumes that the elements
% correspond to eeg channels positioned on a scalp. If no channel
% locations are provided, the scalp map displays the head outline only.
%
% The |parent| is a graphics handle to the container for this plot. The
% |manager| is an |viscore.dataManager| object containing managed objects
% for the configurable properties of this object, and |key| is a string
% identifying this object in the property manager GUI.
% 
% |obj = visviews.blockScalpPlot(parent, manager, key)| returns a handle to
% the newly created object.
%
% |visviews.blockScalpPlot| is configurable, resizable, clickable, and cursor explorable.
%
%% Configurable properties
% The |visviews.blockScalpPlot| has seven configurable properties: 
%
% |CombineMethod| specifies how to combine multiple blocks into a 
% single block to determine an overall block value. The value can be 
% |'max'|  (default), |'min'|, |'mean'|, or  |'median'|. Detail plots use 
% the combined block value to determine slice colors. 
%
% Suppose the plot has 128 elements and 100 windows. The block scalp
% map requires a single value for each element and must combine the
% block values over the 100 windows to obtain a single value for each
% element. Possible combination methods include max, min, mean, or
% median. The default is the max.
%
% |ElementColor| specifies the color used for an element and its
% corresponding label when the electrode is in the current slice. The
% default is |[0, 0, 0]|.
%
% |HeadColor| specifies the color for the head outline. The plot function
% uses the same color for electrodes and their corresponding labels
% when the electrodes are not in the current slice. The
% default is |[0.75, 0.75, 0.75]|.
%
% |InterpolationMethod| specifies the method used to produce the shaded
% map of block values on the scalp. The default value is |'v4'| which
% specifies that the block values be interpolated on a grid that is
% 2 x HeadRadius with extrapolation. After interpolation, 
% the plot masks values the values that fall outside the 
% inscribed circle with radius HeadRadius. This method is the default 
% method used by EEGLAB topolot. Since some of the outer grid points 
% on the square are outside the convex hull of the elements, values 
% along the edges are extrapolated rather than interpolated. 
% This can result in contours maps that are visually pleasing 
% but can be misleading.
%
% Alternative interpolation methods include |'linear'|, |'cubic'| and
% |'nearest'|. These three methods only create the map within the 
% convex hull. All map values are then interpolated.
%
% |IsClickable| is a boolean specifying whether this plot should respond to
% user mouse clicks when incorporated into a linkable figure. The
% default value is |true|.
%
% |LinkDetails| is a boolean specifying whether clicking this plot in a
% linkable figure should cause detail views to display the clicked
% slice. The default value is |true|.
%
% ShowColorbar is a logical value specifying whether to display a colorbar
%    in addition to the scalp map (if the bar fits).
%
%% Interaction of labels with slices:
%
% The |visview.blockScalpMap| visualization displays the locations of all 
% valid electrodes as points overlaid on the scalp map. The behavior of 
% these depends on whether they are in the current slice:
%   
% The visualization displays an electrode in the current 
% as a point location and as a label, both displayed in the electrode 
% color. When the user clicks on the electrode point, |blockScalpMap| 
% delivers a slice corresponding to the clicked electrode to the downstream 
% visualizations through the master. When the user clicks on the
% electrode label, the displayed string toggles between electrode
% name and number.
%
% When an electrode is not in the current slice, the visualization displays
% the electrode as a point location in the head color. When the user 
% clicks on the electrode point, blockScalpMap toggles a label
% associated with the point among name, number and no display.
%     
%% Example 1: Create a kurtosis scalp map for 32 exponentially distributed channels

   % Create a block box plot
   sfig = figure('Name', 'Kurtosis for 32 exponentially distributed channels');
   bp = visviews.blockScalpPlot(sfig, [], []);

   % Generate some data to plot
   data = random('exp', 1, [32, 1000, 20]);
   load chanlocs.mat;
   testVD = viscore.blockedData(data, 'Exponenitally distributed', ...
            'ElementLocations', chanlocs);

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

%% Example 2: Compare scalp map interpolation methods

   % Create a block box plot
   
   
   % Generate some data to plot
   data = random('exp', 1, [32, 1000, 20]);
   load chanlocs.mat;
   testVD = viscore.blockedData(data, 'Exponenitally distributed', ...
            'ElementLocations', chanlocs);

   % Create a kurtosis block function object
   defaults = visfuncs.functionObj.createObjects('visfuncs.functionObj', ...
              visfuncs.functionObj.getDefaultFunctions());
   thisFunc = defaults{1};
   thisFunc.setData(testVD);
   
   sfig1 = figure('Name', 'Default interpolation (v4)');
   bp1 = visviews.blockScalpPlot(sfig1, [], []);
   bp1.InterpolationMethod = 'v4';
   bp1.Title = 'v4 (default)';
   bp1.plot(testVD, thisFunc, []);
   gaps = bp1.getGaps();
   bp1.reposition(gaps);

   sfig2 = figure('Name', 'Linear interpolation');
   bp2 = visviews.blockScalpPlot(sfig2, [], []);
   bp2.InterpolationMethod = 'linear';
   bp2.Title = 'linear';
   bp2.plot(testVD, thisFunc, []);
   gaps = bp2.getGaps();
   bp2.reposition(gaps);
   
   sfig3 = figure('Name', 'Cubic interpolation');
   bp3 = visviews.blockScalpPlot(sfig3, [], []);
   bp3.InterpolationMethod = 'cubic';
   bp3.Title = 'cubic';
   bp3.plot(testVD, thisFunc, []);
   gaps = bp3.getGaps();
   bp3.reposition(gaps);
   
   sfig4 = figure('Name', 'Nearest interpolation');
   bp4 = visviews.blockScalpPlot(sfig4, [], []);
   bp4.InterpolationMethod = 'nearest';
   bp4.Title = 'nearest';
   bp4.plot(testVD, thisFunc, []);
   gaps = bp4.getGaps();
   bp4.reposition(gaps);

%% Notes:
%
% * If manager is empty, the class defaults are used to initialize.
% * If key is empty, the class name is used to identify in GUI configuration.
% * The block scalp map tries to display as big a scalp map as will fit
% vertically in the panel. It does not enforce the axis square
% constraint unless there is room, since the goal of resizing is to
% make the electrodes available for clicking. If the color doesn't fit
% completely, blockScalpMap does not display it, regardless of the
% setting of ShowColorbar.
%
%% Acknowledgment: 
% This function contains code from topoplot.m of the EEGLAB  
% software, Andy Spydell, Colin Humphries, Arnaud Delorme & Scott Makeig, 
% CNL / Salk Institute, 8/1996-/10/2001; SCCN/INC/UCSD, Nov. 2001.
%  
%% Class documentation
% Execute the following in the MATLAB command window to view the class 
% documentation for |visviews.blockScalpPlot|:
%
%    doc visviews.blockScalpPlot
%
%% See also
% <axesPanel_help.html |visviews.axesPanel|>,
% <blockImagePlot_help.html |visviews.blockImagePlot|>, 
% <clickable_help.html |visviews.clickable|>, 
% <configurable_help.html |visprops.configurable|>,
% <cursorExplorable_help.html |visviews.cursorExplorable|>, 
% <elementBoxPlot_help.html |visviews.elementBoxPlot|>, and
% <resizable_help.html |visviews.resizable|> 
%

%% 
% Copyright 2011 Kay A. Robbins, University of Texas at San Antonio