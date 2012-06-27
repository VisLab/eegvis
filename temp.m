load('EEGArtifact.mat');
values.EEGArtifact = EEGArtifact;
load('ArtifactLabels.mat');
values.artifactEvents = artifactEvents;
%%
pS = viewTestClass.getDefaultPlotsWithEvents();
assertEqual(length(pS), 10);
testVD3 = viscore.blockedData(values.EEGArtifact.data, ...
    'Artifact (Artifact events)', 'Events', values.artifactEvents, ...
    'BlockSize', 1000, 'SampleRate', values.EEGArtifact.srate);
bv3 = visviews.dualView('VisData', testVD3, 'Plots', pS');
assertTrue(isvalid(bv3));


%%
x = figure
y = findall(x);
 for k = 1:length(y)
     p = get(y(k), 'Type');
    fprintf('%d: %s ', k, get(y(k), 'Tag'));
    if strcmp(p, 'uimenu')
        fprintf('%s', get(y(k), 'Label'));
    end
    fprintf('\n');
end