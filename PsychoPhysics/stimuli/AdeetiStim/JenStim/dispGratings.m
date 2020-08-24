%dispGratings.m
%Jennifer Luo
%6/21/19
%This program creates a contrast reversing grating in 9 different locations

function dispGratings(angle, cpd, cps, contrast, distanceToMonitor, gratingSize, drawMask, duration)
    %% defaults
    
    if nargin < 1
        angle = [];
    end
    
    if nargin < 2
        cpd= [];
    end
    
    if nargin < 3
        cps = [];
    end
    if nargin < 4
        contrast = [];
    end
    if nargin < 5
        distanceToMonitor = [];
    end
    
    if nargin < 6
        gratingSize = [];
    end
    
    if nargin < 7
        drawMask = [];
    end
    if nargin < 8
        duration = [];
    end
    
    if isempty(angle)
        angle = 0;
    end
    if(isempty(cpd))
        cpd = .036;
    end
    if isempty(cps)
        cps = 1;
    end
    if(isempty(contrast))
        contrast = 1;
    end
    if isempty(distanceToMonitor)
        distanceToMonitor= 25;
    end
    if(isempty(gratingSize))
        gratingSize = 10;
    end
    if isempty(drawMask)
        drawMask = 1;
    end
    if(isempty(duration))
        duration = 10;
    end
    
    %% code stuff
    sca;

    Screen('Preference', 'VisualDebuglevel', 3);
    
    %preallocating array of stimulus times
    stimTimes = strings(2, 9);
    
    %open a window
    PsychDefaultSetup(2);
    w = max(Screen('Screens'));
    [w, screenRect]=PsychImaging('OpenWindow',w, [.5 .5 .5]);

    %load gamma table
    load('/home/adeeti/gammaCorrectionExpMonitor.mat')
    Screen('LoadNormalizedGammaTable', w, gammaTable');
    
    %get params
    params.distanceToMonitor = distanceToMonitor; %set equal to monitor distance in cm
    params = COPYconfigureScreens_pipelineAA(w, params); %gets params from configureScreens
    lj = labJack('verbose', false); %sets up labjack
    params.maskStd = 100;

    %creates 9 different centers
    centers = zeros(9,2); 
    for i = 1:9
        %fills in x value of centers, which move from left to right for each y
        %value change
        centers(i, 1) = (mod(i - 1, 3) + 1)*.25*params.dims(1); 
        %fills in y value of centers which increase every 3 gratings
        centers(i, 2) = (floor((i - 1)/3)+1)*.25*params.dims(2);
    end
    
    %get starting time
    startTime = datestr(now);
    
    %displays 9 different gratings
    for j = 1:9
        stimTimes(1,j) =  string(datestr(now)); %data for params.txt
        lj.timedTTL(1, j); %send timed ttl with location of stimulus
        WaitSecs(0.1)
        lj.toggleFIO(1); %send signal to labjack
        %run grating centered at a point
        COPYcontrastRevGratFun(w, params, angle, cpd, cps, contrast, duration, centers(j,:), gratingSize, drawMask);
        lj.toggleFIO(1); %send signal to labjack
        stimTimes(2,j) =  string(datestr(now));
    end

    Screen('Close', w)
    
    %creates title
    fileID = fopen('params.txt','a');
    fprintf(fileID, '\n\n\nContrast Reversing Grating Stimulus\nTime and Date\n');
    fprintf(fileID, '%s', startTime);
    fprintf(fileID, '\n\n');
    
    %describes params
    fprintf(fileID, strcat("\n\nAngle:\t\t\t\t", num2str(angle), " degrees"));
    fprintf(fileID, strcat("\n\nSpatial Frequency:\t", num2str(cpd), " cycles per degree"));
    fprintf(fileID, strcat("\n\nTemporal Frequency:\t", num2str(cps), " cycles per second"));
    fprintf(fileID, strcat("\n\nContrast:\t\t\t", num2str(contrast)));
    fprintf(fileID, strcat("\n\nMonitor Distance:\t", num2str(distanceToMonitor), " cm"));
    fprintf(fileID, strcat("\n\nGrating Size:\t\t", num2str(gratingSize), " degrees"));
    fprintf(fileID, strcat("\n\nMask Drawn?\t\t\t", num2str(drawMask)));
    fprintf(fileID, strcat("\n\nDuration:\t\t\t", num2str(duration), " seconds"));
    fprintf(fileID, '\n\n');

    %creates a table of locations and time
    locsAndTimes = vertcat(1:9, stimTimes, centers');
    fprintf(fileID, '%-10s %-25s %-25s %-10s %-10s', "trial", "start time", "end time", "xloc", "yloc");
    fprintf(fileID, '\n');
    fprintf(fileID, '%-10s %-25s %-25s %-10s %-10s\n', locsAndTimes);
    
    fclose(fileID);
     
end
 