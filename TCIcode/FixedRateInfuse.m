function [ ] = FixedRateInfuse( rate, time, p )
%given the rate in ul/min time in seconds and handle to the pump will start
%the infusion

    fprintf(p, 'CITIME\n');
    fprintf(p, ['TTIME ', num2str(time), '\n']);
    fprintf(p, ['IRATE ',num2str(rate),' ul/min','\n']);
    fprintf(p, 'IRUN\n');

end

