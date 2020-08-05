clear
clc
close all

%%
if isunix
    dirIn = '/synology/adeeti/spatialParamWaves/Awake/';
    dirPic = '/synology/adeeti/spatialParamWaves/images/2DFFTMovies/Awake/';
elseif ispc
    dirIn = 'Z:/adeeti/spatialParamWaves/Awake/';
    dirPic = 'Z:\adeeti\spatialParamWaves\images\2DFFTMovies\Awake\';
end
dirFFT = [dirIn, 'FFTs/'];

mkdir(dirPic)
norm2TotPower = 1;
numSets = 25;
tapers = 7;
inDims = [5000,2750];

interpBy = 50;
gridSpacing = 500;
samplingFreq = 1;

plotTime =50:200;

cd(dirIn)
load('dataMatrixFlashes.mat')

cd(dirFFT)
allData = dir('gab*');
%
allMice = unique([dataMatrixFlashes.exp]);

%%
for mouseID = 1:length(allMice)
    [isoHighExp, isoLowExp, emergExp, awaExp1, awaLastExp, ketExp] = ...
        findAnesArchatypeExp(dataMatrixFlashes, allMice(mouseID));
    
    MFE = [isoHighExp, isoLowExp, awaLastExp, ketExp];
    titleString = {'High Isoflurane', 'Low Isoflurane', 'Awake', 'Ketamine'};
    
    if mouseID ==1
        startAT =1;
    else
        startAT =1;
    end
    FFT2PowerAtFreq_normTP = [];
    
    for expInd = startAT:length(MFE)
        if isnan(MFE(expInd))
            continue
        end
        disp(allData(MFE(expInd)).name)

        load(allData(MFE(expInd)).name,  'allSpecShift', 'fftXscale', ...
            'fftYscale')
        for n = 1:numSets
            for TP2comp =1:length(plotTime)
                
                % calcuating single vector of power
                [condFreqVect_2DFFTEXP, powerVect_2DFFTEXP, ~]= ...
                    spectrumSub2FreqDistance(squeeze(allSpecShift(n,TP2comp,:,:)), fftXscale, ...
                    fftYscale, norm2TotPower);
                
                FFT2DcondFreqVect = condFreqVect_2DFFTEXP;
                FFT2PowerAtFreq_normTP(n,TP2comp,:) = powerVect_2DFFTEXP;
            end
        end
        save([dirFFT, allData(MFE(expInd)).name], 'FFT2PowerAtFreq_normTP', '-append')
    end
end