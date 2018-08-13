The eegVis package provides configurable viewers for exploring and 
summarizing array data, such as multichannel EEG. The eegVis package 
requires MATLAB 2010a or later and the MATLAB Statistics toolbox. 

The dependencies on the statististics toolbox are minor:  
                                       nanmean, nanmedian, and kurtosis.

To run without eeglab:

1)  Add the package to your path. From this directory:

       addpath(pathgen(pwd))

2)  You can now call the eegVis function from the command line or in 
    any of your scripts


To run with eeglab:

1)  Make sure this distribution directory is unzipped into the EEGLAB 
    plugins directory.

2)  Start EEGLAB to add everything to the path. 

3)  At this point:

    a)  The eegVis function will be available to call from the command
        line or any of your scripts to create your own figure window for
        data viewing

    b)  The eegBrowse function will be available to call from the command
        line or any of your scripts to browse collections of eeglab .set
        files. You can use eegBrowse to load EEG files directly into the 
        the workspace without going through EEGLAB. If eegBrowse has its
        UseEEGLAB property set to true:

                     eegBrowse.UseEEGLAB = true;

        eegBrowse will update the status of EEGLAB by calling eeglab('redraw');

    c)  The eegBrowse function will be available available from the File
        menu of EEGLAB as a data previewer.  The eegVis function will be 
        avalailable from the Plot menu of EEGLAB as a data viewer.

Note: The current release of EEGLAB (eeglab10.2.2.4b) comes up with the
previewer grayed out on the File menu until at least one data set is loaded
into the EEGLAB workspace. A copy of the unreleased version of eeglab.m that
allows file previewing before the first data file is loaded can be found on
the eegVis website (http://visual.cs.utsa.edu/software/eegvis).

Other items included with the distribution:

1) The GUIs in eegVis are built on the +uiextras package which part of the
   GUI Layout Toolbox written by Ben Tordoff of Mathworks. The +uiextras
   used here is part of the original release of this package. The current
   version of this package is available on MATLAB Central at
   http://www.mathworks.com/matlabcentral/fileexchange/27758.

2) The eegVis package has a fairly extensive set of unit tests and includes
   the MATLAB xUnit Test Framework, which is available on MATLAB Central
   at https://www.mathworks.com/matlabcentral/fileexchange/47302-xunit4.

   To run all of the regression tests type:

          runAllTests 
   
   from the top-level package directory. 
   
