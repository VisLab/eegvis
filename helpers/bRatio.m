function ratio = bRatio(x, sRate, topBand, botBand) %#ok<INUSL>
   % Compute spectral intensity ratio of two frequency bands along dim 2
   % Parameters:
   %    x       an array to be summarized
   %   sRate    sampling rate in Hz
   %   topBand  two-element vector specifying numerator frequency band in Hz
   %   botBand  two-element vector specifying denominator frequency band in Hz
   %
   % If botBand is empty, spectral intensity of topBand is returned
   nSamples = size(x, 2);
   fftSize = 2^nextpow2(nSamples);            % Need power of 2 for FFT
   FY = fft(x, fftSize, 2)/nSamples;          %#ok<NASGU> % Fourier coefficients
   f = sRate/2*linspace(0, 1, fftSize/2 + 1); % Frequencies for mask
   nFrequencies = int32(1:nSamples/2 + 1);    % Find actual frequencies
   f = f(nFrequencies);                       %#ok<NASGU> % Account for padding
   backDims = repmat(',:', 1, max(1, ndims(x) - 2));  % Handle arbitrary dimensions
   intens = eval(['abs(FY(:, nFrequencies' backDims '));']);  %#ok<NASGU>   
   topSi = eval(['sum(intens (:, topBand(1) <= f & f <= topBand(2)' ...
                 backDims '), 2);']);
   if isempty(botBand)
       botSi = 1;
   else
       botSi = eval(['sum(intens (:,  botBand(1) <= f & f <= botBand(2)' ...
                 backDims '), 2);']);
   end
   if sum(botSi) == 0;
       warning('bRatio:DivideByZero', ...
               'Denominator spectral intensity is 0, ratio set to 0');
       ratio = zeros(size(topSi));
   else
       ratio = topSi./botSi;                      
   end
end


