%% breaking up the Neuropatt outputs by parameter

if isunix
    dirIn = '/synology/adeeti/spatialParamWaves/Awake/';
    dirPic = '/synology/adeeti/spatialParamWaves/images/NeuroPatt/Awake/noSVDfirst/';
elseif ispc
    dirIn = 'Z:/adeeti/spatialParamWaves/Awake/';
    dirPic = 'Z:\adeeti\spatialParamWaves\images\NeuroPatt\Awake\noSVDfirst\';
end

mkdir(dirPic)
screensize = get(groot, 'Screensize');

allMice = [6, 9, 13];
anesString = {'High Isoflurane', 'Low Isoflurane', 'Awake', 'Ketamine'};
shortAnesString = {'HIso', 'LIso', 'Awa', 'Ket'};
testAlphas = [0.1, 0.5, 1];
testBetas = [1, 5, 10, 15];

useModes = 0;
numModes = 1;


%% breaking up parameters
for mouseID = 1:3
    for experiment = 1:4
        if useModes
            for m = 1:numModes
                useExpMode = squeeze(spModes(mouseID,experiment,m,:,:));
                for a = 1:length(testAlphas)
                    for b = 1:length(testBetas)
                        numPatterns(mouseID,experiment,m,a,b) = size(useExpMode(a,b).patterns{1},1);
                        typePatt{mouseID,experiment,m,a,b} = [useExpMode(a,b).patterns{1}(:,1)];
                        pattDur{mouseID,experiment,m,a,b} = [useExpMode(a,b).patterns{1}(:,4)];
                        pattDisp{mouseID,experiment,m,a,b} = [useExpMode(a,b).patterns{1}(:,9)];
                    end
                end
            end
            
        else
            useExpMode = squeeze(spModes(mouseID,experiment,:,:));
            for a = 1:length(testAlphas)
                for b = 1:length(testBetas)
                    numPatterns(mouseID,experiment,a,b) = size(useExpMode(a,b).patterns{1},1);
                    typePatt{mouseID,experiment,a,b} = [useExpMode(a,b).patterns{1}(:,1)];
                    pattDur{mouseID,experiment,a,b} = [useExpMode(a,b).patterns{1}(:,4)];
                    pattDisp{mouseID,experiment,a,b} = [useExpMode(a,b).patterns{1}(:,9)];
                end
            end
        end

    end
end



%% Make figures: pattern types
%ff = figure('Position', screensize, 'Color', 'w'); clf;

useData =  typePatt;
useXlabels = 1;
x_Ticks = [1:7];
X_TickLab = {'plane', 'sync', 'sink', 'srce', 'sp.in', 'sp.out', 'sad'};
edges = [1:8];
supTit = 'Patterns Types Detected No SVD first';
saveTit = 'pattTypes_AlphaBeta_avg';

compPatternsAlpBetPic(useData, edges, useXlabels, x_Ticks, X_TickLab, supTit, saveTit, dirPic, useModes, numModes)


%% Make figures: pattern number
%ff = figure('Position', screensize, 'Color', 'w'); clf;

useData =  numPatterns;
useXlabels = 0;
x_Ticks = [];%[1:7];
X_TickLab = [];%{'plane', 'sync', 'sink', 'srce', 'sp.in', 'sp.out', 'sad'};
edges = [1:10];
supTit = 'Number of Patterns Detected No SVD first';
saveTit = 'numPattDet_AlphaBeta_avg';

compPatternsAlpBetPic(useData, edges, useXlabels, x_Ticks, X_TickLab, supTit, saveTit, dirPic, useModes, numModes)

%% Make figures: pattern duration
%ff = figure('Position', screensize, 'Color', 'w'); clf;

useData =  pattDur;
useXlabels = 0;
x_Ticks = [];%[1:7];
X_TickLab = [];%{'plane', 'sync', 'sink', 'srce', 'sp.in', 'sp.out', 'sad'};
edges = [30:30:360];
supTit = 'Pattern Durations No SVD first';
saveTit = 'pattDur_AlphaBeta_avg';

compPatternsAlpBetPic(useData, edges, useXlabels, x_Ticks, X_TickLab, supTit, saveTit, dirPic, useModes, numModes)

%% Make figures: pattern displacement
%ff = figure('Position', screensize, 'Color', 'w'); clf;

useData =  pattDisp;
useXlabels = 0;
x_Ticks = [];%[1:7];
X_TickLab = [];%{'plane', 'sync', 'sink', 'srce', 'sp.in', 'sp.out', 'sad'};
bins = 10;
supTit = 'Pattern Displacement No SVD first';
saveTit = 'pattDisp_AlphaBeta_avg';

compPatternsAlpBetPic(useData, bins, useXlabels, x_Ticks, X_TickLab, supTit, saveTit, dirPic, useModes, numModes)


%%
function compPatternsAlpBetPic(useData, edges, useXlabels, x_Ticks, X_TickLab, supTit, saveTit, dirPic, useModes, numModes)

if nargin<9
    useModes = 1;
    numModes = 3;
    legendString = {'m = 1', 'm = 2', 'm = 3'};
end



allMice = [6, 9, 13];
anesString = {'High Isoflurane', 'Low Isoflurane', 'Awake', 'Ketamine'};
shortAnesString = {'HIso', 'LIso', 'Awa', 'Ket'};
testAlphas = [0.1, 0.5, 1];
testBetas = [1, 5, 10, 15];


for mouseID = 1:length(allMice)
    for experiment = 1:length(shortAnesString)
        ff = figure('Position', [1, 79,1912,737] , 'Color', 'w'); clf;
        for m = 1:numModes
            for a = 1:length(testAlphas)
                for b = 1:length(testBetas)
                    subplot(length(testAlphas), length(testBetas), length(testBetas)*(a-1) + b)
                    if useModes
                        plotData = squeeze(useData(mouseID,experiment,m,a,b));
                    else plotData = squeeze(useData(mouseID,experiment,a,b));
                    end
                    if iscell(plotData)
                        histData = cell2mat(plotData);
                        histogram(histData, edges);
                    else
                        histogram(plotData, edges);
                    end
                    
                    hold on;
                    title(['alpha = ', num2str(testAlphas(a)), ' beta = ', num2str(testBetas(b))])
                    
                    if numModes>1
                        legend(legendString)
                    end
                    
                    if useXlabels ==1
                        xticks(x_Ticks)
                        xticklabels(X_TickLab)
                        set(gca, 'FontSize',8)
                    end
                end
            end
        end
        sgtitle(['GL', num2str(allMice(mouseID)), ' : ' anesString{experiment}, ', ', supTit])
        saveas(ff, [dirPic, 'GL', num2str(allMice(mouseID)), shortAnesString{experiment} '_', saveTit, '.png'])
        close all
    end
end


end


