
mousCount= 2;
tr = 44;
time = 500:2000;
plotTime = time- 1000;

figure 
subplot(4,1,1)
plot(plotTime,squeeze(allExpH(mousCount,1,:,tr,time))')
title('High Iso')
subplot(4,1,2)
plot(plotTime,squeeze(allExpH(mousCount,2,:,tr,time))')
title('Low Iso')
subplot(4,1,3)
plot(plotTime,squeeze(allExpH(mousCount,3,:,tr,time))')
title('Awake')
subplot(4,1,4)
plot(plotTime,squeeze(allExpH(mousCount,4,:,tr,time))')
title('Ket')

sgtitle([allMiceIDs(mousCount), ' Tr: ', num2str(tr)])

%%
bootTrials = randsample(100,15, 'true')

figure 
subplot(4,1,1)
plot(plotTime,squeeze(nanmean(allExpH(mousCount,1,:,bootTrials,time),4))')
title('High Iso')
subplot(4,1,2)
plot(plotTime,squeeze(nanmean(allExpH(mousCount,2,:,bootTrials,time),4))')
title('Low Iso')
subplot(4,1,3)
plot(plotTime,squeeze(nanmean(allExpH(mousCount,3,:,bootTrials,time),4))')
title('Awake')
subplot(4,1,4)
plot(plotTime,squeeze(nanmean(allExpH(mousCount,4,:,bootTrials,time),4))')
title('Ket')

sgtitle([allMiceIDs(mousCount)])

%%' Tr: ', num2str(bootTrials)])