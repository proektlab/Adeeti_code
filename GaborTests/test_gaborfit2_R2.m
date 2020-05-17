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

allLambda = [0, 0.05, 0.5, 1 , 2];

PLOT_PARAMS = 0;
PLOT_TESTANDFITMOVIES =0;

plotTime = 1:150; %[1:size(movieToFit,1)];

%%

for expID = 1%:length(allData)
    load([dirIn, allData(expID).name]);

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

            lastParams_R2 = [];
            
            for i = plotTime %1:size(movieToFit,1)
                imageToFit = squeeze(movieToFit(i,:,:));
                %[fitParameters, score, corrleation, gridX, gridY, lastParams] = fitGaborToImage(imageToFit, 0, lastParams, lambda);
%                 [fitParameters_L2, score_L2, corrleation_L2, gridX_L2, gridY_L2, lastParams_L2] = fitGaborToImage_L2(imageToFit, 0, lastParams_L2, lambda);
                %[fitParameters_R2, score_R2, corrleation_R2, gridX_R2, gridY_R2, lastParams_R2] = fitGaborToImage_R2(imageToFit, 0, lastParams_R2, lambda);
                [fitParameters_R2, score_R2, corrleation_R2, gridX_R2, gridY_R2, lastParams_R2] = fitGaborToImage_corr(imageToFit, 0, lastParams_R2, lambda);

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
end

%%
[ff] = plotGaborParams(allParameters_R2, allCorr_R2, allScores_R2, plotTime, allLambda)

%%
%[movieOutput, f, allGabs] = gaborFitCompTrueMovie(movieToFit, allParameters_R2, allCorr_R2, allLambda, plotTime, lamInd, n);
