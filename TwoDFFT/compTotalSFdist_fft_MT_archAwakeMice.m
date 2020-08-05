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
dirOut = [dirIn, 'FFTs/'];

mkdir(dirPic)
mkdir(dirOut)
norm2TotPower = 0;
numSets = 25;
tapers = 7;
inDims = [5000,2750];

interpBy = 50;
gridSpacing = 500;
samplingFreq = 1;

plotTime =50:200;

cd(dirIn)
load('dataMatrixFlashes.mat')
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
    
    for expInd = startAT:length(MFE)
        if isnan(MFE(expInd))
            continue
        end
        disp(allData(MFE(expInd)).name)
        compMTSpec = [];
        allSpecShift = [];
        
        for n =1:numSets
            clearvars -except dirIndirPic dirOut norm2TotPower numSets tapers inDims ...
                interpBy gridSpacing samplingFreq plotTime dataMatrixFlashes ...
                allData mouseID allMice MFE titleString expInd ...
                startAT compMTSpec allSpecShift n FFT2PowerAtFreq MTPowerAtFreq
            
            tempBoot = ['interp50Boot', num2str(floor(n))];
            %         load(allData(MFE(expInd)).name, 'interp100FiltDataTimes', 'info')
            load(allData(MFE(expInd)).name, tempBoot, 'info')
            disp(tempBoot)
            eval(['useBoot = ', tempBoot, ';'])
            movieToFit = useBoot;
            
            disp('Calc FFT')
            for TP2comp =1:length(plotTime)
                testImage = squeeze(movieToFit(plotTime(TP2comp),:,:));
                
                %% fft22D
                [spectrum2D, NFFTX, NFFTY] = twoDFFT4gridMovies(testImage);
                shiftSpec2D = abs(fftshift(spectrum2D));
                %if TP2comp ==1
                % Find X and         Y frequency spaces, assuming sampling rate of 1
                samplingFreq = gridSpacing/interpBy; %5;
                
                plotUB = 1/gridSpacing*2; %samplingFreq/interpBy*2;
                plotLB = -plotUB;
                
                fullFFTXscale = 1/samplingFreq*2*linspace(-1,1,NFFTX);
                fullFFTYscale = 1/samplingFreq*2*linspace(-1,1,NFFTY);
                
                validIndX = find(fullFFTXscale<=plotUB & fullFFTXscale >=plotLB);
                validIndY = find(fullFFTYscale<=plotUB & fullFFTYscale >=plotLB);
                
                fftXscale = fullFFTXscale(validIndX);
                fftYscale = fullFFTYscale(validIndY);
                %end
                allSpecShift(n,TP2comp,:,:) = shiftSpec2D(validIndY,validIndX);
                
                % calcuating single vector of power
                [condFreqVect_2DFFTEXP, powerVect_2DFFTEXP, ~]= ...
                    spectrumSub2FreqDistance(squeeze(allSpecShift(n,TP2comp,:,:)), fftXscale, ...
                    fftYscale, norm2TotPower);
                
                FFT2DcondFreqVect = condFreqVect_2DFFTEXP;
                FFT2PowerAtFreq(n,TP2comp,:) = powerVect_2DFFTEXP;
            end
            
            %% MT
%             disp('Calc MT')
%             for TP2comp = 1:length(plotTime)
%                 testImage = squeeze(movieToFit(plotTime(TP2comp),:,:));
%                 testImage;
%                 av = nansum(testImage(:)) / length(testImage(:));
%                 dcRem_testImage = testImage - av;
%                 
%                 [Out] = mtImageFFT_AA(dcRem_testImage,tapers, inDims, [], []);
%                 
%                 % if TP2comp ==1
%                 xFreqMT = Out.freq1(find(Out.freq1<0.004));
%                 yFreqMT = Out.freq2(find(Out.freq2<0.004));
%                 % end
%                 allMTSpec = abs(Out.spectrum((find(Out.freq2<0.004)),(find(Out.freq1<0.004))))';
%                 compMTSpec(n,TP2comp,:,:) =allMTSpec;
%                 
%                 
%                 % calcuating single vector of power
%                 [condFreqVect_MTEXP, powerAtCondFreq_MTEXP, freqGrid]= ...
%                     spectrumSub2FreqDistance(squeeze(compMTSpec(n,TP2comp,:,:)),xFreqMT, yFreqMT, norm2TotPower);
%                 
%                 MTcondFreqVect = condFreqVect_MTEXP;
%                 MTPowerAtFreq(n,TP2comp,:) = powerAtCondFreq_MTEXP;
%             end
        end
        
        save([dirOut, allData(MFE(expInd)).name], 'allSpecShift', 'fftXscale', ...
            'fftYscale','FFT2DcondFreqVect', 'FFT2PowerAtFreq')
        
%        save(allData(MFE(expInd)).name, 'allSpecShift', 'fftXscale', ...
%             'fftYscale','FFT2DcondFreqVect', ...
%             'FFT2PowerAtFreq', 'yFreqMT', 'xFreqMT', 'compMTSpec', 'MTcondFreqVect', ...
%             'MTPowerAtFreq', '-append')
    end
end