% visviews.plotObj   holds definition and and settings for a plot
%
% Usage:
%   >>  visviews.plotObj(objectID, structure)
%   >>  obj = visviews.plotObj(objectID, structure)
%
% Inputs:
%    objectID         ID for this object (if empty uses a new unique ID)
%    structure        Structure array with the values to be managed
%
% Outputs:
%     obj             Handle to plotObj object
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
%    Category            % string determining figure area to draw in (usually 'summary' or 'detail')
%    DisplayName         % readable string identifying the plot
%    Definition          % string used for evaluating graphics object constructor
%    Description         % readable string describing the plot
%    Enabled             % true if this plot is currently available and graphics should be created
%    ID                  % unique integer identifying this plot object (generated)
%    
% Author: Kay Robbins, UTSA, 2011
%
% See also: viscore.managedObj(), visviews.plotConfig()
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

% $Log: plotObj.m,v $
% Revision: 1.00  04-Dec-2011 09:11:20  krobbins $
% Initial version $
%

classdef plotObj < hgsetget & viscore.managedObj
    
    methods
        
        function obj = plotObj(objectID, structure) 
            % Create a managed plot object, ignoring objectID
            obj = obj@viscore.managedObj(objectID, structure);
        end % Plotobj constructor
        
        function def = getCategory(obj)
            % Return the definition of the plot class suitable for eval
            def = obj.ManStruct(1).Category;
        end % getCategory 
        
        function confObj = getConfigurableObj(obj)
            % Create a configurable object for this plot object 
            confObj = [];
            try
               s = eval([obj.getDefinition() '.getDefaultProperties()']);
               ID = obj.ManStruct(1).DisplayName;
               confObj = visprops.configurableObj(ID, s, obj.getDefinition());
               confObj.CategoryModifier = obj.ManStruct(1).DisplayName;
            catch ME
                warning('plotObj:getConfigurableObj', [obj.getDefinition() ...
                    ' does not correspond to a configurable class: ' ...
                    ME.message]);
            end
        end % getConfigurableObj
        
        function def = getDefinition(obj)
            % Return the class name of the plot
            def = obj.ManStruct(1).Definition;
        end % getClassName
        
        
        function displayName = getDisplayName(obj)
            % Return the display name for this plot
            displayName = obj.ManStruct(1).DisplayName;
        end % getDisplayName
        
        function sources = getSources(obj)
            % Return the source cell array for this plot or empty if none
            sources = lower(strtrim(regexp(obj.ManStruct(1).Sources, ',', 'split')));
            if isempty(sources) 
                return;
            end
            if ~isa(sources, 'cell')
                sources = {sources};
            end
            empty = strcmp(sources, '');
            none = strcmp(sources, 'none');
            sources = sources(~empty & ~none);
        end % getSource
        
    end % public methods
    
    methods(Static = true)
        
        function objs = createConfigurableObjs(pList)
            % Create cell array of configurable objects from cell array of plot objects
             objs = cell(1, length(pList));
             for k = 1:length(pList)
                 objs{k} = pList{k}.getConfigurableObj();
             end
        end % createConfigurableObjs
        
        function bfs = createObjects(className, s, keyfun) %#ok<INUSD>
            % Create a list of plot objects from the structure s
            keyfun = @(x) x.('DisplayName');
            bfs = viscore.managedObj.createObjects('visviews.plotObj', ...
                s, keyfun);
        end % createObjects
        
        function fields = getDefaultFields()
            % Default fields are the ones that  are configured.
            fields = viscore.managedObj.getDefaultFields();
            fields = [fields{:}, {'Sources'}];
        end % getDefaultFields
        
    end % static methods
    
end % plotObj

