load('EEGEpoch.mat')

%%
[event, sTimes, tScale] = viscore.eventData.getEEGTimes(EEGEpoch);