function [myFavoriteExp] = findMyExpMulti(dataMatrixFlashes, exp, drugType, conc, stimIndex,  numStim, typeTrial, forkPos)
%find experiment name for you with criteria 
% syntax: findMyExpMulti(dataMatrixFlashes, exp, drugType, conc, stimIndex, forkPos)
% exp = experiment number 
% conc = drug concentration
% int = intensity pulse 

% 8/8/18 AA converted for multistimdata 
% 9/10/18 AA added fork position to 
% 11/19/19 AA added numStim and typeTrial
%%

    expVector = ones(1, length(dataMatrixFlashes));
    drugTypeVector = ones(1, length(dataMatrixFlashes));
    concVector = ones(1, length(dataMatrixFlashes));
    stimIndexVector = ones(1, length(dataMatrixFlashes));
    numStimVector = ones(1, length(dataMatrixFlashes));
    typeTrialVector = ones(1, length(dataMatrixFlashes));
    forkPosVector = ones(1, length(dataMatrixFlashes));

    if nargin > 1 && ~isempty(exp)
        expVector = [dataMatrixFlashes.exp]== exp;
    end
    if nargin > 2 &&~isempty(drugType)
        for i=1:size(dataMatrixFlashes,2)
            dtype{i}=dataMatrixFlashes(i).AnesType;
        end
        drugTypeVector = contains(dtype, drugType, 'IgnoreCase', true);
    end
    if nargin > 3 &&~isempty(conc)
        temp = zeros(1, length(dataMatrixFlashes));
        concVector = zeros(1, length(dataMatrixFlashes));
        for i = 1:length(conc)
            temp = [dataMatrixFlashes.AnesLevel]== conc(i);
            concVector = bitor(temp,concVector);
        end
        
        %concVector = [dataMatrixFlashes.AnesLevel]== conc;
    end
    if nargin > 4 &&~isempty(stimIndex)
        matStimIndex = (reshape([dataMatrixFlashes.stimIndex], [size(stimIndex,2), size(dataMatrixFlashes,2)]))';
        [stimIndexVector] = (ismember(matStimIndex, stimIndex, 'rows'))';
    end
    if nargin > 5 &&~isempty(numStim)
       numStimVector = [dataMatrixFlashes.numberStim]== numStim;
    end
    
    if nargin > 6 &&~isempty(typeTrial)
        for i=1:size(dataMatrixFlashes,2)
            ttype{i}=dataMatrixFlashes(i).TypeOfTrial;
        end
        typeTrialVector = contains(ttype, typeTrial, 'IgnoreCase', true);
    end
    
    
    if nargin > 7 &&~isempty(forkPos)
        for i = 1:size(dataMatrixFlashes,2)
            forkIndex(i,:) = dataMatrixFlashes(i).forkPosition(1,:);
        end
        [~,forkPosVector] = (ismember(forkIndex, forkPos, 'rows'))';
    end
    
    myFavoriteExp = find(expVector & drugTypeVector & concVector & stimIndexVector & numStimVector & typeTrialVector & forkPosVector);
end
