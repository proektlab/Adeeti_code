dirInGen = 'Z:\adeeti\JenniferHelen\';
expIdentifier = '*20*.mat'; %all the experiemnts are done in the during 2017-2020 and have the .mat ending
dirInExp = 'rats_BS_grid_iso'; % this comes from the list of experiments that we have
dirIn = [dirInGen, dirInExp]; %this created the full path
cd(dirIn);

allData = dir(expIdentifier);

allData(3) = []; %remove rat data that isn't completed 
allData(1) = [];

counter = 1;

ratLegendNames = [];
ratBurstSep = {}; %burst lengths for each mouse/rat
ratSupSep = {}; %sup legnths for each mouse/rat
ratBurstNums = []; %number of bursts for each mouse/rat
ratSupNums =[];%number of sups for each mouse/rat
ratTotalBSLengths = [];

for i = 1:numel(allData) %for each dataset, get data from each thing
    experimentName = allData(i).name; 
    load(experimentName, 'info', 'correctPeriodLengths')
    allBurstLens = [];
    allSupLens = [];
    numberOfBursts = 0;
    numberofSups = 0;
    totalBS = 0;

    if(exist('correctPeriodLengths', 'var')) %make sure pipeline was run
        for j = 1:numel(correctPeriodLengths) %for each bs section
            allBurstLens = [allBurstLens, correctPeriodLengths{j}.burst];  %add up all the burst or sup 
            numberOfBursts = numel(allBurstLens);
            
            allSupLens = [allSupLens, correctPeriodLengths{j}.sup];  
            numberOfSups = numel(allSupLens);
            
            totalBS = totalBS + correctPeriodLengths{j}.bsSegment;
        end
        
        ratTotalBSLengths(counter) = totalBS;
        ratLegendNames{counter} = experimentName; %add current experiment to counter
       
        
        ratBurstSep{counter} = allBurstLens;
        ratSupSep{counter} = allSupLens;
        ratBurstNums(counter) = numberOfBursts;
        ratSupNums(counter) = numberOfSups;
        
        counter = counter + 1 ;
    end
    
   clear correctPeriodLengths
end


%% figure stuff

figure
hold on
figure
hold on
figure(1)

logBurstEdges = 0:.16:4; %set the edges
burstEdges = 500:400:10000;
logSupEdges = 0:.25:5;
supEdges = 500:1000:40000;

for i = 1:numel(ratLegendNames)
        figure(1)
        subplot(2, 1, 1); %subplot for log plot of sup lengths 
        histogram(log10(ratSupSep{i}), logSupEdges, 'Normalization','probability')
        
        hold on
        
        subplot(2,1,2) %subplot for lin plot of sup lengths
        histogram(ratSupSep{i}, supEdges, 'Normalization','probability')
        
        hold on
        
        figure(2)
        subplot(2, 1, 1); %subplot for log plot of burst lengths
        histogram(log10(ratBurstSep{i}), logBurstEdges, 'Normalization','probability')
        
        hold on
        
        subplot(2,1,2) %subplot for lin plot of burst lengths
        histogram(ratBurstSep{i}, burstEdges, 'Normalization','probability')
        
        hold on
end

figure(1) %title figures

sgtitle('Rat Suppression Length p = 6.6935e-81')

subplot(2, 1, 1)
xlabel('Suppresion Time (log scale)')
ylabel('Probability')

subplot(2, 1, 2)
xlabel('Suppresion Time (ms)')
ylabel('Probability')
legend(ratLegendNames);


figure(2)

sgtitle('Rat Burst Length p = 5.8481e-52')

subplot(2, 1, 1)
xlabel('Burst Time (log scale)')
ylabel('Probability')

subplot(2, 1, 2)
xlabel('Burst Time (ms)')
ylabel('Probability')
legend(ratLegendNames);


hold off


%% kruskal wallis

kwArray = [] %array for kruskal wallis

arraySize = 181 %maximum size, so the rest can be filled with nans

for i = 1:numel(ratBurstSep)
    kwArray(i, :) = [ratBurstSep{i}, NaN(1, arraySize-numel(ratBurstSep{i}))];
end

kruskalwallis(kwArray', ratLegendNames)

title('kruskal wallis of mouse bursts')

%% whoops the p value was really low, guess we need to run a ranksum

ranksumPs = NaN(numel(ratBurstSep)); %all the p values of the comparisons
 
for i = 1:size(kwArray, 1) %for each dataset
    for j = i+1:size(kwArray, 1) %compare to the other datasets
        ranksumPs(i,j) = ranksum(kwArray(i,:), kwArray(j,:)); %and run a ranksum between them
    end
end

format shortG

ranksumPs

%% more kruskal wallis

kwArray = []

arraySize = 767

for i = 1:numel(ratSupSep)
    kwArray(i, :) = [ratSupSep{i}, NaN(1, arraySize-numel(ratSupSep{i}))];
end

kruskalwallis(kwArray', ratLegendNames)

title('kruskal wallis of mouse sups')


%% have some more stats

disp("the mean length of burst is " + mean(cell2mat(ratBurstSep)) + " ms") 
disp("the std length of burst is " + std(cell2mat(ratBurstSep))+ " ms")
disp("the mean length of sups is " + mean(cell2mat(ratSupSep))+ " ms") 
disp("the std length of sups is " + std(cell2mat(ratSupSep))+ " ms") 


disp("the mean number of burst is " + mean(ratBurstNums./ratTotalBSLengths*1000) + " bursts per second") 
disp("the std number of burst is " + std(ratBurstNums./ratTotalBSLengths*1000)+ " bursts per second")
disp("the mean number of sups is " + mean(ratSupNums./ratTotalBSLengths*1000)+ " sups per second") 
disp("the std number of sups is " + std(ratSupNums./ratTotalBSLengths*1000)+ " sups per second") 

%% compare mice and rats

figure() %plot histograms of mice and rats over each other

histogram(cell2mat(mouseBurstSep), burstEdges, 'Normalization','probability');

hold on

histogram(cell2mat(ratBurstSep), burstEdges, 'Normalization','probability');

title("Rat and Mouse Burst Times p = 1.1828e-05");
xlabel("Burst Time (ms)");
ylabel("Probability");

legend("Mice", "Rats")

%% sup figure
figure()

histogram(cell2mat(mouseSupSep), supEdges, 'Normalization','probability');

hold on

histogram(cell2mat(ratSupSep), supEdges, 'Normalization','probability');

title("Rat and Mouse Suppression Times p = 2.4261e-23");
xlabel("Suppression Time (ms)");
ylabel("Probability");

legend("Mice", "Rats")

figure()

histogram(log10(cell2mat(mouseSupSep)), logSupEdges, 'Normalization','probability');

hold on

histogram(log10(cell2mat(ratSupSep)), logSupEdges, 'Normalization','probability');

title("Rat and Mouse Suppression Times p = 2.4261e-23");
xlabel("Log Suppression Time");
ylabel("Probability");

legend("Mice", "Rats")


%% stat tests; couldn't make them normal

ranksum(cell2mat(mouseBurstSep), cell2mat(ratBurstSep))

ranksum(cell2mat(mouseSupSep), cell2mat(ratSupSep))