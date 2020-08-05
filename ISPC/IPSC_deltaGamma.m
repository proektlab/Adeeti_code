%% Coherence between channels

%% Inter-site phase clustering (ISPC)

% extract phase angle from wavelet transform
% phase - just about timing, invarient of the phase

onLinux = 1;
onWindows = 0;

if onLinux ==1
    genDir = '/synology/adeeti/ecog/iso_awake_VEPs/';
elseif onWindows ==1
    genDir =  'Z:\adeeti\ecog\iso_awake_VEPs\'  ;
end

cd(genDir)

allDir = [dir('IP*'); dir('GL*')];

ident1 = '2019*';
ident2 = '2020*';
stimIndex = [0, Inf];
screensize=get(groot, 'Screensize');

deltaLow = 3.25;
deltaHigh = 6;

gammaLow = 20;
gammaHigh = 60;

%%

for d = 1:length(allDir)
    cd([genDir, allDir(d).name])
    mouseID = allDir(d).name;

    mouseECoGFolder = genDir;
    genPicsDir =  [genDir(1:end-16), '/images/Iso_Awake_VEPs/', mouseID, '/'];
    dirIn = [mouseECoGFolder, mouseID, '/'];
    
    disp(['Analyzing mouse ', mouseID]) 

    dirIPSC = [dirIn, 'IPSC/'];
    dirWAVE = [dirIn, 'Wavelets/'];

    mkdir(dirIPSC);
    
    allData = dir(ident1);
    identifier = ident1;
    
    if isempty(allData)
        allData = dir(ident2);s
        identifier = ident2;
    end

    for experiment = 1:length(allData)
        if experiment == 1
            disp(['IPSC for ', mouseID])
            cd(dirWAVE)
            load([allData(experiment).name(1:end-4), 'wave.mat'], 'Freq')
            deltaBand = find(Freq>deltaLow & Freq<deltaHigh);
            gammaBand = find(Freq>gammaLow & Freq<gammaHigh);
            band = [gammaBand, deltaBand];
            clear loadFreq
            for fr= 1:length(band)
                temp = ['WAVE', num2str(band(fr))];
                loadFreq{fr} = temp;
            end
        end
        
        disp(['Saving ISPC for ', num2str(experiment), ' out of ', num2str(length(allData))])
        
        for fr = 1:length(loadFreq)
            trueFreq = floor(Freq(band(fr)));
            disp(['Frequency ', num2str(trueFreq)])
            load([allData(experiment).name(1:end-4), 'wave.mat'], loadFreq{fr}, 'info')
            waveDecop = eval(loadFreq{fr});
            phaseData = angle(waveDecop);
            
            ISPC = nan(info.channels, info.channels, size(waveDecop,1));
            
            %     phase angles from the wavlet transform
            for ch2= 1:size(waveDecop, 2)
                for ch1 = 1:size(waveDecop, 2)
                    angleDiff = phaseData(:, ch1 ,:)-phaseData(:, ch2, :);
                    ISPC(ch1, ch2, :) = squeeze(mean(exp(1i*(angleDiff)),3));
                end
            end
            eval([['ISPC', num2str(trueFreq)] '= ISPC;'])
            temp = ['ISPC', num2str(trueFreq)];
            if exist([dirIPSC, allData(experiment).name(1:end-4), 'wave.mat'])
                save([dirIPSC, allData(experiment).name(1:end-4), 'wave.mat'], temp, '-append')
            else
                save([dirIPSC, allData(experiment).name(1:end-4), 'wave.mat'], temp)
            end
            clearvars temp ISPC angleDiff
        end
        save([dirIPSC, allData(experiment).name(1:end-4), 'wave.mat'], 'info', 'Freq', '-append')
        clearvars info
    end
end