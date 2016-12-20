# EEGVIS Toolbox

EEGVIS provides a visualization tools and a development infrastructure
for quickly viewing data such as continuously recorded EEG, which
can be large and exhibit widely varying scales. A typical EEG apparatus 
might record 128 channels at 512 Hz resulting in about 4 million data 
points per minute. While normal EEG signals tend to vary on a scale of 
approximately 100 microvolts, a loose connector can result in voltages in the 
tens of thousands of microvolts. 

EEGVIS uses a flexible drill-down strategy to summarize the data and to 
all users to examine more closely areas of interest.  See [EEGVIS Project Page](http://visual.cs.utsa.edu/eegvis) for more details.

The EEGVIS design is described in:
EEGVIS: a MATLAB toolbox for browsing, exploring, and viewing large datasets
by Kay A. Robbins, University of Texas at San Antonio
Front. Neuroinform., 28 May 2012 | doi: 10.3389/fninf.2012.00017 
[Paper Link](http://www.frontiersin.org/Neuroinformatics/10.3389/fninf.2012.00017/abstract)

### Acknowledgements
The EEGVIS Toolbox is being developed as part of the Army Research Laboratories
CAN-CTA Neuroergonomics Project. Also acknowledged are SCCN and
the [EEGLAB](http://sccn.ucsd.edu/eeglab) team at University of California at San Diego.
