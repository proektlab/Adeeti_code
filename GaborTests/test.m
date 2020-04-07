
xSize = 18;
ySize = 33;

[gridX, gridY] = meshgrid(1:xSize, 1:ySize);

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
centerX = 10.3044;
centerY = 18;
sigmaX = 2.5332;
sigmaY = 5;
amplitude = 8.0000;
background = 100;
wavelength = 12;
theta = pi/2;
phi = 0;
psi = pi/16;

imageToFit = makeGaborTestImage(gridX, gridY, centerX, centerY, amplitude, background, sigmaX, sigmaY, wavelength, theta);%, phi, psi);
% imageToFit = imageToFit + normrnd(0, 0.5, size(imageToFit));
% imageToFit = perlin2D(100);

goalImage = squeeze(interpFiltDataTimes(2,:,:));

figure(1);
clf;
subplot(1,2,1)
imagesc(goalImage)
subplot(1,2,2)
imagesc(imageToFit)
sgtitle(['Corr: ' num2str(corrleation) ' fit: ' num2str(score)]);
colormap(parula)

%%

% imageToFit = squeeze(rawFiltDataTimes(2,:,:));
imageToFit = squeeze(interpFiltDataTimes(100,:,:));

% for i = 1:ceil(numel(imageToFit)/10)
%     imageToFit(randi(length(imageToFit(:)))) = nan;
% end

[fitParameters, score, corrleation, gridX, gridY, params] = fitGaborToImage(imageToFit, 0, [], []); %expParams, lambda);

gaborApproximation = makeGaborTestImage(gridX, gridY, fitParameters.centerX,fitParameters.centerY, fitParameters.amplitude, fitParameters.background, fitParameters.sigmaX, fitParameters.sigmaY, fitParameters.wavelength, fitParameters.theta, fitParameters.phi, fitParameters.psi);

figure(1);
clf;
subplot(1,2,1)
imagesc(imageToFit)
subplot(1,2,2)
imagesc(gaborApproximation)
sgtitle(['Corr: ' num2str(corrleation) ' fit: ' num2str(score)]);
colormap(parula)


%% figure of lamdas

allData = dir('Gab*');

for expID = 2:5
    load(allData(expID).name, 'allCorr')
allLambda = [0.05, 0.2, 0.5, 1, 2, 4, 8, 10, 15, 20];

figure(1)
for i = 1:length(allLambda)
subplot(5,2,i)
plot(cell2mat(allCorr(i,:)))
hold on
title(num2str(allLambda(i)))
end
end



