% pop_eegvis opens eegvis as a singleton callback for EEGLAB
%
% Usage:
%   >>  EEGOUT = pop_eegvis(EEG)
%
% Inputs:
%    EEG     EEG dataset 
%
% Outputs:
%   EEGOUT  - the input EEG dataset
% 
% The pop_eegvis provides a graphical display of the current EEG dataset 
%
% Notes:
%  -  pop_eegvis() is meant to be used as the callback for a visualizate
%     item under the the EEGLAB Plot menu. It is a singleton and clicking
%     the menu item again will not create a new window if one already
%     exists.
% 
% See also:
%   eeglab, eegvis, and visviews.dualView
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

% $Log: pop_eegvis.m,v $
% Revision 1.00  24-Jul-2010 07:50:18  krobbins
% Initial version
%


function [EEG, com] = pop_eegvis(EEG) 

com = '';       

% Display help if inappropriate number of arguments
if nargin < 1 
	help pop_eegvis;
	return;
end;

% Create the dualView object for the EEG plot menu if it doesn't exist
figTag = 'EEGLAB:DualVisPlotMenu';
visSource = 'EEGLAB/Plot';
dvFig = findobj('Tag', figTag);
if isempty(dvFig)
    dv = visviews.dualView(...
        'Functions', visviews.dualView.getDefaultFunctions(), ...
        'Plots', visviews.dualView.getDefaultPlots());
    set(dv.VisFig, 'Tag', figTag);
    dv.VisSource = visSource;  
else
    dv = get(dvFig, 'UserData');
end

% Set the data and redraw the figure
if isempty(EEG.setname)
    dname = EEG.filename;
else
    dname = EEG.setname;
end
dv.setDataSource(eegbrowse.getBlockDataFromEEG(EEG, dname, 1000));
dv.reset(true, true, true);

% Return the string command
formatString = char('%s = pop_eegvis(%s');
com = sprintf(formatString, inputname(1), inputname(1));


  
   
