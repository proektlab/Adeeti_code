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
dirIn = '/synology/adeeti/GaborTests/Awake/';
elseif ispc
    dirIn = 'Z:/adeeti/GaborTests/Awake/';
end

dirOut = [dirIn, 'allParams/Awake/'];
identifier = 'gaborCoh*';

mkdir(dirOut)
cd(dirIn)
allData = dir(identifier);

allLambda = [0.05, 0.2, 0.5, 1];

PLOT_PARAMS = 0;
PLOT_TESTANDFITMOVIES =0;

%%

for expID = 1:length(allData)
    load([dirIn, allData(expID).name]);
    
    allParameters = {};
    allScores = [];
    allCorr = [];
    for n = 1:1%size(interpFiltDataTimes,1)
        
        for lamInd = 1:length(allLambda)
            lambda = allLambda(lamInd);
            if size(interpFiltDataTimes) ==4
                movieToFit = squeeze(interpFiltDataTimes(n, 50:350,:,:));
            else
                movieToFit = squeeze(interpFiltDataTimes(50:350,:,:));
            end
            
            lastParams = [];
            
            for i = 1:size(movieToFit,1)
                imageToFit = squeeze(movieToFit(i,:,:));
                [fitParameters, score, corrleation, gridX, gridY, lastParams] = fitGaborToImage(imageToFit, 0, lastParams, lambda);
                
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
                
                disp(['Processed image ' num2str(i) ' of ' num2str(size(movieToFit,1))]);
            end
        end
    end
    
    save([dirOut, 'GabCohExp' num2str(expID), '.mat'], 'allParameters', 'allScores', 'allCorr')
end




%% looking at averages and CIs

% std([allParametersArray(lamID,:,:).sigmaY])
% 
% lamID= 1;
% expID =1;
% 
% cd(dirOut)
% allParamsSets = dir('Gab*');
% 
% load([dirOut, allParamsSets(expID).name], 'allParameters', 'allScores', 'allCorr')
% allParametersArray = cell2mat(allParameters);
% 
% figure
% NUM_BOOTSTRAP = size(interpFiltDataTimes,1);
% 
% PLOT_PARAMS = 1;
% 
% 
% 
% statParamsArrayMean = {};
% statParamsArrayMean(lamID,:).theta = mean([allParametersArray(lamID,:,:).theta],2)
% 
% 
% 
% 
% 
% 
% figure;
% if PLOT_PARAMS ==1
%     numParam = 9;
%     
%     subplot(numParam,1,1)
%     hold on
%     for n = 1:NUM_BOOTSTRAP
%     plot([allParametersArray(lamID,n,:).theta])
%     scatter(1:size(allParametersArray,3), [allParametersArray(lamID,n,:).theta], 20, [allCorr{lamID,n,:}])
%     colormap(jet(256));
%     end
%     colorbar;
%     title('Theta')
%     
%     subplot(numParam,1,2)
%     hold on
%     for n = 1:NUM_BOOTSTRAP
%     plot([allParametersArray(lamID,n,:).phi])
%     scatter(1:size(allParametersArray,3), [allParametersArray(lamID,n,:).phi], 20, [allCorr{lamID,n,:}])
%     colormap(jet(256));
%     end
%     colorbar;
%     title('phi')
%     
%     subplot(numParam,1,3)
%     counter = counter +1;
%     hold on
%     for n = 1:NUM_BOOTSTRAP
%     plot([allParametersArray(lamID,n,:).amplitude])
%     scatter(1:size(allParametersArray,3), [allParametersArray(lamID,n,:).amplitude], 20, [allCorr{lamID,n,:}])
%     colormap(jet(256));
%     end
%     colorbar;
%     title('amplitude')
%     
%     subplot(numParam,1,4)
%     counter = counter +1;
%     hold on
%     for n = 1:NUM_BOOTSTRAP
%     plot([allParametersArray(lamID,n,:).wavelength])
%     scatter(1:size(allParametersArray,3), [allParametersArray(lamID,n,:).wavelength], 20, [allCorr{lamID,n,:}])
%     colormap(jet(256));
%     end
%     colorbar;
%     title('wavelength')
%     
%     subplot(numParam,1,5)
%     counter = counter +1;
%     hold on
%     for n = 1:NUM_BOOTSTRAP
%     plot([allParametersArray(lamID,n,:).centerX])
%     scatter(1:size(allParametersArray,3), [allParametersArray(lamID,n,:).centerX], 20, [allCorr{lamID,n,:}])
%     colormap(jet(256));
%     end
%     colorbar;
%     title('centerX')
%     
%     subplot(numParam,1,6)
%     counter = counter +1;
%     hold on
%     for n = 1:NUM_BOOTSTRAP
%     plot([allParametersArray(lamID,n,:).centerY])
%     scatter(1:size(allParametersArray,3), [allParametersArray(lamID,n,:).centerY], 20, [allCorr{lamID,n,:}])
%     colormap(jet(256));
%     end
%     colorbar;
%     title('centerY')
%     
%     subplot(numParam,1,7)
%     counter = counter +1;
%     hold on
%     for n = 1:NUM_BOOTSTRAP
%     plot([allParametersArray(lamID,n,:).sigmaX])
%     scatter(1:size(allParametersArray,3), [allParametersArray(lamID,n,:).sigmaX], 20, [allCorr{lamID,n,:}])
%     colormap(jet(256));
%     end
%     colorbar;
%     title('sigmaX')
%     
%     subplot(numParam,1,8)
%     counter = counter +1;
%     hold on
%     for n = 1:NUM_BOOTSTRAP
%     plot([allParametersArray(lamID,n,:).sigmaY])
%     scatter(1:size(allParametersArray,3), [allParametersArray(lamID,n,:).sigmaY], 20, [allCorr{lamID,n,:}])
%     colormap(jet(256));
%     end
%     colorbar;
%     title('sigmaY')
%     
%     subplot(numParam,1,9)
%     counter = counter +1;
%     hold on
%     for n = 1:NUM_BOOTSTRAP
%     plot([allCorr{lamID,n,:}])
%     scatter(1:size(allCorr,3), [allCorr{lamID,n,:}], 20, [allCorr{lamID,n,:}])
%     colormap(jet(256));
%     end
%     colorbar;
%     title('correlation')
% end
% 
% 
% sgtitle(['lambda = ' num2str(allLambda(lamID))])



