
if isunix
    genDir = '/synology/adeeti/ecog/iso_awake_VEPs/';
    picsDir =  '/synology/adeeti/ecog/images/Iso_Awake_VEPs/';
elseif ispc
    genDir = 'Z:\adeeti\ecog\iso_awake_VEPs\';
    picsDir =  'Z:\adeeti\ecog\images\Iso_Awake_VEPs\';
end

allMice = [{'goodMice'}; {'maybeMice'}];

cd(genDir)


ident1 = '2019*';
ident2 = '2020*';
stimIndex = [0, Inf];
START_AT = 1;
fr = 35;
interpBy = [100, 1];
noiseBlack = [0,1];
if isunix
    dropboxLocation = '/home/adeeti/Dropbox/ProektLab_code/Adeeti_code/'; %'C:\Users\adeeti\Dropbox\KelzLab\';
elseif ispc
    dropboxLocation = 'C:\Users\adeeti\Dropbox\ProektLab_code\Adeeti_code\';
end

%%
for g = 2:length(allMice)
    genDirM = [genDir, (allMice{g}), '/'];
    picsDirM = [picsDir, (allMice{g}), '/'];
    
    cd(genDirM)
    allDir = [dir('GL*'); dir('*IP2');dir('*CB3')];
    
    if g ==2
        startD = 3;
    else
        startD = 1;
    end
    
    for d = startD:length(allDir)
        cd([genDirM, allDir(d).name])
        mouseID = allDir(d).name;
        disp(mouseID)
        genPicsDir =  [picsDirM, mouseID, '/'];
        dirIn = [genDirM, mouseID, '/'];
        dirFILT = [dirIn, 'FiltData/'];
        
        allData = dir(ident1);
        identifier = ident1;
        
        if isempty(allData)
            allData = dir(ident2);
            identifier = ident2;
        end
        
        clearvars -except d genDir genDirM allDir ident1 ident2 dirIn ...
            identifier START_AT stimIndex dirWAVE dirFILT genPicsDir ...
            mouseID picsDir picsDirM dropboxLocation stimIndex START_AT ...
            fr interpBy noiseBlack allMice g

        close all
        
        dirMovies = [genPicsDir, 'coher35Movies_blkNoise_noInt/'];

        if strcmpi(mouseID, 'GL10')
            START_AT =10
        else
            START_AT =1
            end
        moviesCoherenceSinglesOnly
        
    end
end