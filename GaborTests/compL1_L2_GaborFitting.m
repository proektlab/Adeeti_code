%% Goes through movie and makes a series of gabor filters for each frame with associated parameters

% centerX = normrnd(xSize/2, xSize/5);
% centerY = normrnd(ySize/2, ySize/5);
% sigmaX = normrnd(xSize/4, xSize/10);
% sigmaY = normrnd(ySize/4, ySize/10);
% amplitude = normrnd(5, 1);
% background = normrnd(1, 1);
% wavelength = abs(normrnd(xSize/2, xSize/4));
% theta = normrnd(0, pi);
% phi = normrnd(0, pi);
% psi = normrnd(0, pi);

%parameter(1) - Sub-pixel resolution of foci position X
%parameter(2) - Sub-pixel resolution of foci position Y
%parameter(3) - Intensity of the gaussian
%parameter(4) - background intensity
%parameter(5) - sigma of gaussian X
%parameter(6) - sigma of gaussian Y
%parameter(7) - wavelength
%parameter(8) - spatial angle
%parameter(9) - spatial phase
%parameter(10) - gaussian spatial phase


%%

if isunix 
    dirLoc = '/synology/adeeti/';
elseif ispc
    dirLoc = 'Z:/adeeti/';
end

dirIn =  [dirLoc, 'spatialParamWaves/Awake/'];
dirOut = [dirLoc, 'spatialParamWaves/allParams/Awake/'];
identifier = 'gaborCoh*';

mkdir(dirOut)
cd(dirIn)
allData = dir(identifier);

allLambda = 0.05; %[0.05, 0.2, 0.5, 1];

PLOT_PARAMS = 0;
PLOT_TESTANDFITMOVIES =0;

%%

