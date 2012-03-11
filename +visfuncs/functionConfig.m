% visfuncs.functionConfig  GUI for function configuration
%
% Usage:
%   >>  visfuncs.functionConfig(selector, title)
%   >>  obj = visfuncs.functionConfig(selector, title)
% Description:
% visfuncs.functionConfig(selector, title) creates a configuration
%     GUI for functions. The selector must be a non-empty object of 
%     type viscore.dataSelector and a configuration type of
%     'visfuncs.functionConfig'. The title string appears on the 
%     title bar of the figure window.
%
% obj = visfuncs.dataConfig(selector, title) returns a handle to
%      a function configuration GUI
%
% The function configuration GUI presents a table view of the functions
% with the following columns:
%
% BackgroundColor	Numeric color vector (1 × 3) giving background color 
%                   for visualizations. 
%
% Enabled	        Logical	indicating whether the object should be 
%                   enabled in the visualization.
%
% Category	        String indicating the type of function (now only 'Block').
%
% DisplayName	    String identifying the object in the visualization.
%
% Definition	    String representation of function for evaluation with eval.
%
% Description	    String description used in tooltips in the visualization.
%
% ShortName	        String giving a brief identification of object 
%                   (used as a key in configuration and must be unique).
%
% ThresholdColors	Numeric color vector (n × 3) where n is the 
%                   number of threshold levels.
%
% ThresholdLevels	Numeric vector of cutoff levels.
%
% ThresholdScope	String indicating whether thresholds are computed 
%                   globally or by element. Currently only 'global' is
%                   implemented, indicating that thresholds are computed
%                   over the entire data set.
%
% ThresholdType	    String indicating criteria used for thresholding 
%                   function values. Currently the only valid choices
%                   are 'z score' and 'value'. 
%
% Example 1:
% Create a function configuration GUI
%
%    keyfun = @(x) x.('ShortName');  % Functions uniquely identified by short name
%    defaults = visfuncs.functionObj.createObjects( 'visfuncs.functionObj', ...
%          visfuncs.functionObj.getDefaultFunctions(), keyfun);
%    selector = viscore.dataSelector('visfuncs.functionConfig');
%    selector.getManager().putObjects(defaults);
%    fc = visfuncs.functionConfig(selector, 'Example function configuration');
%
% Example 2:
% Create a function structure for a kurtosis function
%
%    fStruct = struct( ...
%                'Enabled',        {true}, ...
%                'Category',       {'block'}, ...
%                'DisplayName',    {'Kurtosis'}, ...
%                'ShortName',      {'K'}, ...
%                'Definition',     {'@(x) (kurtosis(x, 1, 2))'}, ...
%                'ThresholdType',  {'z score'}, ...
%                'ThresholdLevels', {2, 3}, ...
%                'ThresholdColors', {[1, 0, 1], [1, 0, 0]}, ...
%                'BackgroundColor', {[0.7, 0.7, 0.7]}, ...
%                'ThresholdScope', {'global'}, ...
%                'Description',    {'Kurtosis computed for each (element, block)'});
%
% The structure specifies that a kurtosis value with a z score > 3
% will be displayed in red (color value [1, 0, 0]), a kurtosis value
% with a z-score between 2 and 3 will be displayed in magenta (color
% value [1, 0, 1]), and a kurtosis value less than 2 will be displayed
% using the gray background color ([0.7, 0.7, 0.7]).
% 
%
% Notes:
%  - visfuncs.functionConfig uses the ShortName field as the unique key.
%  - The ShortName should be no more than 4 characters
%
%
%% Class documentation
% Execute the following in the MATLAB command window to view the class 
% documentation for visfuncs.functionConfig:
%
%    doc visfuncs.functionConfig
%
% See also: viscore.dataManager, viscore.dataSelector, 
%           visfuncs.functionObj, and viscore.managedObj


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

% $Log: functionConfig.m,v $
% Revision: 1.00  04-Dec-2011 09:11:20  krobbins $
% Initial version $
%

classdef functionConfig < viscore.tableConfig
 
    methods
        
        function obj = functionConfig(selector, title)
            % Constructor - brings up GUI
            obj = obj@viscore.tableConfig(selector, title);
            if ~strcmpi(class(obj), selector.getType())
                throw(MException('functionConfig:InvalidParameters', ...
                    ['Selector must have conType ' class(obj)]));
            end
            set(obj.ConFig, 'Position', [200 342 800 500]);
        end % functionConfig constructor     
        
    end % public methods
    
    methods (Access = protected)
        
        function key = getKeyFromRow(obj, row) 
            % Returns the key used to identify this structure  
            namePos = find(strcmp('ShortName', obj.TableFields), 1, 'first');
            if isempty(namePos)
                key = '';
            else
                 key = row{namePos};
            end
        end % getKeyFromRow
        
       function key = getKeyFromStructure(obj, s) %#ok<MANU>
            % Return key corresponding to this structure (override)
            key = s.('ShortName');
        end % getKeyFromStructure
        
        function newObj = getNewManagedObj(obj, s) 
            % Returns new managed object for s using unique key
            newObj = visfuncs.functionObj(obj.getKeyFromStructure(s), s);
        end % getNewManagedObj
        
    end % protected methods
    
    methods (Static = true)
        
        function s = getDefaultStructure()
            % Return a valid structure corresponding to a dummy function row  
            c = viscore.counter.getInstance();  % needed for unique entries
            s.Enabled = true;
            s.Category = 'block';
            s.DisplayName = ['DummyFunction ' num2str(c.getNext())];
            s.ShortName = ['New' num2str(c.getNext())];
            s.ThresholdType = 'Z score';
            s.ThresholdLevels = 3;
            s.ThresholdColors = [1, 0, 0];
            s.ThresholdScope = 'global';
            s.BackgroundColor = [0.7, 0.7, 0.7];
            s.Definition = '@(x) (x(:, 1, :))';
            s.Description = 'Extract the 1st column of a 2 or 3D array';
        end  % getDefaultStructure
           

        function tableStruct = getTableStructure()
            % Return the column structure and type for function table
            scopes = visfuncs.functionObj.ThresholdScopes;
            types = visfuncs.functionObj.ThresholdTypes;
            tableStruct = struct( ...
                'title',    {'Enabled', 'Category', 'Function|Name', 'Short|Name', 'Definition', 'Threshold|Type',  'Threshold|Levels', 'Threshold|Colors', 'Threshold|Scope', 'Background|Color'  'Description'}, ...
                'name',     {'Enabled', 'Category', 'DisplayName',   'ShortName',  'Definition', 'ThresholdType',   'ThresholdLevels',  'ThresholdColors',  'ThresholdScope',  'BackgroundColor',  'Description'}, ...
                'format',   {'logical', 'char',     'char',          'char',       'char',       types,             'char',             'colors',            scopes,            'colors',          'char'}, ...
                'editable', {false,      false,      false,           false,       false,        false,             false,              false,              false,              false,              false}, ...
                'unique',   {false,      false,      true,            true,        false,        false,             false,              false,              false,              false,              false}, ...
                'width',    {1,          1,          2,               1,           3,            1,                 1,                  1,                  1,                  1,                  2} ...
                );
        end % getTableStructure
        
    end % static methods
    
end % functionConfig


