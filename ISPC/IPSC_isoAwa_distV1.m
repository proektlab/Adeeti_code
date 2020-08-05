%% Plotting Corralation drop off from V1

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
screensize=get(groot, 'Screensize');
stimIndex = [0, Inf];


gammaFreq = [21, 25, 30, 35, 42, 50];
addChan = 8;

baselineTime = [750:900]; % 150 ms before stim 
evokedTime = [1020:1170]; % 150 ms of stim activity


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
    dirCohDropDisPics = [genPicsDir, 'coh_by_dist/'];
    
    mkdir(dirCohDropDisPics);

    allData = dir(ident1);
    identifier = ident1;
    
    if isempty(allData)
        allData = dir(ident2);
        identifier = ident2;
    end
    
    for a = 1:length(allData)
        load([dirIPSC, allData(a).name(1:end-4), 'wave.mat'], 'ISPC21','ISPC25', 'ISPC30', 'ISPC35', 'ISPC42', 'ISPC50', 'Freq', 'info')
        
        % finding V1 and channels around V1
        V1 = info.lowLat;
        [adjRight, adjLeft, adjTop, adjBottom] = findChanFromV1(V1, addChan, info);
        
        cohMag = [];
        avgCohMag = [];
        allBeforeCoh = [];
        allEvokedCoh = [];
        adjBeforeStimCoh = [];
        adjEvokedCoh = [];
        
        counter = 0;
        
        %% calculating magnitude of coherence in gamma band
        for fr = fliplr([21, 25, 30, 35, 42, 50])
            counter = counter +1;
            sig = eval(['ISPC', num2str(fr)]);
            cohMag(counter,:,:,:) = squeeze(abs(sig));
        end
        avgCohMag = squeeze(nanmean(cohMag,1));
        allBeforeCoh = nanmean(avgCohMag(:,:,baselineTime),3);
        allEvokedCoh = nanmean(avgCohMag(:,:,evokedTime),3);
        
        %% breaking up coherence magnitude into directions
        indexDirection = [adjRight; adjLeft; adjTop; adjBottom];
        
        for ID = 1:size(indexDirection, 1)
            for direction = 1:size(indexDirection, 2)
                if isnan(indexDirection(ID, direction))
                    continue
                end
                if ismember(indexDirection(ID, direction), info.noiseChannels)
                    continue
                end
                adjBeforeStimCoh(ID, direction) = allBeforeCoh(V1, indexDirection(ID, direction));
                adjEvokedCoh(ID, direction) = allEvokedCoh(V1, indexDirection(ID, direction));
            end
            adjEvokedCoh(adjEvokedCoh==0) = nan;
            adjBeforeStimCoh(adjBeforeStimCoh==0) = nan;
        end
        
        %% making figure
        currentFig = figure('Position', screensize, 'Color', 'w'); clf;
        for i = 1:4
            subplot(2,2,i)
            plot(squeeze(adjBeforeStimCoh(i,:)), 'o--')
            hold on
            plot(squeeze(adjEvokedCoh(i,:)), 'o--')
            legend('Baseline', 'Evoked')
            ylabel('Coherence Magnitude')
            xlabel('Electrodes away')
            if i ==1
                title('Medial to V1')
            elseif i ==2
                title('Lateral to V1')
            elseif i ==3
                title('Anterior of V1')
            elseif i ==4
                title('Posterior of V1')
            end
            sgtitle(['Coherence of ', mouseID, ': ', info.AnesType, ' ', num2str(info.AnesLevel)])
        end
        saveas(currentFig, [dirCohDropDisPics, info.AnesType(1:3), allData(a).name(end-22:end-7), '.png'])
        close all
        
    end
end