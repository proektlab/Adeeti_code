function [W, L_train, P_train, L_test, P_test, mixMatrix, targets, Y, allTest, testTargets]= classifyAnesAwakeLDA(num2train, useData1, useData2, useData3, useData4)
% [W, L_train, P_train, mixMatrix, targets, Y]= classifyAnesAwakeLDA(useData1, useData2, num2train)

Y= randsample(size(useData1,1), num2train);

trainData1 = useData1(Y,:);
trainData2 =  useData2(Y,:);

mixMatrix =[trainData1; trainData2];
targets = [ones(size(trainData1,1),1); [ones(size(trainData2,1),1)+1]];

if exist('useData3')
    trainData3 =  useData3(Y,:);
    mixMatrix = [mixMatrix; trainData3];
    targets = [targets;[ones(size(trainData3,1),1)+2]];
end


if exist('useData4')
    trainData4 =  useData4(Y,:);
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

testTr = [1:size(useData1,1)];
testTr(Y) = [];

testData1 = useData1(testTr,:);
testData2 =  useData2(testTr,:);
allTest = [testData1; testData2];
testTargets = [ones(size(testData1,1),1); [ones(size(testData2,1),1)+1]];


if exist('useData3')
    testData3 =  useData3(testTr,:);
    allTest = [allTest; testData3];
    targets = [targets;[ones(size(testData3,1),1)+2]];
end

if exist('useData4')
    testData4 =  useData4(testTr,:);
    allTest = [allTest; testData4];
    targets = [targets;[ones(size(testData4,1),1)+3]];
end

L_test = [ones(length(allTest),1) allTest]*W';

P_test = exp(L_test) ./ repmat(sum(exp(L_test),2),[1 2]);

if ~exist('useData3')||~exist('useData4')
    P_test(:,3) = zeros(size(P_test,1),1);
end


