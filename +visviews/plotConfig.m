% visviews.plotConfig  GUI for configuring list of plots
%
% Usage:
%   >>  visviews.plotConfig(selector, title)
%   >>  obj = visviews.plotConfig(plots)
%
% Description:
% visfuncs.functionConfig(selector, title) creates a configuration
%     GUI for functions. The selector must be a non-empty object of 
%     type viscore.dataSelector. The title string appears on the 
%     title bar of the figure window.
%
% obj = visfuncs.dataConfig(selector, title) returns a handle to
%      a function configuration GUI,
%
% The plot configuration GUI presents a table view of the functions
% with the following columns:
%
% Enabled	        Logical	indicating whether the object should be 
%                   enabled in the visualization.
%
% Category	        String indicating the type of function (now only 'Block'). 
%
% DisplayName	    String identifying the object in the visualization.
%
% Definition	    String containing the full class name.
%
% Description	    String description used in tooltips in the
%                   visualization.
%
% Sources           String or cell array of strings specifying linkage.
%                   Values 'none' and 'master' specify top-level 
%                   summary and details, respectively. If the DisplayName
%                   of another plot is given, the named plot is considered 
%                   a source and this plot displays slices of the named 
%                   plot, when that plot is clicked. 
%
% Example:
% Create a specification of a top-level block image summary visualization
%    pStruct = struct( ...
%               'Enabled',     {true}, ...
%               'Category',    {'summary'}, ...
%               'DisplayName', {'Block image'}, ...
%               'Definition',  {'visviews.blockImagePlot'}, ...
%               'Sources',     {'None'}, ...
%                'Description', {'Image of blocked value array'});
%    defaults = visviews.plotObj.createObjects('visviews.plotObj', pStruct);
%    selector = viscore.dataSelector('visviews.plotConfig');
%    selector.getManager().putObjects(defaults);
%    pc  = visviews.plotConfig(selector, 'Testing plotConfig');
%
% The structure specifies that a visviews.blockImagePlot should be
% created with the unique display name 'Block image'. 
% 
% Notes:
%  - visviews.plotObj uses the DisplayName field as the unique key.
%
% Class documentation:
% Execute the following in the MATLAB command window to view the class 
% documentation for visviews.plotConfig:
%
%    doc visviews.plotConfig
%
% See also: viscore.dataConfig, viscore.dataManager, viscore.dataSelector,
%           viscore.managedObj, and visviews.plotObj
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

% $Log: plotConfig.m,v $
% Revision: 1.00  04-Dec-2011 09:11:20  krobbins $
% Initial version $
%

classdef plotConfig < viscore.tableConfig
    
    methods 
        
        function obj = plotConfig(selector, title)
            % Constructor creates a GUI for configuring plots
            obj = obj@viscore.tableConfig(selector, title);
            if ~strcmpi(class(obj), selector.getType())
                throw(MException('plotConfig:InvalidParameters', ...
                    ['Selector must have conType ' class(obj)]));
            end
        end % plotConfig constructor
         
    end % public methods
    
    methods (Access = protected)
        
        function newObj = getNewManagedObj(obj, s) 
            % Return new managed object for s using unique key
            newObj = visviews.plotObj(obj.getKeyFromStructure(s), s);
        end % getNewManagedObj
        
    end % protected methods
        
    methods (Static = true)
        
        function s = getDefaultStructure()
            % Return a valid structure corresponding to a dummy row 
            c = viscore.counter.getInstance();  % needed for unique entries
            s.Enabled = true;
            s.Category = 'summary';
            s.DisplayName = ['Image plot '  num2str(c.getNext())];
            s.Definition = 'visviews.blockImagePlot';
            s.Sources = 'None';
            s.Description = 'Displays an array of windowed values as an image';
        end % getDefaultStructure
        
        function tableStruct = getTableStructure()
            % Return default columns for a plot configuration table 
            tableStruct = struct( ...
                'title',    {'Enabled', 'Category', 'Plot name',   'Plot class', 'Sources', 'Description'}, ...
                'name',     {'Enabled', 'Category', 'DisplayName', 'Definition', 'Sources', 'Description'}, ...
                'format',   {'logical', 'char',     'char',        'char',       'char',      'char'}, ...
                'editable', {false,      false,      false,         false,       false,       false}, ...
                'unique',   {false,      false,      true,          false,       false,       false}, ...
                'width',    {1,          2,          2,             3,           3,           3} ...
                );
        end % getTableStructure
        
    end % static methods
    
end % plotConfig


