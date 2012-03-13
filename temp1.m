%%
EEG = pop_loadset('filename','eeglab_data.set', 'filepath', ...
    'H:\Research\NeuroErgonomics\eeglab11_0_0_0b\sample_data\');
EEG = pop_chanedit(EEG, 'load', ...
    'H:\Research\NeuroErgonomics\eeglab11_0_0_0b\sample_data\eeglab_chan32.locs', ...
    'filetype', 'autodetect');

%%
% topoplot(EEG.data(:, 1), EEG.chanlocs, ...
%                            'style', 'map',  'electrodes', 'numpoint');
                       
%%
Values = EEG.data(:, 1);
loc_file = EEG.chanlocs;
run tempPlot;