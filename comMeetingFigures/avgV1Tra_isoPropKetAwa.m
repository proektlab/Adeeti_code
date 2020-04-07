%% average traces of iso, prop, ket and awake 

% 8/13/18 Editted for multistim  and multiple anesthetics experiments
% 1/15/19 Editted for larger fonts and new dropbox location
%% Make movie of mean signal at 30-40 Hz for all experiments
clc
clear
close all

set(0,'defaultfigurecolor',[1 1 1])

dirAwake = '/synology/adeeti/ecog/iso_awake_VEPs/'; %'Z:\adeeti\ecog\iso_awake_VEPs\GL_early\';
mouseID = 'GL13';
dirInAwake = [dirAwake, mouseID,];

dirInProp = '/synology/adeeti/ecog/matIsoPropMultiStimVIS_ONLY_/flashTrials/'; %'Z:\adeeti\ecog\iso_awake_VEPs\GL_early\';


%%
dropboxLocation = '/home/adeeti/Dropbox/ProektLab_code/Adeeti_code/'; %'C:\Users\adeeti\Dropbox\KelzLab\';
dirOut =  '/home/adeeti/Dropbox/KelzLab/misc_figures/';

screensize=get(groot, 'Screensize');
finalSampR = 1000;

stimIndex = [0, Inf]; 
numTrials = 90;

conStrings = {'Isoflurane High'; 'Propofol High'; 'Ketamine Low'; 'Isoflurane Low'; 'Propofol Low'; 'Awake'};


%% awake and ketamine data 

cd(dirInAwake)
identifier = '2020*.mat';
allData = dir(identifier);

awakeID = 5;
ketID = 6;

load(allData(awakeID).name, 'info', 'meanSubData', 'aveTrace')
awakeTrials = squeeze(meanSubData(info.lowLat, 1:numTrials, :)*1000);
awakeAvg = squeeze(aveTrace(1, info.lowLat, :)*1000);

load(allData(ketID).name, 'info', 'meanSubData', 'aveTrace')
ketTrials = squeeze(meanSubData(info.lowLat, 1:numTrials, :)*1000);
ketAvg = squeeze(aveTrace(1, info.lowLat, :)*1000);


%% iso and prop data 

cd(dirInProp)
identifier = '2018*.mat';
allData = dir(identifier);

highIsoID = 1;
lowIsoID = 2;
lowPropID = 3;
highPropID = 4;

load(allData(highIsoID).name, 'info', 'meanSubData', 'aveTrace')
highIsoTrials = squeeze(meanSubData(info.lowLat, 1:numTrials, :));
highIsoAvg = squeeze(aveTrace(1, info.lowLat, :));

load(allData(lowIsoID).name, 'info', 'meanSubData', 'aveTrace')
lowIsoTrials = squeeze(meanSubData(info.lowLat, 1:numTrials, :));
lowIsoAvg = squeeze(aveTrace(1, info.lowLat, :));

load(allData(lowPropID).name, 'info', 'meanSubData', 'aveTrace')
lowPropTrials = squeeze(meanSubData(info.lowLat, 1:numTrials, :));
lowPropAvg = squeeze(aveTrace(1, info.lowLat, :));

load(allData(highPropID).name, 'info', 'meanSubData', 'aveTrace')
highPropTrials = squeeze(meanSubData(info.lowLat, 1:numTrials, :));
highPropAvg = squeeze(aveTrace(1, info.lowLat, :));

%%
conStrings = {'Isoflurane High'; 'Propofol High'; 'Ketamine Low'; 'Isoflurane Low'; 'Propofol Low'; 'Awake'};
allST = [];
allST(1,:,:) = highIsoTrials;
allST(2,:,:) = highPropTrials;
allST(3,:,:) = ketTrials;
allST(4,:,:) = lowIsoTrials;
allST(5,:,:) = lowPropTrials;
allST(6,:,:) = awakeTrials;

allAvg = [];
allAvg(1,:) = highIsoAvg;
allAvg(2,:) = highPropAvg;
allAvg(3,:) = ketAvg;
allAvg(4,:) = lowIsoAvg;
allAvg(5,:) = lowPropAvg;
allAvg(6,:) = awakeAvg;


%%

plotTime = 500:2000;
timeAxis = linspace((plotTime(1)/finalSampR-1),(plotTime(end)/finalSampR-1), length(plotTime));

figure 
clf
for i = 1:size(allAvg,1)
    h(i) = subplot(2,3,i)
    plot(timeAxis, squeeze(allAvg(i,plotTime)))
    set(gca, 'ylim', [min(allAvg(:)), max(allAvg(:))]);
    title(conStrings{i})
     if i == 4
         line([0.5 0.5], [-350 -250], 'LineWidth', 2, 'Color', 'k'); % vertical line
         line([0.5 1], [-350 -350], 'LineWidth', 2, 'Color', 'k'); % horizontal line
         tt=text(0.5, -250, '100 uV', 'FontName', 'Arial', 'FontSize', 12); % vertical line
         tt2=text(.75, -400, '0.5 s', 'FontName', 'Arial', 'FontSize', 12); % horizontal line
    end
    axis off
end































