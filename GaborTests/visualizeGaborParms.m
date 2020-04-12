%% visualizing gabor parameters

if isunix
    dirIn = '/synology/adeeti/GaborTests/allParams/';
    dirPic = 'synology/adeeti/ecog/images/Gabors/ParamTest041120/';
elseif ispc
    dirIn = 'Z:/adeeti/GaborTests/allParams/';
    dirPic = 'Z:/adeeti/ecog/images/Gabors/ParamTest041120/';
end

cd(dirIn)
allData = dir('GabCoh*.mat');
allLambda = [0.05, 0.2, 0.5, 1, 2, 4, 8, 10, 15, 20];

figure

for i = 1:length(allData)
    load(allData(i).name, 'allCorr')
    allCorr = cell2mat(allCorr);
    for l = 1:length(allLambda)
        useLambda = allLambda(l);
        subplot(5,2,l)
        plot(squeeze(allCorr(l,:,:)))
        hold on
        title(['Lambda = ', num2str(useLambda)])
    end
end

%% lets try looking at all prop vs all iso

if isunix
    dirDataMatrix = '/synology/adeeti/ecog/matIsoPropMultiStimVIS_ONLY_/flashTrials/';
elseif ispc
    dirDataMatrix = 'Z:\adeeti\ecog\matIsoPropMultiStimVIS_ONLY_\flashTrials\';
end

cd(dirDataMatrix)
load('dataMatrixFlashesVIS_ONLY.mat')

cd(dirIn)
[allProp] = findMyExpMulti(dataMatrixFlashesVIS_ONLY, [], 'prop', [], [],  [], []);
[allIso] = findMyExpMulti(dataMatrixFlashesVIS_ONLY, [], 'iso', [], [],  [], []);

close all

figure; clf;
for i = allProp(allProp<=32)
    load(allData(i).name, 'allCorr')
    allCorr = cell2mat(allCorr);
    for l = 1:5
        useLambda = allLambda(l);
        subplot(5,2,2*l-1)
        plot(squeeze(allCorr(l,:,:)))
        set(gca, 'ylim', [0.2, 1])
        set(gca, 'xlim', [1,300])
        hold on
        if l ==1
            title(['Prop only experiments Lambda = ', num2str(useLambda)]);
        else
            title(['Lambda = ', num2str(useLambda)])
        end
    end
end

for i = allIso(allIso<=32)
    load(allData(i).name, 'allCorr')
    allCorr = cell2mat(allCorr);
    for l = 1:5
        useLambda = allLambda(l);
        subplot(5,2,2*l)
        plot(squeeze(allCorr(l,:,:)))
        set(gca, 'ylim', [0.2, 1])
        set(gca, 'xlim', [1,300])
        hold on
        if l ==1
            title(['Iso only experiments Lambda = ', num2str(useLambda)]);
        else
            title(['Lambda = ', num2str(useLambda)])
        end
    end
end


%%
PLOT_PARAMS = 1;
 n= 1;
 
%cd(dirOut)
%allParamsSets = dir('Gab*');


%load([dirOut, allParamsSets(expID).name], 'allParameters', 'allScores', 'allCorr')
allParametersArray = cell2mat(allParameters);

legendString = [];
counter = 0;
for i = 3:5
    counter = counter +1;
    legendString{counter} = num2str(allLambda(i));
end

mkdir(dirPic)

