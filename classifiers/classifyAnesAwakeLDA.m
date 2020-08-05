function [W, L_train, P_train, L_test, P_test, mixMatrix, targets, Y_1, Y_2, allTest, testTargets]= classifyAnesAwakeLDA(num2train, useData1, useData2, useData3, useData4)
% [W, L_train, P_train, mixMatrix, targets, Y]= classifyAnesAwakeLDA(useData1, useData2, num2train)

Y_1= randsample(size(useData1,1), num2train);
Y_2= randsample(size(useData2,1), num2train);

trainData1 = useData1(Y_1,:);
trainData2 =  useData2(Y_2,:);

mixMatrix =[trainData1; trainData2];
targets = [ones(size(trainData1,1),1); [ones(size(trainData2,1),1)+1]];

if exist('useData3')
    Y_3= randsample(size(useData3,1), num2train);
    trainData3 =  useData3(Y_3,:);
    mixMatrix = [mixMatrix; trainData3];
    targets = [targets;[ones(size(trainData3,1),1)+2]];
end


if exist('useData4')
    Y_4= randsample(size(useData4,1), num2train);
    trainData4 =  useData4(Y_4,:);
    mixMatrix = [mixMatrix; trainData4];
    targets = [targets; [ones(size(trainData4,1),1)+3]];
end

W = LDA(mixMatrix,targets);


%% project train data on LDA
L_train = [ones(length(targets),1) mixMatrix]*W';

P_train = exp(L_train) ./ repmat(sum(exp(L_train),2),[1 size(W,1)]);

if size(W,1)<3
    P_train(:,3) = zeros(size(P_train,1),1);
end

%% giving back the test data (what was not trained on)

testTr_1 = [1:size(useData1,1)];
testTr_1(Y_1) = [];

testTr_2 = [1:size(useData2,1)];
testTr_2(Y_2) = [];

testData1 = useData1(testTr_1,:);
testData2 =  useData2(testTr_2,:);
allTest = [testData1; testData2];
testTargets = [ones(size(testData1,1),1); [ones(size(testData2,1),1)+1]];


if exist('useData3')
    testTr_3 = [1:size(useData3,1)];
    testTr_3(Y_3) = [];
    testData3 =  useData3(testTr_3,:);
    allTest = [allTest; testData3];
    targets = [targets;[ones(size(testData3,1),1)+2]];
end

if exist('useData4')
    testTr_4 = [1:size(useData4,1)];
    testTr_4(Y_4) = [];
    testData4 =  useData4(testTr_4,:);
    allTest = [allTest; testData4];
    targets = [targets;[ones(size(testData4,1),1)+3]];
end

L_test = [ones(length(allTest),1) allTest]*W';

P_test = exp(L_test) ./ repmat(sum(exp(L_test),2),[1 2]);

if ~exist('useData3')||~exist('useData4')
    P_test(:,3) = zeros(size(P_test,1),1);
end


