% LoadEVs


function [EV_Timestamps, EV_EventIDs, EV_TTLs, EV_EventStrings] = LoadEVs_mouse(directory)


files = dir( [directory '*.nev']) ;
fname = { files.name}; %get only file names
filename=[directory fname{1}];
[EV_Timestamps, EV_EventIDs, EV_TTLs, EV_EventStrings] = importEV(filename);

clear filename


%EV_TTLs_Temp = EV_TTLs;

%ttls_size_2d = size(EV_TTLs_Temp);
%ttls_size = ttls_size_2d(1,2);

%StimID = zeros(1,ttls_size);
%StimID_End = zeros(1,ttls_size);

clear EV_TTLs_Temp ttls_size_2d ttls_size asize next_a_s next_a k j a b i StimID StimID_End

