clear
close all

dirIn = '/data/adeeti/ecog/mat_OpenEphys_WhiskerTesting/';
dirPic1 = '/data/adeeti/ecog/images/mat_OpenEphys_WhiskerTesting/preProcessing/';
%dirPic2 = '/data/adeeti/ecog/images/mat_OpenEphys_WhiskerTesting/singleTrialSpec/';
%dirOut = '/data/adeeti/ecog/mat_OpenEphys_WhiskerTesting/Wavelets/';

identifier = '2019*.mat';

cd(dirIn)
%mkdir(dirOut)
mkdir(dirPic1)
%mkdir(dirPic2)

allData = dir(identifier);
screensize=get(groot, 'Screensize');
%%
for experiment = 1:length(allData)
    dirName = allData(experiment).name(1:end-4);
    
    % find what kind and how much of each trials do we have
    
    load(allData(experiment).name, 'meanSubData', 'dataSnippits', 'finalTime', 'info')
    
    plotData1 = meanSubData;
    
    [currentFig] = plotSingleTrials(plotData1, finalTime, info);
    
    saveas(currentFig, [dirPic1, allData(experiment).name, 'singleTrialsMeanSub.png'])
    
    close all;
    
    plotData2 = dataSnippits;
    
    [currentFig] = plotSingleTrials(plotData2, finalTime, info);
    
    saveas(currentFig, [dirPic1, allData(experiment).name, 'singleTrialsDataSnips.png'])
    close all;
    
end

    