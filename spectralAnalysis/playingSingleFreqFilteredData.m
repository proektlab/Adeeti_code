%% To look at the 30-40Hz initial band individualize 

clear

dirIn = '/data/adeeti/ecog/matFlashesJanMar2017/Wavelets/';
dirOut = '/data/adeeti/ecog/matFlashesJanMar2017/Wavelets/';

identifier = '2017*.mat';

%%
cd(dirIn);
mkdir(dirOut)
allData = dir(identifier);

%% Band of interest
band = [15 16 17];
loadFreq = {};

for i= 1:length(band)
    temp = ['WAVE', num2str(band(i))];
    loadFreq{i} = {temp};
end

%% Loading relavent data and creating band freq matrix

for experiment = 1:length(allData)
    load(allData(experiment).name, 'Freq', 'SCALE', 'PARAMOUT', 'K');
    for i = 1:length(band)
        load(allData(experiment).name, char(loadFreq{i}))
    end
    
    waveVariables = {};
    for i = 1:length(band)
        waveVariables{i} = eval(['WAVE' num2str(band(i))]);
    end
    
    filtSingalInd = nan([length(band), size(waveVariables{1})]);
    HInd = nan([length(band), size(waveVariables{1})]);
    
    for f = 1:length(band)
        filtWavelet=zeros([length(Freq), size(waveVariables{1})]);
        filtWavelet(band(f),:,:,:) = waveVariables{f};
        filtSingalInd(f,:,:,:) = squeeze(invcwt(filtWavelet, 'MORLET', SCALE, PARAMOUT, K)); %filtSingal in timepoints x channels x trials
        HInd(f,:,:,:)=hilbert(filtSingalInd(f,:,:,:));
    end
    disp(['Saving experiment ', num2str(experiment), ' out of ', num2str(length(allData))])
    save(allData(experiment).name, 'HInd', 'filtSingalInd', '-append')
end

