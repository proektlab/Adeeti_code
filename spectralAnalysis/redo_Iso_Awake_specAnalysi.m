
genDir = '/synology/adeeti/ecog/iso_awake_VEPs/';

cd(genDir)

allDir = [dir('GL8*')];

ident1 = '2019*';
ident2 = '2020*';
stimIndex = [0, Inf];

for d = 1:length(allDir)
    cd([genDir, allDir(d).name])
    mouseID = allDir(d).name;
    genPicsDir =  ['/synology/adeeti/ecog/images/Iso_Awake_VEPs/', mouseID, '/'];
    dirIn = ['/synology/adeeti/ecog/iso_awake_VEPs/', mouseID, '/'];
    
    allData = dir(ident1);
    identifier = ident1;
    
    if isempty(allData)
        allData = dir(ident2);
        identifier = ident2;
    end
    
    
    %% wavelet analysis
%     clearvars -except d  genDir allDir ident1 ident2 dirIn identifier START_AT stimIndex genPicsDir mouseID
%     close all
%     dirPic1 = [genPicsDir, 'AverageSpec/'];
%     
%     dirWAVE = [dirIn, 'Wavelets/'];
%     USE_SNIPPITS = 1;
%     
%     waveletAnalysis
    
    %% Filter Data
    
    clearvars -except d  genDir allDir ident1 ident2 dirIn identifier START_AT stimIndex dirWAVE genPicsDir mouseID
    close all
    dirFILT = [dirIn, 'FiltData/'];
    
    lowBound = 4;
    highBound = 12;
    
    filterDataandHilbertSavingAll
    
    %% Coherence movies
    clc
    clearvars -except d genDir allDir ident1 ident2 dirIn identifier START_AT stimIndex dirWAVE dirFILT genPicsDir mouseID
    close all
    
    dirCoh35Movies = [genPicsDir, 'coher35MoviesOutlines/'];
    dropboxLocation = '/home/adeeti/Dropbox/ProektLab_code/Adeeti_code/'; %'C:\Users\adeeti\Dropbox\KelzLab\';
    
    fr = 35;
    moviesCoherenceSinglesOnly
    
end
