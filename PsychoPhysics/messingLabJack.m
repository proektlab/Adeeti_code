


flipTTL = 16;
missTTL= 2;


lj = labJack('verbose', true, 'deviceID', 3);

for i = 1:1000
timedTTL(lj,flipTTL,100)
pause(0.5)
end

lj.close;