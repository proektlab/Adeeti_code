%% Stats on ITPC measures and making graphs for each experiment

%% parameters for bootstrapping
trialsPerSamp = 100;
totSamp = 1000;
totTrialsPerExp = size(meanSubData, 2);

channels = 15;

%% Making fake data flashes onsets (rand time of starts)

[fakeSnippits] = makeFakeSnippits(meanSubData, smallSnippets);

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

%% make second fake data

[fake2Snippits] = makeFakeSnippits(meanSubData, smallSnippets);

fake2WAVE=zeros(40, 2001, size(fake2Snippits,1), size(fake2Snippits,2));
for i=1:size(fake2WAVE,3)
    disp(i);
    for j = 1:size(fakeSnippits,2)
        sig=detrend(squeeze(fake2Snippits(i, j,:)));
        % [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/1000,1, 0.1);
        [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/1000,1, 0.25);
        fake2WAVE(:,:,i, j)=temp; %WAVE is in freq by time by channels by trials
        Freq=1./PERIOD;
    end
end

%% Run ITPC on first fake data

clear exp

statsFakeITPC = nan(totSamp, length(channels), size(fakeWAVE, 1), size(fakeWAVE, 2));

for i = 1:totSamp
    trials = randsample(totTrialsPerExp, trialsPerSamp);
%     useWAVE = fakeWAVE(:, :, : , trials);
    [ITPCmeasures] = ITPC_AA(fakeWAVE, channels, trials);
    statsFakeITPC(i, :, :, :) = ITPCmeasures;
    disp(['Calculating ', num2str(i), ' out of ', num2str(totSamp)])
end

fakeITPC = ITPC_AA(fakeWAVE);

stdFakeITPC = squeeze(std(statsFakeITPC, [], 1));
meanFakeITPC = squeeze(mean(statsFakeITPC, 1));

%zfakeITPC = (squeeze(fakeITPC(15,:,:)) - meanFakeITPC) ./ stErrorFakeITPC;

%% Run ITPC on second fake data

clear exp

stats2FakeITPC = nan(totSamp, length(channels), size(fake2WAVE, 1), size(fake2WAVE, 2));

for i = 1:totSamp
    trials = randsample(totTrialsPerExp, trialsPerSamp);
%     useWAVE = fakeWAVE(:, :, : , trials);
    [ITPCmeasures] = ITPC_AA(fake2WAVE, channels, trials);
    stats2FakeITPC(i, :, :, :) = ITPCmeasures;
    disp(['Calculating ', num2str(i), ' out of ', num2str(totSamp)])
end

fake2ITPC = ITPC_AA(fake2WAVE);

std2FakeITPC = squeeze(std(stats2FakeITPC, [], 1));
mean2FakeITPC = squeeze(mean(stats2FakeITPC, 1));

% z2FakeITPC = (squeeze(trueITPC(15,:,:)) - meanFakeITPC) ./ stErrorFakeITPC;


%% T test to compare how real data compares with fake data
% Welch's t test- equal sample size, unequal variances 

tVals = (mean2FakeITPC- meanFakeITPC)./sqrt((std2FakeITPC.^2+stdFakeITPC.^2));

pVals = tcdf(tVals,trialsPerSamp-1);

%% plotting and shit
% plot results
figure
clf

% h1= subplot(3,1,1)
% plot(squeeze(mean(fake2Snippits(channels,:,:),2)));
% colorbar
% title('Average trace')

h1 = subplot(3, 1, 1)
pcolor(1:size(smallSnippets,3), Freq, squeeze(fakeITPC(channels,:,:)));  shading 'flat';
set(gca, 'yscale', 'log')
colorbar
title('Fake ITPC')
%set(gca,'clim',[1-0.001/(numel(pVals)) 1])

h2 = subplot(3, 1, 2)
pcolor(1:size(smallSnippets,3), Freq, squeeze(fake2ITPC(channels,:,:))); shading 'flat';
set(gca, 'yscale', 'log')
colorbar
title('Fake 2 ITPC')
%set(gca,'clim',[1-0.001/(numel(pVals)) 1])

% h3=  subplot(3, 1, 3)
% pcolor(1:size(smallSnippets,3), Freq, squeeze(tVals)); shading 'flat';
% set(gca, 'yscale', 'log')
% colorbar
% title('T-Value ITPC')
% % set(gca,'clim',[0.95 1])
% suptitle(['ITPC for channel ', num2str(channels)])

h3=  subplot(3, 1, 3)
pcolor(1:size(smallSnippets,3), Freq, log10(squeeze(1-pVals))); shading 'flat';
set(gca, 'yscale', 'log')
colorbar
title('p-Vals of Comparison of 2 Fake Data Sets')
set(gca,'clim',[-10 -2])
suptitle(['Sanity Check ', num2str(channels)])

linkaxes([h1 h2 h3], 'x')
set(gca, 'xlim', [0, 2001])
