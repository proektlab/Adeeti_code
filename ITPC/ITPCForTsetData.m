%% ITPC for test data

outName = [];

%% Build test data

NUM_TRIALS = 300;
TRIAL_LENGTH = 3001;

meanSubData = zeros(1,NUM_TRIALS,TRIAL_LENGTH);

for i = 1:NUM_TRIALS
    trialData = normrnd(0, 0.1, TRIAL_LENGTH,1);
    deltaFunctionPostion = round(normrnd(1000,20));
    trialData(deltaFunctionPostion:deltaFunctionPostion+10) = 1;
    
    meanSubData(1,i,:) = trialData;
end

smallSnippits = meanSubData(1,:,1:2001);

%%


screensize=get(groot, 'Screensize');

%% finding V1 for each experiment based on mode
[adjVector] = findAdjacentChan(info);
V1 = 1;

%% Parameters for Stats
totTrialsPerExp = size(meanSubData, 2);
trialsPerSamp = totTrialsPerExp;
totSamp = 100;

%% Making fake data flashes onsets (rand time of starts)
[fakeSnippits] = makeFakeSnippits(meanSubData, smallSnippits);

%% Run wavelet on fake data
disp('Wavelet on Fake Data')
fakeWAVE=zeros(40, 2001, size(fakeSnippits,1), size(fakeSnippits,2));
for i=1:size(fakeWAVE,3)
    disp(i);
    for j = 1:size(fakeSnippits,2)
        sig=detrend(squeeze(fakeSnippits(i, j,:)));
        % [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/1000,1, 0.1);
        [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/1000,1, 0.25);
        fakeWAVE(:,:,i, j)=temp; %WAVE is in freq by time by channels by trials
        Freq=1./PERIOD;
    end
end

%% Run wavelet on real data
disp('Wavelet on Real Data')
WAVE=zeros(40, 2001, size(smallSnippits,1), size(smallSnippits,2));
for i=1:size(WAVE,3)
    disp(i);
    for j = 1:size(smallSnippits,2)
        sig=detrend(squeeze(smallSnippits(i, j,:)));
        % [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/1000,1, 0.1);
        [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/1000,1, 0.25);
        WAVE(:,:,i, j)=temp; %WAVE is in freq by time by channels by trials
        Freq=1./PERIOD;
    end
end

%% For intertrial phase coherence

disp('Running ITPC iterations')

myChannels = 1;
statsFakeITPC = nan(totSamp, length(myChannels), size(WAVE, 1), size(WAVE, 2));
statsRealITPC = nan(totSamp, length(myChannels), size(WAVE, 1), size(WAVE, 2));

clear exp
for i = 1:totSamp
    tic
    trials = randsample(totTrialsPerExp, trialsPerSamp, 'true'); %with replacement
    %     useWAVE = fakeWAVE(:, :, : , trials);
    [ITPCmeasures] = ITPC_AA(fakeWAVE, myChannels, trials);
    statsFakeITPC(i, :, :, :) = ITPCmeasures;
    disp(['Calculating ', num2str(i), ' out of ', num2str(totSamp) ' time taken ' num2str(round(toc*1000)) 'ms'])
end
stErrorFakeITPC = squeeze(std(statsFakeITPC, [], 1));
meanFakeITPC = squeeze(mean(statsFakeITPC, 1));

clear exp
for i = 1:totSamp
    tic
    trials = randsample(totTrialsPerExp, trialsPerSamp, 'true');
    %     useWAVE = fakeWAVE(:, :, : , trials);
    [ITPCmeasures] = ITPC_AA(WAVE, myChannels, trials);
    statsRealITPC(i, :, :, :) = ITPCmeasures;
    disp(['Calculating ', num2str(i), ' out of ', num2str(totSamp) ' time taken ' num2str(round(toc*1000)) 'ms'])
end
trueITPC = ITPC_AA(WAVE);
stErrorRealITPC = squeeze(std(statsRealITPC, [], 1));
meanRealITPC = squeeze(mean(statsRealITPC, 1));

%% T test to compare how real data compares with fake data
% Welch's t test- equal sample size, unequal variances
tVals = (meanRealITPC- meanFakeITPC)./sqrt((stErrorFakeITPC.^2+stErrorRealITPC.^2));
pVals = tcdf(tVals,trialsPerSamp-1);

use_p_value = 3; % 1 for p value, 0 for t Value, any other number for true ITPC
currentFig = figure('Position', screensize); clf;

for ch = 1:length(myChannels)
    channel = myChannels(ch);
    if isnan(channel)
        continue
    end
    
    % plot results- average trace on top and p values of ITPC on the
    % bottom
    h1= subplot(2,1,1)
    plot(squeeze(nanmean(smallSnippits(channel,:,:),2)));
    title(['Average trace channel ', num2str(channel)])
    colorbar
    
    h2= subplot(2, 1,2)
    if use_p_value == 1;
        pcolor(1:size(smallSnippits,3), Freq, log10(squeeze(1-squeeze(pVals(:,:))))); shading 'flat';
        set(gca, 'yscale', 'log')
        colorbar
        title(['P-Value ITPC channel ', num2str(channel)])
        set(gca,'clim',[-8 0])
    elseif use_p_value == 0;
        pcolor(1:size(smallSnippits,3), Freq, squeeze(tVals(:,:))); shading 'flat';
        set(gca, 'yscale', 'log')
        colorbar
        title(['t-Value ITPC channel ', num2str(channel)])
    else
        pcolor(1:size(smallSnippits,3), Freq, squeeze(trueITPC(1,:,:))); shading 'flat';
        set(gca, 'yscale', 'log')
        colorbar
        title(['True ITPC channel ', num2str(channel)])
    end
    
    linkaxes([h1 h2], 'x')
    set(gca, 'xlim', [0, 2001])
end

suptitle(['ITPC for test data'])

if (~isempty(outName))
    saveas(currentFig, [outName, '.png'])
    close all;
end