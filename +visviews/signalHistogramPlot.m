% visviews.signalHistogramPlot() display histogram of signal values
%
% Usage:
%   >>   visviews.signalHistogramPlot(parent, manager, key)
%   >>   obj = visviews.signalHistogramPlot(parent, manager, key)
%
% Inputs:
%    parent     parent container for the panel
%    manager    dataManager handling configuration
%    key        string used as key to identify for property configuration
%
% % Outputs:
%    obj        handle to the newly created object
%
% Notes:
%   - If manager is empty, use the class defaults.
%   - If key is empty, use the class name
%   - Many summaries supported by this viewer are window or epoch oriented.
%   - Some displays treat epoched data differently than non-epoched data.
%   - Epoched data may not be continuous and cannot be reblocked by
%     changing the block size.
%
% Author: Kay Robbins, UTSA,
%
% See also: visviews.dualView(), visviews.cursorExplorable()
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

% $Log: signalHistogramPlot.m,v $
% Revision: 1.00  04-Dec-2011 09:11:20  krobbins $
% Initial version $
%

classdef signalHistogramPlot < visviews.axesPanel & visprops.configurable 
 
    properties
        DefaultColor = [0.7, 0.7, 0.7];      % color used in various places
        HistogramColor = [0.85, 0.85, 0.85]; %
        NumBins = 20;                        % number of bins used
        SignalLabel = '{\mu}V';              % label used for the signals
    end % public properties
    
    properties(Access = private)
        BlockSize = 1;
        Colors = [];
        CurrentSource = [];
        CurrentElement = [];
        CurrentWindow = [];
        EpochTimes = [];
        PlotWindow = true;
        SampleRate = 1;
        Selected = [];
        SelectedHandle = [];          % handle of selected signal or empty
        SelectedSignal = [];          % data in selected signal or empty
        SignalHistogram = []          % panel with signal histogram
        Signals = [];
        SignalScale = 1;
        XValues = [];
    end % private properties
    
    methods 
        
        function obj = signalHistogramPlot(parent, manager, key)
            % Constructor must have parent for axesPanel
            obj = obj@visviews.axesPanel(parent);
            obj = obj@visprops.configurable(key);
            % Update properties if any are available
            if isa(manager, 'viscore.dataManager')
                visprops.property.updateProperties(obj, manager);
            end
            set(obj.MainAxes, 'Box', 'on',  'Tag', 'signalHistogramAxes', ...
                'ActivePositionProperty', 'position');
        end % signalHistogramPlot constructor
        
        function plot(obj, visData, bFunction, dslice)
            % Plot the specified slice of visData
            obj.CurrentSource = visData; 
            bFunction.setData(visData);
            [nElements, nSamples, nBlocks] = visData.getDataSize(); %#ok<NASGU,ASGLU>
            [slices, names, cDims] = dslice.getParameters([]);
            obj.Signals = squeeze(viscore.dataSlice.getDataSlice(visData.getData(), [], [], []));
            if isempty(obj.Signals)
                warning('signalHistogramPlot:plotSlice', ...
                    'must have at least 2 samples to plot');
                return;
            end  
            if isempty(cDims) || ~isempty(intersect(cDims, 3))  % Plot all elements for a window
                xBaseString = [names{3} ' ' slices{3}];
                yBaseString = names{1};
                obj.CursorString = '';
                obj.PlotWindow = true;
                obj.CurrentWindow = str2double(slices{3});
                obj.CurrentElement = [];
                obj.XLimOffset = (obj.CurrentWindow - 1)*size(obj.Signals, 2)/visData.SampleRate;
            elseif ~isempty(intersect(cDims, 1))  % Plot all windows for an element
                obj.Signals = (obj.Signals)';
                xBaseString  = [names{1} ' ' slices{1}];
                yBaseString = names{3};
                obj.PlotWindow = false;
                obj.CurrentWindow = [];
                obj.CurrentElement = str2double(slices{1});
                obj.XLimOffset = 0;
            else
                warning('signalHistogramPlot:plotSlice', ...
                    'array slice is empty and cannot be plotted');
                return;
            end
            obj.Colors = bFunction.getBlockColorsSlice(dslice);
            obj.CursorString = '';
            obj.BlockSize = size(obj.Signals, 2);
            obj.SampleRate = visData.SampleRate;
            obj.EpochTimes = visData.EpochTimes;
           if visData.isEpoched()    % add time scale to x label
                obj.EpochTimes = visData.EpochTimes(...
                    dimStarts(2):obj.BlockSize - 1);
                obj.XValues = obj.EpochTimes;
                xBaseString = ['Time (ms) [' xBaseString ']'];
            else
                obj.EpochTimes = [];
                obj.XValues = obj.XLimOffset + ...
                    (0:(obj.BlockSize - 1))/visData.SampleRate;
                xBaseString = ['Time (s) [' xBaseString ']'];
            end
            obj.SelectedHandle = [];
            obj.SelectedSignal = [];
            obj.YString = yBaseString;
            obj.XString = xBaseString;
            obj.displayPlot();
        end % plotSlice
               
        function s = updateString(obj, point)
            %  Translate point to data units and make a string
            s = '';   % string to be returned
            [x, y, xInside, yInside] = getDataCoordinates(obj, point);
            if ~xInside || ~yInside
                return;
            end
            c = ceil([x, y] - 0.5);
            z = obj.CurrentFunction.BlockValues(c(2), c(1));
            s = {[obj.CursorString{1} num2str(c(1))]; ...
                [obj.CursorString{2} num2str(c(2))]; ...
                [obj.CursorString{3} num2str(z)]};
        end % updateString
 
    end % public methods
    
    methods(Access = private)
       function displayPlot(obj) 
            % Plot the histogram and boxplot
            obj.reset();
            set(obj.MainAxes, 'Box', 'on',  'Tag', 'signalHistogramPlot', ...
                'ActivePositionProperty', 'position'); 
            d = obj.Signals(:);
            [hHeight, xout] = hist(d, obj.NumBins);
            hHeight = hHeight/length(d);  % probability
            hFact = floor(1/max(hHeight));
            hTop = ceil(max(hHeight)*hFact)/hFact;      % top scale of histogram
            boxplot(obj.MainAxes, d, 'Notch', 'on', ...
                'Positions', 1.5*hTop, 'Widths', 0.25*hTop, ...
                'orientation', 'horizontal', 'Labels', {});
            bar(obj.MainAxes, xout, hHeight, 1.0, ...
                'Facecolor', obj.HistogramColor);
            set(obj.MainAxes, 'YLimMode', 'manual', 'YLim', [0, 2*hTop], ...
                'YTickMode', 'manual', 'YTick', [0, hTop/2, hTop], ...
                'YTickLabelMode', 'manual', ...
                'YTickLabel', {'0', '', num2str(hTop)});
            obj.XString = obj.SignalLabel;
            obj.CursorString = {'Val: '};  
            obj.YString =  '';
            obj.redraw();
        end % plot
        
    end % private methods
 
    methods (Static = true)  
        
        function settings = getDefaultProperties()
            % Structure specifying how to set configurable public properties
            cName = 'visviews.signalHistogramPlot';
            settings = struct( ...
                 'Enabled',       {true}, ...
                 'Category',      {cName}, ...
                 'DisplayName',   {'Histogram bar color'}, ...
                 'FieldName',     {'HistogramColor'}, ... 
                 'Value',         {[0.8, 0.8, 0.8]}, ...
                 'Type',          {'visprops.colorProperty'}, ...
                 'Editable',      {true}, ...
                 'Options',       {''}, ...
                 'Description',   {'Color of the histogram bars'} ...
                                   );
       end % getDefaultProperties
    
    end % static methods
 
end % signalHistogramPlot

