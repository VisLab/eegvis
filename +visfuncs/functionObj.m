% visfuncs.functionObj  definition and current values of a summary function
%
% The function obj uses lazy evaluation whenever possible, trying not to
% recompute unless required by changes to data or parameters.
%
% Usage:
%   >>  visfuncs.functionObj(objectID, structure)
%   >>  obj = visfuncs.functionObj(objectID, structure)
%
% Description:
% visfuncs.functionObj(objectID, structure) creates a function object
%     with specified ID from a function structure.
%
% obj = visfuncs.functionObj(objectID, structure) returns a handle
%     to the newly created function object.
%
%
% The structure for specifying function objects has the following fields:
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
% Definition	    String representation of function for evaluation with
%                   eval.
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
% Example: 
% Create a function object for kurtosis and print the fields.
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
%      bf = visfuncs.functionObj([], fStruct);
%      bf.printObject();
%      
% Notes:
%   - The function must operate on a 3D array by collapsing dimension 2,
%     resulting in a 2D array.
%   - Specify a function by providing its structure as indicated below.
%   - The function object now keeps a reference to the data object and
%     computes its values only if needed. It also has a unique ID so that
%     the GUI can clear its values if there is a change in parameters.
%   - Functions can have different categories.  Currently only 'block'
%     is supported, meaning that the data is blocked and a single value
%     is computed for each block.
%
% Class documentation:
% Execute the following in the MATLAB command window to view the class 
% documentation for visfuncs.functionObj:
%
%    doc visfuncs.functionObj
%
% See also: viscore.ManagedObj and visfuncs.FunctionConfig
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

% $Log: functionObj.m,v $
% Revision: 1.00  04-Dec-2011 09:11:20  krobbins $
% Initial version $
%

