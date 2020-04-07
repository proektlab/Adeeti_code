

dirIn = 'Z:\adeeti\ecog\iso_awake_VEPs\GL_early\';
dirOut = 'Z:\adeeti\ecog\images\Iso_Awake_VEPs\GL_early\avgMovies\';

mkdir(dirOut);
cd(dirIn);

start = 900; %time before in ms
endTime = 1750; %time after in ms
screensize=get(groot, 'Screensize');
movieOutput = [];
finalSampR = 1000;
darknessOutline = 80;
dropboxLocation = 'C:\Users\adeeti\Dropbox\KelzLab\'; %'/home/adeeti/Dropbox/KelzLab/'; %'C:\Users\adeeti\Dropbox\KelzLab\';


experiment =   '2019-10-04_17-38-00.mat';

plotIndex = 1;
    load(experiment, 'meanSubData', 'info', 'uniqueSeries', 'indexSeries')
    
    bregmaOffsetX = info.bregmaOffsetX;
    bregmaOffsetY = info.bregmaOffsetY;
    gridIndicies = info.gridIndicies;
    
    % Making sure to only grab  indexes that you are looking
    % for in the mix of trials
    [indices] = getStimIndices([0, Inf], indexSeries, uniqueSeries);
    useAvg = nanmean(meanSubData(:,indices,:), 2);
    useAvg = permute(useAvg, [2,3,1]);

%     %average signal at 35 Hz
%     sig = squeeze(mean(sig,3));
%     
%     %normalize signal to baseline
%     m = mean(sig(1:1000,:),1);
%     s = std(sig(1:1000,:),1);
%     ztransform=(m-sig)./s;
%     filtSig(anes,:,:) = ztransform;
%     
    %create labels
    plotTitles{1} = [info.AnesType, ', dose: ', num2str(info.AnesLevel)];


superTitle = ['Average ' info.AnesType, ', Exp: ', num2str(info.exp)];
colorTitle = ['Raw voltage'];

[movieOutput] = makeMoviesWithOutlinesFunc(useAvg, start, endTime, bregmaOffsetX, bregmaOffsetY, gridIndicies, plotTitles, superTitle, colorTitle, [], darknessOutline, dropboxLocation);

v = VideoWriter([dirOut, 'Exp', experiment(1:end-4), '.avi']);
open(v)
writeVideo(v,movieOutput)
close(v)
close all