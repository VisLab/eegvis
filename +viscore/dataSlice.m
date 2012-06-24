% viscore.dataSlice  defines a regular subarray for data manipulation
%
% Usage:
%   >>  viscore.dataSlice(type, elements, samples, blocks);
%   >>  obj = viscore.dataSlice(type, elements, samples, blocks)
%
% Outputs:
%    obj         Handle to this class
%
% Description
% viscore.dataSlice() is the identity subarray. That is, when this
%     slice is applied to an array, it returns the array itself.
%
% viscore.dataSlice('key1', 'value1', ...) specifies optional parameter
%    name/value pairs.
%    'NumDim'  Number of dimensions in the slice. The default is 3. If  
%              'NumDim' is omitted and 'Slice' is given, the number of 
%              dimensions is the minimum of 3 and the length of the slice.
%
%    'CombineDim' Vector of dimension numbers to combine when processing 
%              the slice. The default is empty.
%
%    'CombineMethod' Funtion to apply to combine the dimensions to produce
%               this slice. The default is 'mean' which
%               takes the mean of the values in the combine dimensions,
%               ignoring NaNs. Other valid values include 'median',
%               'max' and 'min'.
%
%     'DimNames' Cell array of names of the values plotted along the 
%               slice dimensions. The default names are {'Element', 
%               'Sample', 'Block', 'Dim4', ...}.
%     'Slices'   Cell array of strings specifying the indices of the
%                subarray represented by the slice. For example
%                {':', '4:5', 7} represents the subarray formed
%                by taking all rows, columns 4 and 5, and index 7 along
%                dimension 3.
%
% A data slice does not itself contain data, but contains static methods for 
% extracting data from an array based on the slice specification. 
% For example, a viscore.dataSlice with specification {':', '4', ':'} 
% extracts an unsqueezed subarray from a two-dimensional or three-dimensional 
% array by setting the index in dimension two to 4, provided that 4 is a 
% valid index for the array. Otherwise, the slice extracts an empty array. 
% When presented with a one-dimensional array, this slice 
% extracts a copy of the original array. When presented with a data array  
% of dimension higher than three, this slice replaces the dimensions 
% above three with ':' when evaluating. 
%
% In linked visualizations, a data slice provides information about the
% piece of the data that was clicked so that downstream visualizations
% can react with an appropriate display.
%
% Example: 
% Extract subarrays from various arrays
%
%    data1 = random('exp', 1, [30, 20, 10]); 
%    subData1 = viscore.dataSlice.getDataSlice(data1, {':', '4', ':'}, [], '');
%    data2 = random('exp', 1, [30, 20]); 
%    subData2 = viscore.dataSlice.getDataSlice(data2, {':', '4', ':'}, [], '');
%    data3 = random('exp', 1, [30]); 
%    subData3 = viscore.dataSlice.getDataSlice(data3, {':', '4', ':'}, [], ''); 
%    data4 = random('exp', 1, [30, 20, 10, 8]); 
%    subData4 = viscore.dataSlice.getDataSlice(data4, {':', '4', ':'}, [], '');
%
% Class documentation:
% Execute the following in the MATLAB command window to view the class 
% documentation for viscore.dataSlice:
%
%    doc viscore.dataSlice
%
% See also:  viscore.blockedData


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

% $Log: dataSlice.m,v $
% Revision: 1.00  04-Dec-2011 09:11:20  krobbins $
% Initial version $
%

