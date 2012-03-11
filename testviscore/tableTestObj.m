% tableTestObj   holds definition and current values of a function
%
% Usage:
% >>  tableTestObj(objectID, structure)
% >>  obj = tableTestObj(objectID, structure)
%
% Inputs:
%    objectID         ID for this object (if empty uses a new unique ID)
%    structure        Structure array with the values to be managed
%
% Outputs:
%     obj             Handle to BlockFunction object
%
% Notes:
%   - The categories are used to determine which area of the visualization
%     the plot will appear in. Multiple plots of the same class may be used
%     in different places. 
%   - Plot objects have a single structure rather than an array of structures.
%   - The plot object ID should always be the ID of the structure 
%
%% Default structure fields for plot objects:
%
%    Category            % String determining figure area to draw in (usually 'summary' or 'detail')
%    DisplayName         % Readable string identifying the plot
%    Definition          % String to use to eval the constructor
%    Description         % Readable string describing function of the plot
%    Enabled             % True if this plot is currently available
%    ID                  % Unique integer identifying this plot object (generated)
%    
% Author: Kay Robbins, UTSA, 2011
%
% See also: viscore.managedObj(), visviews.PlotConfiguration()
%

% Copyright (C) 2011  Kay Robbins, UTSA, krobbins@cs.utsa.edu
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

% $Log: PlotObj.m,v $
% Revision 1.00  10-Jun-2011 16:44:07  krobbins
% Initial version
%
classdef tableTestObj < hgsetget & viscore.managedObj
    
    methods
        
        function obj = tableTestObj(objectID, structure) %#ok<INUSD>
            % Create a managed plot object, ignoring objectID
            obj = obj@viscore.managedObj([], structure);
            obj.ObjectID = obj.ManStruct(1).ID; % Force agreement
        end % tableTestObj constructor
        
        function def = getDefinition(obj)
            % Return the definition of the plot class suitable for eval
            def = obj.ManStruct(1).Definition;
        end % getDefinition
        
    end % public methods
    
    methods(Static = true)
         
        function pStruct = getDefaults()
            % Field name, class name, class modifier, display name, type, default, options,
            % descriptions
            pStruct = struct( ...
                'Enabled',        {true,              true}, ...
                'Category',       {'summary',        'detail'}, ...
                'DisplayName',    {'Block Image',    'Signal'}, ...
                'Definition',     {'visviews.blockImagePlot', ...
                                   'visviews.stackedSignalPlot'}, ...
                'Description',    {'Displays an array of windowed values as an image', ...
                                   'Displays raw signal in a time window using a stacked view' ...
                });
        end % getDefaults
        
        function pStruct = getDefaultPlots()
            % Structure specifying the individual visualizations used
            pStruct = struct( ...
                'Enabled',        {true,           true,           true,          false,           true,           false}, ...
                'Category',       {'summary',      'summary',      'summary',     'summary',       'detail',        'detail'}, ...
                'DisplayName',    {'Block Image',  'Element Box',  'Block Box',   'Block Histogram' 'Stacked Signal', 'Shadow Signal'}, ...
                'Definition',     {'visviews.blockImagePlot', ...
                                   'visviews.elementBoxPlot', ...
                                   'visviews.blockBoxPlot', ...       
                                   'visviews.blockHistogramPlot', ...       
                                   'visviews.stackedSignalPlot', ...
                                   'visviews.shadowSignalPlot', ...
                                    }, ...
                'Description',    {'Displays an array of windowed values as an image', ...
                                    'Displays a box plot of blocked values for each element', ...
                                    'Displays a box plot of blocked values for groups of blocks', ...
                                    'Displays a histogram of the blocked values', ...
                                    'Displays raw signal in a time window in a stacked plot', ...
                                    'Displays raw signal in a time window in a shadow plot' ...
                                    });                       
        end % getDefaultPlots
        
        function fStruct = getDefaultFunctions()
            % Structure specifying the default functions (one per tab)
            fStruct = struct( ...
                'Enabled',        {true,         true}, ...
                'Category',       {'block',        'block'}, ...
                'DisplayName',    {'Kurtosis', 'Standard Deviation'}, ...
                'ShortName',      {'K',        'SD'}, ...
                'Definition',     {'@(x) (squeeze(kurtosis(x, 1, 2)))', ...
                                    '@(x) (squeeze(std(x, 0, 2)))'}, ...
                'ThresholdType',  {'z score',    'z score'}, ...
                'ThresholdScope', {'global'     'global'}, ...
                'ThresholdLevels', {3,              3}, ...
                'ThresholdColors', {[1, 0, 0],    [0, 1, 1]}, ...
                'Description',    {'Kurtosis computed for each (element, block)', ...
                                    'Block size for computation (must be positive)' ...
                                    });                       
        end % getDefaultFunctions
       
    end % static methods 
    
end % PlotObj

