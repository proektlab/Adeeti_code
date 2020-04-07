%% To create grid of images of VEPs

close all
clear
dirPic = '/data/adeeti/ecog/images/2018IsoFlashes/preProcessing/';
dirIn= '/data/adeeti/ecog/mat2018IsoLED/';

identifier = '2018-01-22*.mat';
START_AT = 1;

before = 1;
after = 2;
flashOn = [0,0];

mkdir(dirPic)

cd(dirIn)
allData = dir(identifier);

loadingWindow = waitbar(0, 'Converting data...');
totalExp = length(allData);

for exp = START_AT:length(allData)
    
    dirName = allData(exp).name;
    load(dirName, 'info', 'finalTime', 'meanSubData', 'aveTrace')
    disp(['Displaying data ', allData(exp).name])
     % Single trial images
    
    [currentFig] = plotSingleTrials(meanSubData, finalTime, info);

    saveas(currentFig, [dirPic, dirName, 'singletrials.png'])
    close all;
    
    % Flash triggered average images
    
    [currentFig] = plotAverages(aveTrace, finalTime, info, [], [], [],  before, after, flashOn);
    
    saveas(currentFig, [dirPic, allData(exp).name, 'average.png'])
    close all;
    waitbar(exp/totalExp)
    
end
close(loadingWindow)
    
