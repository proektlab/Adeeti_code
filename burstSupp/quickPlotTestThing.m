figure



plot(meanSubFullTrace(3, :)')
title('window size 700, smooths and probs shifted')
hold on

offset = windowSize/2
plot([zeros(1, offset), mean(smoothedTrace{shortIndex},1)*40], 'LineWidth', 3);
plot([zeros(1, offset), mean(postBurstProb{shortIndex},1)*max(smoothedTrace{shortIndex}(1,:)*100)], 'LineWidth', 3)

plot([zeros(1, offset), isBurst*max(smoothedTrace{1}(1,:)*40)], 'LineWidth', 3)