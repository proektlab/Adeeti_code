%% To perform spectral analysis on all data

%% entering in data
genDir = '/synology/adeeti/ecog/iso_awake_VEPs/';

cd(genDir)

allDir = [dir('*GL1'); dir('*GL10'); dir('*GL3')];

ident1 = '2019*';
ident2 = '2020*';
stimIndex = [0, Inf];
START_AT = 1;
driveLocation = '/home/adeeti/Dropbox/';

%%

for d = 1:length(allDir)
    cd([genDir, allDir(d).name])
    mouseID = allDir(d).name;
    mouseECoGFolder = '/synology/adeeti/ecog/iso_awake_VEPs/';
    genPicsDir =  ['/synology/adeeti/ecog/images/Iso_Awake_VEPs/', mouseID, '/'];
    dirIn = [mouseECoGFolder, mouseID, '/'];
    disp(['Analyzing mouse ', mouseID]) 
    allData = dir(ident1);
    identifier = ident1;
    
    if isempty(allData)
        allData = dir(ident2);
        identifier = ident2;
    end
    
    
    %% artifact removal and preprocessing
    dirPic = [genPicsDir, 'preprocessing/'];
    dirOut = dirIn;
    
    MAXSTIM = 1;
    ADD_MAN_NOISE_CHANNELS = 0;
    ANALYZE_IND = 0;
    REMOVE_STIM_ARTIFACT = 1;
    
    PicByTrialType = 0;
    PicByAnesType = 1;
    PicByAnesAndTrial = 0;
    
    removingArtifactAndInterpolating
    
    %% finding latency
    clearvars -except d  genDir allDir ident1 ident2 dirIn identifier START_AT stimIndex genPicsDir mouseID driveLocation stimIndex
    
    findLatency
    
    %% Wavelets and making average spec pictures
    clearvars -except d  genDir allDir ident1 ident2 dirIn identifier START_AT stimIndex genPicsDir mouseID
    close all
    dirPic1 = [genPicsDir, 'AverageSpec/'];
    
    dirWAVE = [dirIn, 'Wavelets/'];
    
    USE_SNIPPITS = 1;
    
    waveletAnalysis
    
    %% Filter Data at gamma and delta
    
    clearvars -except d genDir allDir ident1 ident2 dirIn identifier START_AT stimIndex dirWAVE genPicsDir mouseID
    close all
    dirWAVE =  [dirIn, 'Wavelets/'];
    dirFILT = [dirIn, 'FiltData/'];
    
    lowBound = 4;
    highBound = 12;
    filterDataandHilbertSavingAll
    
    lowBound = 20;
    highBound = 80;
    filterDataandHilbertSavingAll
    
    %% ITPC
    
    clearvars -except d genDir allDir ident1 ident2 dirIn identifier START_AT stimIndex dirWAVE dirFILT genPicsDir mouseID
    close all
    
    dirPicITPC = [genPicsDir, 'localITPC/'];
    useStimIndex = 0;
    useNumStim = 1;
    
    lowestLatVariable = 'lowLat';
    stimIndex = [0, Inf]; %if want all, stimIndex = matStimIndex; % if want
    %all uniStimIndexes/multiStimIndexes, use [uniStimIndex, multiStimIndex] =
    %findUniMutliStimIndex(matStimIndex), [stimIndex, ~] = findUniMutliStimIndex(matStimIndex)
    
    numStim = 1;
    
    ITPC_for_all_exp
    
    %% delta coherence movies 
        clc
    clearvars -except d genDir allDir ident1 ident2 dirIn identifier START_AT stimIndex dirWAVE dirFILT genPicsDir mouseID
    close all
    
    dirCoh35Movies = [genPicsDir, 'coher5MoviesOutlines/'];
    dropboxLocation = '/home/adeeti/Dropbox/ProektLab_code/Adeeti_code/'; %'C:\Users\adeeti\Dropbox\KelzLab\';
    
    fr = 5;
    moviesCoherenceSinglesOnly
    
    %% gamma coherence movies
    
       clc
    clearvars -except d genDir allDir ident1 ident2 dirIn identifier START_AT stimIndex dirWAVE dirFILT genPicsDir mouseID
    close all
    
    dirCoh35Movies = [genPicsDir, 'coher5MoviesOutlines/'];
    dropboxLocation = '/home/adeeti/Dropbox/ProektLab_code/Adeeti_code/'; %'C:\Users\adeeti\Dropbox\KelzLab\';
    
    fr = 35;
    moviesCoherenceSinglesOnly

end
