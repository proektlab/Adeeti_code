%% finding all V1

clc
clear
close all

set(0,'defaultfigurecolor',[1 1 1])

dirAwake = '/synology/adeeti/ecog/iso_awake_VEPs/'; %'Z:\adeeti\ecog\iso_awake_VEPs\GL_early\';


cd(dirAwake)
allDir = [dir('IP*'); dir('GL*')];

ident1 = '2019*';
ident2 = '2020*';

allV1 = [];
allLat = [];
allIso = [];
allAwake = [];
allKet = [];

allCounter = 1;
isoCounter = 1;
awaCounter = 1;
ketCounter = 1;

for d = 1:length(allDir)
    cd([dirAwake, allDir(d).name])
    mouseID = allDir(d).name;
    genPicsDir =  ['/synology/adeeti/ecog/images/Iso_Awake_VEPs/', mouseID, '/'];
    dirIn = ['/synology/adeeti/ecog/iso_awake_VEPs/', mouseID, '/'];
    
    allData = dir(ident1);
    identifier = ident1;
    
    if isempty(allData)
        allData = dir(ident2);
        identifier = ident2;
    end
    
    for a = 1:length(allData)
        load(allData(a).name, 'info', 'latency')
        if a ==1
            allV1(d) = info.lowLat;
        end
        allLat(allCounter,:) = latency;
        allCounter = allCounter +1;
        
        if contains(info.AnesType, 'iso', 'IgnoreCase', true)
            allIso(isoCounter,:) = latency;
            isoCounter = isoCounter +1;
        elseif contains(info.AnesType, 'awa', 'IgnoreCase', true)
            allAwake(awaCounter,:) = latency;
            awaCounter = awaCounter +1;
        elseif contains(info.AnesType, 'ket', 'IgnoreCase', true)
            allKet(ketCounter,:) = latency;
            ketCounter = ketCounter +1;
        end
    end
end



%%

figure 

histogram(allAwake, 80)
hold on 
histogram(allIso, 80)
histogram(allKet, 60)


%%

stimIndex = [0 Inf];
allV1Lat = 22;


for d = 1:length(allDir)
    cd([dirAwake, allDir(d).name])
    mouseID = allDir(d).name;
    dirIn = ['/synology/adeeti/ecog/iso_awake_VEPs/', mouseID, '/'];
    
    allData = dir(ident1);
    identifier = ident1;
    
    if isempty(allData)
        allData = dir(ident2);
        identifier = ident2;
    end

[allV1, onsetMat] = V1forEachMouse(1, 0, stimIndex, 1, 'lowLat', allV1Lat, 1);

end

%%

for d = 1:length(allDir)
    cd([dirAwake, allDir(d).name])
    mouseID = allDir(d).name;
    genPicsDir =  ['/synology/adeeti/ecog/images/Iso_Awake_VEPs/', mouseID, '/'];
    dirIn = ['/synology/adeeti/ecog/iso_awake_VEPs/', mouseID, '/'];
    
    allData = dir(ident1);
    identifier = ident1;
    
    if isempty(allData)
        allData = dir(ident2);
        identifier = ident2;
    end
    
    for a = 1:length(allData)
        load(allData(a).name, 'info', 'latency')
        if a ==1
            allV1(d) = info.lowLat;
        end
    end
end

allV1


%% seems like GL3, GL1, and GL24 have edge effects 
