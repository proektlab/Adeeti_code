function [trialOrder] = makeConRevGratTrialOrder(conRevParam)
    numTrials = conRevParam.totalTrialsPerCondition;
    
    conRevParam.angles = [0 180]; %horizontal or vertical grating
conRevParam.cpd = 0.08;
conRevParam.cps = 2; 
conRevParam.contrast = 1;
conRevParam.movieDurationSecs = 10;
conRevParam.centers = [0 1 2 3 4]; % C, UL, UR, LL, UR
conRevParam.gratingSize = 5; % in degrees of visual space
conRevParam.drawmask = 0;
    
    
    if numel(conRevParam.angles) ==1
        
    elseif isempty(conRevParam.angles) 
    else
        
        if 
    
    find(numel(conRevParam.centers)


end
