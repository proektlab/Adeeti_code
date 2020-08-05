function [RMS, ZRMS, Sig, m] = TemporalImportance(Tamp,Stim,Dur, Win, Thresh)
%This function takes in temporal activation of modes (or electrodes) and
%identifies which one is most responsive to a stimulus by looking at
%whether RMS of the signal peaks after the stimulus. 
% INPUTS:
%   Tamp is temporal Activation of different modes and is time by mode
%   index. Stim is the index at which the stimulus is given. Dur is the
%   duration in terms of time points of the window where the response
%   occurs. Win is the number of window in which RMS is computed (non
%   overlapping windows are used). Thresh is the threshold (in terms of
%   Zscore at which the mode is considered to be significant
%Outputs: RMS is the RMS of the temporal activation data. ZRMS is the same
%thing expressed in terms of Z-scores computed based on all windows outside of
%the stimulus duration. SIG is the binary vector which shows 1 if the mode
%is signficant (gien Thresh). m reports the most sensory responsive mode.


RMS=zeros(size(Tamp,2), ceil(size(Tamp,1)./Win));
% partition the data into chunks and compute RMS
for i=1:size(Tamp,2)
   temp=buffer(Tamp(:,i), Win);
   RMS(i,:)=rms(temp,1);        
end
% find the chunk where the stimulus occurs
StimWindow=floor(Stim./Win);
% now see how power is distributed among modes before the stimulus
PreStimPowerDist=mean(RMS(:,1:StimWindow),2);
PreStimPowerDist=PreStimPowerDist./sum(PreStimPowerDist);
%same thing for post
EffectWindow=floor(Dur./Win);           % define effect window in terms of RMS windows;
PostStimPowerDist=mean(RMS(:,1:StimWindow+1:StimWindow+1+EffectWindow),2);
PostStimPowerDist=PostStimPowerDist./sum(PostStimPowerDist);

% now find significant modes
% first convert to Zscores;
StimEnd=StimWindow+1+EffectWindow; % end of the stimulus interval
BaseInd=[2:StimWindow, StimEnd+1:size(RMS,2)]; % remove for edge effect elimination
BaselineMeans=mean(RMS(:,BaseInd),2);
BaselineStd=std(RMS(:,BaseInd),[],2);
ZRMS=(RMS-repmat(BaselineMeans, 1, size(RMS,2)))./repmat(BaselineStd,1, size(RMS,2));

Test=ZRMS(:,StimWindow+1:StimWindow+1+EffectWindow); 
Sig=zeros(size(Test,1),1);

for i=1:size(Sig,1)
   if ~isempty(find(Test(i,:)>Thresh))
       Sig(i)=1;
   end
    
end
% find most responsive mode
m=find(max(Test,[],2)==max(Test(:)));
end
