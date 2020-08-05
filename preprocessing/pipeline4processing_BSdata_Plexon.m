close all
clear

if isunix
    dirDat = '/synology/adeeti/';
    dirCode = '/synology/code/Adeeti_code/';
elseif ispc
    dirDat = 'Z:/adeeti/';
    dirCode = 'Z:\code\Adeeti_code\';
end

expDate = [{'2020-07-20'}]; %, {'2020-02-19'}];
mouseID = [{'BSup4'}]; %, {'CB3'}];
identifierSubjects = '2020*';
mouseECoGFolder = [dirDat, 'JenniferHelen/'];
infoSheets = [4]; %];
useArduino = 1; %for extracting snippets
adj4arduino = 0; %for assigning indexSeries 

dirIsoFlash = [mouseECoGFolder, 'Iso_flashes/'];
dirIsoBaseline = [mouseECoGFolder, 'iso_longBaseline/'];

for i = 1:length(expDate)
    genDirIn = [dirDat, 'plexonData_adeeti/', expDate{i}, '/'];
    genDirOut =  [genDirIn, 'matlab/'];
    
    identifierFile = '*.pl2';
    START_AT= 1;
    
    clearvars eventsChan
    eventsChan{1} = 'EVT01';
    
    convertPL2intoMat_Plexon_LinuxWS
    
    clearvars -except genDirOut genPicsDir mouseID expDate identifierSubjects ...
        mouseECoGFolder infoSheets dirCode dirDat adj4arduino useArduino ...
        dirIsoFlash dirIsoBaseline
end

%%
for dateInd = 1:length(mouseID)
    dirIn = [dirDat, 'plexonData_adeeti/', expDate{dateInd}, '/matlab/'];
    dirOut = dirIn;
    stimIndex = [0, Inf];
    identifier = '2020*.mat';
    START_AT = 1;

    excelFileName = 'preprocessing/BurstSuppMice.xlsx';
    excelSheet = infoSheets(dateInd);
    
    MAXSTIM = 1;
    ADD_MAN_NOISE_CHANNELS = 1;
    ANALYZE_IND = 0;
    
    %% Making info files
    
    makeInfoFiles_Plexon(dirCode, excelFileName, excelSheet, dirIn, identifier, dirOut, MAXSTIM)
    
    %% Finding noise Channels
    if ADD_MAN_NOISE_CHANNELS ==1
        numbOfSamp = 8;
        cd(dirOut)
        allData = dir(identifier);
        adddManNoiseChan_allExpMouse(allData,  ANALYZE_IND, numbOfSamp);
    end
    %% adding index series and unique series to flashes
    
    addingUniqueIndexSeries_uniStim(dirIn, identifier, stimIndex, adj4arduino)
    
    %% Clean data, mean subtract
    close all
    
    START_AT = 1;
    flashOn = [0,0];
    before = 1;
    after = 2;

    cd(dirIn)
    allData = dir(identifier);
    
    for experiment = START_AT:length(allData)
        dirName = allData(experiment).name;
        [meanSubData, meanSubFullTrace] = meanSubAndAvgTrace(dirName, before, after);
    end
    
    %% move files to appriorpte folders and add to data flash matrix
    
    sortBurstSuppFiles4analysis(dirIn, identifier, dirIsoFlash, dirIsoBaseline)
end
