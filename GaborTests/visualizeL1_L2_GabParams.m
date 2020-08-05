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
            title('Theta R2')
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
            title('background R2')
            
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
            title('amplitude R2')
            
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
            title('wavelength R2')
            
            
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
            title('centerY R2')
            
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
            title('centerX R2')
            
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
            title('sigmaY R2')
            
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
            title('sigmaX R2')
            
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
            title('correlation R2')
            
            
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
            title('Fit Scores R2')
        end
    end
    sgtitle(allData(i).name)
    %saveas(ff, [dirPic, allData(i).name(1:end-4), '.png'])
end
