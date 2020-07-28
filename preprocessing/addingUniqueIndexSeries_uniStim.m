function addingUniqueIndexSeries_uniStim(dirIn, identifier, stimIndex, adj4arduino)
%% Adding Unique Series and Index Series to plexon data
if nargin <4
    adj4arduino =0;
end

cd(dirIn)
allData = dir(identifier);

for experiment = 1:length(allData)
    load(allData(experiment).name, 'dataSnippits', 'info')
    if contains(info.TypeOfTrial, 'base','IgnoreCase',true)
        continue
    end
    uniqueSeries = stimIndex;
    indexSeries = ones(size(dataSnippits,2), 1);
    if adj4arduino ==1
        if size(dataSnippits,2)>100
            indexSeries(1) =2;
            uniqueSeries(2,:) = [Inf, Inf];
        end
    end
    info.stimIndex = stimIndex;
    save(allData(experiment).name, 'uniqueSeries', 'indexSeries', 'info', '-append')
end
