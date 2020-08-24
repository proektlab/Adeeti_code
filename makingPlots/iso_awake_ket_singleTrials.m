%% making single trial pictures for each experiment 

onLinux = 0;
onMacDesk = 1;

if onLinux ==1
    raidLoc = '/synology/';
end

if onMacDesk ==1
    raidLoc = '/Volumes/LabData/';
end


genDir =  [raidLoc, 'adeeti/ecog/iso_awake_VEPs/'];

cd(genDir)

allDir = [dir('IP*'); dir('GL*')];

ident1 = '2019*';
ident2 = '2020*';
stimIndex = [0, Inf];

time2Plot = [850:1500];
timeAxis = linspace(-1+time2Plot(1)*.001, -1+time2Plot(end)*.001, numel(time2Plot));

numTrials = 8;
screensize=get(groot, 'Screensize');
%%
for d = 1:length(allDir)
    cd([genDir, allDir(d).name])
    mouseID = allDir(d).name;
    genPicsDir =  [raidLoc, 'adeeti/ecog/images/Iso_Awake_VEPs/', mouseID, '/'];
    dirIn = [raidLoc, 'adeeti/ecog/iso_awake_VEPs/', mouseID, '/'];
    disp(mouseID)
    
    allData = dir(ident1);
    identifier = ident1;
    
    if isempty(allData)
        allData = dir(ident2);
        identifier = ident2;
    end
    
    close all
    dirPic = [genPicsDir, 'singleTrials/'];
    mkdir(dirPic)
    
    plotTrials = nan(length(allData), numTrials, length(time2Plot));

    for a = 1:length(allData)
        load(allData(a).name, 'meanSubData', 'info', 'finalTime', 'finalSampR')
        trialInd = randsample(size(meanSubData,2), numTrials);
        plotTrials(a,:,:) = meanSubData(info.lowLat, trialInd, time2Plot);
        allInfo{a} = info.AnesType;
    end
    
    plotCounter = 0;
    expPerPlot = 6;
    
    while plotCounter*expPerPlot < length(allData) 
        ff = figure('Position', screensize, 'color', 'w'); clf;
        ff.Renderer='Painters';
        clf
        
       % if length(allData) -plotCounter*expPerPlot >= expPerPlot
            plotNumEXP = expPerPlot;
%         else
%             plotNumEXP = length(allData) -plotCounter*expPerPlot;
%         end

        for b = 1:plotNumEXP
            experimentInd = plotCounter*expPerPlot+b;
            if experimentInd> length(allData)
                continue
            end
            for trial = 1:numTrials
                h(b+(trial-1)*plotNumEXP) =subplot(numTrials, plotNumEXP, b+(trial-1)*plotNumEXP);
                plot(timeAxis, squeeze(plotTrials(experimentInd,trial,:)))
                set(gca, 'ylim', [min(plotTrials(:)), max(plotTrials(:))]);
                hold on
                if trial ==1
                    title([allInfo{experimentInd}])
                end
            end
        end
        sgtitle(info.date)
        saveas(ff, [dirPic, 'singTr', num2str(plotCounter+1) '.png'])
        close all
        plotCounter = plotCounter +1;
    end
end
