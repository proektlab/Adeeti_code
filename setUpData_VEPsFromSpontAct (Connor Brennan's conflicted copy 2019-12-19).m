

dirIn = 'Z:\adeeti\ecog\matIsoPropMultiStimVIS_ONLY_\flashTrials\';
dirOut = 'C:\Users\adeeti\Dropbox\ProektLab_code\machinelearning\';
identifer = '2018*mat';

allData = dir(identifer);

spontAct = [1:1001];
VEP = [1030:1300];

inputs = [];
outputs = [];
IDs = [];

counter = 1;
for i = 1:length(allData)-4
    load(allData(i).name, 'meanSubData', 'info', 'uniqueSeries', 'indexSeries')
    disp(num2str(i));
    [indices] = getStimIndices([0 inf], indexSeries, uniqueSeries);
    useData = squeeze(meanSubData(info.lowLat,indices,:));
    for j = 1:size(useData,1)
        inputs(counter,:) = useData(j,spontAct);
        outputs(counter,:) = useData(j,VEP);
        IDs(counter) = i; 
        counter = counter +1;
    end
end


save([dirOut,'VEPs_IsoProp.mat'], 'inputs', 'outputs', 'IDs')