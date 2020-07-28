function addingUniqueIndexSeries_infoDataMat(dirIn, identifier, stimIndex)
%% Adding Unique Series and Index Series to plexon data 

cd(dirIn)
allData = dir(identifier);
load('dataMatrixFlashes.mat');

for experiment = 1:length(allData)
    load(allData(experiment).name, 'info', 'uniqueSeries', 'indexSeries')
    y =  mode(indexSeries);
    info.stimIndex = uniqueSeries(y,:);
    dataMatrixFlashes(experiment).stimIndex = info.stimIndex;
    save(allData(experiment).name, 'info', '-append')
end

save('dataMatrixFlashes.mat', 'dataMatrixFlashes')
