if isunix
    dirIn = '/synology/adeeti/spatialParamWaves/Awake/';
    dirPic = '/synology/adeeti/spatialParamWaves/images/spatSpread/Awake/';
elseif ispc
    dirIn = 'Z:/adeeti/spatialParamWaves/Awake/';
    dirPic = 'Z:\adeeti\spatialParamWaves\images\spatSpread\Awake\';
end

mkdir(dirPic)

cd(dirIn)
allData = dir('gab*.mat');
load('dataMatrixFlashes.mat')

%%
allMice = [6, 9, 13];

%interpBy = 3;
gridSpacing = 500;
samplingFreq = 1;
plotTime =50:350;
tapers = 9;
inDims = [5000, 2750];
norm2TotPower =0;
baselineTime = 1:25;
postStimTime = 50:200;

for mouseID = 1%:length(allMice)
    [isoHighExp, isoLowExp, emergExp, awaExp1, awaLastExp, ketExp] = ...
        findAnesArchatypeExp(dataMatrixFlashes, allMice(mouseID));
    
    MFE = [isoHighExp, isoLowExp, awaLastExp, ketExp];
    titleString = {'High Isoflurane', 'Low Isoflurane', 'Awake', 'Ketamine'};
    
    %% load each mouse and compute MTSpectrum
    for expInd = 1:length(MFE)
      
        load(allData(MFE(expInd)).name, 'interpFiltDataTimes', ...
            'info')
        
        disp(allData(MFE(expInd)).name)
        movieToFit = interpFiltDataTimes;
        compImage(expInd,:,:,:) = movieToFit(plotTime,:,:);
    end
    %%
    baselineImagesSum = squeeze(sum(abs(compImage(:,baselineTime,:,:)),2));
    postStimImagesSum = squeeze(sum(abs(compImage(:,postStimTime,:,:)),2));
    
    baselineImagesMean = squeeze(mean(abs(compImage(:,baselineTime,:,:)),2));
    postStimImagesMean = squeeze(mean(abs(compImage(:,postStimTime,:,:)),2));
    
    baselineImagesStd = squeeze(std(abs(compImage(:,baselineTime,:,:)),0,2));
    postStimImagesStd = squeeze(std(abs(compImage(:,postStimTime,:,:)),0,2));
    
    z_baselineImages = baselineImagesMean./baselineImagesStd;
    z_postStimImages = (postStimImagesMean-baselineImagesMean)./baselineImagesStd;
    
    %%
    figure
    for i = 1:4
    subplot(2,4,i)
    imagesc(squeeze(baselineImagesSum(i,:,:)))
    colorbar
    title(['Baseline ', titleString{1}])
    
    subplot(2,4,i+4)
    imagesc(squeeze(postStimImagesSum(i,:,:)))
    colorbar
    title(['VEP ', titleString{i}])
    end
    
    sgtitle(['GL',  num2str(allMice(mouseID)), ' Sum of Gamma Power'])
    %saveas(ff, [dirPic, 'SpatAct_sum_GL', num2str(allMice(mouseID)), '.png'])
    
    %%
    
     figure
    for i = 1:4
    subplot(2,4,i)
    imagesc(squeeze(baselineImagesMean(i,:,:)))
    colorbar
    title(['Baseline ', titleString{1}])
    
    subplot(2,4,i+4)
    imagesc(squeeze(postStimImagesMean(i,:,:)))
    colorbar
    title(['VEP ', titleString{i}])
    end
    
    sgtitle(['GL',  num2str(allMice(mouseID)), ' Mean of Gamma Power'])
    %saveas(ff, [dirPic, 'SpatAct_mean_GL', num2str(allMice(mouseID)), '.png'])
    
    %%
    
      figure
    for i = 1:4
    subplot(2,4,i)
    imagesc(squeeze(z_baselineImages(i,:,:)))
    colorbar
    title(['Baseline ', titleString{1}])
    
    subplot(2,4,i+4)
    imagesc(squeeze(z_postStimImages(i,:,:)))
    colorbar
    title(['VEP ', titleString{i}])
    end
    
    sgtitle(['GL',  num2str(allMice(mouseID)), ' Z score of Gamma Power'])
    %saveas(ff, [dirPic, 'SpatAct_z_GL', num2str(allMice(mouseID)), '.png'])


end

    