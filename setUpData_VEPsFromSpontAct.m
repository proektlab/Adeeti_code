
gendir = '\\192.168.1.206\LabData';


dirIn = [ gendir, '\adeeti\ecog\matIsoPropMultiStimVIS_ONLY_\flashTrials\'];
dirOut = 'C:\Users\adeeti\Dropbox\ProektLab_code\machinelearning\';
dirOut = 'F:\Dropbox\ProektLab_code\MachineLearning\';
identifer = '2018*mat';
cd(dirIn)
allData = dir(identifer);
load('dataMatrixFlashesVIS_ONLY.mat')

spontAct = [1:1001];
VEP = [1030:1300];

inputs = [];
outputs = [];
IDs = [];

inputsOneExp = [];
outputsOneExp = [];
IDsOneExp = [];

% counter = 1;
% for i = 1:length(allData)-4
%     load(allData(i).name, 'meanSubData', 'info', 'uniqueSeries', 'indexSeries')
%     disp(num2str(i));
%     [indices] = getStimIndices([0 inf], indexSeries, uniqueSeries);
%     useData = squeeze(meanSubData(info.lowLat,indices,:));
%     for j = 1:size(useData,1)
%         inputs(counter,:) = useData(j,spontAct);
%         outputs(counter,:) = useData(j,VEP);
%         IDs(counter) = i; 
%         counter = counter +1;
%     end
% end

useEXP = 1;
drugType = 'iso';
conc = [1.2];
stimIndex = [0, Inf];

[MFE]=findMyExpMulti(dataMatrixFlashesVIS_ONLY, useEXP, drugType, conc, stimIndex);

counter = 1;
for i = MFE
    load(dataMatrixFlashesVIS_ONLY(i).expName, 'meanSubData', 'info', 'uniqueSeries', 'indexSeries')
    disp(num2str(i));
    [indices] = getStimIndices([0 inf], indexSeries, uniqueSeries);
    useData = squeeze(meanSubData(info.lowLat,indices,:));
    for j = 1:size(useData,1)
        inputsOneExp(counter,:) = useData(j,spontAct);
        outputsOneExp(counter,:) = useData(j,VEP);
        IDsOneExp(counter) = i; 
        counter = counter +1;
    end
end

inputs = inputsOneExp;
outputs = outputsOneExp;
IDs = IDsOneExp;


% save([dirOut,'VEPs_IsoProp.mat'], 'inputs', 'outputs', 'IDs')
save([dirOut,'SingleEXP_VEPs_IsoProp.mat'], 'inputs', 'outputs', 'IDs')