for expID = 1%:length(allData)
    load([dirIn, allData(expID).name]);
    
    allParameters = {};
    allScores = [];
    allCorr = [];
    allParameters_L2 = {};
    allScores_L2 = [];
    allCorr_L2 = [];
    allParameters_R2 = {};
    allScores_R2 = [];
    allCorr_R2 = [];
    
    for n = 1:1%size(interpFiltDataTimes,1)
        
        for lamInd = 1:length(allLambda)
            lambda = allLambda(lamInd);
            if size(interpFiltDataTimes) ==4
                movieToFit = squeeze(interpFiltDataTimes(n, 50:350,:,:));
            else
                movieToFit = squeeze(interpFiltDataTimes(50:350,:,:));
            end
            
            lastParams = [];
            lastParams_L2 = [];
            lastParams_R2 = [];
            
            for i = 1:size(movieToFit,1)
                imageToFit = squeeze(movieToFit(i,:,:));
                [fitParameters, score, corrleation, gridX, gridY, lastParams] = ...
                    fitGaborToImage(imageToFit, 0, lastParams, lambda);
                
                [fitParameters_L2, score_L2, corrleation_L2, gridX_L2, gridY_L2, lastParams_L2] = ...
                    fitGaborToImage_L2(imageToFit, 0, lastParams_L2, lambda);
                
                [fitParameters_R2, score_R2, corrleation_R2, gridX_R2, gridY_R2, lastParams_R2] = ...
                    fitGaborToImage_corr(imageToFit, 0, lastParams_R2, lambda);

                
                allParameters{lamInd,n,i}.centerX = fitParameters.centerX;
                allParameters{lamInd,n,i}.centerY = fitParameters.centerY;
                allParameters{lamInd,n,i}.sigmaX = fitParameters.sigmaX;
                allParameters{lamInd,n,i}.sigmaY = fitParameters.sigmaY;
                allParameters{lamInd,n,i}.amplitude = fitParameters.amplitude;
                allParameters{lamInd,n,i}.background = fitParameters.background;
                allParameters{lamInd,n,i}.wavelength = fitParameters.wavelength;
                allParameters{lamInd,n,i}.theta = fitParameters.theta;
                %allParameters{lamInd,n,i}.phi = fitParameters.phi;
                %allParameters{lamInd,i}.psi = fitParameters.psi;
                
                allScores{lamInd,n,i} = score;
                allCorr{lamInd,n,i} = corrleation;
                
                
                allParameters_L2{lamInd,n,i}.centerX = fitParameters_L2.centerX;
                allParameters_L2{lamInd,n,i}.centerY = fitParameters_L2.centerY;
                allParameters_L2{lamInd,n,i}.sigmaX = fitParameters_L2.sigmaX;
                allParameters_L2{lamInd,n,i}.sigmaY = fitParameters_L2.sigmaY;
                allParameters_L2{lamInd,n,i}.amplitude = fitParameters_L2.amplitude;
                allParameters_L2{lamInd,n,i}.background = fitParameters_L2.background;
                allParameters_L2{lamInd,n,i}.wavelength = fitParameters_L2.wavelength;
                allParameters_L2{lamInd,n,i}.theta = fitParameters_L2.theta;
                %allParameters{lamInd,n,i}.phi = fitParameters.phi;
                %allParameters{lamInd,i}.psi = fitParameters.psi;
                
                allScores_L2{lamInd,n,i} = score_L2;
                allCorr_L2{lamInd,n,i} = corrleation_L2;
                
                
                
                
                allParameters_R2{lamInd,n,i}.centerX = fitParameters_R2.centerX;
                allParameters_R2{lamInd,n,i}.centerY = fitParameters_R2.centerY;
                allParameters_R2{lamInd,n,i}.sigmaX = fitParameters_R2.sigmaX;
                allParameters_R2{lamInd,n,i}.sigmaY = fitParameters_R2.sigmaY;
                allParameters_R2{lamInd,n,i}.amplitude = fitParameters_R2.amplitude;
                allParameters_R2{lamInd,n,i}.background = fitParameters_R2.background;
                allParameters_R2{lamInd,n,i}.wavelength = fitParameters_R2.wavelength;
                allParameters_R2{lamInd,n,i}.theta = fitParameters_R2.theta;
                %allParameters{lamInd,n,i}.phi = fitParameters.phi;
                %allParameters{lamInd,i}.psi = fitParameters.psi;
                
                allScores_R2{lamInd,n,i} = score_R2;
                allCorr_R2{lamInd,n,i} = corrleation_R2;

                
                disp(['Processed image ' num2str(i) ' of ' num2str(size(movieToFit,1))]);
            end
        end
    end
    
%     save([dirOut, 'GabCohExp' num2str(expID), '.mat'], 'allParameters', 'allScores', 'allCorr', ...
%         'allParameters_L2', 'allScores_L2', 'allCorr_L2', 'allParameters_R2', 'allScores_R2', 'allCorr_R2', '-append')
end




%% looking at averages and CIs

%%
PLOT_PARAMS = 1;
n= 1;

%cd(dirOut)
%allParamsSets = dir('Gab*');


%load([dirOut, allParamsSets(expID).name], 'allParameters', 'allScores', 'allCorr')
%allParametersArray = cell2mat(allParameters);

legendString = [];
counter = 0;

useLambdaRange = 1:length(allLambda);


for i = useLambdaRange
    counter = counter +1;
    legendString{counter} = num2str(allLambda(i));
end

%mkdir(dirPic)

for i = 1:length(allData)
    %load(allData(i).name, 'allParameters', 'allScores', 'allCorr')
    
    allParametersArray_L1 = squeeze(cell2mat(allParameters));
    if size(allParametersArray_L1,1) ==301
        allParametersArray_L1 = allParametersArray_L1';
    end
    
    allParametersArray_L2 = squeeze(cell2mat(allParameters_L2));
    if size(allParametersArray_L2,1) ==301
        allParametersArray_L2 = allParametersArray_L2';
    end
    allParametersArray_R2 = squeeze(cell2mat(allParameters_R2));
    if size(allParametersArray_R2,1) ==301
        allParametersArray_R2 = allParametersArray_R2';
    end
    
   allCorr_L1 = squeeze(cell2mat(allCorr));
    if size(allCorr_L1,1) ==301
        allCorr_L1 = allCorr_L1';
    end
   allCorr_L2 = squeeze(cell2mat(allCorr_L2));
    if size(allCorr_L2,1) ==301
        allCorr_L2 = allCorr_L2';
    end
    allCorr_R2 = squeeze(cell2mat(allCorr_R2));
    if size(allCorr_R2,1) ==301
        allCorr_R2 = allCorr_R2';
    end
    
    
    allScores_L1 = squeeze(cell2mat(allScores));
    if size(allScores_L1,1) ==301
        allScores_L1 = allScores_L1';
    end
    allScores_L2 = squeeze(cell2mat(allScores_L2));
