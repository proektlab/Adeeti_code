% Quick time freqency analysis on ecog data and making the ITPC for channels around V1
% 9/19/18 AA editted for multistim delivery

clear
close all

dateToday = '2019-10-04';

dirIn =['D:\AdeetiData\' dateToday, '\matlab\'];
dirOutPIC = ['D:\Images\' dateToday, '\'];
cd(dirIn)
identifier = '*.mat';
allData = dir(identifier);
expID = 3;

experiment = allData(expID).name;

lowestLatVariable = 'lowLat';
stimIndex = [0, Inf]; %if want all, stimIndex = matStimIndex; % if want
%all uniStimIndexes/multiStimIndexes, use [uniStimIndex, multiStimIndex] =
%findUniMutliStimIndex(matStimIndex), [stimIndex, ~] = findUniMutliStimIndex(matStimIndex)

sizeSmallSnippit = 1:2001;

%% Setting up parameters

addpath(genpath('C:\Users\Plexon\Google Drive\NEURA_codeShare\Adeeti_code'))

mkdir(dirOutPIC);
screensize=get(groot, 'Screensize');

%%

load(experiment, 'info', 'meanSubData', 'finalSampR', 'finalTime', 'uniqueSeries', 'indexSeries', 'meanSubFullTrace')

if ~isfield(info, lowestLatVariable)
disp(['No variable info.' lowestLatVariable, ' . Trying next experiment.']);
end

[indices] = getStimIndices(stimIndex, indexSeries, uniqueSeries);
useMeanSubData = meanSubData(info.ecogChannels, indices,:);
useSmallSnippits = meanSubData(info.ecogChannels, indices,sizeSmallSnippit);

%% finding V1 for each experiment based on mode
[adjVector] = findAdjacentChan(info);
eval(['lowLat = info.', lowestLatVariable, ';'])

%% Run wavelet on real data
disp('Wavelet on Real Data')
WAVE=zeros(40, 2001, size(useSmallSnippits,1), size(useSmallSnippits,2));
for i=1:size(WAVE,3)
    disp(i);
    for j = 1:size(useSmallSnippits,2)
        sig=detrend(squeeze(useSmallSnippits(i, j,:)));
        % [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/1000,1, 0.1);
        [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/1000,1, 0.25);
        WAVE(:,:,i, j)=temp; %WAVE is in freq by time by channels by trials
        Freq=1./PERIOD;
    end
end

%% For intertrial phase coherence

disp('Running ITPC')

myChannels = adjVector(lowLat,:);

trueITPC = ITPC_AA(WAVE);

%% Plotting just the ITPC over the channels around lowLat

currentFig = figure('Position', screensize); clf;

for ch = 1:length(myChannels)
    channel = myChannels(ch);
    if isnan(channel)
        continue
    end
    
    % plot results- average trace on top and p values of ITPC on the
    % bottom
    h1= subplot(6,3,floor((ch-1)/3)*6 + mod(ch-1,3) + 1);
    plot(squeeze(nanmean(useSmallSnippits(channel,:,:),2)));
    title(['Average trace channel ', num2str(channel)])
    colorbar
    
    h2= subplot(6, 3, floor((ch-1)/3)*6 + mod(ch-1,3)+4);
    pcolor(1:size(useSmallSnippits,3), Freq, squeeze(trueITPC(channel,:,:))); shading 'flat';
    set(gca, 'yscale', 'log')
    colorbar
    title(['True ITPC channel ', num2str(channel)])
    
    linkaxes([h1 h2], 'x')
    set(gca, 'xlim', [0, 2001])
end

suptitle(['ITPC for channels around V1 of ', info.expName, ' drug: ', info.AnesType, ' conc: ' num2str(info.AnesLevel)])
saveas(currentFig, [dirOutPIC, info.expName(1:end-4), 'trueITPC.png'])
%close all;

%% making coherence movie using inverse wavelet

% fr = 35;
% dropboxLocation = 'C:\Users\Plexon\Dropbox\';
% start = 900;
% endTime = 1300; %time after in ms
% 
% frIndex = find(floor(Freq) == fr);
% 
% filtWavelet=zeros(size(WAVE));
% filtWavelet(frIndex,:,:,:) = squeeze(WAVE(frIndex,:,:,:));
% for i = 1:size(WAVE, 3)
%     for j = 1:size(WAVE, 4)
%         filtSigFr(:,:,i,j) = squeeze(invcwt(filtWavelet(:,:,i,j), 'MORLET', SCALE, PARAMOUT, K)); %filtSingal in timepoints x channels x trials
%     end
% end
% filtSigFr = squeeze(filtSigFr);
% 
% [movieOutput, filtSigFr] = singleMovieCoherenceFromWAVE(info, filtSigFr, dropboxLocation, start, endTime);
% 
% v = VideoWriter([dirOutPIC, experiment, 'coherence35.avi']);
% open(v)
% writeVideo(v,movieOutput)
% close(v)
% close all 

%%  making coherence movie with bandpass filtering data

filtbound = [20 70]; % Hz
%filtbound = [30 40]; % Hz
trans_width = 0.2; % fraction of 1, thus 20%
filt_order = 50; %filt_order = round(3*(EEG.srate/filtbound(1)));

dropboxLocation = 'C:\Users\Plexon\Google Drive\NEURA_codeShare\Adeeti_code\';
start = 900;
endTime = 1300; %time after in ms

[filterweights] = buildBandPassFiltFunc_AA(finalSampR, filtbound, trans_width, filt_order);

% apply filter to data
filtered_data = zeros(size(meanSubData));
for ch=1:size(meanSubData, 1)
    for tr = 1:size(meanSubData,2)
    filtered_data(ch,tr,:) = filtfilt(filterweights,1,squeeze(meanSubData(ch,tr,:)));
    end
end

filtered_data = permute(filtered_data(:,:,1:2001), [3 1 2]);

[movieOutput, filtSigFr] = singleMovieCoherenceFromWAVE(info, filtered_data, dropboxLocation, start, endTime);

v = VideoWriter([dirOutPIC, info.expName, 'filtfiltcohWideGamma.avi']);
%v = VideoWriter([dirOutPIC, info.expName, 'filtfiltcoh35Gamma.avi']);
open(v)
writeVideo(v,movieOutput)
close(v)
close all 

