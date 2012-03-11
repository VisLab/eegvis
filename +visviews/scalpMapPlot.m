% visviews.scalpMapPlot() displays element vs block values as an image
%
% Usage:
%   >>   visviews.scalpMapPlot(parent, manager, key)
%   >>   obj = visviews.scalpMapPlot(parent, manager, key)
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

% $Log: scalpMapPlot.m,v $
% Revision: 1.00  04-Dec-2011 09:11:20  krobbins $
% Initial version $
%

classdef scalpMapPlot < visviews.axesPanel  & visprops.configurable 
 
    properties
        ImageBackground = [0.7, 0.7, 0.7];  %  color indicating no activity
        ImageMap = [];                      %  color map (truecolor) of the block data
    end % public properties
    
    properties (Access = private)
        CurrentFunction = [];   % block function that is currently displayed
    end % private properties
    
    properties(Constant = true)
        BLANKINGRINGWIDTH = 0.0350;
        CIRCGRID = 201;
    end % constant properties 
    
    methods
        
        function obj = scalpMapPlot(parent, manager, key)
            % Constructor must have parent for axesPanel
            obj = obj@visviews.axesPanel(parent);
            obj = obj@visprops.configurable(key);
            % Update properties if any are available
            if isa(manager, 'viscore.dataManager')
                visprops.property.updateProperties(obj, manager);
            end
            set(obj.MainAxes, 'Box', 'on',  'Tag', 'scalpMapAxes', ...
                'ActivePositionProperty', 'position');
        end % scalpMapPlot constructor
        
        function colors = getColorMap(obj, numEntries) 
            % Returns a colormap for image plot visualizations
            % --TO DO: generalize to selectable color map
            if isempty(obj.ImageBackground)
                colors = jet(numEntries + 1);
            else
               colors = [obj.ImageBackground; jet(numEntries)];
            end
        end % getColorMap
        
        function colors = getWindowColors(obj, visData, window) %#ok<INUSL>
            %
            cColors = get(obj.ImageMap, 'CData');
            if window < 1 || window > size(cColors, 2)
                colors = [];
            else
                colors = squeeze(cColors(:, window, :));
            end
        end % getWindowColors
        
        function plot(obj, visData, blockName, elementName, bFunction)
            %
            obj.reset();
            set(obj.MainAxes, 'Box', 'on',  'Tag', 'scalpMapAxes', ...
                'ActivePositionProperty', 'position');
            if ~isfield(visData, 'ElementLocations') % Map info is not available
                return;
            end                            
%             bFunction.setValues(visData);    % Make sure data is correct
%             obj.CurrentFunction = bFunction; % Remember for data explorer
%             [nElements, nSamples, nBlocks] = visData.getDataSize();   %#ok<ASGLU>
%             yLimits = [0.5, nElements + 0.5];
%             xLimits = [0.5, nBlocks + 0.5];
%             yTickLabels = cell(1, nElements);
%             yTickLabels{1} = '1';
%             yTickLabels{nElements} = num2str(nElements);
%             colors = obj.getColorMap(length(bFunction.getValue(1, 'ThresholdLevels')));
%             if isempty(obj.CurrentFunction)
%                 imageMask = [];   %This is a problem-----------------
%             else
%                 imageMask = bFunction.getBlockMask() + 1;
%             end
%             cData = reshape(colors(imageMask(:), :)', 3, nElements, nBlocks);
%             cData = permute(cData, [2, 3, 1]);
%             obj.ImageMap = image(cData, 'Parent', obj.MainAxes, 'Tag', 'ImageMap');
%             set(obj.ImageMap, 'HitTest', 'off') %Get position from axes not image
%             set(obj.MainAxes, ...
%                 'YLimMode', 'manual', 'YLim', yLimits, ...
%                 'YTickMode','manual', 'YTick', 1:nElements, ...
%                 'YTickLabelMode', 'manual', 'YTickLabel', yTickLabels, ...
%                 'XLimMode', 'manual', 'XLim', xLimits);
%            
%             obj.XString = blockName;
%             obj.CursorString = {'x: '; 'y: '; ...
%                 [bFunction.getValue(1, 'ShortName') ': ']};
%             if ~isempty(blockName)
%                 obj.CursorString{1} = [blockName(1) ': '];
%             end
%             
%             obj.YString =  elementName;
%             if ~isempty(elementName)
%                 obj.CursorString{2} = [elementName(1) ': '];
%             end
         end % plot
        
        function s = updateString(obj, point)
            % Return [Block, Element, Function] value string for point
            s = '';   % String to be returned
            try   % Use exception handling for small round-off errors
                p = getpixelposition(obj.MainAxes, true);
                if point(1) < p(1) || point(2) < p(2) || ...
                        point(1) >= p(1) + p(3) || point(2) >= p(2) + p(4)
                    return    % not on this graph so return an empty string
                end
                % Translate point to data units and make a string
                a = get(obj.MainAxes,  'XLim');
                x = (a(2) - a(1))*(point(1) - p(1))/p(3) + a(1);
                b = get(obj.MainAxes,  'YLim');
                y = (b(1) - b(2))*(point(2) - p(2))/p(4) + b(2);
                c = ceil([x, y] - 0.5);
                z = obj.CurrentFunction.BlockValues(c(2), c(1));
                s = {[obj.CursorString{1} num2str(c(1))]; ...
                    [obj.CursorString{2} num2str(c(2))]; ...
                    [obj.CursorString{3} num2str(z)]};
            catch  %#ok<CTCH>
            end        
        end % updateString 
        
    end % public methods
 
    methods (Static = true)  
        
        function settings = getDefaultProperties()
            % Structure specifying how to set configurable public properties
            cName = 'visviews.scalpMapPlot';
            settings = struct( ...
                 'Enabled',       {true}, ...
                 'Category',      {cName}, ...
                 'DisplayName',   {'Image background color'}, ...
                 'FieldName',     {'ImageBackground'}, ... 
                 'Value',         {[0.7, 0.7, 0.7]}, ...
                 'Type',          {'visprops.colorProperty'}, ...
                 'Editable',      {true}, ...
                 'Options',       {''}, ...
                 'Description',   {'scalpMapPlot background color (cannot be empty)'} ...
                                   );
       end % getDefaultProperties

    end % static methods
 
end % scalpMapPlot

