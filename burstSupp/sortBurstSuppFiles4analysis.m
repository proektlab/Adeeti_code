function sortBurstSuppFiles4analysis(dirIn, identifier, dirIsoFlash, dirIsoBaseline, isoThres)
% sortBurstSuppFiles4analysis(dirIn, identifier, dirIsoFlash, dirIsoBaseline)

if nargin<5
    isoThres = 1;
end

cd(dirIn)
allData = dir(identifier);

for i = 1:length(allData)
    load(allData(i).name, 'info')
    if contains(info.TypeOfTrial, 'baseline', 'IgnoreCase', true) && info.AnesLevel >= isoThres
           expName = allData(i).name;
          % system(['copy ',dirIn, expName, ' ', dirIsoBaseline, expName])
          copyfile([dirIn,expName], [dirIsoBaseline, expName])
         % load([dirIsoBaseline,'dataMatrixFlashes.mat'])
         % [dataMatrixFlashes] = adding2bigAssmatrix(dirIsoBaseline, dataMatrixFlashes, info)
    end
     if contains(info.TypeOfTrial, 'flash', 'IgnoreCase', true) && info.AnesLevel >= isoThres
           expName = allData(i).name;
        %   system(['copy ',dirIn, expName, ' ', dirIsoFlash, expName])
        copyfile([dirIn,expName], [dirIsoFlash, expName])
        load([dirIsoFlash,'dataMatrixFlashes.mat'])
        [dataMatrixFlashes] = adding2bigAssmatrix(dirIsoFlash, dataMatrixFlashes, info)
     end
end
