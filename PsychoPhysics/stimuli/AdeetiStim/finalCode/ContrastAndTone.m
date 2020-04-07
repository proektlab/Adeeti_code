%function ContrastAndTone([distanceToMonitor = 25], [angle = 30], [cpd = 0.08], [cps = 1], [contrast = 1], [movieDurationSecs = 5], [center = 1], [gratingSize = 15], [drawmask = 1], [maskStd = 60], [toneFs = 44100], [toneFreq = 4000], [sigFreq = 0.5]) 
%creates a contrast reverse grating and also a tone
%input parameters:
%   distanceToMonitor = distance to monitor in cm
%   angle = orientation of the grating in degrees
%   cpd = cycles per degree (spatial frequency) *******REPLACE THIS********
%   cps = cycles per second (temporal frequency)
%   contrast = difference between white and black
%   movieDurationSecs = duration in seconds
%   center = where the grating is located in pixels
%   gratingSize = how big the grating is in pixels
%   drawmask = either 0 or 1. 1 turns on drawmask, 0 turns drawmask off
%   maskStd = value that changes how strong the mask is
%   toneFs = sampling frequency (usually 8192 for matlab and 44100 for
%   psychtoolbox)
%   toneFreq = frequency of the tone (Hz)
%   sigFreq = frequency of the signal

function ContrastAndTone(distanceToMonitor, angle, cpd, cps, contrast,...
movieDurationSecs, center, gratingSize, drawmask, maskStd, toneFs, toneFreq, sigFreq)
%% defaults
sca;
    if nargin < 1
        distanceToMonitor = [];
    end
    if nargin < 2
        angle = [];
    end
    if nargin < 3
        cpd = [];
    end
    if nargin < 4
        cps = [];
    end
    if nargin < 5
        contrast = [];
    end
    if nargin < 6
        movieDurationSecs = [];
    end
    if nargin < 7
        center = [];
    end
    if nargin < 8
        gratingSize = [];
    end
    if nargin < 9
        drawmask = [];
    end
    if nargin < 10
        maskStd = [];
    end
    if nargin < 11
        toneFs = [];
    end
    if nargin < 12
        toneFreq = [];
    end
    if nargin < 13
        sigFreq = [];
    end
%   ^o^       
    if isempty(distanceToMonitor)
        distanceToMonitor = 25;
    end
    if isempty(angle)
        angle = 30;
    end
    if isempty(cpd)
        cpd = 0.08;
    end
    if isempty(cps)
        cps = 1;
    end
    if isempty(contrast)
        contrast = 1;
    end
    if isempty(movieDurationSecs)
        movieDurationSecs = 5;
    end
    if isempty(center)
        center = [1280/2, 512];
    end
    if isempty(gratingSize)
        gratingSize = 15;
    end
    if isempty(drawmask)
        drawmask = 1;
    end
    if isempty(maskStd)
        maskStd = 70;
    end
    if isempty(toneFs)
        toneFs = 44100;
    end
    if isempty(toneFreq)
        toneFreq = 440;
    end
    if isempty(sigFreq)
        sigFreq = 0.5;
    end
%% actual code
    Screen('Preference', 'VisualDebuglevel', 3);
    
        
    %open a window
    PsychDefaultSetup(2);
    w = max(Screen('Screens'));
    [w, screenRect]=PsychImaging('OpenWindow',w, [.5 .5 .5]);

    params.distanceToMonitor = distanceToMonitor; %set equal to monitor distance in cm
    params = COPYconfigureScreens_pipelineAA(w, params); %gets params from configureScreens

    soundContrastRevGratFun(w, params, angle, cpd, cps, contrast,...
    movieDurationSecs, center, gratingSize, drawmask, maskStd, toneFs, toneFreq, sigFreq);

    sca;
end