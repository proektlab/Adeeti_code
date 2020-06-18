%% figure for SNACC abstract
clc
clear
%close all

if isunix
    dirIn = '/synology/adeeti/';
    dirCode = '/synology/code/Adeeti_code/';
elseif ispc
    dirIn = 'Z:/adeeti/';
    dirCode = 'Z:/code/Adeeti_code/';
end

dirInAwake = [dirIn, 'ecog/iso_awake_VEPs/goodMice/GL13/'];
dirInAwakeFiltData = [dirInAwake, '/FiltData/'];
dirIsoProp = [dirIn, 'ecog/matIsoPropMultiStim/'];
dirIsoPropFiltData = [dirIsoProp, '/FiltData/'];

dirPic = [dirIn, 'images/'];

%% Make movie of mean signal at 30-40 Hz for all experiments
fr = 35;
start = 1000; %time before in ms
endTime = 1250; %time after in ms
screensize=get(groot, 'Screensize');
darknessOutline = 80; %0 = no outline, 255 is max for black outlines, 80 is good middle ground

stimIndex = [0, Inf]; %if want all, stimIndex = matStimIndex; % if want

lowConc = [0.6, 20, 25]; %use these if want to split between low and high concentrations
highConc = [1.2, 35];

allConc = {lowConc};
conStrings = {'Low Dose'; 'High Dose'};

%%  finding experiments with the same characteristics: iso prop
cd(dirIsoProp)
load('dataMatrixFlashes.mat')
cd(dirIsoPropFiltData)
clear compAnesIsoProp

useExpIsoProp = 1;
myExp = findMyExpMulti(dataMatrixFlashes, useExpIsoProp, [], lowConc, stimIndex);
for t = 1:length(myExp)
    temp = dataMatrixFlashes(myExp(t)).expName;
    compAnesIsoProp{t} = [temp(length(temp)-22:end-4), 'wave.mat'];
end

clear filtSig sig absSig intSigAwake
numExp = length(compAnesIsoProp);

for anes = 1:numExp
    disp(compAnesIsoProp{anes})
    load(compAnesIsoProp{anes}, ['filtSig', num2str(fr)], 'info', 'uniqueSeries', 'indexSeries')
    
    bregmaOffsetXIsoProp = info.bregmaOffsetX;
    bregmaOffsetYIsoProp = info.bregmaOffsetY;
    gridIsoProp = info.gridIndicies;
    
    % Making sure to only grab  indexes that you are looking
    % for in the mix of trials
    [indices] = getStimIndices(stimIndex, indexSeries, uniqueSeries);
    eval(['sig = filtSig', num2str(fr), '(:, :,indices);']);
    
    %average signal at 35 Hz
    sig = squeeze(mean(sig,3));
    
    %normalize signal to baseline
    m = mean(sig(1:1000,:),1);
    s = std(sig(1:1000,:),1);
    ztransform=(m-sig)./s;
    filtSig(anes,:,:) = ztransform;
    absSig = abs(ztransform);
    intSigIsoProp(anes,:) = nansum(absSig(start:endTime,:),1);
    
    %create labels
    plotTitlesIsoProp{anes} = [info.AnesType];

end
intSigIsoProp = permute(intSigIsoProp, [1 3 2]);


%% Iso Awake ketamine
cd(dirInAwake)
load('dataMatrixFlashes.mat')

[~, isoLowExp, ~, ~, awaLastExp, ketExp] = ...
    findAnesArchatypeExp(dataMatrixFlashes);

MFE = [isoLowExp, awaLastExp, ketExp];
plotTitlesAwake = {'Low Isoflurane', 'Awake', 'Ketamine'};

cd(dirInAwakeFiltData)
allData = dir('2020*.mat');
clearvars intSigAwake

for anes = 1:length(MFE)
    disp(allData(MFE(anes)).name)
    load(allData(MFE(anes)).name, ['filtSig', num2str(fr)], 'info', 'uniqueSeries', 'indexSeries')
    
    bregmaOffsetX_Awake = info.bregmaOffsetX;
    bregmaOffsetY_Awake = info.bregmaOffsetY;
    gridAwake = info.gridIndicies;
    
    % Making sure to only grab  indexes that you are looking
    % for in the mix of trials
    [indices] = getStimIndices(stimIndex, indexSeries, uniqueSeries);
    eval(['sig = filtSig', num2str(fr), '(:, :,indices);']);
    
    %average signal at 35 Hz
    sig = squeeze(mean(sig,3));
    
    %normalize signal to baseline
    m = mean(sig(1:1000,:),1);
    s = std(sig(1:1000,:),1);
    ztransform=(m-sig)./s;
    filtSigAwake(anes,:,:) = ztransform;
    absSig = abs(ztransform);
    intSigAwake(anes,:) = nansum(absSig(start:endTime,:),1);
end
intSigAwake = permute(intSigAwake, [1 3 2]);
%% bringing data together 

allCompSig = nan(4,1,64);
%allCompSig(1,:,:) = intSigAwake(1,:,:);% isoflurane
allCompSig(1,:,:) = intSigIsoProp(1,:,:);% isoflurane
allCompSig(2,:,:) = intSigIsoProp(2,:,:);% propofol
allCompSig(3,:,:) = intSigAwake(2,:,:);% Awake
allCompSig(4,:,:) = intSigAwake(3,:,:);% ketamine

%allGridInd{1} = gridAwake;
allGridInd{1} = gridIsoProp;
allGridInd{2} = gridIsoProp;
allGridInd{3} = gridAwake;
allGridInd{4} = gridAwake;

offsetX(1:2) = bregmaOffsetXIsoProp;
offsetX(3:4) = bregmaOffsetX_Awake;
offsetY(1:2) = bregmaOffsetYIsoProp;
offsetY(3:4) = bregmaOffsetY_Awake;

plotTitles{1} = plotTitlesIsoProp{1};
plotTitles{2} = plotTitlesIsoProp{2};
plotTitles{3} = plotTitlesAwake{2};
plotTitles{4} = plotTitlesAwake{3};


%%

ff = figure('Color', 'w', 'Position', [5,397,1433,401]);

fontSize = 14;
for d = 1:4
    
    
    [g] = subplotForGridStills(d, 1, allCompSig, allGridInd{d}, [1,4], offsetX(d), ...
        offsetY(d), plotTitles{d}, [0 1500], 'zScore Coherent Gamma Power', fontSize);
    %superTitle = ['Spread of Visual Evoked Coherent Gamma Power Anesthetics ';
    %colorTitle = 'z threshold voltages from baseline';
    
    %[movieOutput] = makeMoviesWithOutlinesFunc(intSigIsoProp, 1, 1, bregmaOffsetX, bregmaOffsetY, gridIndicies, plotTitlesIsoProp, superTitle, colorTitle, [], darknessOutline, dirCode);
    
    %v = saveas([dropboxLocation, 'IntFilt_Exp', num2str(expLabel(exp)), stimIndexSeriesString, strrep(conStrings{c}, ' ', '_') '.pdf']);
    %open(v)
    %writeVideo(v,movieOutput)
    %close(v)
    %close all
    sgtitle(num2str(useExpIsoProp))
end

%% 
