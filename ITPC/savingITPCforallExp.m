%% saving ITPC for all experiments

clear
dirIn = '/data/adeeti/ecog/matFlashesJanMar2017/Wavelets/';
dirOut = '/data/adeeti/ecog/matFlashesJanMar2017/Wavelets/ITPC/';
identifier = '2017*.mat';
%%
cd(dirIn)
mkdir(dirOut);

allData = dir(identifier);
%%
load(allData(1).name, 'WAVE1', 'Freq')
numChan = 64;
numFreq = 40;
numTimepoints = 2001;

wavelets = {};
for i= 1:length(Freq)
    temp = ['WAVE', num2str(i)];
    wavelets{i} = temp;
end

trueITPC = nan(numChan, numFreq, numTimepoints); %WAVE is in freq by time by channels by trials

for experiment = 1:length(allData)
    for i= 1:length(Freq)
    load(allData(experiment).name, wavelets{i})
    WAVE = eval(wavelets{i});
    WAVE = permute(WAVE, [4 1 2 3]);
    temp = ITPC_AA(WAVE);
    trueITPC(:,i,:) = temp;
    clearvars WAVE*
    end
    disp(['Saving ITPC for ', num2str(experiment), ' out of ', num2str(length(allData))])
    save([dirOut, allData(experiment).name], 'trueITPC')
end

