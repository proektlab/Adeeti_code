if isunix
    dirIn = '/synology/adeeti/spatialParamWaves/Awake/';
    dirPic = '/synology/adeeti/spatialParamWaves/images/NeuroPatt/Awake/';
elseif ispc
    dirIn = 'Z:/adeeti/spatialParamWaves/Awake/';
    dirPic = 'Z:\adeeti\spatialParamWaves\images\NeuroPatt\Awake\';
end

fs = 1000;
testTime = 350;
baselineStart = 100;
epStart = 500;
allMice = [6, 9, 13];

%%
baselineTime= baselineStart:baselineStart+testTime;
epTime = epStart:epStart+testTime;

mkdir(dirPic)

cd(dirIn)
allData = dir('gab*.mat');
load('dataMatrixFlashes.mat')
%%
mouseID = 3; %1=GL6, 2=GL9, 3=GL13
a = 2; %1 = high iso, 2 = low iso, 3 = awake, 4 = ket

[isoHighExp, isoLowExp, emergExp, awaExp1, awaLastExp, ketExp] = ...
    findAnesArchatypeExp(dataMatrixFlashes, allMice(mouseID));

MFE = [isoHighExp, isoLowExp, awaLastExp, ketExp]
titleString = {'High Isoflurane', 'Low Isoflurane', 'Awake', 'Ketamine'};


%%

a = 3;
if isnan(MFE(a))
    disp(['No experiment for', titleString{a}]);
end

load(allData(MFE(a)).name, 'interp1Coh35', 'interp1BootCoh35', 'info')

epDataAvg = permute(interp1Coh35(epTime,:,:), [2,3,1]);
baselineDataAvg = permute(interp1Coh35(baselineTime,:,:), [2,3,1]);

epDataBoot = permute(interp1BootCoh35(:,epTime,:,:), [3,4,2,1]);
baselineDataBoot = permute(interp1BootCoh35(:,baselineTime,:,:), [3,4,2,1]);

% ff = figure('color', 'w', 'position', [440,113,560,685])
% for t =1:length(epTime)
%     imagesc(squeeze(epDataAvg(:,:,t)))
%     colorbar
%     set(gca, 'clim', [-10,10])
%     title(['Time = ', num2str(t)])
%     pause(0.01)
% end

NeuroPattGUI(epDataBoot, fs)

