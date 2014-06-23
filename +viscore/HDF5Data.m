% viscore.blockedData   manages a data array for visualization
%
% Usage:
%   >>  viscore.blockedData(data, dataID)
%   >>  viscore.blockedData(data, dataID, 'key1', 'value1', ...)
%   >>  obj = viscore.blockedData(...)
%
% Description:
% viscore.blockedData(data, dataID) creates a data object for the
%    visualization. The data parameter is an array, and the dataID is
%    a string identifying the data. This ID is used as part of visualization
%    titles.
%
%    Blocked data objects can be reshaped or reblocked along a specified
%    dimension called the BlockDim. A summary function such as standard
%    deviation or kurtosis is applied along this dimension to provide a
%    summary of the function.
%
%    The data of blockData objects is always converted to double, even if it
%    comes in as single or some other type.
%
%
% viscore.blockedData(data, dataID, 'key1', 'value1', ...| specifies
%     optional name/value parameter pairs:
%   'BlockDim'         array dimension for reblocking (defaults to 2)
%   'BlockSize'        window size for reblocking the data
%   'BlockStartTimes'  times in seconds of begining of each block
%   'BlockTimeScale'   times corresponding to block samples
%   'ElementLocations' structure of element (channel) locations
%   'Epoched'          if true, data is epoched and can't be reblocked
%   'Events'           blockedEvents object if this data has events
%   'PadValue'         numeric value to pad uneven blocks (defaults to 0)
%   'SampleRate'       sampling rate in Hz for data (defaults to 1)
%
% obj = viscore.blockedData(...) returns a handle to the newly created
% object.
%
% Example 1:
% Create a blocked data object for a random array
%   data = random('normal', 0, 1, [32, 1000, 20]);
%   bd = viscore.blockedData(data, 'Normal(0, 1)');
%
% Example 2:
% Reblock a data object in blocks of 500 frames
%   data = random('normal', 0, 1, [32, 1000, 20]);
%   bd = viscore.blockedData(data, 'Normal(0, 1)');
%   bd.reblock(500);
%   [rows, cols, blks] = bd.getDataSize();
%
% Notes:
%  - Data that is initially epoched cannot be reblocked.
%  - An empty sampling rate implies that the data is not sampled at a fixed
%    sampling rate. This feature will be supported in the future in a child class.
%  - This data object has a version ID that changes each time the data
%    is modified. The version ID enables functions to know whether
%    to recompute their values.
%  - The BlockDim is set in the constructor and later changes do not affect
%    the blocking.
%  - The|BlockTimeScale| is in ms if epoched and s if not epoched
%
% The ElementLocations structure follows the standard EEGLAB chanlocs
% structure with the following fields:
%    theta    polar coordinates theta for flattened scalp
%    radius   polar-coordinate radii (arc_lengths) for flattened scalp
%    labels   short label of element name
%    X        x coordinate of element location (nose is +X direction)
%    Y        y coordinate of element location
%    Z        z coordinate of element location
%
%
%
% Class documentation:
% Execute the following in the MATLAB command window to view the class
% documentation for viscore.blockedData:
%
%    doc viscore.blockedData
%
% See also: viscore.dataSlice and visviews.DualView
%

%1234567890123456789012345678901234567890123456789012345678901234567890

% Copyright (C) Kay Robbins, UTSA, July 1, 2011, krobbins@cs.utsa.edu
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
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
%
% $Log: blockedData.m,v $
% $Revision: 1.00 04-Dec-2011 09:11:20 krobbins $
% $Initial version $
%

classdef HDF5Data < hgsetget
    
    properties (Access = private)
        BlockDim              % dimension used for reblocking (default 2)
        BlockSize = [];       % window size to use when data is reshaped
        Data;                 % 2D or 3D array of data, first dim for elements
        DataID                % ID of the data contained in this object
        HDF5File;             % hdf5 file that contains a data array
        VersionID             % version ID of this data
    end % private properties
    
    methods
        
        function obj = HDF5Data(data, dataID, hdf5File, varargin)
            % Constructor parses parameters and sets up initial data
            c = viscore.counter.getInstance();
            obj.VersionID = num2str(c.getNext());  % Get a unique ID
            obj.parseParameters(data, dataID, hdf5File, varargin{:});
        end % blockedData constructor
        
        function values = funEval(obj, fn, fh)
            try
                % Get data from file if it exists
                values = h5read(obj.HDF5File, ['/',fn,...
                    '_',num2str(obj.BlockSize)]);
            catch
                % Compute the data and store it in the file
                [e, s, b] = obj.getDataSize(); %#ok<ASGLU>
                values = reshape(...
                    feval(fh, h5read(obj.HDF5File,'/data')), e, b);
                h5create(obj.HDF5File,['/',fn,...
                    '_',num2str(obj.BlockSize)],size(values));
                h5write(obj.HDF5File,['/',fn,...
                    '_',num2str(obj.BlockSize)], values);
            end
        end % funEval
        
        function dataID = getDataID(obj)
            % Return the data ID
            dataID = obj.DataID;
        end % getDataID
        
        function [nElements, nSamples, nBlocks] = getDataSize(obj)
            % Return number of elements, samples and blocks in data
            dims = h5read(obj.HDF5File, '/dims');
            nElements = dims(1);
            nSamples = obj.BlockSize;
            nBlocks = ceil(dims(2) / obj.BlockSize);
        end % getDataSize
        
        function reblock(obj, blockSize)
            obj.BlockSize = blockSize;
        end
        
    end % public methods
    
    methods(Access = private)
        
        function parseParameters(obj, data, dataID, hdf5File, varargin)
            % Parse parameters provided by user in constructor
            parser = viscore.HDF5Data.getParser();
            parser.parse(data, dataID, hdf5File, varargin{:})
            pdata = parser.Results;
            
            % Assign specified private properties
            obj.BlockDim = pdata.BlockDim;
            obj.BlockSize = pdata.BlockSize;
            obj.DataID = pdata.DataID;
            obj.Data = double(pdata.Data);
            
            % Check the hdf5 file
            checkHDF5File(obj, pdata);
            
        end % parseParameters
        
        function checkHDF5File(obj, pdata)
            % Case 1
            if ~isempty(pdata.Data) && ...
                    ~exist(pdata.HDF5File, 'file')
                createHDF5(double(pdata.Data), pdata.HDF5File);
                obj.HDF5File = pdata.HDF5File;
                % Case 2
            elseif ~isempty(pdata.Data) && ...
                    exist(pdata.HDF5File, 'file') && ~pdata.Overwrite
                obj.HDF5File = pdata.HDF5File;
                % Case 3
            elseif isempty(pdata.Data) && ...
                    exist(pdata.HDF5File, 'file')
                obj.HDF5File = pdata.HDF5File;
                % Case 4
            elseif isempty(pdata.Data) && ...
                    ~exist(pdata.HDF5File, 'file')
                throw(MException('HDF5Chk:NoData', ...
                    'Data and HDF5 file cannot be empty'));
            end
        end % compareDataAndHDF5File
        
        function data = computeData(data)
            
        end
        
    end % private methods
    
    methods(Static = true)
        
        function parser = getParser()
            % Create a parser for blockedData
            parser = inputParser;
            parser.addRequired('Data', ...
                @(x) (isempty(x) || isnumeric(x)));
            parser.addRequired('DataID', ...
                @(x) validateattributes(x, {'char'}, {}));
            parser.addRequired('HDF5File', ...
                @(x) (isempty(x) || ischar(x)));
            parser.addParamValue('Overwrite', false, ...
                @(x) validateattributes(x, {'logical'}, {}));
            parser.addParamValue('BlockDim', 2, ...
                @(x) validateattributes(x, {'numeric'}, ...
                {'scalar', 'nonnegative'}));
            parser.addParamValue('BlockSize', 1000, ...
                @(x) validateattributes(x, {'numeric'}, ...
                {'scalar', 'nonnegative'}));
        end % getParser
        
    end % static methods
    
end % blockedData