%% Looking at emergence

clear
clc
close all

if isunix ==1 && ismac ==0
    dirIn = '/synology/adeeti/ecog/iso_awake_VEPs/CB3/';
    emergInd = 3;
    lowIsoInd = 2;
    awakeInd1 = 4;
    awakeInd2 = 5;
elseif ispc ==1
    dirIn = 'Z:\adeeti\ecog\iso_awake_VEPs\CB3\';
    emergInd = 3;
    lowIsoInd = 2;
    awakeInd1 = 4;
    awakeInd2 = 5;
elseif ismac ==1
    dirIn = '/Users/adeetiaggarwal/Desktop/CB3/';
    emergInd = 2;
    lowIsoInd = 1;
    awakeInd1 = 3;
    
end

cd(dirIn)
identifier = '2020*';
allData = dir(identifier);

% loading data
load(allData(emergInd).name, 'meanSubData', 'info')
emgMeanSubData = meanSubData;
avgEmg = squeeze(nanmean(emgMeanSubData,2));
load(allData(lowIsoInd).name, 'meanSubData', 'info')
lowIsoMeanSubData = meanSubData;
avgIso = squeeze(nanmean(lowIsoMeanSubData,2));
load(allData(awakeInd1).name, 'meanSubData', 'info')
awake1MeanSubData = meanSubData;
avgAwake1 = squeeze(nanmean(awake1MeanSubData,2));
if exist('awakeInd2')
    load(allData(awakeInd2).name, 'meanSubData', 'info')
    awake2MeanSubData = meanSubData;
    avgAwake2 = squeeze(nanmean(awake2MeanSubData,2));
end

%% looking at single trials
figure
subplot(1,4,1)
imagesc(squeeze(lowIsoMeanSubData(info.lowLat,:,500:1700)))
colorbar
set(gca, 'clim', [-0.25, 0.25])
title('Iso')
subplot(1,4,2)
imagesc(squeeze(emgMeanSubData(info.lowLat,:,500:1700)))
colorbar
set(gca, 'clim', [-0.25, 0.25])
title('Emergence')
subplot(1,4,3)
imagesc(squeeze(awake1MeanSubData(info.lowLat,:,500:1700)))
colorbar
title('Awake')
set(gca, 'clim', [-0.25, 0.25])
subplot(1,4,4)
imagesc(squeeze(awake2MeanSubData(info.lowLat,:,500:1700)))
colorbar
title('Awake')
set(gca, 'clim', [-0.25, 0.25])

%% mean subtracting or z scoring trials/ averages 

compTime = 1015:1300;
baseline = 500:900;

emgV1SingleTrials = squeeze(emgMeanSubData(info.lowLat,:,compTime));

emgV1ST_meanSub = [];
emgV1ST_zscore = [];
for i = 1:size(emgV1SingleTrials,1)
    mD = mean(emgV1SingleTrials(i,:));
    emgV1ST_meanSub(i,:) = emgV1SingleTrials(i,:) - mD;
    mB = mean(squeeze(emgMeanSubData(info.lowLat,i,baseline)));
    sB = std(squeeze(emgMeanSubData(info.lowLat,i,baseline)));
    emgV1ST_zscore(i,:) = (emgV1SingleTrials(i,:) - mB)/sB;
end

isoV1avg = avgIso(info.lowLat, compTime);
isoV1avg_meanSub = isoV1avg - mean(isoV1avg);
isoV1avg_zscore = (isoV1avg- mean(squeeze(avgIso(info.lowLat, baseline))))/std(squeeze(avgIso(info.lowLat, baseline)));

awake1V1avg = avgAwake1(info.lowLat, compTime);
awa1V1avg_meanSub = awake1V1avg - mean(awake1V1avg);
awa1V1avg_zscore = (awake1V1avg- mean(squeeze(avgAwake1(info.lowLat, baseline))))/std(squeeze(avgAwake1(info.lowLat, baseline)));


if exist('avgAwake2')
awake2V1avg = avgAwake2(info.lowLat, compTime);
awa2V1avg_meanSub = awake2V1avg - mean(awake2V1avg);
awa2V1avg_zscore = (awake2V1avg- mean(squeeze(avgAwake2(info.lowLat, baseline))))/std(squeeze(avgAwake2(info.lowLat, baseline)));
end


%% mean subtracted cosine distance 
% emg2Iso = pdist2(emgV1SingleTrials, isoV1avg,'cosine');
% emg2Awa1 = pdist2(emgV1SingleTrials, awake1V1avg,'cosine');
% emg2Awa2 = pdist2(emgV1SingleTrials, awake2V1avg,'cosine');

