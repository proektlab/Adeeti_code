%% visualizing gabor parameters

if isunix
    dirIn = '/synology/adeeti/GaborTests/allParams/Awake/';
    dirPic = 'synology/adeeti/ecog/images/Gabors/ParamTest041120/Awake/';
elseif ispc
    dirIn = 'Z:/adeeti/GaborTests/allParams/Awake/';
    dirPic = 'Z:/adeeti/ecog/images/Gabors/ParamTest041120/Awake/';
end

cd(dirIn)
allData = dir('GabCoh*.mat');
allLambda = [0.05, 0.2, 0.5, 1];

useL = 3;

%allLambda = [0.05, 0.2, 0.5, 1, 2, 4, 8, 10, 15, 20];

ISOPROP =1;
AWAKE = 1;

figure
n = 1;


for i = 1:length(allData)
    load(allData(i).name, 'allCorr', 'allParameters' )
    allCorr = cell2mat(allCorr);
    allParametersArray = cell2mat(allParameters);
    for l = 1:length(allLambda)
        useLambda = allLambda(l);
        subplot(ceil(length(allLambda)/2),2,l)
        if ndims(allParametersArray) ==3
            plot([allParametersArray(l,n,:).wavelength])
        else
            plot([allParametersArray(l,:).wavelength])
        end
        hold on
        title(['Lambda = ', num2str(useLambda)])
    end
end



%% lets try looking at all prop vs all iso

if ISOPROP ==1
    if isunix
        dirDataMatrix = '/synology/adeeti/ecog/matIsoPropMultiStimVIS_ONLY_/flashTrials/';
    elseif ispc
        dirDataMatrix = 'Z:\adeeti\ecog\matIsoPropMultiStimVIS_ONLY_\flashTrials\';
    end
    
    cd(dirDataMatrix)
    load('dataMatrixFlashesVIS_ONLY.mat')
    dataMatrixFlashes = dataMatrixFlashesVIS_ONLY;
    
    cd(dirIn)
    [allProp] = findMyExpMulti(dataMatrixFlashes, [], 'prop', [], [],  [], []);
    [allIso] = findMyExpMulti(dataMatrixFlashes, [], 'iso', [], [],  [], []);
    
    close all
    
    figure; clf;
    for i = allProp(allProp<=32)
        load(allData(i).name, 'allCorr', 'allParameters' )
        allCorr = cell2mat(allCorr);
        allParametersArray = cell2mat(allParameters);
        for l = 1:length(allLambda)
            useLambda = allLambda(l);
            subplot(5,2,2*l-1)
            if ndims(allParametersArray) ==3
                plot([allParametersArray(l,n,:).wavelength])
            else
                plot([allParametersArray(l,:).wavelength])
            end
            hold on
            if l ==1
                title(['Prop only experiments Lambda = ', num2str(useLambda)]);
            else
                title(['Lambda = ', num2str(useLambda)])
            end
        end
    end
    
    for i = allIso(allIso<=32)
        load(allData(i).name, 'allCorr', 'allParameters' )
        allCorr = cell2mat(allCorr);
        allParametersArray = cell2mat(allParameters);
        for l = 1:length(allLambda)
            useLambda = allLambda(l);
            subplot(5,2,2*l)
            if ndims(allParametersArray) ==3
                plot([allParametersArray(l,n,:).wavelength])
            else
                plot([allParametersArray(l,:).wavelength])
            end
            hold on
            if l ==1
                title(['Iso only experiments Lambda = ', num2str(useLambda)]);
            else
                title(['Lambda = ', num2str(useLambda)])
            end
        end
    end
    
end

%%
if AWAKE ==1
    if isunix
        dirDataMatrix = '/synology/adeeti/GaborTests/allParams/Awake/';
    elseif ispc
        dirDataMatrix = 'Z:\adeeti\GaborTests\allParams\Awake\';
    end
    
    cd(dirDataMatrix)
    load('dataMatrixFlashes.mat')
    
    cd(dirIn)
    [allAwa] = findMyExpMulti(dataMatrixFlashes, [], 'awa', [], [],  [], []);
    [allIso] = findMyExpMulti(dataMatrixFlashes, [], 'iso', [], [],  [], []);
    [allKet] = findMyExpMulti(dataMatrixFlashes, [], 'ket', [], [],  [], []);
    
    close all
    alldata = dir('Gab*');
    
    figure; clf;
    for i = allAwa
        load(allData(i).name, 'allCorr', 'allParameters' )
        allCorr = cell2mat(allCorr);
        allParametersArray = cell2mat(allParameters);
        for l = 1:length(allLambda)
            useLambda = allLambda(l);
            subplot(length(allLambda),3,3*l-2)
            if ndims(allParametersArray) ==3
                plot([allParametersArray(l,n,:).wavelength])
            else
                plot([allParametersArray(l,:).wavelength])
            end
            hold on
            if l ==1
                title(['Awake only experiments Lambda = ', num2str(useLambda)]);
            else
                title(['Lambda = ', num2str(useLambda)])
            end
        end
    end
    
    for i = allIso
        load(allData(i).name, 'allCorr', 'allParameters' )
        allCorr = cell2mat(allCorr);
        allParametersArray = cell2mat(allParameters);
        for l = 1:length(allLambda)
            useLambda = allLambda(l);
            subplot(length(allLambda),3,3*l-1)
            if ndims(allParametersArray) ==3
                plot([allParametersArray(l,n,:).wavelength])
            else
                plot([allParametersArray(l,:).wavelength])
            end
            hold on
            if l ==1
                title(['Iso only experiments Lambda = ', num2str(useLambda)]);
            else
                title(['Lambda = ', num2str(useLambda)])
            end
        end
    end
    
    for i = allKet
        load(allData(i).name, 'allCorr', 'allParameters' )
        allCorr = cell2mat(allCorr);
        allParametersArray = cell2mat(allParameters);
        for l = 1:length(allLambda)
            useLambda = allLambda(l);
            subplot(length(allLambda),3,3*l)
            if ndims(allParametersArray) ==3
                plot([allParametersArray(l,n,:).wavelength])
            else
                plot([allParametersArray(l,:).wavelength])
            end
            hold on
            if l ==1
                title(['Ket only experiments Lambda = ', num2str(useLambda)]);
            else
                title(['Lambda = ', num2str(useLambda)])
            end
        end
    end
end





