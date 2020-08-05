function [ADChannels] = convertNNchan2PlexADChanAcute32(NNChannels)
% mapping 32 channel neuronexus probes with A32 acute adapter
% NN channels put in order that makes sense for recording 
% example: NNChannels = [9 8 10 7 11 6 12 5 13 4 14 3 15 2 16 1] for one
% shank of a 32 channel electrode in which 9 is the top most channel and 
% 09/11/18 AA
%%
ChanConversionMatrix = [[1	23];...
[2	19];...
[3	3];...
[4	7];...
[5  20];...
[6	2];...
[7	4];...
[8	18];...
[9	21];...
[10	1];...
[11	5];...
[12	17];...
[13	22];...
[14	6];...
[15	24];...
[16	8];...
[17	25];...
[18	9];...
[19	27];...
[20	11];...
[21	16];...
[22	15];...
[23	32];...
[24	26];...
[25	31];...
[26	10];...
[27	14];...
[28	13];...
[29	30];...
[30	12];...
[31	29];...
[32	28]];


ADChannels = zeros(size(NNChannels));
for i = 1:numel(NNChannels)
    AD = ChanConversionMatrix(NNChannels,:);
    ADChannels(i) = ChanConversionMatrix(NNChannels(i),2);
end
