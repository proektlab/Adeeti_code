


%%




useIso = pcIso_comp;
useAwake1 = pcAwa_comp;
useEmerg = pcEmg_comp;

data1= [pcIso_comp(1:50,:);pcAwa_comp(1:50,:)];
ranInd= randsample(100,100);
data1 = data1(ranInd,:);

data2= [pcIso_comp(51:101,:);pcAwa_comp(51:101,:)];
ranInd= randsample(100,100);
data2 = data2(ranInd,:);

% useIso = isoLow_boot_DC;
% useAwake1 = awa1_boot_DC;
% useEmerg = slide_emergDC;

numTrain = 50;

[W, L_train, P_train, L_test, P_test, mixMatrix, targets, Y, ~, ~]= classifyAnesAwakeLDA(numTrain, data1, data2);

size(W)

figure
histogram(P_test)




%% 


random1 = rand(100,15);
random2 = rand(100,15);

numTrain = 50;

[W, L_train, P_train, L_test, P_test, mixMatrix, targets, Y, testMatrix, testTargets]= ...
    classifyAnesAwakeLDA(numTrain, random1, random2);

L_train
P_train

%%
thresh = 0.5;
undet_thresh = .20;


classLowIso = find(P_test(:,1)>thresh-undet_thresh);
realLowIso = find(testTargets ==1);
classAwake1 = find(P_test(:,2)>thresh-undet_thresh);
realAwake1 = find(testTargets ==2);

hitsLowIso = ismember(classLowIso, realLowIso);
hitLowIso_rate =  numel(find(hitsLowIso ==1))/numel(realLowIso);
falseNegLowIso = numel(find(hitsLowIso ==0))/numel(realLowIso);

hitsAwake1 = ismember(classAwake1, realAwake1);
hitAwake1_rate = numel(find(hitsAwake1 ==1))/numel(realAwake1);
falseNegAwake1 = numel(find(hitsAwake1 ==0))/numel(realAwake1);


  %% LDA to distingish high iso from low iso
        allLowIsoHit = [allLowIsoHit, hitLowIso_rate];
        allAwakeHit = [allAwakeHit, hitAwake1_rate];
        allLowIsoConHit = [allLowIsoConHit, hitLowIso_con_rate];
        allHighIsoConHit = [allHighIsoConHit, hitHighIso_con_rate];
        




%%

compIsoAwa(:,1) = allLowIsoHit;
compIsoAwa(:,2) = allAwakeHit;

compIsoCon(:,1) = allLowIsoConHit;
compIsoCon(:,2) = allHighIsoConHit;

figure 
boxplot(compIsoAwa(:,1:2),'Labels',{'Low Iso', 'Awake'})%, 'notch', 'on') 
xlabel('Behavioral state')

figure
boxplot(compIsoCon(:,1:2), 'Labels',{'Low Iso', 'High Iso'})%, 'notch', 'on') 
xlabel('Anes state')