function [BSTimepoints, BSPeriods] = makeBSper4fullBSuppexp(experimentName, meanSubFullTrace, expID)

BSTimepoints(1,1) = 1;
BSTimepoints(2,1) = size(meanSubFullTrace,2);

BSPeriods = {};

for i = 1:size(BSTimepoints, 2)
    BSPeriods{i} = meanSubFullTrace(:, BSTimepoints(1,i):BSTimepoints(2,i));
end

expID = expID + 1


save(experimentName, 'BSTimepoints', 'BSPeriods', '-append')