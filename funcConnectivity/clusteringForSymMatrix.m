displayFreq = 20;
displayTime = 1200;

connectivity = eval(['ISPC' num2str(displayFreq) '(:,:,' num2str(displayTime) ')']);
connectivity(isnan(connectivity)) = 0;
for i = 1:size(connectivity,1)
    if (connectivity(i,i) == 0)
        for j = 1:size(connectivity,2)
            if (connectivity(j,j) == 0)
                connectivity(i,j) = 1;
                connectivity(j,i) = 1;
            end
        end
    end
end


communities = modularity_dir(connectivity, 1.1);

neuronCounts = [];
for i = 1:max(communities)
    neuronCounts(i) = numel(find(communities == i));
end
[sortedCounts, countIndicies] = sort(neuronCounts);

for i = 1:max(communities)
    communities(communities == countIndicies(i)) = i + size(connectivity,1);
end
communities = communities - size(connectivity,1);

[communityIDs, indicies] = sort(communities);

sortedConnectivity = connectivity(indicies,indicies);

PlotOnECoG(communities, info, 3)
title(['Spatial coherece clusters ' num2str(Freq(displayFreq)) 'Hz ' num2str(displayTime) 'ms']);