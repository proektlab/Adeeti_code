%% Preprocessing code
% Convert PL2 into .mat files for transfer onto the workstation for futher
% analysis
% 11/29/18 AA only written so far for LFP data 

%% Making snippits for each experiment
% clear
% clc
% 
% genDirIn = '/synology/adeeti/plexonData_adeeti/2019-11-26/';
% genDirOut =  '/synology/adeeti/ecog/iso_awake_VEPs/GL7/';
% identifierSubjects = '2019*';
% 
% identifierFile = '*.pl2';
% START_AT= 1;
% 
% clearvars eventsChan
% eventsChan{1} = 'EVT01';


%eventsChan{2} = 'EVT04';

% eventsChan{1} = 'EVT05';
% eventsChan{2} = 'EVT06';
% eventsChan{3} = 'EVT07';
% eventsChan{4} = 'EVT08';

numChan = 64;
before = 1; %in seconds amount of prestim data
l = 3; %total length in seconds of the trial
startBaseline = 0; %0 if want to make chan by trials by timepoints, 1 if want to extract intial baseline sequence
LFPcutOff = 325; % low pass cut off if want to extract LFP from WB signal
finalSampR = 1000;
interPulseInterval = 3;
cutoff = interPulseInterval;

makeSnippits = 1; %1 if want to make snippits from events, 0 if want to extract LFP data only
extractLFPFromWB = 0; %1 if recorded WB data and want to use filtered to filter out LFP, 0 if only recoded FP
useMultipleSubject =0; %0 if using only one subject, 1 if wanting to convert multiple subjects in the same mother directory

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
        dirIn = [genDirIn, allSubjects(subject).name, '/'];
        dirOut = genDirOut;
        mkdir(dirOut)
        date = allSubjects(subject).name;
    elseif useMultipleSubject ==0
        dirIn = genDirIn;
        dirOut = genDirOut;
        mkdir(dirOut)
        date = expDate{1};
    end
    
    cd(dirIn)
    allData = dir(identifierFile);

    for experiment = 1:length(allData)
        
        if ~contains(allData(experiment).name,date)
            strName = strsplit(allData(experiment).name, '.pl2');
            expName = [date, '_', strName{1}];
        else
            strName = strsplit(allData(experiment).name, '.pl2');
            expName = strName;
        end
        
        %[LFPData, lfpSampRate, allStartTimes, fullTraceTime, plexInfoStuffs] = ExtractPL2ECOG_LFP_data(allData(experiment).name,eventsChan, 64, 1);
        if extractLFPFromWB ==1
            [LFPData, ogSampRate, eveTimes, fullTraceTime, plexInfoStuffs] = ExtractPL2_LFP_from_WB_Plexon(allData(experiment).name,eventsChan, numChan, LFPcutOff, finalSampR);
        elseif extractLFPFromWB == 0
            [LFPData, lfpSampRate, eveTimes, fullTraceTime, plexInfoStuffs] = ExtractPL2_LFP_data_Plexon(allData(experiment).name,eventsChan, numChan, startChan);
        end
        
        % Extract segments of data and save
        disp(['Breaking up file ', allData(experiment).name])
        
        if cellfun(@isempty,eveTimes)
            allStartTimes = [];
        else 
            [~, allStartTimes, stimOffSet, uniqueSeries, indexSeries] = findAllStartsAndSeries_Plexon(eventsChan, eveTimes, LFPData, finalSampR, interPulseInterval, cutoff);
        end
        
        if makeSnippits ==1
            if cellfun(@isempty,eveTimes)
                dataSnippits= LFPData;
                save([dirOut, expName, '.mat'], 'dataSnippits', 'finalSampR', 'LFPData', 'fullTraceTime','plexInfoStuffs', 'eveTimes')
            else
                [dataSnippits, finalTime] = extractSnippets_Plexon(LFPData, allStartTimes, before, l, finalSampR, startBaseline, useArduino);
                save([dirOut, expName, '.mat'], 'dataSnippits', 'finalTime', 'finalSampR', 'LFPData', 'fullTraceTime','plexInfoStuffs', 'eveTimes', 'allStartTimes', 'uniqueSeries', 'indexSeries')
            end
        elseif makeSnippits ==0
            dataSnippits= LFPData;
            save([dirOut, expName, '.mat'], 'dataSnippits', 'finalSampR', 'LFPData', 'fullTraceTime','plexInfoStuffs', 'allStartTimes', 'eveTimes')
        end
        clearvars dataSnippits finalTime lfpSampRate LFPData allStartTimes fullTraceTime plexInfoStuffs eveTimes uniqueSeries indexSeries
        
    end
    if useMultipleSubject ==1
        loadingWindow = waitbar(subject/length(allSubjects));
    elseif useMultipleSubject ==0
        loadingWindow = waitbar(experiment/length(allData));
    end
     
end
close(loadingWindow);