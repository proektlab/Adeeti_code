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
    
    allIsoWavelength = [];
    allPropWavelength = [];
    
    close all
    
    figure(1); clf;
    counterProp = 0;
    for i = allProp(allProp<=32)
        counterProp = counterProp +1;
        load(allData(i).name, 'allCorr', 'allParameters' )
        allCorr = cell2mat(allCorr);
        allParametersArray = cell2mat(allParameters);
        for l = 1:length(allLambda)
            useLambda = allLambda(l);
            subplot(length(allLambda),2,2*l-1)
            if ndims(allParametersArray) ==3
                plot([allParametersArray(l,n,:).wavelength])
                allPropWavelength(counterProp,l,:) = squeeze([allParametersArray(l,n,:).wavelength]);
            else
                plot([allParametersArray(l,:).wavelength])
                allPropWavelength(counterProp,l,:) = squeeze([allParametersArray(l,:).wavelength]);
            end
            hold on
            if l ==1
                title(['Prop only experiments Lambda = ', num2str(useLambda)]);
            else
                title(['Lambda = ', num2str(useLambda)])
            end
        end
    end
    
    counterIso = 0;
    for i = allIso(allIso<=32)
        counterIso = counterIso +1;
        load(allData(i).name, 'allCorr', 'allParameters' )
        allCorr = cell2mat(allCorr);
        allParametersArray = cell2mat(allParameters);
        for l = 1:length(allLambda)
            useLambda = allLambda(l);
            subplot(length(allLambda),2,2*l)
            if ndims(allParametersArray) ==3
                plot([allParametersArray(l,n,:).wavelength])
                allIsoWavelength(counterIso,l,:) = squeeze([allParametersArray(l,n,:).wavelength]);
            else
                plot([allParametersArray(l,:).wavelength])
                allIsoWavelength(counterIso,l,:) = squeeze([allParametersArray(l,:).wavelength]);
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

useL = 3

meanProp = squeeze(nanmean(allPropWavelength(:,useL,:),1));
stdProp = squeeze(nanstd(allPropWavelength(:,useL,:),0,1));
jackMeanP = jackknife(@mean,squeeze(allPropWavelength(:,useL,:)));
ubP = max(jackMeanP, [], 1);
lbP = min(jackMeanP, [], 1);
% ubP = meanProp+ stdProp*2;
% lbP = meanProp- stdProp*2;

meanIso = squeeze(nanmean(allIsoWavelength(:,useL,:),1));
stdIso = squeeze(nanstd(allIsoWavelength(:,useL,:),0,1));
jackMeanI = jackknife(@mean,squeeze(allIsoWavelength(:,useL,:)));
ubI = max(jackMeanI, [], 1);
lbI = min(jackMeanI, [], 1);
% ubI = meanIso+ stdIso*2;
% lbI = meanIso- stdIso*2;