for i = 1:5 %length(allData)
    load(allData(i).name, 'allParameters', 'allScores', 'allCorr')
    allParametersArray = cell2mat(allParameters);
    allCorr = cell2mat(allCorr);
    close all
    ff = figure;
    ff.Renderer = 'Painters';
    ff.Color = 'white';
    ff.Position = [174,42,1138,954];
    clf
    if PLOT_PARAMS ==1
        for lamID = [3:5]
            numParam= 9;
            subplot(numParam,1,1)
            hold on
            if ndims(allParametersArray) ==3
                plot([allParametersArray(lamID,n,:).theta])
            else
                plot([allParametersArray(lamID,:).theta])
            end
            %scatter(1:size(allParametersArray,3), [allParametersArray(lamID,n,:).theta], 20, [allCorr{lamID,n,:}])
            %colormap(jet(256));
            %colorbar;
            title('Theta')
            legend(legendString,'Location','southeast')
            
            subplot(numParam,1,2)
            hold on
            plot([allParametersArray(lamID,n,:).background])
            %scatter(1:size(allParametersArray,3), [allParametersArray(lamID,n,:).background], 20, [allCorr{lamID,n,:}])
            %colormap(jet(256));
            %colorbar;
            title('background')
            
            subplot(numParam,1,3)
            hold on
            if ndims(allParametersArray) ==3
            plot([allParametersArray(lamID,n,:).amplitude])
            else 
               plot([allParametersArray(lamID,:).amplitude])
            end
            %scatter(1:size(allParametersArray,3), [allParametersArray(lamID,n,:).amplitude], 20, [allCorr{lamID,n,:}])
            %colormap(jet(256));
            %colorbar;
            title('amplitude')
            
            subplot(numParam,1,4)
            hold on
            if ndims(allParametersArray) ==3
            plot([allParametersArray(lamID,n,:).wavelength])
            else 
               plot([allParametersArray(lamID,:).wavelength])
            end
            %scatter(1:size(allParametersArray,3), [allParametersArray(lamID,n,:).wavelength], 20, [allCorr{lamID,n,:}])
            %%scatter(1:size(allParametersArray,3), [allParametersArray(lamID,n,:).centerX], 20, [allCorr{lamID,n,:}])
            %colormap(jet(256));
            %colorbar;
            title('wavelength')
            
            subplot(numParam,1,5)
            hold on
            if ndims(allParametersArray) ==3
            plot([allParametersArray(lamID,n,:).centerY])
            else 
               plot([allParametersArray(lamID,:).centerY])
            end
            %scatter(1:size(allParametersArray,3), [allParametersArray(lamID,n,:).centerY], 20, [allCorr{lamID,n,:}])
            %colormap(jet(256));
            %colorbar;
            title('centerY')
            
            subplot(numParam,1,6)
            hold on
            if ndims(allParametersArray) ==3
            plot([allParametersArray(lamID,n,:).centerX])
            else 
               plot([allParametersArray(lamID,:).centerX])
            end
            %scatter(1:size(allParametersArray,3), [allParametersArray(lamID,n,:).centerY], 20, [allCorr{lamID,n,:}])
            %colormap(jet(256));
            %colorbar;
            title('centerX')
            
            subplot(numParam,1,7)
            hold on
            if ndims(allParametersArray) ==3
            plot([allParametersArray(lamID,n,:).sigmaY])
            else 
               plot([allParametersArray(lamID,:).sigmaY])
            end
            %scatter(1:size(allParametersArray,3), [allParametersArray(lamID,n,:).sigmaX], 20, [allCorr{lamID,n,:}])
            %colormap(jet(256));
            %colorbar;
            title('sigmaY')
            
            subplot(numParam,1,8)
            hold on
            if ndims(allParametersArray) ==3
            plot([allParametersArray(lamID,n,:).sigmaX])
            else 
               plot([allParametersArray(lamID,:).sigmaX])
            end
            %scatter(1:size(allParametersArray,3), [allParametersArray(lamID,n,:).sigmaY], 20, [allCorr{lamID,n,:}])
            %colormap(jet(256));
            %colorbar;
            title('sigmaX')
            
            subplot(numParam,1,9)
            hold on
            if ndims(allCorr) ==3
            plot(allCorr(lamID,n,:))
            else 
               plot(allCorr(lamID,:))
            end
            %scatter(1:size(allCorr,3), [allCorr{lamID,n,:}], 20, [allCorr{lamID,n,:}])
            %colormap(jet(256));
            %colorbar;
            title('correlation')
        end
    end
    sgtitle(allData(i).name)
    saveas(ff, [dirPic, allData(i).name(1:end-4), '.png'])
end
