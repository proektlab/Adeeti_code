figure('Color', 'w'); clf
subplot(2,1,1)
scatter(L_test(:,1), L_test(:,2),[],  P_test, 'filled')
legend('Isoflurane', 'Awake')
title('Test Iso and Awake')
xlabel('LDA 1')
ylabel('LDA 2')
subplot(2,1,2)
scatter(L_emg(:,1), L_emg(:,2), [], P_emg, 'filled')
xlabel('LDA 1')
ylabel('LDA 2')
title('emergence')
suptitle('Classification of Single Trials')


map = [1 0 0
    0.9 0.1 0
    0.8 0.2 0
    0.7 0.3 0
    0.6 0.4 0
    0.5 0.5 0
    0.4 0.6 0
    0.3 0.7 0
    0.2 0.8 0
    0.1 0.9 0
    0 1 0];

colormap(map)
c = colorbar
c.Label.String = 'Probabilty Classify as Iso';