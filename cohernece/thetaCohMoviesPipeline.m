
if isunix 
    genDir = '/synology/adeeti/ecog/iso_awake_VEPs/';
    picsDir =  '/synology/adeeti/ecog/images/Iso_Awake_VEPs/';
elseif ispc
    genDir = 'Z:\adeeti\ecog\iso_awake_VEPs\';
    picsDir =  'Z:\adeeti\ecog\images\Iso_Awake_VEPs\';
end

cd(genDir)

allDir = [dir('*CB3')];

ident1 = '2019*';
ident2 = '2020*';
stimIndex = [0, Inf];
START_AT = 1;

%%

for d = 1:length(allDir)
    cd([genDir, allDir(d).name])
    mouseID = allDir(d).name;
    genPicsDir =  [picsDir, mouseID, '/'];
    dirIn = [genDir, mouseID, '/'];
    
    allData = dir(ident1);
    identifier = ident1;
    
    if isempty(allData)
        allData = dir(ident2);
        identifier = ident2;
    end
    
    %% Filter Data
    
%     clearvars -except d  genDir allDir ident1 ident2 dirIn identifier picsDir
%     START_AT stimIndex dirWAVE genPicsDir mouseID pics
%     close all

     dirWAVE = [dirIn, 'Wavelets/'];
     dirFILT = [dirIn, 'FiltData/'];
%   

    lowBound = 4;
    highBound = 12;
    
    filterDataandHilbertSavingAll

    
    %% Coherence movies
    clc
    clearvars -except d genDir allDir ident1 ident2 dirIn identifier START_AT stimIndex dirWAVE dirFILT genPicsDir mouseID picsDir
    close all
    
    dirCoh35Movies = [genPicsDir, 'coher5MoviesOutlines/'];
    if isunix
        dropboxLocation = '/home/adeeti/Dropbox/ProektLab_code/Adeeti_code/'; %'C:\Users\adeeti\Dropbox\KelzLab\';
    elseif ispc
        dropboxLocation = 'C:\Users\adeeti\Dropbox\ProektLab_code\Adeeti_code\';
    end
   
    fr = 5;
    START_AT = 1;

    moviesCoherenceSinglesOnly
    
end
