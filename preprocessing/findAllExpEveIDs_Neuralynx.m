function [allIDs] = findAllExpEveIDs(directory, identifier)
cd(directory)

allData = dir(identifier);

allIDs = [];

for i = 1:length(allData)
    cd(allData(i).name)
    load( 'Events.mat')
    x = unique(eveID); 
    allIDs = [allIDs; x];
    cd(directory)
end

allIDs = unique(allIDs);
end

