%% viscore.dataSlice
% Define a regular subarray for data manipulation
%
%% Syntax
%    viscore.dataSlice() 
%    viscore.dataSlice('key1', 'value1', ...)
%    obj = viscore.dataSlice('key1', 'value1', ...)
%
%% Description
% |viscore.dataSlice()| is the identity subarray. That is, when this
%     slice is applied to an array, it returns the array itself.
%
% |viscore.dataSlice('key1', 'value1', ...)| specifies optional parameter
%    name/value pairs.
%
% <html>
% <table>
% <thead><tr><td>Name</td><td>Value</td></tr></thead>
% <tr><td><tt>'NumDim'</tt></td>
%      <td>Number of dimensions in the slice. The default is 3. If  
%  |'NumDim'| is omitted and |'Slice'| is given, the number of dimensions
%  is the minimum of 3 and the length of the slice.</td></tr>
% <tr><td><tt>'CombineDim'</tt></td>
%      <td>Vector of dimension numbers to combine when processing the slice.
%      The default is empty.</tr>
% <tr><td><tt>'CombineMethod'</tt></td>
%      <td>Funtion to apply to combine the dimensions to produce
%          this slice. The default is <tt>'mean'</tt> which
%          takes the mean of the values in the combine dimensions,
%          ignoring NaNs. Other valid values include <tt>'median'</tt>,
%          <tt>'max'</tt> and <tt>'min'</tt>.</td></tr>
% <tr><td><tt>'DimNames'</tt></td>
%      <td>Cell array of names of the values plotted along the slice dimensions.
%      The default names are  <tt>{'Element', 'Sample', 'Block', 
%      'Dim4', ...}.</tt></td></tr>
% <tr><td><tt>'Slices'</tt></td>
%      <td>Cell array of strings specifying the indices of the
%          subarray represented by the slice. For example
%         <tt>{':', '4:5', 7}</tt> represents the subarray formed
%             by taking all rows, columns 4 and 5, and index 7 along
%             dimension 3.</td></tr>
% </table>
% </html>
%
% |obj = viscore.dataSlice(...)| returns a handle to the newly created
%    slice.
%
% A data slice does not itself contain data, but contains static methods for 
% extracting data from an array based on the slice specification. 
% For example, a |viscore.dataSlice| with specification |{':', '4', ':'}| 
% extracts an unsqueezed subarray from a two-dimensional or three-dimensional 
% array by setting the index in dimension two to 4, provided that 4 is a 
% valid index for the array. Otherwise, the slice extracts an empty array. 
% When presented with a one-dimensional array, this slice 
% extracts a copy of the original array. When presented with a data array  
% of dimension higher than three, this slice replaces the dimensions 
% above three with |':'| when evaluating. 
%
% In linked visualizations, a data slice provides information about the
% piece of the data that was clicked so that downstream visualizations
% can react with an appropriate display.
%
%
%% Example 1
% Extract subarrays from various arrays

    data1 = random('exp', 1, [30, 20, 10]); 
    subData1 = viscore.dataSlice.getDataSlice(data1, {':', '4', ':'}, [], '');
    data2 = random('exp', 1, [30, 20]); 
    subData2 = viscore.dataSlice.getDataSlice(data2, {':', '4', ':'}, [], '');
    data3 = random('exp', 1, 30); 
    subData3 = viscore.dataSlice.getDataSlice(data3, {':', '4', ':'}, [], ''); 
    data4 = random('exp', 1, [30, 20, 10, 8]); 
    subData4 = viscore.dataSlice.getDataSlice(data4, {':', '4', ':'}, [], '');

%% Example 2
% Combine unwanted dimensions after extracting a subarray

    data = random('exp', 1, [30, 20, 10, 8]); 
    subData = viscore.dataSlice.getDataSlice(data, {':', '4', ':'}, 1:3, 'mean');
    sSubData = squeeze(subData);

%%
% In this example |sSubData| is an 8 x 1 vector obtained by taking the mean over
% dimensions 1 and 3 after setting the column number to 4 and extracting
% the array. (Note: the mean is also taken over dimension 2, but because 
% it is a singleton the mean has no effect.)
%
%% Class documentation
% Execute the following in the MATLAB command window to view the class 
% documentation for |viscore.dataSlice|:
%
%    doc viscore.dataSlice
%
%% See also
% <blockedData_help.html |viscore.blockedData|>
%
%% 
% Copyright 2011 Kay A. Robbins, University of Texas at San Antonio