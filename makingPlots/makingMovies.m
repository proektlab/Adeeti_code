%% Makes movies of EEG stuffs

clear

dirIn = '/data/adeeti/ecog/matIsoPropMultiStim/';
dirOut1 = '/data/adeeti/ecog/images/IsoPropMultiStim/bigFontMovies/';
%dirOut2 = '/data/adeeti/ecog/images/2018Stim/averageMovies/';

cd(dirIn)

load('dataMatrixFlashes.mat')
load('matStimIndex.mat')

makeSingleTrailsMoivies = 0;
makeAverageMovies = 1;

identifier = '2018*.mat';

stimIndex = [0, Inf]; %if want all, stimIndex = matStimIndex; % if want
%all uniStimIndexes/multiStimIndexes, use [uniStimIndex, multiStimIndex] =
%findUniMutliStimIndex(matStimIndex), [stimIndex, ~] = findUniMutliStimIndex(matStimIndex)

% Setting up new data set for just visual only stim

expNum = 1;
drugType = 'iso';
conc = 0.6;

[myFavoriteExp] = findMyExpMulti(dataMatrixFlashes, expNum, drugType, conc, stimIndex, []);

trial = 15;
start = 900; %time before in ms
cutTime = 1850; %time after in ms


%% making movies

if length(myFavoriteExp) >3
    myFavoriteExp(1) = [];
end

for e = 1:length(myFavoriteExp)
    load(dataMatrixFlashes(myFavoriteExp(e)).expName, 'info', 'indexSeries', 'uniqueSeries', 'meanSubData')
    [indices] = getStimIndices(stimIndex, indexSeries, uniqueSeries);
    useMeanSubData = meanSubData(:, indices,:);
    if makeSingleTrailsMoivies ==1
        data = useMeanSubData;
    end
    if makeAverageMovies ==1
        data = squeeze(nanmean(useMeanSubData,2));
    end
    
    counter = 1;
    clear movieOutput
    figure
    clf
    f = gcf;
    f.Position = [789 -32 845 1003];
    f.Color = 'white';
    
    g = gca;
    xGridAxis = fliplr(linspace(0, 2.75, 5+1));
    yGridAxis = linspace(0, 5, 10+1);
    lowerCax = min(data(:));
    upperCax = max(data(:));
    
    for t = start:length(data)-cutTime 
        if makeSingleTrailsMoivies ==1
            plotOnGridInterp(data(:,trial, t), 1, info.gridIndicies)
        end
        if makeAverageMovies ==1
            plotOnGridInterp(data(:, t), 1, info.gridIndicies)
        end
        
        caxis([lowerCax,upperCax]);
        g.XTickMode = 'Manual';
        g.YTickMode = 'Manual';
        g.YTick = linspace(1,1100, 10+1);
        g.XTick = linspace(1,600, 5+1);
        g.XTickLabel = xGridAxis;
        g.YTickLabel = yGridAxis;
        colorbar;
        c = colorbar;
        c.Label.String = 'Voltage in uV';
        c.Label.FontSize = 22;
        title(['Iso Concentration: ', num2str(info.AnesLevel), '%, Time: ', num2str(t-1000), ' msec'], 'FontSize', 30);
        ylabel('Ant-Post Distance in mm', 'FontSize', 22);
        xlabel('Med-Lat Distance in mm', 'FontSize', 22);
        set(gca, 'FontSize', 22);
        drawnow
        movieOutput(counter) = getframe(gcf);
        counter = counter +1;
        disp([dataMatrixFlashes(myFavoriteExp(e)).expName, ' ', num2str(t)])
    end
    
    if makeSingleTrailsMoivies ==1
        v = VideoWriter([dirOut1, dataMatrixFlashes(myFavoriteExp(e)).date, 'iso', num2str(info.AnesLevel), 'SingleTrial.avi']);
    end
    if makeAverageMovies ==1
        v = VideoWriter([dirOut1, dataMatrixFlashes(myFavoriteExp(e)).date, 'iso', num2str(info.AnesLevel), 'averageEP.avi']);
    end
    
    open(v)
    writeVideo(v,movieOutput)
    close(v)
end