classdef functionObj < hgsetget & viscore.managedObj
    
    properties (Access = private)
        BlockMean = 0;        % overall mean of current block values
        BlockStd = 1;         % overall std dev of current block values
        CurrentData = [];     % handle to blockData object for data
        CurrentLimits = [-inf, inf];   % current limits for graphs that use clipping
        CurrentValues = []    % current block values for this function
        VersionID = -1;       % version ID of current blockData obj or -1 if invalid
    end % private properties
    
    properties(Constant = true)
        ThresholdScopes = ... % allowed threshold scopes
            {'element',  'global'};
        ThresholdTypes = ...  % allowed threshold types
            {'value', 'z score'};
        % To be implemented: 'range ratio', 'scaled rank', 'whisker length
    end % constant properties
    
    methods
        
        function obj = functionObj(objectID, structure)
            % Create a managed function object
            obj = obj@viscore.managedObj(objectID, structure);
            obj.clearValues();
        end % functionObj constructor
        
        function clearValues(obj)
            % Clear data and associated values
            obj.BlockMean = 0;
            obj.BlockStd = 1;
            obj.CurrentData = [];
            obj.CurrentLimits = [-inf, inf];
            obj.CurrentValues = [];
            obj.VersionID = -1;
        end % clearValues
        
        function colors = getBlockColors(obj, bvalues)
            % Return the colors corresponding to this array of block values
            colors = [];
            mask = calculateMask(obj, bvalues);
            if isempty(mask)
                return;
            end
            mask = mask + 1;
            bColor = obj.ManStruct(1).BackgroundColor;
            colors = [bColor; obj.ManStruct(1).ThresholdColors];
            cSize = size(mask);
            colors = reshape(colors(mask(:), :)', [3, cSize]);
            perm = 1:max(3, ndims(colors));
            perm = [perm(2:end) perm(1)];
            colors = permute(colors, perm);
        end % getBlockColors
        
        function colors = getBlockColorsSlice(obj, slice)
            % Return the colors corresponding to this slice
            ds = obj.getBlockSlice(slice);
            colors = obj.getBlockColors(ds);
        end % getBlockColorsSlice
        
        function limits = getBlockLimits(obj)
            % Return cutoffs for graphs such as boxplots that need clipping
            limits = obj.CurrentLimits;
        end % getBlockLimits
        
        function [values, sValues] = getBlockSlice(obj, dSlice)
            % Return function values and starting indices corresponding to this slice
            if ~isempty(dSlice)
                slices = dSlice.getParameters(3);
                slices(2) = [];
            else
                slices = [];
            end
            [values, sValues] = viscore.dataSlice.getDataSlice(...
                                      obj.CurrentValues, slices, [], []);
        end % getBlockSlice
        
        function value = getBlockValue(obj, row, col)
            % Return block value in (row, col) or empty if out of range
            % Note: used for cursor exploration
            value = [];
            try
                value = obj.CurrentValues(row, col);
            catch %#ok<CTCH>
            end
        end % getBlockValue
        
        function values = getBlockValues(obj)
            % Return the current values for this block function
            values = obj.CurrentValues;
        end  % getBlockValues     
        
        function source = getData(obj)
            % Return underlying blockData object for this function
            source = obj.CurrentData;
        end % getData
        
        function [nElements, nSamples, nBlocks] = getDataSize(obj)
            % Return 3D size of underlying data from which
            if isempty(obj.CurrentData)
                nElements = 0;
                nSamples = 0;
                nBlocks = 0;
            else
                [nElements, nSamples, nBlocks] = obj.CurrentData.getDataSize();
            end
        end % getDataSize
        
        function def = getDefinition(obj)
            % Return string definition of this function suitable for eval
            def = obj.ManStruct(1).Definition;
        end % getDefinition
        
        function colors = getThresholdColors(obj)
            % Return a color map with one color for each threshold level
            colors = obj.ManStruct(1).ThresholdColors();
        end % getThresholdColors
        
        function levels = getThresholdLevels(obj)
            % Return a vector of threshold level
            levels = obj.ManStruct(1).ThresholdLevels();
        end % getThresholdLevels
        
        function printObject(obj)
            % Output the contents of this managed object in readable form
            obj.printObject@viscore.managedObj();
            fprintf('Current data size: ');
            if ~isempty(obj.CurrentData)
               [e, s, b] = obj.CurrentData.getDataSize();
               fprintf('[%g, %g, %g]', e, s, b);
            end
            fprintf('\nCurrent block value size: ');
            if ~isempty(obj.CurrentValues)
               [e, b] = size(obj.CurrentValues);
               fprintf('[%g, %g]', e, b);
            end
            fprintf('\n');
        end % printObject
        
        function setData(obj, bData)
            % Set the current data and re-evaluate if data is modified
            %
            % Inputs:
            %   bData     blockData object
            %
            if isempty(bData)
                obj.clearValues();
            elseif strcmpi(bData.getVersionID(), obj.VersionID) == 0
                obj.clearValues();
                obj.VersionID = bData.getVersionID();
                obj.CurrentData = bData;
                obj.reevaluate();
            end
        end % setData
        
    end % public methods
    
    methods (Access = private)
        
        function mask = calculateMask(obj, bvalues)
            % Return mask of quantized block values based on current threshold levels
            scores = obj.calculateScores(bvalues);
            mask = zeros(size(scores));
            for k = 2:length(obj.ManStruct.ThresholdLevels)
                mask(scores >= obj.ManStruct.ThresholdLevels(k - 1) & ...
                    scores < obj.ManStruct.ThresholdLevels(k)) = k - 1;
            end;
            mask(scores > obj.ManStruct.ThresholdLevels(end)) = ...
                length(obj.ManStruct.ThresholdLevels);
            mask = uint8(mask);  % Assume less than 256 threshold levels
        end % calculateMask
        
        function scores = calculateScores(obj, bvalues)
            % Return scores for an array of block data based on this obj
            switch lower(obj.ManStruct.ThresholdType)
                case {'z score'}
                    scores = getZScores(obj, bvalues);
                case {'value'}
                    scores = bvalues;
            end
        end % calculateScores
        
        function scores = getZScores(obj, bvalues)
            % Calculate the z-scores for the current block values
            if isempty(bvalues)
                scores = [];
            else
                scores = (bvalues - obj.BlockMean)./obj.BlockStd;
            end
        end % getZScores
        
        function calculateLimits(obj)
            % Calculate z-score cutoffs for the current threshold levels
            if isempty(obj.CurrentValues) || ...
                    strcmpi(obj.ManStruct.ThresholdType, 'value')
                obj.CurrentLimits = [-inf, inf];
            else
                cValue = obj.ManStruct.ThresholdLevels(end);
                obj.CurrentLimits = [obj.BlockMean - cValue*obj.BlockStd, ...
                    obj.BlockMean + cValue*obj.BlockStd];
            end
        end % calculateLimits
        
        function reevaluate(obj)
            % Evaluate the function and the threshold mask
            fh = str2func(obj.ManStruct.Definition);
            %             [e, s, b] = obj.getDataSize(); %#ok<ASGLU>
            %             obj.CurrentValues = reshape(...
            %                 feval(fh, obj.CurrentData.getData()), e, b);
            if isa(obj.CurrentData, 'viscore.memoryData')
                obj.CurrentValues = obj.CurrentData.funEval(fh);
            elseif isa(obj.CurrentData, 'viscore.hdf5Data')
                 fn = obj.ManStruct.DisplayName;
                 obj.CurrentValues = obj.CurrentData.funEval(fn, fh);
            end
            obj.BlockMean = nanmean(obj.CurrentValues(:));
            obj.BlockStd = nanstd(obj.CurrentValues(:));
            obj.calculateLimits();
        end % reevaluate
        
    end % private methods
    
    methods(Static = true)
        
        function bfs = createObjects(className, s, keyfun) %#ok<INUSD>
            % Return a cell array of objects corresponding to structure s
            keyfun = @(x) x.('ShortName');
            bfs = viscore.managedObj.createObjects('visfuncs.functionObj', ...
                s, keyfun);
        end % createObjects
        
        function fields = getDefaultFields()
            % Default fields are the ones that  are configured.
            fields = viscore.managedObj.getDefaultFields();
            fields = [fields{:}, {'ShortName', 'ThresholdType', ...
                'ThresholdLevels', 'ThresholdColors', 'ThresholdScope', ...
                'BackgroundColor'}];
        end % getDefaultFields
        
        function numLevels = getMaxNumberThresholdLevels(bFuncs)
            % Return max number of threshold levels for a block function list
            numLevels = 1;
            for k = 1:length(bFuncs)
                numLevels = max(numLevels, ...
                    length(bFuncs{k}.ThresholdLevels));
            end
        end % getMaximumNumberThresholdLevels
        
        function [isvalid, msg] = validateFunctionList(list)
            % Validate a cell array of visfuncs.functionObj
            msg = '';
            isvalid = isa(list, 'cell');
            for k = 1:length(list)
                isvalid = isvalid && isa(list{k}, 'visfuncs.functionObj');
            end
            if ~isvalid
                msg = 'Invalid cell array of visfuncs.functionObj';
            end
        end % validateFunctionList
        
        function [isvalid, msg] = validateThreshold(tType, tScope, tLevels, tColors)
            % Validate level and scope criteria for specific threshold types
            [isvalid, msg] = validateThresholdType(tType);
            if ~isvalid
                return;
            end
            [isvalid, msg] = validateThresholdScope(tScope);
            if ~isvalid
                return;
            end
            [isvalid, msg] = validateThresholdLevels(tLevels);
            if ~isvalid
                return;
            end
            [isvalid, msg] = validateThresholdClolors(tColors, tLevels);
            if ~isvalid
                return;
            end
            if ~strcmpi(tType, 'value')
                isvalid = all(tLevels > 0);
                if ~isvalid
                    msg = ['Threshold levels must be positive for type ' tType];
                end
            end
        end  % validateThreshold
        
        function [isvalid, msg] = validateThresholdColors(tColors, tLevels)
            %
            msg = '';
            isvalid = ~isempty(tColors) && isnumeric(tColors) && ...
                isvector(tColors) && size(tColors, 2) == 3 && ...
                size(tColors, 1) == length(tLevels) && ...
                max(tColors(:)) <= 1 && min(tColors(:) >= 0);
            if ~isvalid
                msg = 'Threshold colors n x 3 vectors with values between 0 and 1';
            end
        end % validateThresholdColors
        
        function [isvalid, msg] = validateThresholdLevels(tLevels)
            % Validate the threshold levels basic properties, msg indicates error
            msg = '';
            isvalid = ~isempty(tLevels) && isnumeric(tLevels) && isvector(tLevels);
            if ~isvalid
                msg = 'Threshold levels for quantizing block values must be numeric';
            end
        end % validateThresholdLevels
        
        function [isvalid, msg] = validateThresholdScope(tScope)
            % Validate the threshold scope, msg indicates error
            msg = '';
            isvalid = ~isempty(tScope) && ischar(tScope) && ...
                sum(strcmpi(tScope, visfuncs.functionObj.ThresholdScopes)) == 1;
            if ~isvalid
                msg = 'Threshold scope for defining threshold application range of is invalid';
            end
        end % validateThresholdScope
        
        function [isvalid, msg] = validateThresholdType(tType)
            % Validate the threshold type, msg indicates error
            msg = '';
            isvalid = ~isempty(tType) && ischar(tType) && ...
                sum(strcmpi(tType, visfuncs.functionObj.ThresholdTypes)) == 1;
            if ~isvalid
                msg = 'Threshold type for quantizing block values is invalid';
            end
        end % validateThresholdType
        
       function fStruct = getDefaultFunctions()
            % Field name, class name, class modifier, display name, type, default, options, descriptions
            fStruct = struct( ...
                'Enabled',        {true,         true}, ...
                'Category',       {'block',        'block'}, ...
                'DisplayName',    {'Kurtosis', 'Standard Deviation'}, ...
                'ShortName',      {'K',        'SD'}, ...
                'Definition',     {'@(x) (kurtosis(x, 1, 2))', ...
                '@(x) (std(x, 0, 2))'}, ...
                'ThresholdType',  {'z score',    'z score'}, ...
                'ThresholdLevels', {3,              3}, ...
                'ThresholdColors', {[1, 0, 0],    [0, 1, 1]}, ...
                'BackgroundColor', {[0.7, 0.7, 0.7], [0.7, 0.7, 0.7]}, ...
                'ThresholdScope', {'global',     'global'}, ...
                'Description',    {'Kurtosis computed for each (element, block)', ...
                'Standard deviation for each (element, block)' ...
                });
        end % getDefaultFunctions
        
    end % static methods
    
end % functionObj

