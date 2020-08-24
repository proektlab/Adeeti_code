
clear
close all
clc

genDir = '/Users/adeetiaggarwal/Google Drive'; %laptop
%genDir = '/Users/adeeti/Google Drive/'; %kelzmac

cd(genDir)
cd('data/matIsoPropMultiStimVIS_ONLY_/flashTrials/')
load('dataMatrixFlashesVIS_ONLY.mat')

%%
lowestLatVariable = 'lowLat';
stimIndex = [0, Inf]; %if want all, stimIndex = matStimIndex; % if want
%all uniStimIndexes/multiStimIndexes, use [uniStimIndex, multiStimIndex] =
%findUniMutliStimIndex(matStimIndex), [stimIndex, ~] = findUniMutliStimIndex(matStimIndex)

%[allIso] = findMyExpMulti(dataMatrixFlashesVIS_ONLY, [], 'iso', [], stimIndex);
%[allProp] = findMyExpMulti(dataMatrixFlashesVIS_ONLY, [], 'prop', [], stimIndex);


% Setting up new data set for just visual only stim
% expLabel =unique(vertcat(dataMatrixFlashes(:).exp));
% allExp = {};
% if exist('stimIndex')  && ~isempty(stimIndex)
%     for i = 1:length(expLabel)
%         for j = 1:size(stimIndex,1)
%             [MFE] = findMyExpMulti(dataMatrixFlashes, expLabel(i), [], [], stimIndex(j,:));
%             allExp{i}(:) = MFE;
%         end
%     end
% else
%     [MFE] = 1:length(dataMatrixFlashes);
% end
% 
% numSubjects = size(allExp,2);
% maxExposuresPerSubject = max(cellfun(@length, allExp));
% fs = 1000;


%%

load('2018-07-07_16-28-49.mat', 'info', 'aveTrace', 'meanSubFullTrace', 'meanSubData', 'finalSampR', 'allStartTimes')

allTTLs = zeros(1,size(meanSubFullTrace,2));
allTTLs(floor(allStartTimes*1000)) = 1;

timeKernal = [1020:1200];

timeAvgKern = squeeze(aveTrace(1,:,timeKernal));

%% filtering data

filtbound = [30 40]; % Hz
trans_width = 0.2; % fraction of 1, thus 20%
filt_order = 50; %filt_order = round(3*(EEG.srate/filtbound(1)));



[filterweights] = buildBandPassFiltFunc_AA(finalSampR, filtbound, trans_width, filt_order);

% apply filter to data
filtered_data = zeros(size(meanSubData));
filt_fullTrace = zeros(size(meanSubFullTrace));

for ch=1:size(meanSubData, 1)
    for tr = 1:size(meanSubData,2)
        filtered_data(ch,tr,:) = filtfilt(filterweights,1,squeeze(meanSubData(ch,tr,:)));
    end
    filt_fullTrace(ch,:) = filtfilt(filterweights,1,squeeze(meanSubFullTrace(ch,:)));
end

%filtered_data = permute(filtered_data(:,:,1:2001), [3 1 2]);

avgFiltData = nanmean(filtered_data,2);

gamAvgKern = avgFiltData(:,timeKernal);

figure(1); clf;
plot(timeAvgKern(info.lowLat,:))
hold on
plot(gamAvgKern(info.lowLat,:))
legend('Time Avg','Gamma Avg')
title('Kernals')

%% making test traces 1D

testTrace1 = zeros(1,10000);
testTrace1(1000:1000+size(timeAvgKern,2)-1) = timeAvgKern(48,:);
testTrace2 = zeros(1,10000);
testTrace2(1000) = 1;

figure(2); clf
plot(testTrace1)
hold on
plot(testTrace2)

testCon1s = convn(testTrace1, fliplr(timeAvgKern(48,:)), 'same');
testCon1v = convn(testTrace1, fliplr(timeAvgKern(48,:)), 'valid');
testCon1f = convn(testTrace1, fliplr(timeAvgKern(48,:)), 'full');
testCon2 = convn(testTrace2, fliplr(timeAvgKern(48,:)), 'same');

figure(2); clf
hold on
plot(testTrace1)
plot(testCon1s)
plot(testCon1v)
plot(testCon1f)
%plot(testCon2)
%plot(timeAvgKern(48,:))

%% making test traces 2D

testGrid1 = zeros(64,10000);
testGrid1(:,1000:1000+size(timeAvgKern,2)-1) = timeAvgKern(:,:);

