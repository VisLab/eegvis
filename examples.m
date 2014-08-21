%% default arguments (v4 interpolation)
load('chanlocs.mat');
load('vector.mat');
plotBlockScalp(bValues, chanlocs); 

%% linear interpolation
load('chanlocs.mat');
load('vector.mat');
plotBlockScalp(bValues, chanlocs, 'InterpolationMethod', 'linear'); 

%% cubic interpolation
load('chanlocs.mat');
load('vector.mat');
plotBlockScalp(bValues, chanlocs, 'InterpolationMethod', 'cubic'); 

%% nearest interpolation
load('chanlocs.mat');
load('vector.mat');
plotBlockScalp(bValues, chanlocs, 'InterpolationMethod', 'nearest'); 

%% don't show color bar
load('chanlocs.mat');
load('vector.mat');
plotBlockScalp(bValues, chanlocs, 'ShowColorbar', false); 

%% black head color 
load('chanlocs.mat');
load('vector.mat');
plotBlockScalp(bValues, chanlocs, 'HeadColor', [0,0,0]); 

%% white element color 
load('chanlocs.mat');
load('vector.mat');
plotBlockScalp(bValues, chanlocs, 'ElementColor', [1,1,1]); 
