load('EEGArtifact.mat');
load('ArtifactEvents.mat');
%%
testData = viscore.blockedData(EEGArtifact.data, ...
    'Artifact (Artifact events)', 'Events', artifactEvents, ...
    'BlockSize', 1000, 'SampleRate', EEGArtifact.srate);

%%
visviews.dualView('VisData', testData);

