%% breaking up the Neuropatt outputs by parameter

if isunix
    dirIn = '/synology/adeeti/spatialParamWaves/Awake/';
    dirPic = '/synology/adeeti/spatialParamWaves/images/NeuroPatt/Awake/';
elseif ispc
    dirIn = 'Z:/adeeti/spatialParamWaves/Awake/';
    dirPic = 'Z:\adeeti\spatialParamWaves\images\NeuroPatt\Awake\';
end

mkdir(dirPic)
screensize = get(groot, 'Screensize');

allMice = [6, 9, 13];
anesString = {'High Isoflurane', 'Low Isoflurane', 'Awake', 'Ketamine'};
shortAnesString = {'HIso', 'LIso', 'Awa', 'Ket'};
useAlphaBetaInd = 0;

testAlphas = [0.1, 0.5, 1];
testBetas = [1, 5, 10, 15];
aInd = 2;
bInd = 3;

numIndModes = 1;

%% breaking up parameters
for mouseID = 1:3
    for experiment = 1:4
        for m = 1:numIndModes
            if numIndModes>1
                if useAlphaBetaInd ==1
                    useExpMode = squeeze(spModes(mouseID,experiment,m,aInd,bInd));
                else
                    useExpMode = squeeze(spModes(mouseID,experiment,m));
                end
                
            else
                if useAlphaBetaInd ==1
                    useExpMode = squeeze(spModes(mouseID,experiment,aInd,bInd));
                else
                    useExpMode = squeeze(spModes(mouseID,experiment));
                end
            end
            
            tempNumPatt = [];
            tempPattType = [];
            tempPattDur =[];
            tempPattDisp = [];
            
            for tr = 1:length(useExpMode.patterns)
                tempNumPatt = [tempNumPatt, size(useExpMode.patterns{tr},1)];
                tempPattType = [tempPattType; [useExpMode.patterns{tr}(:,1)]];
                tempPattDur = [tempPattDur; [useExpMode.patterns{tr}(:,4)]];
                tempPattDisp = [tempPattDisp; [useExpMode.patterns{tr}(:,9)]];
            end
            
            numPatterns{mouseID,experiment,m} = tempNumPatt;
            typePatt{mouseID,experiment,m} = tempPattType;
            pattDur{mouseID,experiment,m} = tempPattDur;
            pattDisp{mouseID,experiment,m} = tempPattDisp;
            
        end
    end
end

numPatterns= squeeze(numPatterns);
typePatt= squeeze(typePatt);
pattDur= squeeze(pattDur);
pattDisp= squeeze(pattDisp);

%%

for mouseID = 1:length(allMice)
    ff = figure('Position', [1, 79,1912,737] , 'Color', 'w'); clf;
    for experiment = 1:length(shortAnesString)
        for m = 1:numIndModes
            
            % pattern type
            subplot(4, length(anesString), 1*experiment)
            edges = [1:8];
            if numIndModes>1
                histData = cell2mat(typePatt(mouseID,experiment,m));
                histogram(histData, edges);
            else
                histData = cell2mat(typePatt(mouseID,experiment));
                histogram(histData, edges);
            end
            hold on;
            title([anesString{experiment}, ', pattern type'])
            %legend({'m = 1', 'm = 2', 'm = 3'})
            xticks([1:7])
            xticklabels({'plane', 'sync', 'sink', 'srce', 'sp.in', 'sp.out', 'sad'})
            set(gca, 'FontSize',8)
            
            
            % pattern number
            subplot(4, length(anesString), experiment+4)
            edges = [1:max([numPatterns{mouseID,experiment,m}])];
            if numIndModes>1
                 histData = cell2mat(numPatterns(mouseID,experiment,m));
                histogram(histData, edges);
 
            else
                histData = cell2mat(numPatterns(mouseID,experiment));
                histogram(histData, edges);
            end
            hold on;
            title([anesString{experiment}, ', pattern number'])
            %legend({'m = 1', 'm = 2', 'm = 3'})
            
            % pattern duration
            subplot(4, length(anesString), experiment+8)
            edges = [30:30:360];
            if numIndModes>1
                histData = cell2mat(pattDur(mouseID,experiment,m));
                histogram(histData, edges);
            else
                histData = cell2mat(pattDur(mouseID,experiment));
                histogram(histData, edges);
            end
            hold on;
            title([anesString{experiment}, ', pattern duration'])
            %legend({'m = 1', 'm = 2', 'm = 3'})
            
            %pattern displacement
            subplot(4, length(anesString), experiment+12)
            bins = 10;
            if numIndModes>1
                histData = cell2mat(pattDisp(mouseID,experiment,m));
                histogram(histData, bins);
            else
                histData = cell2mat(pattDisp(mouseID,experiment));
                histogram(histData, bins);
            end
            hold on;
            title([anesString{experiment}, ', pattern displacement'])
            %legend({'m = 1', 'm = 2', 'm = 3'})
            
        end
    end
    sgtitle(['GL', num2str(allMice(mouseID)), ', ', 'Patterns detected from single trials (interp by 3) gamma, then neuropatt: alpha = ', ...
        num2str(testAlphas(aInd)), ', beta = ', num2str(testBetas(bInd))])
    
    saveas(ff, [dirPic, 'GL', num2str(allMice(mouseID)),'_', 'sT_int3_NeuroPatt', '.png'])
    close all
end





