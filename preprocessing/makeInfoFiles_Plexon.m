function makeInfoFiles_Plexon(driveLocation, excelFileName, excelSheet, dirIn, identifier, dirOut, MAXSTIM)
% makeInfoFiles_Plexon(driveLocation, excelFileName, excelSheet, dirIn, identifier, dirOut)
% Making info files

[num, text, raw] = xlsread([driveLocation, excelFileName], excelSheet); %reads excel sheet

cd(dirIn)
allData = dir(identifier);
loadingWindow = waitbar(0, 'Converting data...');
totalExp = length(allData);

for experiment = 1:length(allData)
    dirName = allData(experiment).name;
    %load(dirName);
    info = [];
    rowInd = experiment+1;
    info = [];
    info.AnesType = raw{rowInd, 2};
    info.AnesLevel = raw{rowInd,3};
    info.TypeOfTrial = raw{rowInd, 4};
    
    info.expName = dirName;
    info.date = dirName(1:10);
    info.channels = raw{rowInd,5};
    info.notes = raw{rowInd, 6};
    noiseChan = raw{rowInd,7};
    if isnan(noiseChan)
        info.noiseChannel = nan;
    elseif isnumeric(noiseChan)
        info.noiseChannels = noiseChan;
    else
        info.noiseChannels = str2num(raw{rowInd,7});
    end
    info.exp = raw{rowInd,8};
    info.interPulseInterval = raw{rowInd,10};
    info.interStimInterval = raw{rowInd, 11};
    info.bregmaOffsetX = raw{rowInd, 12};
    info.bregmaOffsetY = raw{rowInd, 13};
    
    info.ecogGridName = raw{rowInd, 14};
    info.ecogChannels = str2num(raw{rowInd, 15});
    
    info.forkName = raw{rowInd, 16};
    if isnan(raw{rowInd, 17})
        info.forkPosition = nan;
        info.forkChannels = nan;
    else
        info.forkPosition = str2num(raw{rowInd, 17});
        info.forkChannels = str2num(raw{rowInd, 18});
    end
    
    if ischar(info.interStimInterval)
        info.interStimInterval = NaN;
    end
    info.numberStim = raw{rowInd,9};
    
    % for stimuli parameters
    modCounter =0;
    if raw{rowInd,9} >= 1
        info.Stim1 = raw{rowInd,19+modCounter};
        info.Stim1ID= raw{rowInd,20+modCounter};
        info.LengthStim1 = raw{rowInd,21+modCounter};
        info.IntensityStim1 = raw{rowInd,22+modCounter};
        modCounter = modCounter + 4;
    end
    
    if MAXSTIM >= 2
        info.Stim2 = raw{rowInd,19+modCounter};
        info.Stim2ID= raw{rowInd,20+modCounter};
        info.LengthStim2 = raw{rowInd,21+modCounter};
        info.IntensityStim2 = raw{rowInd,22+modCounter};
        modCounter = modCounter + 4;
    end
    
    if MAXSTIM >= 3
        info.Stim3 = raw{rowInd,19+modCounter};
        info.Stim3ID= raw{rowInd,20+modCounter};
        info.LengthStim3 = raw{rowInd,21+modCounter};
        info.IntensityStim3 = raw{rowInd,22+modCounter};
        modCounter = modCounter + 4;
    end
    
    if MAXSTIM >= 4
        info.Stim4 = raw{rowInd,19+modCounter};
        info.Stim4ID= raw{rowInd,20+modCounter};
        info.LengthStim4 = raw{rowInd,21+modCounter};
        info.IntensityStim4 = raw{rowInd,22+modCounter};
        modCounter = modCounter + 4;
    end
    
    %     info.gridIndicies = [[32 21 10 58 37 48 ];... %bregma is at top right corner
    %         [31 20 9 57 36 47 ];...
    %         [30 19 8 56 35 46 ];...
    %         [29 18 7 55 34 45 ];...
    %         [22 17 6 54 33 38 ];...
    %         [23 11 1 49 59 39 ];...
    %         [24 12 2 50 60 40 ];...
    %         [25 13 3 51 61 41 ];...
    %         [26 14 4 52 62 42 ];...
    %         [27 15 5 53 63 43 ];...
    %         [28 16 0 0 64 44 ]];
    %
    info.gridIndicies =     [[44    64     0     0    16    28];...
        [43    63    53     5    15    27];...
        [42    62    52     4    14    26];...
        [41    61    51     3    13    25];...
        [40    60    50     2    12    24];...
        [39    59    49     1    11    23];...
        [38    33    54     6    17    22];...
        [45    34    55     7    18    29];...
        [46    35    56     8    19    30];...
        [47    36    57     9    20    31];...
        [48    37    58    10    21    32 ]];
    
    %     NNShank2 = [9 8 10 7 11 6 12 5 13 4 14 3 15 2 16 1];
    %     NNShank1 = NNShank2+16;
    %     NNChannels = [NNShank1;NNShank2];
    %     [ADChannels] = convertNNchan2PlexADChanAcute32_Plexon(NNChannels);
    %     info.forkIndicies = (ADChannels+64)'; %anterior shank is in column 1
    
    info
    save([dirOut, dirName], 'info','-append')
    clearvars info
    loadingWindow = waitbar(experiment/totalExp);
    
end
close(loadingWindow);
