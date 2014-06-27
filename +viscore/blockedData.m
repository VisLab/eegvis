classdef (Abstract) blockedData < hgsetget
    %BLOCKEDDATA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = protected)
        BlockDim              % dimension used for reblocking (default 2)
        BlockSize             % window size to use when data is reshaped
        BlockStartTimes       % start times of blocks in seconds
        BlockTimeScale        % time offsets in seconds for block samples
        DataID                % ID of the data contained in this object
        ElementLocations      % element locations structure with ElementFields
        Epoched;              % true if the data is epoched
        Events;               % blockedEvent object if this object has events
        OriginalMean;         % overall mean of data set (before padding)
        OriginalPrctile;      % original percentiles
        OriginalStd           % overall std of data set (before padding)
        PadValue              % use to pad data if not divisible by BlockSize
        SampleRate            % sampling rate in Hz of data
        TotalValues           % total number of values in original data
        VersionID             % version ID of this data
    end
    
    methods(Abstract)
        values = funEval(obj, fn, fh);
        [nElements, nSamples, nBlocks] = getDataSize(obj);
        [values, sValues] = getDataSlice(obj, dSlice);
        [tMean, tStd, tLow, tHigh] = getTrimValues(obj, percent, data);
        reblock(obj, blockSize); 
    end
    
    methods
        function obj = blockedData(dataID, varargin)
            % Constructor parses parameters and sets up initial data
            c = viscore.counter.getInstance();
            obj.VersionID = num2str(c.getNext());  % Get a unique ID
            obj.parseParameters(dataID, varargin{:});
        end
        
        function blockSize = getBlockSize(obj)
            % Return current block size
            blockSize = obj.BlockSize;
        end % getBlockSize
        
        function bStarts = getBlockStartTimes(obj, varargin)
            % Return a vector of the block or epoch start times
            if nargin == 1
                bStarts = obj.BlockStartTimes;
            else
                bStarts = obj.BlockStartTimes(varargin{1});
            end
        end % getBlockStartTimes
        
        function bTimes = getBlockTimeScale(obj, varargin)
            % Return the relative times of individual samples in one block
            if nargin == 1
                bTimes = obj.BlockTimeScale;
            else
                bTimes = obj.BlockTimeScale(varargin{1});
            end
        end % getBlockTimeScale
        
        function dataID = getDataID(obj)
            % Return the data ID
            dataID = obj.DataID;
        end % getDataID
        
        function elocs = getElementLocations(obj)
            % Return the structure containing element locations
            elocs = obj.ElementLocations;
        end % getElementLocations
        
        function events = getEvents(obj)
            % Return the blockedEvents object containing events for this data
            events = obj.Events;
        end % getEvents
        
        function oMean = getOriginalMean(obj)
            % Return the overall mean of original data
            oMean = obj.OriginalMean;
        end % getOriginalMean
        
        function oStd = getOriginalStd(obj)
            % Return the overall standard deviation of original data
            oStd = obj.OriginalStd;
        end % getOriginalStd
        
        function srate = getSampleRate(obj)
            % Return sample rate for this data
            srate = obj.SampleRate;
        end % getSampleRate
        
        function nValues = getTotalValues(obj)
            % Return total number of values in original data (before padding)
            nValues = obj.TotalValues;
        end % getTotalValues
        
        function version = getVersionID(obj)
            % Return version ID of this data source
            version = obj.VersionID;
        end % getVersionID
        
        function e = isEpoched(obj)
            % Return true if data is epoched and false otherwise
            e = obj.Epoched;
        end % isEpoched
        
        
    end
    
    methods(Access = private)
        
        function parseParameters(obj, dataID, varargin)
            % Parse parameters provided by user in constructor
            parser = viscore.blockedData.getParser();
            parser.parse(dataID, varargin{:})
            pdata = parser.Results;
            
            % Assign specified private properties
            obj.BlockDim = pdata.BlockDim;
            obj.BlockSize = pdata.BlockSize;
            obj.BlockStartTimes = pdata.BlockStartTimes;
            obj.BlockTimeScale = obj.BlockTimeScale;
            obj.DataID = pdata.DataID;
            obj.ElementLocations = pdata.ElementLocations;
            obj.Epoched = pdata.Epoched;
            obj.Events = pdata.Events;
            obj.OriginalMean = [];        
            obj.OriginalPrctile = [];     
            obj.OriginalStd = [];          
            obj.PadValue = pdata.PadValue;
            obj.SampleRate = pdata.SampleRate;
            obj.TotalValues = [];
        end % parseParameters
        
    end
    
    methods(Static = true)
        
        function parser = getParser()
            % Create a parser for memoryData
            parser = inputParser;
            parser.addRequired('DataID', ...
                @(x) validateattributes(x, {'char'}, {}));
            parser.addParamValue('SampleRate', 1, ...
                @(x) validateattributes(x, {'numeric'}, ...
                {'scalar', 'nonempty', 'positive'}));
            parser.addParamValue('ElementLocations', [], ...
                @(x) (isempty(x) || isequal(x, struct()) || (isstruct(x)) ...
                && sum(isfield(x, viscore.memoryData.ElementFields)) ...
                == length(viscore.memoryData.ElementFields)));
            parser.addParamValue('BlockDim', 2, ...
                @(x) validateattributes(x, {'numeric'}, ...
                {'scalar', 'nonnegative'}));
            parser.addParamValue('BlockSize', 1000, ...
                @(x) validateattributes(x, {'numeric'}, ...
                {'scalar', 'nonnegative'}));
            parser.addParamValue('BlockStartTimes', [], ...
                @(x) validateattributes(x, {'numeric'}, {}));
            parser.addParamValue('BlockTimeScale', [], ...
                @(x) validateattributes(x, {'numeric'}, {}));
            parser.addParamValue('Epoched', false, ...
                @(x) validateattributes(x, {'logical'}, {}));
            parser.addParamValue('Events', [], ...
                @(x) (isempty(x) || (isstruct(x)) && ...
                sum(isfield(x, {'type', 'time'})) == 2));
            parser.addParamValue('PadValue', 0, ...
                @(x) validateattributes(x, {'numeric'}, {'scalar'}));
        end % getParser
        
    end % static methods
    
end

