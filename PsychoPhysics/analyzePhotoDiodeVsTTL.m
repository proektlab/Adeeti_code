%% Analyzing photodiode and TTL output

% black no TTL = 0 
% black with TTL = 2
% white no TTL = 4
% white with TTL = 6

figure
plot(eveTime, eveID)
hold on
plot(eveTime, eveID, 'o')

%% Finding the length of TTL 
%to go from black with TTL to black no TTL, diff in ID = -2


eveTimeDiff = diff(eveTime);

TTLlengths = find(diff(eveID)==-2);
TTLlengths = eveTimeDiff(TTLlengths);
unique(TTLlengths)

%% Finding white to black screen switch
% diff in ID = -4

eveTimeDiff = diff(eveTime);

TTLlengths = find(diff(eveID)==-4);
TTLlengths = eveTimeDiff(TTLlengths);
unique(TTLlengths)


%% Finding the timing diff of TTL off to whtie screen
% to go from black no TTL to white no TTL, diff in ID = 4

eveTimeDiff = diff(eveTime);

TTLlengths = find(diff(eveID)==4);
TTLlengths = eveTimeDiff(TTLlengths);
unique(TTLlengths)