load('EEGArtifact.mat');
load('ArtifactLabels.mat');
%%
testData = viscore.blockedData(EEGArtifact.data, ...
    'Artifact (Artifact events)', 'Events', artifactEvents, ...
    'BlockSize', 1000, 'SampleRate', EEGArtifact.srate);
visviews.dualView('VisData', testData);


%%
x = figure;
y = findall(x);
 for k = 1:length(y)
     p = get(y(k), 'Type');
     myTag = get(y(k), 'Tag');
    fprintf('%d: %s ', k, myTag);
    if strcmp(p, 'uimenu')
        fprintf('%s', get(y(k), 'Label'));
    end
    if strcmpi(myTag, 'FigureToolBar')
        w = y(k);
    end
    fprintf('\n');
 end

 %%
 z = findall(w);
 for k = 1:length(z)
     myTag = get(z(k), 'Tag');
    fprintf('%d: %s ', k, myTag);
    fprintf('\n');
 end