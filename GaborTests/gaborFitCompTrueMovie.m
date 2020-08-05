function [movieOutput, f, allGabs] = gaborFitCompTrueMovie(movieToFit, allParameters, allCorr, allLambda, plotTime, lamID, n)
%[[movieOutput, f, allGabs] = gaborFitCompTrueMovie(movieToFit, allParameters, allCorr, allLambda, plotTime, lamID, n)

if nargin<5 || isempty(plotTime)
    plotTime =1:301;
end
if nargin<6 || isempty(lamID)
    lamID = 1;
end
if nargin<7 || isempty(n)
    n = 1;
end

%%
allParametersArray = squeeze(cell2mat(allParameters));
if size(allParametersArray,1) ==length(plotTime)
    allParametersArray = allParametersArray';
end

allCorr_matrix = squeeze(cell2mat(allCorr));
if size(allCorr_matrix,1) ==length(plotTime)
    allCorr_matrix = allCorr_matrix';
end




%%
imageToFit = squeeze(movieToFit(1,:,:));
[gridX, gridY] = meshgrid(1:size(imageToFit,2), 1:size(imageToFit,1));
gridX(isnan(imageToFit)) = nan;
gridY(isnan(imageToFit)) = nan;

clear movieOutput

%gaborApproximation = makeGaborTestImage(gridX, gridY, fitParameters.centerX,fitParameters.centerY, fitParameters.amplitude, fitParameters.background, fitParameters.sigmaX, fitParameters.sigmaY, fitParameters.wavelength, fitParameters.theta, fitParameters.phi, fitParameters.psi);
f = figure('Position', [789 -32 845 1003], 'color', 'w'); clf;
clear movieOutput

% for i = 1:size(movieToFit,1)
for i = plotTime
   if ndims(allParametersArray) ==2
         gaborApproximation = makeGaborTestImage(gridX, gridY, allParametersArray(lamID,i).centerX, ...
        allParametersArray(lamID,i).centerY, allParametersArray(lamID,i).amplitude, ...
        allParametersArray(lamID,i).background, allParametersArray(lamID,i).sigmaX, ...
        allParametersArray(lamID,i).sigmaY, allParametersArray(lamID,i).wavelength, ...
        allParametersArray(lamID,i).theta); %, allParametersArray(lamID,n,i).phi);%,allParametersArray(lamID,n,i).psi);
    else
         gaborApproximation = makeGaborTestImage(gridX, gridY, allParametersArray(lamID,n,i).centerX, ...
        allParametersArray(lamID,n,i).centerY, allParametersArray(lamID,n,i).amplitude, ...
        allParametersArray(lamID,n,i).background, allParametersArray(lamID,n,i).sigmaX, ...
        allParametersArray(lamID,n,i).sigmaY, allParametersArray(lamID,n,i).wavelength, ...
        allParametersArray(lamID,n,i).theta); %, allParametersArray(lamID,n,i).phi);%,allParametersArray(lamID,n,i).psi);
    end
    
    allGabs(i,:,:) = gaborApproximation;
    
    H(1) = subplot(1,2,1);
    imagesc(squeeze(movieToFit(i,:,:)))
    set(gca, 'clim', [-15, 15]);
    colorbar
    title('True Image')
    
    H(2)= subplot(1,2,2);
    imagesc(gaborApproximation)
    %sgtitle(['Corr: ' num2str(corrleation) ' fit: ' num2str(score)]);
    set(gca, 'clim', [-15, 15]);
    colorbar
    title('Gabor Approx')
    suptitle(['Time: ' num2str(i) 'ms, lambda: ', num2str(allLambda(lamID)), ' Corr: ', num2str(allCorr_matrix(i))]);
    %colormap(parula)
    drawnow
    pause(0.15);
    movieOutput(i) = getframe(gcf);
end

%     v = VideoWriter([dirOut, 'test.avi']);
%     open(v)
%     if sum(size(movieOutput(1).cdata) == size(movieOutput(2).cdata)) ==3
%         writeVideo(v,movieOutput(2:end))
%     else
%         writeVideo(v,movieOutput)
%     end
%     close(v)