if size(allScores_L2,1) ==301
        allScores_L2 = allScores_L2';
    end
    allScores_R2 = squeeze(cell2mat(allScores_R2));
if size(allScores_R2,1) ==301
        allScores_R2 = allScores_R2';
    end
    
    
    close all
    ff = figure;
    ff.Renderer = 'Painters';
    ff.Color = 'white';
    ff.Position = [174,42,1138,954];
    clf
    if PLOT_PARAMS ==1
        for lamID = useLambdaRange
            numParam= 10;
            
            %% plot theta 
            subplot(numParam,3,1)
            hold on
            if ndims(allParametersArray_L1) ==3
                plot([allParametersArray_L1(lamID,n,:).theta])
            else
                plot([allParametersArray_L1(lamID,:).theta])
            end
            %scatter(1:size(allParametersArray,3), [allParametersArray(lamID,n,:).theta], 20, [allCorr{lamID,n,:}])
            %colormap(jet(256));
            %colorbar;
            title('Theta L1')
            legend(legendString,'Location','southeast')
            
            
            subplot(numParam,3,2)
            hold on
            if ndims(allParametersArray_L2) ==3
                plot([allParametersArray_L2(lamID,n,:).theta])
            else
                plot([allParametersArray_L2(lamID,:).theta])
            end
            %scatter(1:size(allParametersArray,3), [allParametersArray(lamID,n,:).theta], 20, [allCorr{lamID,n,:}])
            %colormap(jet(256));
            %colorbar;
            title('Theta L2')
            legend(legendString,'Location','southeast')
            
            subplot(numParam,3,3)
            hold on
            if ndims(allParametersArray_R2) ==3
                plot([allParametersArray_R2(lamID,n,:).theta])
            else
                plot([allParametersArray_R2(lamID,:).theta])
            end
            %scatter(1:size(allParametersArray,3), [allParametersArray(lamID,n,:).theta], 20, [allCorr{lamID,n,:}])
            %colormap(jet(256));
            %colorbar;
            title('Theta Corr')
            legend(legendString,'Location','southeast')
            
            
            %% plot background
            subplot(numParam,3,4)
            hold on
            if ndims(allParametersArray_L1) ==3
                plot([allParametersArray_L1(lamID,n,:).background])
             else
                plot([allParametersArray_L1(lamID,:).background])
            end
            %scatter(1:size(allParametersArray,3), [allParametersArray(lamID,n,:).background], 20, [allCorr{lamID,n,:}])
            %colormap(jet(256));
            %colorbar;
            title('background L1')
            
             subplot(numParam,3,5)
            hold on
            if ndims(allParametersArray_L2) ==3
                plot([allParametersArray_L2(lamID,n,:).background])
             else
                plot([allParametersArray_L2(lamID,:).amplitude])
            end
            %scatter(1:size(allParametersArray,3), [allParametersArray(lamID,n,:).background], 20, [allCorr{lamID,n,:}])
            %colormap(jet(256));
            %colorbar;
            title('background L2')
            
             subplot(numParam,3,6)
            hold on
            if ndims(allParametersArray_R2) ==3
                plot([allParametersArray_R2(lamID,n,:).background])
            else
                plot([allParametersArray_R2(lamID,:).amplitude])
            end
            %scatter(1:size(allParametersArray,3), [allParametersArray(lamID,n,:).background], 20, [allCorr{lamID,n,:}])
            %colormap(jet(256));
            %colorbar;
            title('background Corr')
            
            %% amplitude
            subplot(numParam,3,7)
            hold on
            if ndims(allParametersArray_L1) ==3
                plot([allParametersArray_L1(lamID,n,:).amplitude])
            else
                plot([allParametersArray_L1(lamID,:).amplitude])
            end
            %scatter(1:size(allParametersArray,3), [allParametersArray(lamID,n,:).amplitude], 20, [allCorr{lamID,n,:}])
            %colormap(jet(256));
            %colorbar;
            title('amplitude L1')
            
            subplot(numParam,3,8)
            hold on
            if ndims(allParametersArray_L2) ==3
                plot([allParametersArray_L2(lamID,n,:).amplitude])
            else
                plot([allParametersArray_L2(lamID,:).amplitude])
            end
            %scatter(1:size(allParametersArray,3), [allParametersArray(lamID,n,:).amplitude], 20, [allCorr{lamID,n,:}])
            %colormap(jet(256));
            %colorbar;
            title('amplitude L2')
            
            subplot(numParam,3,9)
            hold on
            if ndims(allParametersArray_R2) ==3
                plot([allParametersArray_R2(lamID,n,:).amplitude])
            else
                plot([allParametersArray_R2(lamID,:).amplitude])
            end
            %scatter(1:size(allParametersArray,3), [allParametersArray(lamID,n,:).amplitude], 20, [allCorr{lamID,n,:}])
            %colormap(jet(256));
            %colorbar;
            title('amplitude Corr')
            
            %% wavelength
            subplot(numParam,3,10)
            hold on
            if ndims(allParametersArray_L1) ==3
                plot([allParametersArray_L1(lamID,n,:).wavelength])
            else
                plot([allParametersArray_L1(lamID,:).wavelength])
            end
            %scatter(1:size(allParametersArray,3), [allParametersArray(lamID,n,:).wavelength], 20, [allCorr{lamID,n,:}])
            %%scatter(1:size(allParametersArray,3), [allParametersArray(lamID,n,:).centerX], 20, [allCorr{lamID,n,:}])
            %colormap(jet(256));
            %colorbar;
            title('wavelength L1')
            
             subplot(numParam,3,11)
            hold on
            if ndims(allParametersArray_L2) ==3
                plot([allParametersArray_L2(lamID,n,:).wavelength])
            else
                plot([allParametersArray_L2(lamID,:).wavelength])
            end
            %scatter(1:size(allParametersArray,3), [allParametersArray(lamID,n,:).wavelength], 20, [allCorr{lamID,n,:}])
            %%scatter(1:size(allParametersArray,3), [allParametersArray(lamID,n,:).centerX], 20, [allCorr{lamID,n,:}])
            %colormap(jet(256));
            %colorbar;
            title('wavelength L2')
            
            
             subplot(numParam,3,12)
            hold on
            if ndims(allParametersArray_R2) ==3
                plot([allParametersArray_R2(lamID,n,:).wavelength])
            else
                plot([allParametersArray_R2(lamID,:).wavelength])
            end
            %scatter(1:size(allParametersArray,3), [allParametersArray(lamID,n,:).wavelength], 20, [allCorr{lamID,n,:}])
            %%scatter(1:size(allParametersArray,3), [allParametersArray(lamID,n,:).centerX], 20, [allCorr{lamID,n,:}])
            %colormap(jet(256));
            %colorbar;
            title('wavelength Corr')
            
            
            %% center y
            subplot(numParam,3,13)
            hold on
            if ndims(allParametersArray_L1) ==3
                plot([allParametersArray_L1(lamID,n,:).centerY])
            else
                plot([allParametersArray_L1(lamID,:).centerY])
            end
            %scatter(1:size(allParametersArray,3), [allParametersArray(lamID,n,:).centerY], 20, [allCorr{lamID,n,:}])
            %colormap(jet(256));
            %colorbar;
            title('centerY L1')
            
            subplot(numParam,3,14)
            hold on
            if ndims(allParametersArray_L2) ==3
                plot([allParametersArray_L2(lamID,n,:).centerY])
            else
                plot([allParametersArray_L2(lamID,:).centerY])
            end
            %scatter(1:size(allParametersArray,3), [allParametersArray(lamID,n,:).centerY], 20, [allCorr{lamID,n,:}])
            %colormap(jet(256));
            %colorbar;
            title('centerY L2')
            
            subplot(numParam,3,15)
            hold on
            if ndims(allParametersArray_R2) ==3
                plot([allParametersArray_R2(lamID,n,:).centerY])
            else
                plot([allParametersArray_R2(lamID,:).centerY])
            end
            %scatter(1:size(allParametersArray,3), [allParametersArray(lamID,n,:).centerY], 20, [allCorr{lamID,n,:}])
            %colormap(jet(256));
            %colorbar;
            title('centerY Corr')
            
            %% center x
            subplot(numParam,3,16)
            hold on
            if ndims(allParametersArray_L1) ==3
                plot([allParametersArray_L1(lamID,n,:).centerX])
            else
                plot([allParametersArray_L1(lamID,:).centerX])
            end
            %scatter(1:size(allParametersArray,3), [allParametersArray(lamID,n,:).centerY], 20, [allCorr{lamID,n,:}])
            %colormap(jet(256));
            %colorbar;
            title('centerX L1')
            
            subplot(numParam,3,17)
            hold on
            if ndims(allParametersArray_L2) ==3
                plot([allParametersArray_L2(lamID,n,:).centerX])
            else
                plot([allParametersArray_L2(lamID,:).centerX])
            end
            %scatter(1:size(allParametersArray,3), [allParametersArray(lamID,n,:).centerY], 20, [allCorr{lamID,n,:}])
            %colormap(jet(256));
            %colorbar;
            title('centerX L2')
            
            subplot(numParam,3,18)
            hold on
            if ndims(allParametersArray_R2) ==3
                plot([allParametersArray_R2(lamID,n,:).centerX])
            else
                plot([allParametersArray_R2(lamID,:).centerX])
            end
            %scatter(1:size(allParametersArray,3), [allParametersArray(lamID,n,:).centerY], 20, [allCorr{lamID,n,:}])
            %colormap(jet(256));
            %colorbar;
            title('centerX Corr')
            
            %% sigma y
            subplot(numParam,3,19)
            hold on
            if ndims(allParametersArray_L1) ==3
                plot([allParametersArray_L1(lamID,n,:).sigmaY])
            else
                plot([allParametersArray_L1(lamID,:).sigmaY])
            end
            %scatter(1:size(allParametersArray,3), [allParametersArray(lamID,n,:).sigmaX], 20, [allCorr{lamID,n,:}])
            %colormap(jet(256));
            %colorbar;
            title('sigmaY L1')
            
            subplot(numParam,3,20)
            hold on
            if ndims(allParametersArray_L2) ==3
                plot([allParametersArray_L2(lamID,n,:).sigmaY])
            else
                plot([allParametersArray_L2(lamID,:).sigmaY])
            end
            %scatter(1:size(allParametersArray,3), [allParametersArray(lamID,n,:).sigmaX], 20, [allCorr{lamID,n,:}])
            %colormap(jet(256));
            %colorbar;
            title('sigmaY L2')
            
            subplot(numParam,3,21)
            hold on
            if ndims(allParametersArray_R2) ==3
                plot([allParametersArray_R2(lamID,n,:).sigmaY])
            else
                plot([allParametersArray_R2(lamID,:).sigmaY])
            end
            %scatter(1:size(allParametersArray,3), [allParametersArray(lamID,n,:).sigmaX], 20, [allCorr{lamID,n,:}])
            %colormap(jet(256));
            %colorbar;
            title('sigmaY Corr')
            
            %% sigma x
            subplot(numParam,3,22)
            hold on
            if ndims(allParametersArray_L1) ==3
                plot([allParametersArray_L1(lamID,n,:).sigmaX])
            else
                plot([allParametersArray_L1(lamID,:).sigmaX])
            end
            %scatter(1:size(allParametersArray,3), [allParametersArray(lamID,n,:).sigmaY], 20, [allCorr{lamID,n,:}])
            %colormap(jet(256));
            %colorbar;
            title('sigmaX L2')
            
             subplot(numParam,3,23)
            hold on
            if ndims(allParametersArray_L2) ==3
                plot([allParametersArray_L2(lamID,n,:).sigmaX])
            else
                plot([allParametersArray_L2(lamID,:).sigmaX])
            end
            %scatter(1:size(allParametersArray,3), [allParametersArray(lamID,n,:).sigmaY], 20, [allCorr{lamID,n,:}])
            %colormap(jet(256));
            %colorbar;
            title('sigmaX L2')
            
             subplot(numParam,3,24)
            hold on
            if ndims(allParametersArray_R2) ==3
                plot([allParametersArray_R2(lamID,n,:).sigmaX])
            else
                plot([allParametersArray_R2(lamID,:).sigmaX])
            end
            %scatter(1:size(allParametersArray,3), [allParametersArray(lamID,n,:).sigmaY], 20, [allCorr{lamID,n,:}])
            %colormap(jet(256));
            %colorbar;
            title('sigmaX Corr')
            
            %% correlation
            subplot(numParam,3,25)
            hold on
            if ndims(allCorr_L1) ==3
                plot(squeeze(allCorr_L1(lamID,n,:)))
            else
                plot(allCorr_L1(lamID,:))
            end
            %scatter(1:size(allCorr,3), [allCorr{lamID,n,:}], 20, [allCorr{lamID,n,:}])
            %colormap(jet(256));
            %colorbar;
            title('correlation L1')
            
            subplot(numParam,3,26)
            hold on
            if ndims(allCorr_L2) ==3
                plot(squeeze(allCorr_L2(lamID,n,:)))
            else
                plot(allCorr_L2(lamID,:))
            end
            %scatter(1:size(allCorr,3), [allCorr{lamID,n,:}], 20, [allCorr{lamID,n,:}])
            %colormap(jet(256));
            %colorbar;
            title('correlation L2')
            
            subplot(numParam,3,27)
            hold on
            if ndims(allCorr_R2) ==3
                plot(squeeze(allCorr_R2(lamID,n,:)))
            else
                plot(allCorr_R2(lamID,:))
            end
            %scatter(1:size(allCorr,3), [allCorr{lamID,n,:}], 20, [allCorr{lamID,n,:}])
            %colormap(jet(256));
            %colorbar;
            title('correlation Corr')
            
            
            %% fit score
            subplot(numParam,3,28)
            hold on
            if ndims(allScores_L1) ==3
                plot(squeeze(allScores_L1(lamID,n,:)))
            else
                plot(allScores_L1(lamID,:))
            end
            %scatter(1:size(allCorr,3), [allCorr{lamID,n,:}], 20, [allCorr{lamID,n,:}])
            %colormap(jet(256));
            %colorbar;
            title('Fit Scores L1')
            
            subplot(numParam,3,29)
            hold on
            if ndims(allScores_L2) ==3
                plot(squeeze(allScores_L2(lamID,n,:)))
            else
                plot(allScores_L2(lamID,:))
            end
            %scatter(1:size(allCorr,3), [allCorr{lamID,n,:}], 20, [allCorr{lamID,n,:}])
            %colormap(jet(256));
            %colorbar;
            title('Fit Scores L2')
            
            subplot(numParam,3,30)
            hold on
            if ndims(allScores_R2) ==3
                plot(squeeze(allScores_R2(lamID,n,:)))
            else
                plot(allScores_R2(lamID,:))
            end
            %scatter(1:size(allCorr,3), [allCorr{lamID,n,:}], 20, [allCorr{lamID,n,:}])
            %colormap(jet(256));
            %colorbar;
            title('Fit Scores Corr')
        end
    end
    sgtitle(allData(i).name)
    %saveas(ff, [dirPic, allData(i).name(1:end-4), '.png'])
end