figure(3)
clf
subplot(2,1,1)
hold on
plot(meanProp', 'b')
ciplot(lbP, ubP, [1:301], 'b')
plot(meanIso', 'm')
ciplot(lbI, ubI, [1:301], 'm')
plot([50, 50], [24,33], 'g')
%legend('Propofol', 'Prop JK', 'Isoflurane', 'Iso JK')
legend('Propofol', 'Prop CI', 'Isoflurane', 'Iso CI')
xlabel('time ms')
ylabel('wavelength')
title('Prop vs Iso')



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
    
    %close all
    alldata = dir('Gab*');
    
    allIsoWavelength = [];
    allAwaWavelength = [];
    allKetWavelength = [];
    
    
    figure(2); clf;
    counterAwa = 0;
    for i = allAwa
        counterAwa = counterAwa +1;
        load(allData(i).name, 'allCorr', 'allParameters' )
        allCorr = cell2mat(allCorr);
        allParametersArray = cell2mat(allParameters);
        for l = 1:length(allLambda)
            useLambda = allLambda(l);
            subplot(length(allLambda),3,3*l-2)
            if ndims(allParametersArray) ==3
                plot([allParametersArray(l,n,:).wavelength])
                allAwaWavelength(counterAwa,l,:) = squeeze([allParametersArray(l,n,:).wavelength]);
            else
                plot([allParametersArray(l,:).wavelength])
                allAwaWavelength(counterAwa,l,:) = squeeze([allParametersArray(l,:).wavelength]);
            end
            hold on
            if l ==1
                title(['Awake only experiments Lambda = ', num2str(useLambda)]);
            else
                title(['Lambda = ', num2str(useLambda)])
            end
        end
    end
    
    counterIso = 0;
    for i = allIso
        counterIso = counterIso +1;
        load(allData(i).name, 'allCorr', 'allParameters' )
        allCorr = cell2mat(allCorr);
        allParametersArray = cell2mat(allParameters);
        for l = 1:length(allLambda)
            useLambda = allLambda(l);
            subplot(length(allLambda),3,3*l-1)
            if ndims(allParametersArray) ==3
                plot([allParametersArray(l,n,:).wavelength])
                allIsoWavelength(counterIso,l,:) = squeeze([allParametersArray(l,n,:).wavelength]);
            else
                plot([allParametersArray(l,:).wavelength])
                allIsoWavelength(counterIso,l,:) = squeeze([allParametersArray(l,:).wavelength]);
            end
            hold on
            if l ==1
                title(['Iso only experiments Lambda = ', num2str(useLambda)]);
            else
                title(['Lambda = ', num2str(useLambda)])
            end
        end
    end
    
    counterKet = 0;
    for i = allKet
        counterKet = counterKet +1;
        load(allData(i).name, 'allCorr', 'allParameters' )
        allCorr = cell2mat(allCorr);
        allParametersArray = cell2mat(allParameters);
        for l = 1:length(allLambda)
            useLambda = allLambda(l);
            subplot(length(allLambda),3,3*l)
            if ndims(allParametersArray) ==3
                plot([allParametersArray(l,n,:).wavelength])
                allKetWavelength(counterKet,l,:) = squeeze([allParametersArray(l,n,:).wavelength]);
            else
                plot([allParametersArray(l,:).wavelength])
                allKetWavelength(counteKet,l,:) = squeeze([allParametersArray(l,:).wavelength]);
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

useL = 3

meanAwa = squeeze(nanmean(allAwaWavelength(:,useL,:),1));
jackMeanA = jackknife(@mean,squeeze(allAwaWavelength(:,useL,:)));
ubA = max(jackMeanA, [], 1);
lbA = min(jackMeanA, [], 1);
% stdAwa = squeeze(nanstd(allAwaWavelength(:,useL,:),0,1));
% ubA = meanAwa+ stdAwa*2;
% lbA = meanAwa- stdAwa*2;


meanIso = squeeze(nanmean(allIsoWavelength(:,useL,:),1));
jackMeanI = jackknife(@mean,squeeze(allIsoWavelength(:,useL,:)));
ubI = max(jackMeanI, [], 1);
lbI = min(jackMeanI, [], 1);
stdIso = squeeze(nanstd(allIsoWavelength(:,useL,:),0,1));
% ubI = meanIso+ stdIso*2;
% lbI = meanIso- stdIso*2;

meanKet = squeeze(nanmean(allKetWavelength(:,useL,:),1));
jackMeanK = jackknife(@mean,squeeze(allKetWavelength(:,useL,:)));
ubK = max(jackMeanK, [], 1);
lbK = min(jackMeanK, [], 1);
% stdKet = squeeze(nanstd(allKetWavelength(:,useL,:),0,1));
% ubK = meanKet+ stdKet*2;
% lbK = meanKet- stdKet*2;

figure(3)
subplot(2,1,2)
hold on
plot(meanAwa', 'r')
ciplot(lbA, ubA, [1:301], 'r')
plot(meanIso', 'm')
ciplot(lbI, ubI, [1:301], 'm')
plot(meanKet', 'c')
ciplot(lbK, ubK, [1:301], 'c')
plot([50, 50], [24,33], 'g')
%legend('Awake', 'Awake JK', 'Isoflurane', 'Iso JK', 'Ketamine', 'Ket JK')
legend('Awake', 'Awake CI', 'Isoflurane', 'Iso CI', 'Ketamine', 'Ket CI')
xlabel('time ms')
ylabel('wavelength')
title('Awake vs Iso vs Ket')