emg2Iso = pdist2(emgV1ST_meanSub, isoV1avg_meanSub,'cosine');
emg2Awa1 = pdist2(emgV1ST_meanSub, awa1V1avg_meanSub,'cosine');
if exist('avAwake2')
    emg2Awa2 = pdist2(emgV1ST_meanSub, awa2V1avg_meanSub,'cosine');
end

% awa1_iso_avgSim = pdist2(isoV1avg_meanSub, awa1V1avg_meanSub, 'cosine');
% awa1_awa2_avgSim = pdist2(awa2V1avg_meanSub, awa1V1avg_meanSub, 'cosine');

%% zscored cosine distance 

emg2Iso = pdist2(emgV1ST_zscore, isoV1avg_zscore,'cosine');
emg2Awa1 = pdist2(emgV1ST_zscore, awa1V1avg_zscore,'cosine');
if exist('avAwake2')
    emg2Awa2 = pdist2(emgV1ST_zscore, awa2V1avg_zscore,'cosine');
end

% awa1_iso_avgSim = pdist2(isoV1avg_zscore, awa1V1avg_zscore, 'cosine');
% awa1_awa2_avgSim = pdist2(awa2V1avg_zscore, awa1V1avg_zscore, 'cosine');


%% taking sliding averages for distance measure 
AVG_SLIDE =1;

if AVG_SLIDE ==1
    window = 4;
    for i = 1:size(emgV1ST_zscore,1)-window
        slide_emergST(i,:) = mean(emgV1ST_zscore(i:i+window,:),1);
    end
    
    emg2Iso = pdist2(slide_emergST, isoV1avg_zscore,'cosine');
    emg2Awa1 = pdist2(slide_emergST, awa1V1avg_zscore,'cosine');
    if exist('avAwake2')
        emg2Awa2 = pdist2(slide_emergST, awa2V1avg_zscore,'cosine');
    end
end


%% looking at the data 

% looking at averages 

figure
plot(isoV1avg_meanSub)
hold on
plot(awa1V1avg_meanSub)
if exist('awa2V1avg_meanSub')
plot(awa2V1avg_meanSub)
end

