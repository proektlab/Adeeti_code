function [ff] = plotGaborParams(allParameters_R2, allCorr_R2, allScores_R2, plotTime, allLambda, useLambdaRange, titleString)

if nargin<7
    titleString = [];
end
if nargin <6 || isempty(useLambdaRange) || ~exist('useLambdaRange')
    useLambdaRange = 1:length(allLambda);
end
%%

PLOT_PARAMS = 1;
n= 1;

legendString = [];
counter = 0;

useLambdaRange = 1:length(allLambda);

for i = useLambdaRange
    counter = counter +1;
    legendString{counter} = num2str(allLambda(i));
end


allParametersArray_R2 = squeeze(cell2mat(allParameters_R2));
if size(allParametersArray_R2,1) ==length(plotTime)
    allParametersArray_R2 = allParametersArray_R2';
end

allCorr_R2_mat = squeeze(cell2mat(allCorr_R2));
if size(allCorr_R2_mat,1) ==length(plotTime)
    allCorr_R2_mat = allCorr_R2_mat';
end


allScores_R2_mat = squeeze(cell2mat(allScores_R2));
if size(allScores_R2_mat,1) ==length(plotTime)
    allScores_R2_mat = allScores_R2_mat';
end


close all
ff = figure;
ff.Renderer = 'Painters';
ff.Color = 'white';
ff.Position = [174,42,1138,954];
clf
for lamID = useLambdaRange
    numParam= 10;
    
    %% plot theta
    
    subplot(numParam,1,1)
    hold on
    if ndims(allParametersArray_R2) ==3
        plot([allParametersArray_R2(lamID,n,:).theta])
    else
        plot([allParametersArray_R2(lamID,:).theta])
    end
    %scatter(1:size(allParametersArray,3), [allParametersArray(lamID,n,:).theta], 20, [allCorr{lamID,n,:}])
    %colormap(jet(256));
    %colorbar;
    title('Theta R2')
    legend(legendString,'Location','southeast')
    
    
    %% plot background
    
    subplot(numParam,1,2)
    hold on
    if ndims(allParametersArray_R2) ==3
        plot([allParametersArray_R2(lamID,n,:).background])
    else
        plot([allParametersArray_R2(lamID,:).amplitude])
    end
    %scatter(1:size(allParametersArray,3), [allParametersArray(lamID,n,:).background], 20, [allCorr{lamID,n,:}])
    %colormap(jet(256));
    %colorbar;
    title('background R2')
    
    %% amplitude
    
    subplot(numParam,1,3)
    hold on
    if ndims(allParametersArray_R2) ==3
        plot([allParametersArray_R2(lamID,n,:).amplitude])
    else
        plot([allParametersArray_R2(lamID,:).amplitude])
    end
    %scatter(1:size(allParametersArray,3), [allParametersArray(lamID,n,:).amplitude], 20, [allCorr{lamID,n,:}])
    %colormap(jet(256));
    %colorbar;
    title('amplitude R2')
    
    %% wavelength
    
    subplot(numParam,1,4)
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
    title('wavelength R2')
    
    
    %% center y
    subplot(numParam,1,5)
    hold on
    if ndims(allParametersArray_R2) ==3
        plot([allParametersArray_R2(lamID,n,:).centerY])
    else
        plot([allParametersArray_R2(lamID,:).centerY])
    end
    %scatter(1:size(allParametersArray,3), [allParametersArray(lamID,n,:).centerY], 20, [allCorr{lamID,n,:}])
    %colormap(jet(256));
    %colorbar;
    title('centerY R2')
    
    %% center x
    subplot(numParam,1,6)
    hold on
    if ndims(allParametersArray_R2) ==3
        plot([allParametersArray_R2(lamID,n,:).centerX])
    else
        plot([allParametersArray_R2(lamID,:).centerX])
    end
    %scatter(1:size(allParametersArray,3), [allParametersArray(lamID,n,:).centerY], 20, [allCorr{lamID,n,:}])
    %colormap(jet(256));
    %colorbar;
    title('centerX R2')
    
    %% sigma y
    subplot(numParam,1,7)
    hold on
    if ndims(allParametersArray_R2) ==3
        plot([allParametersArray_R2(lamID,n,:).sigmaY])
    else
        plot([allParametersArray_R2(lamID,:).sigmaY])
    end
    %scatter(1:size(allParametersArray,3), [allParametersArray(lamID,n,:).sigmaX], 20, [allCorr{lamID,n,:}])
    %colormap(jet(256));
    %colorbar;
    title('sigmaY R2')
    
    %% sigma x
    subplot(numParam,1,8)
    hold on
    if ndims(allParametersArray_R2) ==3
        plot([allParametersArray_R2(lamID,n,:).sigmaX])
    else
        plot([allParametersArray_R2(lamID,:).sigmaX])
    end
    %scatter(1:size(allParametersArray,3), [allParametersArray(lamID,n,:).sigmaY], 20, [allCorr{lamID,n,:}])
    %colormap(jet(256));
    %colorbar;
    title('sigmaX R2')
    
    %% correlation
    subplot(numParam,1,9)
    hold on
    if ndims(allCorr_R2_mat) ==3
        plot(squeeze(allCorr_R2_mat(lamID,n,:)))
    else
        plot(allCorr_R2_mat(lamID,:))
    end
    %scatter(1:size(allCorr,3), [allCorr{lamID,n,:}], 20, [allCorr{lamID,n,:}])
    %colormap(jet(256));
    %colorbar;
    title('correlation R2')
    
    
    %% fit score
    subplot(numParam,1,10)
    hold on
    if ndims(allScores_R2_mat) ==3
        plot(squeeze(allScores_R2_mat(lamID,n,:)))
    else
        plot(allScores_R2_mat(lamID,:))
    end
    %scatter(1:size(allCorr,3), [allCorr{lamID,n,:}], 20, [allCorr{lamID,n,:}])
    %colormap(jet(256));
    %colorbar;
    title('Fit Scores R2')
end

sgtitle(titleString)


