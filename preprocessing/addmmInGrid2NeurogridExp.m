clear
clc

if isunix
    dirDat = '/synology/adeeti/';
    dirCode = '/synology/code/Adeeti_code/';
elseif ispc
    dirDat = 'Z:\adeeti\';
    dirCode = 'Z:\code\Adeeti_code\';
end

expDate = [{'2020-07-15'}]; %, {'2020-02-19'}];
mouseID = [{'T2_64Chan_test'}, {'T4_32Chan_test'}]; %, {'CB3'}];

mouseECoGFolder = [dirDat, 'ecog/testing_Viv_Neurogrid_ECOG/'];
useArduino = 1;

%% preprocessing

stimIndex = [0, Inf];
identifier = '2019*.mat';
START_AT = 1;
addUniStimIndexUniqueSeries = 1;
adj4arduino = 0;

for dateInd = 1:length(mouseID)
    genPicsDir =  [dirDat, 'ecog/images/testing_Viv_Neurogrid_ECOG/', mouseID{dateInd}, '/'];
    dirIn = [mouseECoGFolder, mouseID{dateInd}, '/'];
    dirOut = dirIn;
    driveLocation = dirCode;  %'/data/adeeti/Dropbox/'; %'/home/adeeti/googleDrive/'; %dropbox location for excel file and saving
    
    cd(dirIn)
    allData = dir(identifier);
    
    if contains(mouseID{dateInd}, 'T4')
        [~, mmInGrid] = findMyProbChannels('T4');
        
        for i = 1:length(allData)
            dirName = allData(i).name;
            load(dirName, 'info');
            info.mmInGrid = mmInGrid;
            save(dirName, 'info', '-append')
        end
        
        dirWAVE =  [dirIn, 'Wavelets/'];
        cd(dirWAVE)
        allData = dir(identifier);
        for i = 1:length(allData)
            dirName = allData(i).name;
            load(dirName, 'info');
            info.mmInGrid = mmInGrid;
            save(dirName, 'info', '-append')
        end
            
        dirFILT = [dirIn, 'FiltData/'];
        cd(dirFILT)
        allData = dir(identifier);
        for i = 1:length(allData)
            dirName = allData(i).name;
            load(dirName, 'info');
            info.mmInGrid = mmInGrid;
            save(dirName, 'info', '-append')
        end
        
        
    elseif contains(mouseID{dateInd}, 'T2')
        [~, mmInGrid] = findMyProbChannels('T2');
               for i = 1:length(allData)
            dirName = allData(i).name;
            load(dirName, 'info');
            info.mmInGrid = mmInGrid;
            save(dirName, 'info', '-append')
        end
    end
end
