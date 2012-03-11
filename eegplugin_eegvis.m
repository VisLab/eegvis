% eegplugin_eegvis  makes eegbrowse and eegvis plug in to EEGLAB menus
%     
% Usage:
%   >> eegplugin_eegvis(fig, trystrs, catchstrs)
%
%% Description
% eegplugin_eegvis(fig, trystrs, catchstrs) makes eegvis and eegbrowse 
%    plugins for EEGLAB. The eegvis function displays the two-level viewer as a 
%    visualization tool from the EEGLAB Plot menu. The eegbrowse function
%    starts a previewer accessible from the EEGLAB File menu. 
% 
%    The fig, trystrs, and catchstrs arguments follow the
%    convention for plugins to EEGLAB. The fig argument holds the figure
%    number of the main EEGLAB GUI. The trystrs and catchstrs arguments
%    hold the try and catch strings for EEGLAB menu callbacks.
%
% Place the eegvis folder in the |plugins| subdirectory of EEGLAB.
% EEGLAB should detect the plugin on start up.  
%
% Notes:
%   See Contents.m for the contents of this plugin.
%
% See also: eeglab, pop_eegvis, pop_eegbrowse, eegbrowse, and
% visviews.DualView
%

%
% Copyright (C) 2011 Kay Robbins, UTSA, krobbins@cs.utsa.edu
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
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1.07  USA

% $Log: eegplugin_eegvis.m,v $
% Revision 1.0 20-Mar-2011 09:08:57  kay
% Initial revision
%

function vers = eegplugin_eegvis(fig, trystrs, catchstrs)

vers = 'eegvis1.0';
if nargin < 3
    error('eegplugin_eegvis requires 3 arguments');
end;

% add eegvis folder to path if it isn't already there
if ~exist('eegplugin_eegvis-subfoldertest.m', 'file')  % Dummy file to make sure not added
    p = which('pop_eegvis.m');
    p = p(1:(strfind(p, 'pop_eegvis.m') - 2));
    addpath(genpath(p));  % Add all subfolders to path too
end;

% Add to EEGLAB plot menu for current EEG dataset
parentMenu = findobj(fig, 'tag', 'plot');
finalcmd = '[EEG LASTCOM] = pop_eegvis(EEG);';
finalcmd =  [trystrs.no_check finalcmd catchstrs.add_to_hist];
uimenu( parentMenu, 'Label', 'Visualize (eegvis)', 'Callback', finalcmd, ...
    'Separator', 'on');

% Add eegbrowse to EEGLAB file menu as a dataset previewer
menuString = 'Preview (eegbrowse)';
parentMenu = findobj(fig, 'Label', 'File');

finalcmd = 'pop_eegbrowse();';
finalcmd =  [trystrs.no_check finalcmd catchstrs.add_to_hist];

uimenu( parentMenu, 'Label', menuString, ...
        'Callback', finalcmd, 'Separator', 'off', 'Enable', 'on', ...
        'userdata', 'startup:on');

% Reorder EEGLAB file menu appropriately
fileChildren = get(parentMenu, 'Children');
loadExisting = findMenuPosition(parentMenu, 'Load existing dataset');
previewExisting = findMenuPosition(parentMenu, menuString);
if loadExisting == -1 || previewExisting == -1
    return;
end
if previewExisting < loadExisting
    permF = [1:(previewExisting - 1) ...
        (previewExisting + 1):(loadExisting - 1) ...
        previewExisting ...
        loadExisting:length(fileChildren)];
    
else % Untested
    permF = [1:(loadExisting - 1) previewExisting ...
        loadExisting:(previewExisting - 1)
        (previewExisting + 1):length(fileChildren)];
end
fileChildren = fileChildren(permF);
set(parentMenu, 'Children', fileChildren);
end % eegplugin_eegvis


function pos = findMenuPosition(parentMenu, itemLabel)
% Return position of submenu item in parent menu or -1 if not there
pos = -1;
submenu = findobj(parentMenu, 'type', 'uimenu', 'Label', itemLabel);
if ~ishandle(submenu)
    return;
end
theChildren = get(parentMenu, 'Children');
for k = 1:length(theChildren)
    if theChildren(k) == submenu;
        pos = k;
        return;
    end
end
end % findMenuPosition


    
    