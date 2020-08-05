dirInGen = 'Z:\adeeti\JenniferHelen\';
expIdentifier = '*20*.mat'; %all the experiemnts are done in the during 2017-2020 and have the .mat ending
dirInExp = 'rats_BS_grid_iso'; % this comes from the list of experiments that we have
dirIn = [dirInGen, dirInExp]; %this created the full path
cd(dirIn);
allData = dir(expIdentifier);

for i = 1:numel(allData) %for each dataset, get data from each thing
    clear periodLengths
    experimentName = allData(i).name; 
    load(experimentName, 'info', 'periodLengths')
    if(exist('periodLengths', 'var')) %make sure pipeline was run
        correctPeriodLengths = periodLengths;
        for j = 1:numel(periodLengths) %for every BS segment in periodLength
            if ~isempty(correctPeriodLengths{j}.burstIndex) %skip any weird empty indices
                counter = 1;
                while counter < size(correctPeriodLengths{j}.burstIndex,2) %for each column in burstindex
                    if correctPeriodLengths{j}.burstIndex(1, counter + 1)... %if suppression length < 500
                            - correctPeriodLengths{j}.burstIndex(2, counter) < 500
                        %perform merge
                        correctPeriodLengths{j}.burstIndex(2, counter) = correctPeriodLengths{j}.burstIndex(2, counter + 1);
                        correctPeriodLengths{j}.burstIndex(:, counter + 1) = [];
                        counter = counter - 1; %move counter back to account for deleted column
                    end

                    counter = counter + 1;
                end
                %recalculate burst/suppression lengths
                burstIndex = correctPeriodLengths{j}.burstIndex;
                burstLen = zeros(1, size(burstIndex,2)); %length of bursts
                supLen = []; %length of supresses


                for k = 1:size(burstIndex,2) %convert indices to lengths
                    burstLen(k) = burstIndex(2, k) - burstIndex(1, k) + 1;
                    if k > 1
                        supLen(k-1) = burstIndex(1, k) - burstIndex(2, k - 1) - 1;
                    end
                end

                if isBurst(1) == 0
                    supLen = [burstIndex(1, 1) - 1, supLen];
                end

                if isBurst(end) == 0
                    supLen = [supLen, (periodLengths{j}.bsSegment - burstIndex(2, end))];
                end

                correctPeriodLengths{j}.sup = supLen;
                correctPeriodLengths{j}.burst = burstLen;
            end
        end
        save(experimentName, 'correctPeriodLengths', '-append') %save
    end
end
