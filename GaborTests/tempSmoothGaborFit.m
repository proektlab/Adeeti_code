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
dirIn = 'C:/Users/adeeti/Dropbox/ProektLab_code/Adeeti_code/GaborTests/';
experiment = 'Exp1HighIsoTestFull.mat';

load([dirIn, experiment]);

movieToFit = interpFiltDataTimes(50:400,:,:);

lambda = 0.5;
allParameters = {};
allScores = [];
allCorr = [];
lastParams = [];

for i = 1:size(movieToFit,1)
    imageToFit = squeeze(movieToFit(i,:,:));
    [fitParameters, score, corrleation, gridX, gridY, lastParams] = fitGaborToImage(imageToFit, 0, lastParams, lambda);
    
    allParameters(i).centerX = fitParameters.centerX;
    allParameters(i).centerY = fitParameters.centerY;
    allParameters(i).sigmaX = fitParameters.sigmaX;
    allParameters(i).sigmaY = fitParameters.sigmaY;
    allParameters(i).amplitude = fitParameters.amplitude;
    allParameters(i).background = fitParameters.background;
    allParameters(i).wavelength = fitParameters.wavelength;
    allParameters(i).theta = fitParameters.theta;
    allParameters(i).phi = fitParameters.phi;
    allParameters(i).psi = fitParameters.psi;
    
    allScores(i) = score;
    allCorr(i) = corrleation;
    
    disp(['Processed image ' num2str(i) ' of ' num2str(size(movieToFit,1))]);
end

%%

n = 9;
figure(2)
subplot(n,1,1)
plot([allParameters.theta])
title('Theta')

subplot(n,1,2)
plot([allParameters.phi])
title('phi')

subplot(n,1,3)
plot([allParameters.psi])
title('psi')

subplot(n,1,4)
plot([allParameters.wavelength])
title('wavelength')

subplot(n,1,5)
plot([allParameters.centerX])
title('centerX')

subplot(n,1,6)
plot([allParameters.centerY])
title('centerY')

subplot(n,1,7)
plot([allParameters.sigmaX])
title('sigmaX')

subplot(n,1,8)
plot([allParameters.sigmaY])
title('sigmaY')

subplot(n,1,9)
plot(allCorr)
title('correlation')

%%

dirOut = dirIn;
%gaborApproximation = makeGaborTestImage(gridX, gridY, fitParameters.centerX,fitParameters.centerY, fitParameters.amplitude, fitParameters.background, fitParameters.sigmaX, fitParameters.sigmaY, fitParameters.wavelength, fitParameters.theta, fitParameters.phi, fitParameters.psi);
f = figure('Position', [789 -32 845 1003], 'color', 'w'); clf;
clear movieOutput

for i = 1:size(movieToFit,1)
    gaborApproximation = makeGaborTestImage(gridX, gridY, allParameters(i).centerX,allParameters(i).centerY, allParameters(i).amplitude, allParameters(i).background, ...
        allParameters(i).sigmaX, allParameters(i).sigmaY, allParameters(i).wavelength, allParameters(i).theta, allParameters(i).phi, allParameters(i).psi);
    H(1) = subplot(1,2,1)
    imagesc(squeeze(movieToFit(i,:,:)))
    title('True Image')
    H(2)= subplot(1,2,2)
    imagesc(gaborApproximation)
    title('Gabor Approx')
    sgtitle(['Corr: ' num2str(corrleation) ' fit: ' num2str(score)]);
    colormap(parula)
    set(H, 'clim', [-15, 15]);
    drawnow
    pause(0.5);
    movieOutput(i) = getframe(gcf);
end

v = VideoWriter([dirOut, 'test.avi']);
open(v)
if sum(size(movieOutput(1).cdata) == size(movieOutput(2).cdata)) ==3
    writeVideo(v,movieOutput(2:end))
else
    writeVideo(v,movieOutput)
end