% looking at distance on single trial basis 
figure
subplot(2,2,1)
hold on
plot(emg2Iso', 'r')
plot(emg2Awa1', 'g')
legend('iso', 'awake')
xlabel('Emerg ST')
ylabel('Cos dist')
title('Cos dist over trials')

subplot(2,2,2)
plot(emg2Awa1', emg2Iso', 'o')
xlabel('Awake')
ylabel('Iso')
title('Cos dist of awk vs iso for each ST')

subplot(2,2,3)
histogram(log10(emg2Awa1./emg2Iso), 30)
xlabel('log ratio (awk/iso)')
ylabel('freq')
title('Ratio of cos dist Awake to cost dis Iso')

subplot(2,2,4)
plot(log10(emg2Awa1./emg2Iso), 'o-')
ylabel('log ratio (awk/iso)')
ylabel('emerg ST')
title('Ratio of cos dist Awake to cost dis Iso')
sgtitle(['Decimate = ', num2str(decimateData)])







% histograms
figure
if exist('emg2Awa2')
    subplot(3,1,1)
    histogram(emg2Iso)
    title('Emerg to Iso')
    subplot(3,1,2)
    histogram(emg2Awa1)
    title('Emerg to Awake 1')
    subplot(3,1,3)
    histogram(emg2Awa2)
    title('Emerg to Awake 2')
else
    subplot(2,1,1)
    histogram(emg2Iso)
    title('Emerg to Iso')
    subplot(2,1,2)
    histogram(emg2Awa1)
    title('Emerg to Awake 1')
end

% for fixed time sequences
% comp2iso = emg2Iso;
% comp2awa1 = emg2Awa1;
% comp2awa2 = emg2Awa2;

% emgCosDis1 = [];
% emgCosDis1(:,1) = comp2iso;
% emgCosDis1(:,2) = comp2awa1;
% 
% emgCosDis2 = [];
% emgCosDis2(:,1) = comp2iso;
% emgCosDis2(:,2) = comp2awa2;

% figure
% hist3(emgCosDis1)
% axis vis3d
% box on
% xlabel('Iso')
% ylabel('Awake')

























%% using serial pdist2

decimateData =0;

compLongTime = 1000:1350;
emgV1SingleTrials = squeeze(emgMeanSubData(info.lowLat,:,compLongTime));
emgV1ST_meanSub = [];
for i = 1:size(emgV1SingleTrials,1)
    mD = mean(emgV1SingleTrials(i,:));
    %emgV1ST_meanSub(i,:) = emgV1SingleTrials(i,:) - mD;
    emgV1ST_meanSub(i,:) = emgV1SingleTrials(i,:);
    if decimateData ==1
        newEmg(i,:) = decimate(emgV1ST_meanSub(i,:), 10);
    end
end

emg2IsoShift =[];
emg2Awa1Shift= [];
emg2Awa2Shift = [];

if decimateData ==1
    newIso = decimate(isoV1avg_meanSub, 10);
    newAwa1 = decimate(awa1V1avg_meanSub,10);
    if exist('awa2V1avg_meanSub')
    newAwa2 = decimate(awa2V1avg_meanSub,10);
    end
    bufLength = size(newIso,2);
    allShiftsEmg = nan(size(newEmg,1), size(newEmg,2)-bufLength+1, bufLength);
    for i = 1:size(newEmg,1)
        temp = buffer(newEmg(i,:), bufLength, bufLength-1);
        temp = temp(:,bufLength:end);
        temp = temp - mean(temp,1);
        allShiftsEmg(i,:,:) = temp';
    end
    
    for i = 1:size(allShiftsEmg)
        emg2IsoShift(i,:) = pdist2(squeeze(allShiftsEmg(i,:,:)), newIso,'cosine');
        emg2Awa1Shift(i,:) = pdist2(squeeze(allShiftsEmg(i,:,:)), newAwa1,'cosine');
        emg2Awa2Shift(i,:) = pdist2(squeeze(allShiftsEmg(i,:,:)), newAwa2,'cosine');
    end
else
    bufLength = size(isoV1avg_meanSub,2);
    allShiftsEmg = nan(size(emgV1ST_meanSub,1), size(emgV1ST_meanSub,2)-bufLength+1, bufLength);
    for i = 1:size(emgV1ST_meanSub,1)
        temp = buffer(emgV1ST_meanSub(i,:), bufLength, bufLength-1);
        temp = temp(:,bufLength:end);
        temp = temp - mean(temp,1);
        allShiftsEmg(i,:,:) = temp';
    end
    
    for i = 1:size(allShiftsEmg)
        emg2IsoShift(i,:) = pdist2(squeeze(allShiftsEmg(i,:,:)), isoV1avg_meanSub,'cosine');
        emg2Awa1Shift(i,:) = pdist2(squeeze(allShiftsEmg(i,:,:)), awa1V1avg_meanSub,'cosine');
        emg2Awa2Shift(i,:) = pdist2(squeeze(allShiftsEmg(i,:,:)), awa2V1avg_meanSub,'cosine');
    end
end

emg2Iso_minShift = min(emg2IsoShift,[],2);
emg2Awa1_minShift = min(emg2Awa1Shift,[],2);
emg2Awa1_minShift= min(emg2Awa2Shift,[],2);

%%  plotting serial pDist2

trial = 4;
figure; clf
subplot(3,1,1)
if decimateData ==1
    plot(newEmg(trial,:), 'b')
    hold on
    plot(newIso, 'r')
    plot(newAwa1, 'g')
else
    plot(emgV1ST_meanSub(trial,:), 'b')
    hold on
    plot(isoV1avg_meanSub, 'r')
    plot(awa1V1avg_meanSub, 'g')
end
legend('emerg ST', 'iso avg', 'awk avg')
title('Traces')
subplot(3,1,2)
plot(emg2IsoShift(trial,:), 'r')
hold on
plot(emg2Awa1Shift(trial,:), 'g')
title('Cosine distance with lags')
subplot(3,1,3)
imagesc(squeeze(allShiftsEmg(i,:,:)))
sgtitle(['Trial: ', num2str(trial), ' Decimate = ', num2str(decimateData)])
title('allLags')

%%
figure
subplot(2,2,1)
hold on
plot(emg2Iso_minShift', 'r')
plot(emg2Awa1_minShift', 'g')
legend('iso', 'awake')
xlabel('Emerg ST')
ylabel('Cos dist')
title('Cos dist over trials')

subplot(2,2,2)
plot(emg2Awa1_minShift', emg2Iso_minShift', 'o')
xlabel('Awake')
ylabel('Iso')
title('Cos dist of awk vs iso for each ST')

subplot(2,2,3)
histogram(log10(emg2Awa1_minShift./emg2Iso_minShift), 30)
xlabel('log ratio (awk/iso)')
ylabel('freq')
title('Ratio of cos dist Awake to cost dis Iso')

subplot(2,2,4)
plot(log10(emg2Awa1_minShift./emg2Iso_minShift), 'o-')
ylabel('log ratio (awk/iso)')
ylabel('emerg ST')
title('Ratio of cos dist Awake to cost dis Iso')
sgtitle(['Decimate = ', num2str(decimateData)])








