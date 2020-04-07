%% looking at the new grids data 

dirIn =   '/data/adeeti/ecog/testing_Viv_Neurogrid_ECOG/';
cd(dirIn)
identifier = '2019*.mat'; 
allData = dir(identifier);

for experiment = 1:length(allData)
   if experiment <5
       if experiment == 1
           figure 
       end
       load(allData(experiment).name, 'aveTrace')
       subplot(4,1,experiment)
       plot(squeeze(aveTrace(1,:,800:end))')
       suptitle('V4. 64 chan viventi')
   elseif experiment >4 && experiment <7
       if experiment == 5
           figure 
       end
       load(allData(experiment).name, 'aveTrace')
       subplot(2,1,experiment-4)
       plot(squeeze(aveTrace(1,:,800:end))')
       suptitle('T2, 64 chan neurogrid')
   elseif experiment >6
       if experiment == 7
           figure 
       end
       load(allData(experiment).name, 'aveTrace')
       subplot(3,1,experiment-6)
       plot(squeeze(aveTrace(1,:,800:end))')
       suptitle('T4, 32 chan neurogrid')
   end
end


figure
plot(squeeze(meanSubFullTrace(1:3,:)))