classdef dataSlice < hgsetget
    
    properties (Access = private)
        CombineDim     % dimensions to combine
        CombineMethod  % method to use in combining dimensions
        DimNames       % names of dimensions
        NumDims        % number of dimensions handled by slice (default 3)
        Slices         % specification of slice suitable for eval
    end % public properties
    
   properties(Constant = true)
        ValidMethods = ... % allowed methods for combining dimensions
            {'mean', 'median', 'max', 'min', 'sum'};
    end % constant properties
    
    methods
        
        function obj = dataSlice(varargin)
            % Create the data splice specification
            obj.parseParameters(varargin{:});
        end % dataSlice constructor
           
        function [slices, names, cDims, cMethod] = getParameters(obj, n)
            % Return names and slices for this slice. If n is empty use slice dimensions
            cDims = obj.CombineDim;
            cMethod = obj.CombineMethod;
            if isempty(n)
                names = obj.DimNames;
                slices = obj.Slices;
                return;
            end
            names = viscore.dataSlice.createNames(n, obj.DimNames);
            slices = viscore.dataSlice.createSlices(n, obj.Slices);
        end % getSliceParameters
        
    end % public methods
    
    methods (Access = private)
        
        function parseParameters(obj, varargin)
            % Parse command line parameters and set defaults
            %
            % Inputs:
            %    varargin   command line parameters for class
            %
            % Notes:
            %   - See viscore.dataSlice.getParser for command line specification
            %   - This method is only called for initialization
            parser = viscore.dataSlice.getParser();
            parser.parse(varargin{:});
            if isempty(parser.Results)
                data = [];
            else
                data = parser.Results;
            end
            
            % Take default number of dimensions from length of slices
            obj.NumDims = data.NumDims;
            if isfield(data, 'Slices') && ~isempty(data.Slices)
                mSize = min(length(data.Slices), 3);
                obj.Slices = data.Slices(1:mSize);
                obj.NumDims = mSize;
            else    
                obj.Slices = viscore.dataSlice.createSlices(obj.NumDims, []);
            end
 
            % Find the number of combine dimensions
            if isempty(data.CombineDim)
                obj.CombineDim = [];
            else
                obj.CombineDim = data.CombineDim;
            end
            
            % Set the combination method
            if (isempty(data.CombineMethod) || ...
                sum(strcmpi(data.CombineMethod, obj.ValidMethods)) == 0)
                obj.CombineMethod = obj.ValidMethods{1};
            else
                obj.CombineMethod = data.CombineMethod;
            end
            
            % Set the dimension names and slices for number of dimensions
            obj.DimNames = viscore.dataSlice.createNames(obj.NumDims, ...
                                        {'Element', 'Sample', 'Block'});
            
            if isfield(data, 'DimNames') && ~isempty(data.DimNames)
                mSize = min(length(data.DimNames), obj.NumDims);
                obj.DimNames(1:mSize) = data.DimNames(1:mSize);
            end

        end % parseParameters
        
    end % private methods
    
    methods (Static = true)
        
        function data = combineDims(data, dims, method)
            % Combine data across dimensions
            if isempty(data) || isempty(dims) || isempty(method)
                return;
            end
            dims(dims > ndims(data)) = [];
            if isempty(dims)
                return;
            end
            switch lower(method)
                case 'mean'
                    eString = 'nanmean(data, dims(k))';
                case 'median'
                    eString = 'nanmedian(data, dims(k))';
                case 'max'
                    eString = 'max(data, [], dims(k))';
                case 'min'
                    eString = 'min(data, [], dims(k))';
                case 'sum'
                    eString = 'sum(data, dims(k))';
                otherwise
                    eString = '';
            end
            if isempty(eString)
                return;
            end
            
            for k = 1:length(dims)
                data = eval(eString);
            end
           
        end % combineDims
        
        function names = createNames(n, nameList)
            % Create a list of names of length n based on nameList
            names = cell(1, n);
            mSize = min(n, length(nameList));
            names(1:mSize) = nameList(1:mSize);
            for k = (mSize + 1):n
                names{k} = ['Dim' num2str(k)];
            end
        end % createNames
        
         function slices = createSlices(n, sliceList)
            % Create a list of slices of length n based on sliceList
            slices = cell(1, n);
            mSize = min(n, length(sliceList));
            slices(1:mSize) = sliceList(1:mSize);
            for k = (mSize + 1):n
                slices{k} = ':';
            end
        end % createSlices
        
        function [sData, sStart, sSizes] = getDataSlice(data, slices, cDims, method)
            % Returns data subarray of data for specified slice
            %
            % Input:
            %    data   array to take the subarray of
            %    slices cell array of string slice specifications 
            %           (e.g., {':', ':', '4'})
            %    cDims  if non empty specifies dimension of subarray to
            %           combine before returning
            %    method string specifying function to use in combining
            %           subarray dimensions. Possible values are
            %           'mean' (the default), 'median', 'max', or 'min.
            %   
            % Output:
            %    sData   resulting subarray
            %    sStart  starting indices in original array
            %    sSizes  sizes of the slices before combination
            sData = data;
            sStart = [];
            if isempty(data) 
                return;
            end
            
            [dSlice, sStart, sSizes] = ...
                viscore.dataSlice.getSliceEvaluation(size(data), slices);
            if isempty(slices)
                return;
            elseif isempty(sStart)
                sData = '';
                return;
            end

            sData = eval(['data(' dSlice ')']);
            if ~isempty(cDims) && ~isempty(method)
                sData = viscore.dataSlice.combineDims(sData, cDims, method);
            end
        end % getDataSlice
        

        function parser = getParser()
            % Create an inputparser for FileSelector
            parser = inputParser;
            parser.addOptional('NumDims', 3, ...
                @(x) validateattributes(x, {'numeric'}, {'positive', 'scalar'}));
            parser.addParamValue('CombineDim', [], ...
                @(x) validateattributes(x, {'numeric'}, {'positive'}));
            parser.addParamValue('CombineMethod', 'mean', ...
                @(x) validateattributes(x, {'char'}, {}));
            parser.addParamValue('DimNames', {}, ...
                @(x) validateattributes(x, {'cell'}, {}));
            parser.addParamValue('Slices', [], ...
                @(x) validateattributes(x, {'cell'}, {}));
        end % getParser()
        
                function [dSlice, sStart, sSizes] = getSlices(sizes, slices)
            nd = max(length(sizes), 3); % Always return slice starts at least 3
            sSizes = ones(1, nd);
            sSizes(1:length(sizes)) = sizes;
            [dSlice, sStart, sSizes] = ...
                    viscore.dataSlice.getSliceEvaluation(sSizes, slices);
        end % getSlices
        
        
       function [evalSlice, startSlice, sizeSlice] = getSliceEvaluation(aSizes, slices)
            % Returns evaluation string and vector of start values for slice 
            %
            % Input:
            %    aSizes  vector containing sizes of an array to be sliced
            %    slices  cell array of string slice specifications 
            %            (e.g., {':', ':', '4'})
            %   
            % Output:
            %    evalSlice   string suitable for evaluating slice on array
            %                 with dimensions aSize
            %    startSlice  starting values of the slices
            %
            %    sizeSlice   sizes of the slices
            %
            % Always return starts for at least 3 dimensions. If slice is
            % completely out of range in one dimension, both evalSlice and
            % startSlice are empty.
            evalSlice = '';
            startSlice = [];
            sizeSlice = [];
            if isempty(aSizes) 
                return;
            end
            nd = max(length(aSizes), 3); % Always return at least 3 slice starts
            startSlice = ones(1, nd);
            sizeSlice = ones(1, nd);
            sizeSlice(1:length(aSizes)) = aSizes;
            if isempty(slices)
                return;
            end
            sizes = ones(1, nd);
            
            sizes(1:length(aSizes)) = aSizes;
            nSlices = length(slices);
            for k = 1:nd
                nextSlice = ':';
                if nSlices >= k && ~strcmp(slices{k}, ':')  % generic
                    sValues = eval(slices{k});
                    sValues(sValues > sizes(k)) = [];
                    if isempty(sValues)
                        evalSlice = '';
                        startSlice = [];
                        return;
                    end
                    startSlice(k) = min(sValues);
                    sizeSlice(k) = length(sValues);
                    nextSlice = ['[' num2str(sValues) ']'];
                end
                evalSlice = [evalSlice ',' nextSlice]; %#ok<AGROW>
            end
            if ~isempty(evalSlice)  % Take off leading comma if needed
                evalSlice = evalSlice(2:end);
            end
            
        end % getSliceEvaluation
        
        function rString = rangeString(start, numValues)
            % Return a range string of form 'a:b' based on start 
            if numValues == 1
                rString = num2str(start);
            else
                rString = [num2str(start) ':' ...
                           num2str(start + numValues - 1)];
            end
        end % rangeString
        
        function sString = slicesToString(slices)
            % Return the string representation of slice indices
             sString = '';
             if isempty(slices) || ~iscell(slices)
                 return;
             end
             for k = 1:length(slices) - 1
                sString = [sString  slices{k} ',']; %#ok<AGROW>
             end
             sString = [sString slices{end}];
        end % slicesToString
    end % static methods
    
end % dataSlice

