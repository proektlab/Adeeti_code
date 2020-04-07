%% fixing GL8 and rerunning some analysis on it

clear
clc
close all

if ispc
    dirIn = 'Z:\adeeti\ecog\iso_awake_VEPs\GL8\';
    dropboxLocation = 'C:\Users\adeeti\Dropbox\ProektLab_code\Adeeti_code\';
    genPicsDir =  'Z:\adeeti\ecog\images\Iso_Awake_VEPs\GL8\';
elseif isunix
    dirIn = '/synology/adeeti/ecog/iso_awake_VEPs/GL8/';
    dropboxLocation = '/home/adeeti/Dropbox/ProektLab_code/Adeeti_code/'; %'C:\Users\adeeti\Dropbox\KelzLab\';
    genPicsDir =  '/synology/adeeti/ecog/images/Iso_Awake_VEPs/GL8/';
end


identifier = '2019*.mat';
dirWAVE = [dirIn, 'Wavelets/'];
dirFILT = [dirIn, 'FiltData/'];
dirCoh = [dirIn, 'wCoh/'];
dirIPSC = [dirIn, 'IPSC/'];


cd(dirIn)
allData = dir(identifier);

% for i = 1:length(allData)
%     cd(dirIn)
%     load(allData(i).name, 'info')
%     disp(['Experiment info ', num2str(i)])
%     
%     %% saving info in the right places
%     if i== 1
%         disp('Saving IPSC')
%         save([dirIPSC, allData(i).name(1:end-4), 'wave.mat'], 'info', '-append')
%     else
%         disp('Saving wavlet')
%         save([dirWAVE, allData(i).name(1:end-4), 'wave.mat'], 'info', '-append')
%         disp('Saving filtdata')
%         save([dirFILT, allData(i).name(1:end-4), 'wave.mat'], 'info', '-append')
%         disp('Saving IPSC')
%         save([dirIPSC, allData(i).name(1:end-4), 'wave.mat'], 'info', '-append')
%     end
%     
%     
%     
%     %     disp('Saving wCoh')
%     %     save([dirCoh, allData(i).name(1:end-4), 'wave.mat'], 'info', '-append')
%     %
%     %
% end

stimIndex = [0, Inf];
START_AT = 1;

for fr = [5, 35]
    if fr == 5
        dirMovies = [genPicsDir, 'coher5MoviesOutlines/'];
        interpBy = 100;
        noiseBlack = 0;
        moviesCoherenceSinglesOnly
    elseif fr ==35
        interpBy = 100;
        noiseBlack = 0;
        dirMovies = [genPicsDir, 'coher35MoviesOutlines/'];
        moviesCoherenceSinglesOnly

        dirMovies = [genPicsDir, 'coher35Movies_blkNoise_noInt/'];
        interpBy = 1;
        noiseBlack = 1;
        moviesCoherenceSinglesOnly
    end
end