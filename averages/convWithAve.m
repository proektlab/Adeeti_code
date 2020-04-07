conCh15 = squeeze(meanSubData(15,:,:));
conCh15 = reshape(conCh15', 1, numel(conCh15));
plot(conCh15(1:1000))
figure;
gobbleGuck = convn(conCh15, kernal, 'same')
plot(gobbleGuck);
hold on
scatter(flashes, gobbleGuck(flashes), 'o', 'r')
figure;
histogram(gobbleGuck(flashes), 'normalization', 'probability')
histogram(gobbleGuck, 'normalization', 'probability', 'numbins', 20)