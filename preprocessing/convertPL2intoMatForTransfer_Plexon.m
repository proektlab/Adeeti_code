%% Preprocessing code
% Convert PL2 into .mat files for transfer onto the workstation for futher
% analysis
% 11/29/18 AA only written so far for LFP data 

%% Making snippits for each experiment
clear
clc

genDirIn = 'D:\AdeetiData\';
identifierSubjects = '2019*';
identifierFile = '*.pl2';
START_AT= 1;
eventsChan{1} = 'EVT01';
numChan = 64;
before = 1; %in seconds amount of prestim data
l = 3; %total length in seconds of the trial
% for the rat data, we may want before = 0.5 and l = 1.5 for the recordings
% with really short inter-spike flash timing
startBaseline = 0; %0 if want to make chan by trials by timepoints, 1 if want to extract intial baseline sequence
LFPcutOff = 325; % low pass cut off if want to extract LFP from WB signal
finalSampR = 1000;

makeSnippits = 1; %1 if want to make snippits from events, 0 if want to extract LFP data only
extractLFPFromWB = 0; %1 if recorded WB data and want to use filtered to filter out LFP, 0 if only recoded FP
useMultipleSubject =1; %0 if using only one subject, 1 if wanting to convert multiple subjects in the same mother directory

%%
if extractLFPFromWB ==0
    startChan = 1;
end

cd(genDirIn)
if useMultipleSubject ==1
    allSubjects = dir(identifierSubjects);
else
    allSubjects = 1;
end
    
loadingWindow = waitbar(0, 'Converting data...');

for subject = START_AT:length(allSubjects)
    if useMultipleSubject ==1
        dirIn = [genDirIn, allSubjects(subject).name, '\'];
        dirOut = [dirIn, 'matlab\'];
        mkdir(dirOut)
    elseif useMultipleSubject ==0
        dirIn = genDirIn;
        dirOut = [dirIn, 'matlab\'];s
        mkdir(dirOut)
    end
    
    cd(dirIn)
    allData = dir(identifierFile);
    expDate = dirIn(end-10:end-1);

    for experiment = 1:length(allData)%]========= 1:length(allData)
        
        %[LFPData, lfpSampRate, allStartTimes, fullTraceTime, plexInfoStuffs] = ExtractPL2ECOG_LFP_data(allData(experiment).name,eventsChan, 64, 1);
        if extractLFPFromWB ==1
            [LFPData, ogSampRate, allStartTimes, fullTraceTime, plexInfoStuffs] = ExtractPL2_LFP_from_WB_Plexon(allData(experiment).name,eventsChan, numChan, LFPcutOff, finalSampR);
        elseif extractLFPFromWB == 0
            [LFPData, lfpSampRate, allStartTimes, fullTraceTime, plexInfoStuffs] = ExtractPL2_LFP_data_Plexon(allData(experiment).name,eventsChan, numChan, startChan);
        end
        
        if isempty(LFPData)
            continue
        end
        
        
        % Extract segments of data and save
        
        disp(['Breaking up file ', allData(experiment).name])
        
        if length(allStartTimes) ==1
            onTime = allStartTimes{1};
        end
        
        if makeSnippits ==1
            if cellfun(@isempty,allStartTimes)
                dataSnippits= LFPData;
                save([dirOut, expDate, '_', allData(experiment).name(1:end-4), '.mat'], 'dataSnippits', 'finalSampR', 'LFPData', 'fullTraceTime','plexInfoStuffs','-v7.3's)
                % Brenna added '-v7.3' at the end of this function because
                % LFPData was not saving for files larger than 2 GB
            else
                [dataSnippits, finalTime] = extractSnippets_Plexon(LFPData, onTime, before, l, finalSampR, startBaseline);
                save([dirOut, expDate, '_',allData(experiment).name(1:end-4), '.mat'], 'dataSnippits', 'finalTime', 'finalSampR', 'LFPData', 'allStartTimes', 'fullTraceTime','plexInfoStuffs','-v7.3')
                % Brenna added '-v7.3' at the end of this function because
                % LFPData was not saving for files larger than 2 GB
            end
        elseif makeSnippits ==0
            dataSnippits= LFPData;
            save([dirOut, expDate, '_', allData(experiment).name(1:end-4), '.mat'], 'dataSnippits', 'finalSampR', 'LFPData', 'fullTraceTime','plexInfoStuffs','-v7.3')
            % Brenna added '-v7.3' at the end of this function because
            % LFPData was not saving for files larger than 2 GB
        end
        clearvars dataSnippits finalTime lfpSampRate LFPData allStartTimes fullTraceTime plexInfoStuffs
        
    end
    if useMultipleSubject ==1
        loadingWindow = waitbar(subject/length(allSubjects));
    elseif useMultipleSubject ==0
        loadingWindow = waitbar(experiment/length(allData));
    end
     
end
close(loadingWindow);