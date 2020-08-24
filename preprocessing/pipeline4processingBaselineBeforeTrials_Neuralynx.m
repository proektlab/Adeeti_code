%% Making snippits for each experiment

close all
clear
clc

dirIn = '/data/adeeti/ecog/rawIsoPropMultiStim/';
dirOut= '/data/adeeti/ecog/matBaselineIsoPropMultiStim/';
dirTrials = '/data/adeeti/ecog/matIsoPropMultiStim/';

cd(dirIn);
mkdir(dirOut);

allData = dir('2018*');

loadingWindow = waitbar(0, 'Converting data...');
totalExp = length(allData);
%%
for exp = 1:length(allData)
    cd([dirIn, allData(exp).name])
    
    disp(['Starting file ', allData(exp).name])
    
    % do not extract baseline for data that we do not have trials for
    if ~exist([dirTrials, allData(exp).name, '.mat'])
        continue
    end
    
    load('Events.mat')
    
    if unique(eveID) == 0
        continue
    end
    
    %% Extract segments of data and save
    
    firstFlash = eveTime(find(eveID~=0, 1, 'first'));
    
    [dataSnippits, out, ogTime, finalTime, finalSampR] = extractSnippets_Neuralynx(firstFlash, firstFlash, firstFlash, 1000, 1);
    
    save([dirOut, allData(exp).name, '.mat'], 'dataSnippits', 'finalTime', 'finalSampR')
    
    %% Adding info, cleaning data, mean subtracting
    load([dirTrials, allData(exp).name], 'info')
    
    if isfield(info, 'noiseChannels') ==0
        continue
    end
    
    noiseChannels = info.noiseChannels;
    cleanedData = dataSnippits;
    
    for n = 1:length(noiseChannels)
        if isempty(noiseChannels)
            continue
        end
        cleanedData(noiseChannels(n), :, :) = NaN(size(dataSnippits,2), size(dataSnippits, 3));
    end
    
    meanSubBaselineData = cleanedData - repmat(nanmean(cleanedData,1), [size(cleanedData,1), 1, 1]);
    
    dataSnippits = squeeze(dataSnippits);
    cleanedData = squeeze(cleanedData);
    meanSubData = squeeze(meanSubBaselineData);
    
    save([dirOut, allData(exp).name], 'info', 'meanSubData', 'cleanedData', '-append')
    
    close all;
    clearvars -except allData exp totalExp loadingWindow dirOut dirIn dirTrials
    waitbar(exp/totalExp)
end

close(loadingWindow)

cd(dirTirals)
load('dataMatrixFlashes.mat')

save([dirOut, 'dataMatrixFlashes.mat'], 'dataMatrixFlashes')

