%% fixing all GL exp to have neg number exp IDs
clear
clc
close all
%%
if isunix && ~ismac
    dataLoc = '/synology/';
    codeLoc = '/synology/code/';
elseif ispc
    dataLoc = 'Z:\';
    codeLoc = 'Z:\code\';
end

genDirAwa = [dataLoc, 'adeeti/ecog/iso_awake_VEPs/'];
dirGaborTesting = [dataLoc,'adeeti/spatialParamWaves/'];

allMiceAwa = [{'goodMice'}; {'maybeMice'}; {'badMice'}];

ident1Awa = '2019*';
ident2Awa = '2020*';

%%

for g = 3:length(allMiceAwa)
    genDirM = [genDirAwa, (allMiceAwa{g}), '/'];
    cd(genDirM)
    allDir = [dir('GL*');dir('IP*');dir('CB*')];
    
    if g ==1
        START_AT = 2;
    elseif g ==3
        START_AT = 1;
    end
    
    for d = START_AT:length(allDir)
        mouseID = allDir(d).name;
        
        dirIn = [genDirM, mouseID, '/'];
        cd(dirIn)
        load('dataMatrixFlashes.mat')

        allData = dir(ident1Awa);
        identifier = ident1Awa;
        
        if isempty(allData)
            allData = dir(ident2Awa);
            identifier = ident2Awa;
        end
        
        if contains(mouseID, 'GL')
            expIDNum = str2num(mouseID(3:end))
            expIDNum = -expIDNum
        elseif contains(mouseID, 'CB')
            expIDNum = str2num(mouseID(3:end))
        elseif contains(mouseID, 'IP')
            expIDNum = 0
        end
        
        for i = 1:size(dataMatrixFlashes,2)
            dataMatrixFlashes(i).exp = expIDNum;
        end
        save('dataMatrixFlashes.mat', 'dataMatrixFlashes')
        
        disp('Saving Raw data')
        for i = 1:length(allData)
            cd(dirIn)
            
            load(allData(i).name, 'info')
            info.exp = expIDNum;
            save(allData(i).name, 'info', '-append')
        end
        
        for i = 1:length(allData)    
            dirFILT = [dirIn,'FiltData/'];
            disp('Saving Filt data')
            if exist(dirFILT, 'dir') ==7
                cd(dirFILT)
                load([allData(i).name(1:end-4), 'wave.mat'], 'info')
                info.exp = expIDNum;
                save([allData(i).name(1:end-4), 'wave.mat'], 'info', '-append')
            end
        end
        
       for i = 1:length(allData)         
            dirWAVE = [dirIn,'Wavelets/'];
            disp('Saving wave data')
            if exist(dirWAVE, 'dir')==7
                cd(dirWAVE)
                load([allData(i).name(1:end-4), 'wave.mat'], 'info')
                info.exp = expIDNum;
                save([allData(i).name(1:end-4), 'wave.mat'], 'info', '-append')
            end
       end
            
%         for i = 1:length(allData)    
%             dirWCOH = [dirIn,'wCoh/'];
%             disp('Saving wCoh data')
%             if exist(dirWCOH, 'dir')==7
%                 cd(dirWCOH)
%                 load([allData(i).name(1:end-4), 'wave.mat'], 'info')
%                 info.exp = expIDNum;
%                 save([allData(i).name(1:end-4), 'wave.mat'], 'info', '-append')
%             end
%        end
        
        
    end
end

















