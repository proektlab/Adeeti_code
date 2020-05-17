function [meanPreStimFFT, stdPreStimFFT, ub_preFFT, lb_preFFT, meanPostStimFFT, stdPostStimFFT, ub_postFFT, lb_postFFT] ...
    = makePlotsFromCondFFT(allPowerFFT, preStimTime, postStimTime, useQuant, useSTD, ub_qu, lb_qu, times_std)
%[meanPreStimFFT, stdPreStimFFT, ub_preFFT, lb_preFFT, meanPostStimFFT, stdPostStimFFT, ub_postFFT, lb_postFFT] ...
%    = makePlotsFromCondFFT(allPowerFFT, preStimTime, postStimTime, useQuant, useSTD, ub_qu, lb_qu, times_std)

%%
if nargin< 8
    times_std = 2;
end

if nargin< 6
    ub_qu = 0.95;
    lb_qu = 0.05;
end

if nargin< 5
    useSTD = 0;
end
if nargin< 4
    useQuant = 1;
end

if nargin<2
    preStimTime = 1:25;
postStimTime = 60:150;
end


%%
FFT_size = size(allPowerFFT,4);
numExp = size(allPowerFFT,1);

meanPreStimFFT = nan(numExp,FFT_size);
stdPreStimFFT = nan(numExp,FFT_size);
ub_preFFT =  nan(numExp,FFT_size);
lb_preFFT = nan(numExp,FFT_size);

meanPostStimFFT =nan(numExp,FFT_size);
stdPostStimFFT = nan(numExp,FFT_size);
ub_postFFT =  nan(numExp,FFT_size);
lb_postFFT = nan(numExp,FFT_size);


%% finding the evoked power
preStimFFT = squeeze(nanmean(allPowerFFT(:,:,preStimTime,:),3));
postStimFFT = squeeze(nanmean(allPowerFFT(:,:,postStimTime,:),3));


%% Calculating mean and CIs
for i = 1:numExp
    meanPreStimFFT = squeeze(nanmean(preStimFFT,2));
    stdPreStimFFT = squeeze(nanstd(preStimFFT,0,2));%/sqrt(numSets);
    if useQuant ==1
        ub_preFFT(i,:) =  squeeze(quantile(preStimFFT(i,:,:), ub_qu));
        lb_preFFT(i,:) = squeeze(quantile(preStimFFT(i,:,:), lb_qu));
    elseif useSTD ==1
        ub_preFFT(i,:) =  squeeze(meanPreStimFFT(i,:))+ squeeze(stdPreStimFFT(i,:))*times_std;
        lb_preFFT(i,:) = squeeze(meanPreStimFFT(i,:))- squeeze(stdPreStimFFT(i,:))*times_std;
    end
    
    meanPostStimFFT = squeeze(nanmean(postStimFFT,2));
    stdPostStimFFT = squeeze(nanstd(postStimFFT,0,2));%/sqrt(numSets)
    if useQuant ==1
        ub_postFFT(i,:) =  squeeze(quantile(postStimFFT(i,:,:), ub_qu));
        lb_postFFT(i,:) = squeeze(quantile(postStimFFT(i,:,:), lb_qu));
    elseif useSTD ==1
        ub_postFFT(i,:) =  squeeze(meanPostStimFFT(i,:))+ squeeze(stdPostStimFFT(i,:))*times_std;
        lb_postFFT(i,:) = squeeze(meanPostStimFFT(i,:))- squeeze(stdPostStimFFT(i,:))*times_std;
    end
end
   
   