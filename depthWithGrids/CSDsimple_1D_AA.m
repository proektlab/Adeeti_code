function [CSDOutput] = CSDsimple_1D_AA(LFPinput, spacing)
% data in channels (rows) by voltage time points (columns)

for electrode = 3:size(LFPinput,1)-2
    
V0 = LFPinput(electrode,:);
Va = LFPinput(electrode-2,:);
Vb = LFPinput(electrode+2,:);
CSDOutput(electrode,:) = (Vb+Va-2*V0)/(2*spacing)^2;

end


