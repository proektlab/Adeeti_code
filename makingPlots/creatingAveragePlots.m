%% Making averages plots
close all
dirPic = '/data/adeeti/ecog/images/Rat_VEP_Testing/averages/';
dirIn = '/data/adeeti/ecog/Rat_VEP_prop/';

identifier = '2019*.mat';
START_AT = 3;

before = 0.7;
after =1;
flashOn = [0,0];
markTime = -before:.1:after;
screensize=get(groot, 'Screensize');

mkdir(dirPic)

cd(dirIn)
allData = dir(identifier);

loadingWindow = waitbar(0, 'Converting data...');
totalExp = length(allData);

for exp = START_AT:length(allData)
    dirName = allData(exp).name;
    load(dirName, 'aveTrace', 'info', 'finalTime')
    
    [currentFig] = plotAverages(squeeze(aveTrace(1,info.ecogChannels,:)), finalTime, info, [], [], [], [], before, after, flashOn);
    
    saveas(currentFig, [dirPic, dirName(1:end-4), 'average.png'])
    close all;
    
end
