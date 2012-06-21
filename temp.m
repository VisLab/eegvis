load('EEGEmotiv.mat')

%%
[event, sTimes, tScale] = viscore.eventData.getEEGTimes(EEGEmotiv);