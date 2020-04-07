%oddballSequence = oddballSeqencer([typeNum = [14,1,1]], [startBuffer = 3], [oddballBuffer = 3])
%this randomly creates a sequence representing an oddball stimulus
%inputs     typeNum     a vector representing the number of different types
%                       of stimulus. For example, [14, 1, 2] would be 14 
%                       standard, 1 high oddball, 1 low oddball. First
%                       number is always the standard
%           startBuffer number of standards before the first oddball
%           oddballBuffer   number of standards between each oddball
function oddballSequence = oddballSequencer(typeNum, startBuffer, oddballBuffer)
%% default params
    if nargin < 1
        typeNum = [];
    end
    if nargin < 2
        startBuffer = [];
    end
    if nargin < 3
        oddballBuffer = [];
    end
    
    if isempty(typeNum)
        typeNum = [14, 1, 1];
    end
    if isempty(startBuffer)
        startBuffer = 3;
    end
    if isempty(oddballBuffer)
        oddballBuffer = 3;
    end
    
%% generating a vector
    totalTrials = sum(typeNum);
    invalidVector = true;
    %runs while the created array is invalid
    while(invalidVector)
        invalidVector = false;
        trialVector = randperm(totalTrials); %scrambles the vector
        locOddballs = find(trialVector>(typeNum(1))); %finds location of oddballs
        %for each oddball except the last
        for i = 1:(numel(locOddballs) - 1)
            
            %if this oddball's location does not have a certain number of
            %standards before it
            if(locOddballs(i) <= startBuffer)
                %this is an invalid vector. break out of for loop.
                invalidVector = true;
                break;
            end
            
            %if the next oddball happens too after this one
            if(locOddballs(i + 1) <= locOddballs(i) + oddballBuffer)
                %this is an invalid vector. break out of the for loop.
                invalidVector = true;
                break;
            end
        end
    end
    
    %changes trialVector so each number becomes a trial type
    %iterates through each trial type
    for i = 1:numel(typeNum)
        %if the number of trial vector matches the trial type, replace it
        %with that trial type number
        trialVector(trialVector>sum(typeNum(1:i-1)) & trialVector <= sum(typeNum(1:i))) = i;
    end
    
    oddballSequence = trialVector;
end