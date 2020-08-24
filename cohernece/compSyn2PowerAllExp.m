%% Comparing Synchrony to total power in all experiments

outDir = '/data/adeeti/ecog/images/2018Stim/freqBandPowerGammaCoherenceComp/';

infopath = '/data/adeeti/ecog/matFlashesJanMar2017/';
filtpath = '/data/adeeti/ecog/matFlashesJanMar2017/Wavelets/FiltData/';
identifier = '2018*.mat';
ch = []; %[] for V1

freqVect = [3 7 10 25 35];
bandVect = {'delta', 'theta', 'alpha', 'beta', 'gamma'};

cd(infopath)
allData = dir(identifier);

for f = 5:length(freqVect)
    fr = freqVect(f);
    band = bandVect{f};
    mkdir([outDir, band, '/']);
    
    for indexExp = 1:length(allData)
        experiment = allData(indexExp).name;
        nameExp = experiment(1:end-4);
        disp([nameExp, ' ', bandVect(f)]);
        nameExp = '2017-02-23_17-01-15';
        [currentFig] =compCoherenceToTotalPower(nameExp, fr, infopath, filtpath, [600:1600], ch)
        
        saveas(currentFig, [outDir, band, '/' nameExp, '.png'])
        %print(currentFig, ['/data/adeeti/ecog/images/', nameExp,
        %'.eps'],'-deps')
    end
end