testGrid2 = zeros(64,10000);
testGrid2(:,1000) = 1;

noNanTimeAvgKern = timeAvgKern;
noNanTimeAvgKern(isnan(noNanTimeAvgKern)) = 0;

testGrid1(isnan(testGrid1)) = 0;

testGrid2(isnan(testGrid2)) = 0;

% test_gridConv1 = convn(testGrid1,noNanTimeAvgKern,'full');
% [maxVt1, maxIt1] = max(test_gridConv1);
% 
% test_gridConv2 = convn(testGrid2,noNanTimeAvgKern,'valid');
% [maxVt2, maxIt2] = max(test_gridConv2);


test_gridConv1 = zeros(size(testGrid1));
test_gridConv2 = zeros(size(testGrid2));
% for i = 1:64
%     test_gridConv1(i,:) = convn(testGrid1(i,:), fliplr(timeAvgKern(i,:)), 'same');
%     test_gridConv2(i,:) = convn(testGrid2(i,:), fliplr(timeAvgKern(i,:)), 'same');
% end

test_gridConv1 = convn(testGrid1, flipud(fliplr(noNanTimeAvgKern)), 'valid');
test_gridConv2 = convn(testGrid2, flipud(fliplr(noNanTimeAvgKern)), 'valid');



figure(4); clf;
h(1)= subplot(2,1,1);
plot([zeros(1, (length(noNanTimeAvgKern)-1)/2), test_gridConv1])
%plot(test_gridConv1)
title('convoling kernal with itself')
h(2)= subplot(2,1,2);
plot([zeros(1, (length(noNanTimeAvgKern)-1)/2), test_gridConv2])
%plot(test_gridConv2)
title('convoling kernal with just one 1')
suptitle('Flip LR the UD')


%% time data

noNanTimeAvgKern = timeAvgKern;
noNanTimeAvgKern(isnan(noNanTimeAvgKern)) = 0;

noNanMeanSubFullTrace = meanSubFullTrace;
noNanMeanSubFullTrace(isnan(noNanMeanSubFullTrace)) = 0;

time_timeConvSig = convn(noNanMeanSubFullTrace,flipud(fliplr(noNanTimeAvgKern)),'valid');
[maxVtt, maxItt] = max(time_timeConvSig);

figure(4); clf;
h(1)= subplot(3,1,1);
plot([zeros(1, (length(noNanTimeAvgKern)-1)/2), time_timeConvSig])
hold on 
plot(allTTLs*maxVtt)
title('time data, time kernal')




%% time - gamma convolution

noNanGamAvgKern = gamAvgKern;
noNanGamAvgKern(info.noiseChannels,:) = 0;

time_gamConvSig = convn(noNanMeanSubFullTrace,flipud(fliplr(noNanGamAvgKern)),'valid');
[maxVtg, maxItg] = max(time_gamConvSig);

figure(4);
h(2)= subplot(3,1,2);
plot([zeros(1, (length(noNanTimeAvgKern)-1)/2),time_gamConvSig])
title('Time trace, gamma kernal')
hold on 
plot(allTTLs*maxVtg)



%%

noNanFilt_fullTrace = filt_fullTrace;
noNanFilt_fullTrace(isnan(noNanFilt_fullTrace)) = 0;

gam_gamConvSig = convn(noNanFilt_fullTrace,flipud(fliplr(noNanGamAvgKern)),'valid');
[maxVgg, maxIgg] = max(gam_gamConvSig);

figure(4);
h(3)= subplot(3,1,3);
plot([zeros(1, (length(noNanTimeAvgKern)-1)/2),gam_gamConvSig])
title('Gamma filt trace, gamma kernal')
hold on 
plot(allTTLs*maxVgg)

linkaxes(h, 'x')












% 
% for ch = 1:size(avgFiltData,1)
%     time_timeConvSig(ch,:) = convn(meanSubFullTrace(ch,:),timeAvgKern(ch,:),'same');
% end
% 
% 
% for ch = 1:size(gamAvgKern,1)
%     time_gamConvSig(ch,:) = convn(meanSubFullTrace(ch,:),gamAvgKern(ch,:),'same');
% end
% 
% for ch = 1:size(gamAvgKern,1)
%     gam_gamConvSig(ch,:) = convn(filt_fullTrace(ch,:),gamAvgKern(ch,:),'same');
% end



%%

figure
plot(meanSubFullTrace(info.lowLat,1:10000))
hold on
plot(time_timeConvSig(info.lowLat,1:10000))
plot(timeAvgKern(info.lowLat,:))

