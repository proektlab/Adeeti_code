%% extracting baseline for plexon data

dirIn = '/Users/adeetiaggarwal/Google Drive/data/matIsoPropMultiStimVIS_ONLY_/flashTrials/';
dirOut = '/Users/adeetiaggarwal/Google Drive/data/matIsoPropMultiStimVIS_ONLY_/baseline/';

cd(dirIn)
identifier = '2018-12*';
allData = dir(identifier);

baselineTimeCut = 55; %in sec

for i = 1:length(allData)
    load([dirIn, allData(i).name], 'LFPData','meanSubFullTrace', 'info', 'fullTraceTime', 'finalSampR')
    if isfield(info, 'startOffSet')
        dataSnippits = LFPData(:,1:info.startOffSet);
        meanSubData= meanSubFullTrace(:,1:info.startOffSet);
        finalTime = fullTraceTime(:,1:info.startOffSet);
    else
        dataSnippits = LFPData(:,1:baselineTimeCut*finalSampR);
        meanSubData= meanSubFullTrace(:,1:baselineTimeCut*finalSampR);
        finalTime = fullTraceTime(:,1:baselineTimeCut*finalSampR);
    end
    
    save([dirOut, allData(i).name], 'dataSnippits','meanSubData', 'info', 'finalTime', 'finalSampR')
end

