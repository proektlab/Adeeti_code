%function numberoftrials([trialssound = 10], [trialsvisual = 10], [trialsboth = 10;], [angle = 30], [cyclespersecond = 1], [f = 0.01], [drawmask = 1], [maskStd = 90], [gratingsize = 400], [toneFs = 44100], [toneFreq = 4000], [sigFreq = 0.5], [duration = 10])
%randomizes order of three different kind of trials.

function numberoftrials(trialssound, trialsvisual, trialsboth, angle, cyclespersecond, cpd, drawmask, maskStd, gratingsize,...
    toneFs, toneFreq, sigFreq, duration)
 %% defaults and stuff
    %trialssound = number of sound trials
    %trialsvisual = number of visual trials
    %trialsboth = number of trials with both sound and visual

    if nargin < 1
        trialssound = [];
    end
    if nargin < 2
        trialsvisual = [];
    end
    if nargin < 3
        trialsboth = [];
    end
    if nargin < 4
        angle = [];
    end
    if nargin < 5
        cyclespersecond = [];
    end
    if nargin < 6
        cpd = [];
    end
    if nargin < 7
        drawmask = [];
    end
    if nargin < 8
        maskStd = [];
    end
    if nargin < 9
        gratingsize = [];
    end
    if nargin < 10
        toneFs = [];
    end
    if nargin < 11
        toneFreq = [];
    end
    if nargin < 12
        sigFreq = [];
    end
    if nargin < 13
        duration = [];
    end
%   ^o^    
    if isempty(trialssound)
        trialssound = 10;
    end
    if isempty(trialsvisual)
        trialsvisual = 10;
    end
    if isempty(trialsboth)
        trialsboth = 10;
    end
    if isempty(angle)
        angle=30;
    end
    if isempty(cyclespersecond)
        cyclespersecond = 1;
    end
    if isempty(cpd)
        cpd = 0.4;
    end
    if isempty(drawmask)
        drawmask = 1;
    end
    if isempty(maskStd)
        maskStd = 90;
    end
    if isempty(gratingsize)
        gratingsize = 400;
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
    if isempty(duration)
        duration = 10;
    end
    totaltrials = trialssound + trialsvisual + trialsboth
 %% scrambling stuff (hopefully random perming stuff (not hair, the trials))
    trialarray = randperm(totaltrials)
   
    sca;
       
    %open a window
    PsychDefaultSetup(2);
    w = max(Screen('Screens'));
    [w, screenRect]=PsychImaging('OpenWindow',w, [.5 .5 .5]);
%     Screen('Preference', 'VisualDebuglevel', 3);

    %set high priority
    priorityLevel = MaxPriority(w);
    Priority(priorityLevel);
    
    %load gamma table
    load('/home/adeeti/gammaCorrectionExpMonitor.mat')
    Screen('LoadNormalizedGammaTable', w, gammaTable');
    
    
    %get params
    params.distanceToMonitor = 25; %set equal to monitor distance in cm
    params = COPYconfigureScreens_pipelineAA(w, params); %gets params from configureScreens
%    pahandle = PsychPortAudio('Open', [], [], 2, params.toneFs, 2);
    params.drawmask = drawmask;
    params.maskStd = maskStd;
    
    %get starting time
    startTime = datestr(now);
    
    %preallocating array of times and trial types
    stimTimes = strings(1, totaltrials);
    trialType = strings(1, totaltrials);
    
    for i=1:totaltrials
        %some range = trialssound
        if trialarray(i)<=trialssound
            disp('playingsound')
            
            %get time of stim
            stimTimes(i) = string(datestr(now));
            trialType(i) = "a";
            SuperiorSoundOnly(params, toneFreq, sigFreq, duration, 1)
        else
            %some other range = trialsvisual
            if trialssound<=trialarray(i) && trialarray(i)<=totaltrials-trialsboth
                disp('playingvisual')
                %get time of stim
                stimTimes(i) = string(datestr(now));
                trialType(i) = "v";
                SuperiorVisualOnly(params, w, angle, cyclespersecond, cpd, gratingsize, duration, 2)
            %some other other range = trialsboth
            else
                disp('playingboth')
                %get time of stim
                stimTimes(i) = string(datestr(now));
                trialType(i) = "av";
                SuperiorSoundandVisual(params, w, angle, cyclespersecond, cpd, gratingsize, toneFreq, sigFreq, duration, 3)
            end
        end
        % Adds a set delay between each trial
        WaitSecs(1 - params.delay);
    % Abort if any key is pressed:
        if KbCheck
            break;
        end
    end
    
    Priority(0);
    Screen('Close');
    
    %creates title
    fileID = fopen('params.txt','a');
    fprintf(fileID, '\n\n\nAudiovisual Oddball Stimulus\nTime and Date\n');
    fprintf(fileID, '%s', startTime);
    fprintf(fileID, '\n\n');
    
    %describes params
    fprintf(fileID, strcat("\n\nAngle:\t\t\t\t", num2str(angle), " degrees"));
    fprintf(fileID, strcat("\n\nSpatial Frequency:\t", num2str(cpd), " cycles per degree"));
    fprintf(fileID, strcat("\n\nTemporal Frequency:\t", num2str(cyclespersecond), " cycles per second"));
    fprintf(fileID, strcat("\n\nGrating Size:\t\t", num2str(gratingsize), " pixels"));
    fprintf(fileID, strcat("\n\nMask Size:\t\t\t", num2str(maskStd)));
    fprintf(fileID, strcat("\n\nMask Drawn?\t\t\t", num2str(drawmask)));
    fprintf(fileID, strcat("\n\nTone Fs:\t\t\t", num2str(toneFs)));
    fprintf(fileID, strcat("\n\nTone Frequency\t\t", num2str(toneFreq)));
    fprintf(fileID, strcat("\n\nAM Frequency\t\t", num2str(sigFreq)));
    fprintf(fileID, strcat("\n\nDuration:\t\t\t", num2str(duration), " seconds"));
    fprintf(fileID, '\n\n');
    
    %creates a table of trials and times
    trialTimes = vertcat(1:totaltrials, stimTimes, trialType);
    fprintf(fileID, '%-10s %-25s %-10s', "trial", "start time", "trial type");
    fprintf(fileID, '\n');
    fprintf(fileID, '%-10s %-25s %-10s\n', trialTimes);
end