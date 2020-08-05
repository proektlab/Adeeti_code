%% Making movie heat plot of ITPC

%% Make movie of mean signal at 30-40 Hz for all experiments
clear
clc
close all

dirIn1 = '/synology/adeeti/ecog/matIsoPropMultiStim/'; %'Z:\adeeti\ecog\matIsoPropMultiStim\'; %'/synology/adeeti/ecog/matIsoPropMultiStim/';
dirIn2 = '/synology/adeeti/ecog/matIsoPropMultiStim/Wavelets/FiltData/'; %'Z:\adeeti\ecog\matIsoPropMultiStim\Wavelets\FiltData'; %'/synology/adeeti/ecog/matIsoPropMultiStim/Wavelets/FiltData/';
dirOut = '/synology/adeeti/ecog/images/testingGaborFitting/'; %'Z:\adeeti\ecog\GaborTests\'; %'/synology/adeeti/ecog/images/testingGaborFitting/';
dirGaborTesting = '/synology/adeeti/GaborTests/'; %'Z:\adeeti\GaborTests\'; %'/synology/adeeti/GaborTests/';
identifier = '20*.mat*';

BOOTSTRAP =1;
NUM_BOOT = 4;

stimIndex = [0, Inf];

%trial = 50;
fr = 35;
screensize=get(groot, 'Screensize');
interpBy = 3;
steps = [900:1300];


%%
cd(dirIn1)
load('dataMatrixFlashes.mat')

cd(dirIn2)
mkdir(dirOut);

for i = 1:size(stimIndex,1)
    [MFE] = findMyExpMulti(dataMatrixFlashes, [], [], [], stimIndex(i,:));
    allExp{i} = MFE;
end

for expInd = 1:1%length(allExp{1})
    experiment = dataMatrixFlashes(expInd).expName(39:end-4);
    disp(experiment);
    
    %% to make an average of signal at coherent bands
    numExp = 1;
    plotIndex = 1;
    load([experiment, 'wave.mat'], ['filtSig', num2str(fr)], 'info')
    
    eval(['sig =filtSig', num2str(fr),';']);
    meanTotSig = squeeze(nanmean(sig,3));
    s = std(meanTotSig(1:1000,:),1);
    
    interpFiltDataTimes = nan(NUM_BOOT, length(steps), 11*interpBy, 6*interpBy);
    rawFiltDataTimes = nan(NUM_BOOT, length(steps), 11, 6);
    
    for n = 1:NUM_BOOT
        if BOOTSTRAP ==1
            boot_ind  = randsample(size(sig, 3),size(sig, 3), true);
            data_sig = sig(:,:,boot_ind);
        end
        
        data_sig = squeeze(nanmean(sig,3));
        
        m = mean(data_sig(1:1000,:),1);
        ztransform=(m-data_sig)./s;
        filtSig(n,:,:) = ztransform;
        
        %% setting up grid position matrix with data for gabor fitting
        for t = 1:length(steps) %time before in ms:size(meanSubData,3)
            [~, interpValuesFine] = plotOnGridInterp(squeeze(filtSig(n, steps(t),:)), 1, info.gridIndicies, interpBy);
            interpFiltDataTimes(n, t,:,:) = interpValuesFine;
        end
        
        for t = 1:length(steps) %time before in ms:size(meanSubData,3)
            [ ~, ~, gridData] = PlotOnECoG(squeeze(filtSig(n, steps(t),:)), info, 3, 1);
            rawFiltDataTimes(n, t,:,:) = gridData;
        end
    end
    
    %% making pictures of the data for gabor fitting interpolated
    %
    % xGridAxis = fliplr(linspace(0, 2.75, 10+1));
    % yGridAxis = linspace(0, 5, 20+1);
    % lowerCax = min(filtSig(:));
    % upperCax = max(filtSig(:));
    %
    %  f = figure('Position', screensize); clf;
    %  for t = 1:length(steps) %time before in ms:size(meanSubData,3)
    %     g(t)=subplot(1,length(steps),t);
    %     [plotHandle, interpValuesFine] = plotOnGridInterp(squeeze(filtSig(1, steps(t),:)), 1, info.gridIndicies, interpBy);
    %     interpFiltDataTimes(t,:,:) = interpValuesFine;
    %     caxis([lowerCax,upperCax]);
    %     g(t).XTickMode = 'Manual';
    %     g(t).YTickMode = 'Manual';
    %     g(t).YTick = linspace(1,1100, 20+1);
    %     g(t).XTick = linspace(1,600, 10+1);
    %     g(t).XTickLabel = xGridAxis;
    %     g(t).YTickLabel = yGridAxis;
    %     colorbar
    %     c = colorbar;
    %     c.Label.String = 'z threshold voltages from baseline';
    %
    %     ylabel('Ant-Post Distance in mm')
    %     xlabel('Med-Lat Distance in mm')
    %     title(['Timestep t = ', num2str(steps(t))])
    % end
    %
    % sgtitle(info.expName(1:end-4))
    % saveas(f, [dirOut, info.expName(1:end-4), '_3_int.png'])
    
    %% making pictures of the data for gabor fitting not interpolated
    
    % xGridAxis = fliplr(linspace(0, 2.75, 10+1));
    % yGridAxis = linspace(0, 5, 20+1);
    % lowerCax = min(filtSig(:));
    % upperCax = max(filtSig(:));
    %
    %
    % f = figure('Position', screensize); clf;
    % for t = 1:length(steps) %time before in ms:size(meanSubData,3)
    %     g(t)=subplot(1,length(steps),t);
    %
    %     [ ~, colorMatrix, gridData] = PlotOnECoG(squeeze(filtSig(1, steps(t),:)), info, 3, 1);
    %     plotHandle = imagesc(colorMatrix);
    %     rawFiltDataTimes(t,:,:) = gridData;
    %
    %     caxis([lowerCax,upperCax]);
    %     g(t).XTickMode = 'Manual';
    %     g(t).YTickMode = 'Manual';
    %     g(t).YTick = linspace(1,11, 20+1);
    %     g(t).XTick = linspace(1,6, 10+1);
    %     g(t).XTickLabel = xGridAxis;
    %     g(t).YTickLabel = yGridAxis;
    %     colorbar
    %     c = colorbar;
    %     c.Label.String = 'z threshold voltages from baseline';
    %
    %     ylabel('Ant-Post Distance in mm')
    %     xlabel('Med-Lat Distance in mm')
    %     title(['Timestep t = ', num2str(steps(t))])
    % end
    %
    % sgtitle(info.expName(1:end-4))
    % saveas(f, [dirOut, info.expName(1:end-4), '.png'])
    
    %%
    
    save([dirGaborTesting, 'gaborCoh', experiment, '.mat'], 'rawFiltDataTimes', 'interpFiltDataTimes')
end
cd(dirGaborTesting)