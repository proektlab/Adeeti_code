%% Single trial inter electrode coherence with wcoherence.m

%% entering in data

clear
clc

onLinux = 1;
onWindows = 0;

if onLinux ==1
    genDir = '/synology/adeeti/ecog/iso_awake_VEPs/';
elseif onWindows ==0
    genDir =  'Z:\adeeti\ecog\iso_awake_VEPs\'  ;
end

cd(genDir)

allDir = [dir('IP*'); dir('GL*')];

ident1 = '2019*';
ident2 = '2020*';
stimIndex = [0, Inf];
START_AT = 1;
driveLocation = '/home/adeeti/Dropbox/';

timeFrame = 500:2000; % this is 400 ms, so  less than 10Hz will not be well approx here
highFreqCut = 100;
lowFreqCut = 3;


%%

for d = 1:length(allDir)
    cd([genDir, allDir(d).name])
    mouseID = allDir(d).name;
    %mouseECoGFolder = genDir;
    %genPicsDir =  [genDir(1:end-16), '/images/Iso_Awake_VEPs/', mouseID, '/'];
    dirIn = [genDir, mouseID, '/'];
    dirWAVE = [dirIn, 'Wavelets/'];
    dirWCoh = [dirIn, 'wCoh/'];
    
    mkdir(dirWCoh);
    
    disp(['Analyzing mouse ', mouseID])
    allData = dir(ident1);
    identifier = ident1;
    
    if isempty(allData)
        allData = dir(ident2);
        identifier = ident2;
    end
    
    for a = 1:length(allData)
        disp(['Coherence on ', mouseID, ' experiment: ', num2str(a)])
        cd(dirWAVE)
        load([allData(a).name(1:end-4), 'wave.mat'], 'SCALE', 'DJ')
        
        cd(dirIn)
        load(allData(a).name, 'info', 'finalSampR', 'meanSubData','uniqueSeries', 'indexSeries')
        
        %% get freqs
        goodChan = [1:info.channels];
        goodChan(info.noiseChannels) = [];
        sig1 = squeeze(meanSubData(goodChan(1), 1, timeFrame));
        sig2 = squeeze(meanSubData(goodChan(1), 1, timeFrame));
        [~,~,actFreq]= wcoherence_InputScale(sig1, sig2, SCALE, timeFrame, lowFreqCut, highFreqCut, 1/DJ, finalSampR);
        
        %% coherence measure
        tic;
        CohMag = nan(size(meanSubData,1), size(meanSubData,2),length(actFreq), length(timeFrame));
        %CohAngle = nan(size(meanSubData,1), size(meanSubData,2),length(actFreq), length(timeFrame));
        for ch1 = 1:length(goodChan) %size(meanSubData, 1)
            disp(['Calculating coherence for channel ', num2str(ch1)])
            for ch2 = 1:length(goodChan) %size(meanSubData, 1)
                for tr = 1:size(meanSubData, 2)
                    sig1 = squeeze(meanSubData(goodChan(ch1), tr, timeFrame));
                    sig2 = squeeze(meanSubData(goodChan(ch2), tr, timeFrame));
                    if ~isnan(sig1(1)) && ~isnan(sig2(1))
                        %[wcoh,wcs,actFreq]= wcoherence_InputScale(sig1, sig2, SCALE, timeFrame, lowFreqCut, highFreqCut, 1/DJ, finalSampR);
                        [wcoh,~,actFreq]= wcoherence_InputScale(sig1, sig2, SCALE, timeFrame, lowFreqCut, highFreqCut, 1/DJ, finalSampR);
                        CohMag(goodChan(ch2),tr,:,:) = wcoh;
                        %CohAngle(ch2,tr,:,:) = wcs;
                    end
                end
            end
            eval([['cohMag_', num2str(goodChan(ch1))] '= CohMag;'])
            tempMag = ['cohMag_', num2str(goodChan(ch1))];
            %eval([['cohAngle_', num2str(ch1)] '= CohAngle;'])
            %tempAng = ['cohAngle_', num2str(ch1)];
            
            if ch1 ==1 || ~exist([dirWCoh, allData(a).name(1:end-4), 'wave.mat']) ==1
                %save([dirWCoh, allData(a).name], tempMag, tempAng, 'actFreq', 'info','uniqueSeries', 'indexSeries')
                save([dirWCoh, allData(a).name(1:end-4), 'wave.mat'], tempMag, 'actFreq', 'info','uniqueSeries', 'indexSeries')
                clearvars tempAng* tempMag* cohMag* cohAngle*
            else
                %save([dirWCoh, allData(a).name(1:end-4), 'wave.mat'], tempMag, tempAng, '-append')
                save([dirWCoh, allData(a).name(1:end-4), 'wave.mat'], tempMag, '-append')
                clearvars tempAng* tempMag* cohMag* cohAngle*
            end
        end
        toc
    end
end
