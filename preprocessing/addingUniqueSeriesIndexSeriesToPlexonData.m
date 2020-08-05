%% Adding Unique Series and Index Series to plexon data 

clear
close all

dirIn = '/data/adeeti/ecog/Rat_VEP_prop/';
identifier = '*mat';
allData = dir(identifier);

uniqueSeries = [0,inf];
%%
myIndex = [2, 3, 11];

for i = 1: length(allData) %myIndex
    load(allData(i).name, 'meanSubData', 'info')
    indexSeries = ones(size(meanSubData,2), 1);
    info.bregmaOffsetY = 0.5;
    info.bregmaOffsetX = 0.5;
    info.stimIndex = uniqueSeries;
 %   info.numberStim = 1;
   % info.Stim1 = 'flash';
  %  info.ecogChannels = [1:64];
   % info.forkChannels = {[65:(16-1)+65], [16+65:96]};
  %  info.forkPosition = [[1,6]; [1,7]];
    
   % info.forkName= 'A2x16-10mm-50-500-177';
    info.ECOGGridName = 'E64-500-20-60';
    save(allData(i).name, 'uniqueSeries', 'indexSeries', 'info', '-append')
end
%%
electStim = 0;
creatingBigAssMatrix

%% 

