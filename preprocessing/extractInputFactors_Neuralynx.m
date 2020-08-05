
directory = '/data/adeeti/ecog/raw2018IsoLED/';
cd(directory)

allData= dir('2018*');

inv1 = cell(1, length(allData));
inv33 = cell(1, length(allData));

inR1 = nan(1, length(allData));
inR33 = nan(1, length(allData));

factor1 = nan(1, length(allData));
factor33 = nan(1, length(allData));

for i = 1:length(allData)
    cd([directory, allData(i).name])
    load('CSC1.mat', 'blah')
    inv1{i} = blah{22}(16:end);
    stupidRange = regexp(blah{21},['[.\d]+'],'match');
    stupidRange = str2num(stupidRange{1});
    inR1(i) =stupidRange;
    stupidFactor = regexp(blah{16},['[.\d]+'],'match');
    stupidFactor = str2num(stupidFactor{1});
    factor1(i)  = stupidFactor;
    
    load('CSC33.mat', 'blah')
    inv33{i} = blah{22}(16:end);
    stupidRange = regexp(blah{21},['[.\d]+'],'match');
    stupidRange = str2num(stupidRange{1});
    inR33(i) =stupidRange;
    stupidFactor = regexp(blah{16},['[.\d]+'],'match');
    stupidFactor = str2num(stupidFactor{1});
    factor33(i)  = stupidFactor;
end

    
    %%
    
    inRConsistant = nan(1, length(allData));
    invConsistant = nan(1, length(allData));
    factorConsistant = nan(1, length(allData));
    
    for i = 1:length(allData)
        invConsistant(i)= strcmpi(inv1{i}, inv33{i}); %1 means consistant accross boards and 0 means not consistant accross boards 
        factorConsistant(i) = factor1(i) - factor33(i); % 0 means that consistant factor accross experiments
        inRConsistant(i) = inR1(i) - inR33(i); % 0 means that consistant factor accross experiments
    end
    
    %%
    
    inv1True = nan(1, length(allData));
    inv33True = nan(1, length(allData));
  
    for i = 1:length(allData) 
        inv1True(i)= strcmpi(inv1{i},'true');
        inv33True(i) =  strcmpi(inv33{i}, 'true');
    end
    
    find(inv1True)
    
    %%

    
directory = '/data/adeeti/ecog/rawFlashesJanMar2017/';
cd(directory)

allData= dir('2017*');
    
invAll = nan(1, 64);
inRAll = nan(1,64);
factorAll = nan(1,64);

cd([directory, allData(25).name])

inconsitentInv1 = [];
inconsitentInv2 = [];
inconsitentR1 = [];
inconsitentR2 = [];
inconsitentFactor1 = [];
inconsitentFactor2 = [];

    
for i = 17%:length(allData)
    cd([directory, allData(i).name])
    
    for j = 1:64
        load(['CSC', num2str(j), '.mat'], 'blah')

        invAll(j) = strcmpi(blah{22}(16:end), 'true');

        stupidRange = regexp(blah{21},['[.\d]+'],'match');
        stupidRange = str2num(stupidRange{1});
        inRAll(j) =stupidRange;

        stupidFactor = regexp(blah{16},['[.\d]+'],'match');
        stupidFactor = str2num(stupidFactor{1});
        factorAll(j)  = stupidFactor;
    end
    
    
    inconsitentInv1 = [inconsitentInv1, length(unique(invAll(1:32))) ~= 1];
    inconsitentInv2 = [inconsitentInv2, length(unique(invAll(33:64))) ~= 1];
    inconsitentR1 = [inconsitentR1, length(unique(inRAll(1:32))) ~= 1];
    inconsitentR2 = [inconsitentR2, length(unique(inRAll(33:64))) ~= 1];
    inconsitentFactor1 = [inconsitentFactor1, length(unique(factorAll(1:32))) ~= 1];
    inconsitentFactor2 = [inconsitentFactor2, length(unique(factorAll(33:64))) ~= 1];
end

%%


