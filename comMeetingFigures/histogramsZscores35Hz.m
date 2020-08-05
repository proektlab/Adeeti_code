%% Making movie heat plot of ITPC MutliStim Data

% 8/13/18 Editted for multistim  and multiple anesthetics experiments
% 1/15/19 Editted for larger fonts and new dropbox location
%% Make movie of mean signal at 30-40 Hz for all experiments
clc
clear
close all

set(0,'defaultfigurecolor',[1 1 1])

dirAwake = '/synology/adeeti/ecog/iso_awake_VEPs/'; %'Z:\adeeti\ecog\iso_awake_VEPs\GL_early\';
dirProp = '/synology/adeeti/ecog/matIsoPropMultiStim//'; %'Z:\adeeti\ecog\iso_awake_VEPs\GL_early\';

%%
dropboxLocation = '/home/adeeti/Dropbox/ProektLab_code/Adeeti_code/'; %'C:\Users\adeeti\Dropbox\KelzLab\';
dirOut =  '/home/adeeti/Dropbox/KelzLab/misc_figures/';

screensize=get(groot, 'Screensize');

stimIndex = [0, Inf];
fr= 35;

conStrings = {'Isoflurane High'; 'Propofol High'; 'Ketamine Low'; 'Isoflurane Low'; 'Propofol Low'; 'Awake'};

%% find all iso for awake recordings
cd(dirAwake)
allDir = [dir('IP*'); dir('GL*')];

ident1 = '2019*';
ident2 = '2020*';

counter = 1;
for d = 1:length(allDir)
    cd([dirAwake, allDir(d).name])
    mouseID = allDir(d).name;
    genPicsDir =  ['/synology/adeeti/ecog/images/Iso_Awake_VEPs/', mouseID, '/'];
    dirIn = ['/synology/adeeti/ecog/iso_awake_VEPs/', mouseID, '/'];
    
    allData = dir(ident1);
    identifier = ident1;
    
    if isempty(allData)
        allData = dir(ident2);
        identifier = ident2;
    end
    
    load('dataMatrixFlashes.mat')
    MFE = findMyExpMulti(dataMatrixFlashes, [], 'iso', [], stimIndex);
    
    dirFILT = [dirIn, 'FiltData/'];
    cd(dirFILT)
    
    for m = 1:length(MFE)
        load([dataMatrixFlashes(MFE(m)).expName(end-22:end-4), 'wave.mat'], ['filtSig', num2str(fr)], 'info', 'uniqueSeries', 'indexSeries')
        [indices] = getStimIndices(stimIndex, indexSeries, uniqueSeries);
        eval(['sig = filtSig', num2str(fr), ';']);
        
        %average signal at 35 Hz
        sig = squeeze(mean(sig,3));
        
        %normalize signal to baseline
        m = mean(sig(1:1000,:),1);
        s = std(sig(1:1000,:),1);
        ztransform=(m-sig)./s;
        AlexMax(counter,:) = max(ztransform(:));
        AlexMin(counter,:) = min(ztransform(:));
        counter = counter+1;
    end
end




%% Diegos lab

cd(dirProp)
ident1 = '2018*';
load('dataMatrixFlashes.mat')
MFE = findMyExpMulti(dataMatrixFlashes, [], 'iso', [], stimIndex);

counter = 1;

dirFILT = [dirProp, 'Wavelets/FiltData'];
cd(dirFILT)

for m = 1:length(MFE)
    load([dataMatrixFlashes(MFE(m)).expName(end-22:end-4), 'wave.mat'], ['filtSig', num2str(fr)], 'info', 'uniqueSeries', 'indexSeries')
    [indices] = getStimIndices(stimIndex, indexSeries, uniqueSeries);
    eval(['sig = filtSig', num2str(fr), ';']);
    
    %average signal at 35 Hz
    sig = squeeze(mean(sig,3));
    
    %normalize signal to baseline
    m = mean(sig(1:1000,:),1);
    s = std(sig(1:1000,:),1);
    ztransform=(m-sig)./s;
    DiegoMax(counter,:) = max(ztransform(:));
    DiegoMin(counter,:) = min(ztransform(:));
    counter = counter+1;
end

%%

figure
clf
subplot(1,2,1)
histogram(AlexMin,8)
hold on 
histogram(DiegoMin,8)
legend('Alex Rig', 'Deigo Rig')
xlabel('min zscore')
ylabel('frequency')
title('Min zScores')

subplot(1,2,2)
histogram(AlexMax,8)
hold on 
histogram(DiegoMax,8)
legend('Alex Rig', 'Deigo Rig')
xlabel('max zscore')
ylabel('frequency')
title('Max zScores')
    
   
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
