%% correcting unique series and index series data in awake animal s
clc
clear
close all

if isunix && ~ismac
    genDir = '/synology/adeeti/ecog/iso_awake_VEPs/';
    picsDir =  '/synology/adeeti/ecog/images/Iso_Awake_VEPs/';
    dropboxLocation = '/home/adeeti/Dropbox/ProektLab_code/Adeeti_code/'; %'C:\Users\adeeti\Dropbox\KelzLab\';
elseif ispc
    genDir = 'Z:\adeeti\ecog\iso_awake_VEPs\';
    picsDir =  'Z:\adeeti\ecog\images\Iso_Awake_VEPs\';
    dropboxLocation = 'C:\Users\adeeti\Dropbox\ProektLab_code\Adeeti_code\';
end

allMice = [{'goodMice'}; {'maybeMice'}];

cd(genDir)

ident1 = '2019*';
ident2 = '2020*';
stimIndex = [0, Inf];
%%
for g = 1:length(allMice)
    genDirM = [genDir, (allMice{g}), '/'];
    picsDirM = [picsDir, (allMice{g}), '/'];
    
    cd(genDirM)
    allDir = [dir('GL*'); dir('*IP2');dir('*CB3')];
    
    if g ==1
        startD = 2;
    else
        startD = 1;
    end
    
    for d = startD:length(allDir)
        cd([genDirM, allDir(d).name])
        mouseID = allDir(d).name;
        disp(mouseID)
        genPicsDir =  [picsDirM, mouseID, '/'];
        dirIn = [genDirM, mouseID, '/'];
        dirWAVE = [dirIn, 'Wavelets/'];
        dirFILT = [dirIn, 'FiltData/'];
        dirIPSC = [dirIn, 'IPSC/'];
        dirWCOH = [dirIn, 'wCoh/'];
        
        allData = dir(ident1);
        identifier = ident1;
        
        if isempty(allData)
            allData = dir(ident2);
            identifier = ident2;
        end
        

        for a = 1:length(allData)
            load(allData(a).name, 'indexSeries', 'uniqueSeries')
            if length(indexSeries)>100
                indexSeries(1) =2;
                uniqueSeries(2,:) = [Inf, Inf];
                disp('Saving timeseries')
                save([dirIn, allData(a).name], 'indexSeries', 'uniqueSeries', '-append')
                disp('Saving wavelets')
                save([dirWAVE, allData(a).name(1:end-4), 'wave.mat'], 'indexSeries', 'uniqueSeries', '-append')
                disp('Saving filtered data')
                save([dirFILT, allData(a).name(1:end-4), 'wave.mat'], 'indexSeries', 'uniqueSeries', '-append')
                if exist('dirIPSC')
                    disp('Saving IPSC')
                    save([dirIPSC, allData(a).name(1:end-4), 'wave.mat'], 'indexSeries', 'uniqueSeries', '-append')
                end
%                 if exist('dirWCOH')
%                     disp('Saving coherence')
%                     save([dirWCOH, allData(a).name(1:end-4), 'wave.mat'], 'indexSeries', 'uniqueSeries', '-append')
%                 end
                
            end
        end
        
    end
end


