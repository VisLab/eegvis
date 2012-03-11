% pop_eegbrowse opens an eegbrowse GUI for EEGLAB
%
% Usage:
%   >>  pop_eegbrowse()
%
% Description:
% pop_eegbrowse() provides a graphical display that allows the user to
%    explore the existing data sets. The user can optionally view each
%    dataset with a block visualization two-level viewer.  
%
% See also:
%   eegbrowse and eeglab
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

% $Log: pop_eegbrowse.m, v $
% Revision 1.00  24-Jul-2011 07:50:18  krobbins
% Initial version
%

function com = pop_eegbrowse()  

com = '';   %#ok<NASGU>

% Create the DualView object for the EEG plot menu if it doesn't exist
figTag = 'EEGLAB:EEGBrowseFileMenu';
visSource = 'EEGLAB/File';
ebFig = findobj('Tag', figTag);
if isempty(ebFig)
    eB = eegbrowse('UseEEGLab', true, 'Title', ...
         ['eegbrowse: previewer (' visSource ')']);
    set(eB.ConFig, 'Tag', figTag);
    eB.VisSource = visSource;
    drawnow;
end

% return the string command
% -------------------------
formatString = char('pop_eegbrowse()');
com = sprintf(formatString);


   
