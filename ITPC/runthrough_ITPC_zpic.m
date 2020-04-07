%% Sequence to run 

clear
close all

%% GL7 

% dirIn = '/synology/adeeti/ecog/iso_awake_VEPs/GL7/';
% dirPicITPC = '/synology/adeeti/ecog/images/Iso_Awake_VEPs/GL7/V1_ITPC/';
% 
% useStimIndex = 0;
% useNumStim = 1;
% 
% lowestLatVariable = 'lowLat';
% stimIndex = [0, Inf];%, Inf, Inf];
% %stimIndex = [0, Inf]; %if want all, stimIndex = matStimIndex; % if want
% %all uniStimIndexes/multiStimIndexes, use [uniStimIndex, multiStimIndex] =
% %findUniMutliStimIndex(matStimIndex), [stimIndex, ~] = findUniMutliStimIndex(matStimIndex)
% 
% numStim = 1;
% 
% 
% ITPC_lowLat_zoom_pic
% 
% clearvars -except stimIndex lowestLatVariable useNumStim useStimIndex

%% GL early
% dirIn = '/synology/adeeti/ecog/iso_awake_VEPs/GL_early/';
% dirPicITPC = '/synology/adeeti/ecog/images/Iso_Awake_VEPs/GL_early/V1_ITPC/';
% 
% useStimIndex = 0;
% useNumStim = 1;
% 
% lowestLatVariable = 'lowLat';
% stimIndex = [0, Inf];%, Inf, Inf];
% %stimIndex = [0, Inf]; %if want all, stimIndex = matStimIndex; % if want
% %all uniStimIndexes/multiStimIndexes, use [uniStimIndex, multiStimIndex] =
% %findUniMutliStimIndex(matStimIndex), [stimIndex, ~] = findUniMutliStimIndex(matStimIndex)
% 
% numStim = 1;
% 
% ITPC_lowLat_zoom_pic
% 
% clearvars -except stimIndex lowestLatVariable useNumStim useStimIndex numStim

%% IP2

% dirIn = '/synology/adeeti/ecog/iso_awake_VEPs/IP2/';
% dirPicITPC = '/synology/adeeti/ecog/images/Iso_Awake_VEPs/IPmice/V1_ITPC/';
% 
% useStimIndex = 0;
% useNumStim = 1;
% 
% lowestLatVariable = 'lowLat';
% stimIndex = [0, Inf];%, Inf, Inf];
% %stimIndex = [0, Inf]; %if want all, stimIndex = matStimIndex; % if want
% %all uniStimIndexes/multiStimIndexes, use [uniStimIndex, multiStimIndex] =
% %findUniMutliStimIndex(matStimIndex), [stimIndex, ~] = findUniMutliStimIndex(matStimIndex)
% 
% numStim = 1;
% 
% ITPC_lowLat_zoom_pic
% 
% clearvars -except stimIndex lowestLatVariable useNumStim useStimIndex numStim

%% GT2

dirIn = '/synology/adeeti/ecog/matGratingTesting/GT2/';
dirPicITPC = '/synology/adeeti/ecog/images/gratingTesting/GT2/V1_ITPC/';

useStimIndex = 0;
useNumStim = 1;

lowestLatVariable = 'lowLat';
stimIndex = [0, Inf, Inf, Inf];
%stimIndex = [0, Inf]; %if want all, stimIndex = matStimIndex; % if want
%all uniStimIndexes/multiStimIndexes, use [uniStimIndex, multiStimIndex] =
%findUniMutliStimIndex(matStimIndex), [stimIndex, ~] = findUniMutliStimIndex(matStimIndex)

numStim = 1;


ITPC_lowLat_zoom_pic

clearvars -except stimIndex lowestLatVariable useNumStim useStimIndex numStim
%% GT4
dirIn = '/synology/adeeti/ecog/matGratingTesting/GT4/';
dirPicITPC = '/synology/adeeti/ecog/images/gratingTesting/GT4/V1_ITPC/';

stimIndex = [0, Inf, Inf, Inf];

ITPC_lowLat_zoom_pic

clearvars -except stimIndex lowestLatVariable useNumStim useStimIndex numStim