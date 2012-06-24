load('EEGEmotiv.mat')

%%
[event, sTimes, tScale] = viscore.eventData.getEEGTimes(EEGEmotiv);


%%
types = results.predicted;
startTimes = num2cell((results.t)');
certainties =  num2cell((results.confidence)');
%%
events = struct('type', types, 'startTime', startTimes, 'certainty', certainties);

%%
save('ArtifactLabels.mat', 'artifactEvents');
