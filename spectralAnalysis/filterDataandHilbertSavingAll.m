%% To look at the 30-40Hz initial band

% clear
% close all
% 
% dirWAVE = '/synology/adeeti/ecog/iso_awake_VEPs/GL_early/Wavelets/';
% dirFILT = [dirIn, 'FiltData/'];
% 
% identifier = '2019*.mat';

%%

cd(dirWAVE)
mkdir(dirFILT);
allData = dir(identifier);
load(allData(1).name, 'Freq')

%% Band of interest

band = find(Freq>lowBound & Freq<highBound);

% band=find(Freq>4 & Freq<150);
% bandpt5hz= find(Freq>0 & Freq<0.6, 1, 'first');
% band1hz = find(Freq>.9 & Freq<1.5, 1, 'first');
% band2hz = find(Freq>2 & Freq<2.5, 1, 'first');
% band3hz = find(Freq>3 & Freq<3.5, 1, 'first');
% 
% band = [ band band3hz band2hz band1hz bandpt5hz];
% loadFreq = {};
% 
for i= 1:length(band)
    temp = ['WAVE', num2str(band(i))];
    loadFreq{i} = temp;
end

%% Loading relavent data and creating band freq matrix

for experiment = 1:length(allData)
    %tic
    load(allData(experiment).name, 'Freq', 'SCALE', 'PARAMOUT', 'K', 'info', 'uniqueSeries', 'indexSeries');
    for i = 1:length(band)
        load(allData(experiment).name, loadFreq{i})
        waveVariables = eval(['WAVE' num2str(band(i))]);
        filtWavelet=zeros([length(Freq), size(waveVariables)]);
        filtWavelet(band(i),:,:,:) = waveVariables;
 
        filtTemp = squeeze(invcwt(filtWavelet, 'MORLET', SCALE, PARAMOUT, K)); %filtSingal in timepoints x channels x trials
        eval([['filtSig', num2str(floor(Freq(band(i))))] '= filtTemp;'])
        sigTemp = ['filtSig', num2str(floor(Freq(band(i))))];

        HTemp =hilbert(filtTemp);
        eval(['H', num2str(floor(Freq(band(i)))) '= HTemp;'])
        tempH = ['H', num2str(floor(Freq(band(i))))];

        disp(['Saving experiment ', num2str(experiment), ' out of ', num2str(length(allData)), ' frequency', num2str(floor(Freq(band(i))))])
        if i ==1 && ~exist([dirFILT, allData(experiment).name]) ==1
            save([dirFILT, allData(experiment).name], tempH, sigTemp, 'Freq', 'info','uniqueSeries', 'indexSeries')
            clearvars WAVE* filtSig* H*
        else
            save([dirFILT, allData(experiment).name], tempH, sigTemp, '-append')
            clearvars WAVE* filtSig* H*
        end
    end
    %toc
end


