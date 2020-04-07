%function oddball([numStandard = 14], [highOddball = 1], [lowOddball = 1], [oddballBuffer = 3], [toneFs = 44100], [standardFreq = 4000], [lowFreq = 3500], [highFreq = 4500], [duration = 10])
%creates an oddball auditory stimulus.
%inputs:
%       numstandard     number of standard trials
%       highOddball     number of high pitched oddball sounds
%       lowOddball      number of low pitched oddball sounds
%       oddballBuffer   number of standards between each oddball
%       toneFs          sampling rate in Hz. usually 44100Hz.
%       standardFreq    frequency of standard tone in Hz
%       lowFreq         frequency of low oddball tone in Hz
%       highFreq        frequency of high oddball tone in Hz
%       duration        duration of each tone in seconds

function oddball(numStandard, highOddball, lowOddball, oddballBuffer,...
    toneFs, standardFreq, lowFreq, highFreq, duration)
 %% default parameters

    if nargin < 1
        numStandard = [];
    end
    if nargin < 2
        highOddball = [];
    end
    if nargin < 3
        lowOddball = [];
    end
    if nargin < 4
        oddballBuffer = [];
    end
    if nargin < 5
        toneFs = [];
    end
    if nargin < 6
        standardFreq = [];
    end
    if nargin < 7
        lowFreq = [];
    end
    if nargin < 8
        highFreq = [];
    end
    if nargin < 9
        duration = [];
    end
% ^o^    
    if isempty(numStandard)
        numStandard = 14;
    end
    if isempty(highOddball)
        highOddball = 1;
    end
    if isempty(lowOddball)
        lowOddball = 1;
    end
    if isempty(oddballBuffer)
        oddballBuffer = 3;
    end
    if isempty(toneFs)
        toneFs = 44100;
    end
    if isempty(standardFreq)
        standardFreq = 4000;
    end
    if isempty(lowFreq)
        lowFreq = 3500;
    end
    if isempty(highFreq)
        highFreq = 4500;
    end

    if isempty(duration)
        duration = .5;
    end
    
    totaltrials = numStandard + highOddball + lowOddball;
 %% scrambling stuff (hopefully random perming stuff (not hair, the trials))
    %make sure that there is a greater quantity of standards than oddballs
    if(numStandard < (highOddball + lowOddball) * oddballBuffer)
        warning('Not enough space between oddballs!');
        warning('Decrease oddballBuffer or number of oddballs');
        return;
    end
    
    invalidVector = true;
    %runs while the created array is invalid
    while(invalidVector)
        invalidVector = false;
        trialVector = randperm(totaltrials); %scrambles the vector
        locOddballs = find(trialVector>(numStandard)) %finds location of oddballs
        %for each oddball except the last
        for i = 1:(numel(locOddballs) - 1)
            
            %if this oddball's location does not have a certain number of
            %standards before it
            if(locOddballs(i) <= oddballBuffer)
                %this is an invalid vector. break out of for loop.
                invalidVector = true;
                break;
            end
            
            %if the next oddball happens too after this one
            if(locOddballs(i + 1) < locOddballs(i) + oddballBuffer)
                %this is an invalid vector. break out of the for loop.
                invalidVector = true;
                break;
            end
        end
    end
   

    for i=1:totaltrials
        %if the number in trialsVector corresponds a standard trial
        if trialVector(i) <= numStandard
            disp(i);
            disp(' playing standard');
            COPYSoundOnly(toneFs, standardFreq, 0, duration, [1,1]);
        else
            %if the number in trialsVector corresponds to a high oddball
            %trial.
            if trialVector(i) <= highOddball + numStandard
                disp(i);
                disp('playing high oddball')
                COPYSoundOnly(toneFs, highFreq, 0, duration, [2,1])
            %if the number in trialsVector corresponds to a low oddball
            %trial
            else
                disp(i);
                disp('playing low oddball')
                COPYSoundOnly(toneFs, lowFreq, 0, duration, [3,1])
            end
        end
        
        % Abort if any key is pressed:
        if KbCheck
            break;
        end
        
    end
end