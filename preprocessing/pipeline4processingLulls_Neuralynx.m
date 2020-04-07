%% Making snippits for each experiment

directoryIn = '/data/adeeti/ecog/rawJanMar2017/rawPropJanMar2017/';
directoryOut = '/data/adeeti/ecog/matBaselinePropJanMar2017/lulls/';

mkdir(directoryOut)
cd(directoryIn)

allData = dir('2017*');

loadingWindow = waitbar(0, 'Converting data...');
totalExp = length(allData);
finalSampR = 1000;

for exp = 3:length(allData)
    cd([directoryIn, allData(exp).name])
    
    disp(['Starting file ', allData(exp).name])
    
    load('Events.mat')
    
    if unique(eveID) == 0
        continue
    end
    
    %% Extract segments of data and save
    
    firstFlash = eveTime(find(eveID~=0,1, 'first'));
    times = eveTime(find(eveID == eveID(find(eveID~=0,1, 'first'))));
    timeDiff = diff(times);
    ledStop = eveTime(2*(find(timeDiff > 4))+2);
    ledStop = [firstFlash; ledStop];
    before = timeDiff(find(timeDiff > 4));
    before = [firstFlash; before];

    [lullSnippits, finalTime] = extractLulls_Neuralynx(ledStop, before, 1000);
    
    save([directoryOut, allData(exp).name, '.mat'], 'lullSnippits', 'finalTime', 'finalSampR')
    
    %% Adding info, cleaning data, mean subtracting
    load('/data/adeeti/ecog/matPropFlashesJanMar2017/2017-03-01_15-31-25.mat', 'info')
    
    if isfield(info, 'noiseChannels') ==0
        continue
    end
    
    noiseChannels = info.noiseChannels;
    cleanedData = lullSnippits;
    meanSubData = lullSnippits;
    
    for l = 1:size(lullSnippits, 1)
        for n = 1:length(noiseChannels)
            if isempty(noiseChannels)
                continue
            end
            cleanedData{l}(noiseChannels(n),:) = NaN(1, size(lullSnippits{l},2));
        end
        meanSubData{l} = cleanedData{l} - repmat(nanmean(cleanedData{l},1), [size(cleanedData{l},1), 1]);
    end
    
    save([directoryOut, allData(exp).name], 'lullSnippits', 'info', 'meanSubData', 'cleanedData', '-append')
    
    close all;
    clearvars -except allData exp totalExp loadingWindow directoryIn directoryOut finalSampR
    waitbar(exp/totalExp)
end


close(loadingWindow)

