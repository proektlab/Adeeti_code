close all
clear

%%%%% Code for loading in Prop States first
if isunix
    dirData = '/synology/adeeti/';
    dirCode = '/synology/code/Adeeti_code/';
elseif ispc
    dirData = 'Z:/adeeti/';
    dirCode = 'Z:\code\Adeeti_code\';
end

geDirIn = 'ecog\forDrew_02_2019\iso_longBaseline\';
mice = {'2018-12-14\', '2019-01-18b\'};
%%
for m = 1:length(mice)
    dirIn = [dirData, geDirIn, mice{m}];
    identifier = '201*00.mat';
    finalSampR = 1000; %in Hz
    mkdir(dirIn);
    cd(dirIn)
    allData = dir(identifier);
    
    START_AT = 1;
    
    %% Finding noise Channels
    numbOfSamp = 8;
    date = 'start';
    
    for i = START_AT:length(allData)
        dirName = allData(i).name;
        load(dirName, 'info', 'LFPData', 'dataSnippits', 'fullTraceTime');
        
        if ~exist('dataSnippits', 'var')||isempty(dataSnippits)
            dataSnippits = LFPData;
        end
        
        if strcmpi(info.date, date)
            info.noiseChannels = noiseChannels;
            save(dirName, 'info', '-append')
        else
            
            clearvars noiseChannels
            data = dataSnippits;
            
            upperBound = max(data(:));
            lowerBound = min(data(:));
            [ noiseChannelsManual ] = examChannelBaseline(dataSnippits, fullTraceTime);
            noiseChannels = unique([info.noiseChannels, noiseChannelsManual']);
            prompt = ['NoiseChannels =', mat2str(noiseChannels), ' Enter other bad channels, if there are none, put []'];
            exNoise = input(prompt);
            noiseChannels = sort([noiseChannels, exNoise]);
            
            info.noiseChannels = noiseChannels;
            
            save(dirName, 'info', '-append')
            
            date = info.date;
            clearvars LFPData dataSnippits fullTraceTime
        end
        %
    end
    
    %% Clean data, mean subtract make average pictures
    close all
    
    loadingWindow = waitbar(0, 'Converting data...');
    totalExp = length(allData);
    
    for experiment = START_AT:length(allData)
        
        dirName = allData(experiment).name;
        load(dirName)
        disp(['Converting data ', allData(experiment).name])
        
        % Cleaning data and subtracting the mean
        
        noiseChannels = info.noiseChannels;
        cleanedData = dataSnippits;
        fullTrace = dataSnippits;
        
        for n = 1:length(noiseChannels)
            if isempty(noiseChannels)
                continue
            end
            cleanedData(noiseChannels(n),:) = NaN(1, size(dataSnippits,2));
        end
        meanSubFullTrace= cleanedData - repmat(nanmean(cleanedData,1), [size(cleanedData,1), 1]);
        
        save([dirIn, allData(experiment).name], 'meanSubFullTrace', 'cleanedData', 'fullTrace', '-append')
        
        waitbar(experiment/totalExp)
    end
    
    close(loadingWindow);
    
end
