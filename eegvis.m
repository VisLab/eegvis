% eegvis  creates figure window with multi-level summary/details viewer
%
% Usage:
%   >>  eegvis(data)
%   >>  eegvis(data, 'key1', 'value1', ....)
%   >>  hfig = eegvis(...)
%
% Input
%     data           viscore.blockedData object or a 3D or 2D array of data
%
% Optional inputs:
%    'Functions'      dataManager, structure, or cell array of initial functions
%    'Plots'          dataManager, structure, or cell array of initial plots
%    'Properties'     dataManager, structure, or cell array of initial properties
%
% Outputs:
%     hfig             handle to the figure of eegVIS
%
%% |eegvis(data)| creates a summary/detail viewer of |data|. The |data|
% argument can be an array or an object of type viscore.blockedData.
%
% The resulting viewer is divided into two levels. The top portion 
% contains multiple summary views organized by tabs. The bottom 
% portion contains various detail panels, which display relatively 
% small portions of the data. A user selects detail views by clicking 
% a summary view. The user can configure the arrangement of viewing 
% panels and how summary and detail panels link.
%
% |eegvis(data, 'name1', 'value1', ....)| specifies optional parameter 
% name/value pairs:
%    'Functions'      dataManager, structure, or cell array of 
%                     initial functions
%
%    'Plots'          dataManager, structure, or cell array of 
%                     initial plots
%
%    'Properties'     dataManager, structure, or cell array of 
%                     initial properties
%
% visviews.dualView is configurable, resizable, and clickable. It
% is also a container for a cursor explorer.
%
% Configurable properties
% The visviews.dualView has five configurable parameters: 
%
% BlockName specifies base name of the windows in the block summaries
%    for non-epoched data.
%
% BlockSize specifies the number of frames in a block for non-epoched
%    data (e.g., 'Window').
%
% ElementName specifies the base name of an element (e.g., 'Channel').
%
% EpochName specifies the base name of the windows in block summaries
%    for epoched data.
%
% VisName specifies the prefix used for the name on the figure window 
%    title bar.
%
% Example:
% Create a viewer to show some data
%   data = random('exp', 2, [32, 1000, 20]); % Create some random data
%   eegvis(data);                            % View the data
%
% Notes:
%   - Many summaries supported by this viewer are window or epoch oriented.
%   - Some displays treat epoched data differently than non-epoched data.
%   - Epoched data may not be continuous and cannot be reblocked by
%     changing the block size.
%
% Class documentation:
% Execute the following in the MATLAB command window to view the class 
% documentation for visviews.dualView:
%
%    doc visviews.dualView
%
% See also: visviews.dualView, eegBrowse, and eegplugin_eegvis
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

% $Log: dualView.m,v $
% Revision: 1.00  04-Dec-2011 09:11:20  krobbins $
% Initial version $
%


function hfig = eegvis( data, varargin )
% Wrapper to call to visviews.dualView
    obj = visviews.dualView('VisData', data, varargin{:});
    if isvalid(obj)
        hfig = obj.VisFig;
    else
        hfig = [];
    end

end % eegvis

