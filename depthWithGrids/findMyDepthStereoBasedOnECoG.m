function [myStereotaxicPosition, myPositionIndex] = findMyDepthStereoBasedOnECoG(depthPostX, depthPosY, bregmaOffsetX, bregmaOffsetY, hemisphere, electrodeName)
% [myStereotaxicPostion, myPostionIndex] = findMySteroBasedOnECoG(depthPostX, depthPosY, bregmaOffsetY, bregmaOffsetX, useE64_500_20_60)
% depthPostX = hole position in X (Medial to lateral relative to bregma)
% depthPosY = hole position in Y (Top to Bottom)
% bregmaOffsetX = offset of the upper right corner of grid relative to
% bregma (pos is L of bregma and neg is R of bregma) in mm
% bregmaOffsetY = offset of uper right corner of grid relative to bregma
% (pos is P to bregma and neg is A of bregma) in mm
% output myStereotaxicPostion has posterior to bregma as positive and to the
% right as positive (same as bregmaOffset)

% 09/06/18 AA and CRB

if nargin <6
    electrodeName = 'E64-500-20-60';
end
if nargin <5
    hemisphere = 'left';
end

myPositionIndex = [depthPostX, depthPosY];

if strcmpi(electrodeName, 'E64-500-20-60')
    hole2holeX = 0.5; % in mm
    hole2holeY = 0.5; % in mm
    padUpperRCornX = .125; % in mm
    padUpperRCornY = .125; % in mm
    firstHoleX = padUpperRCornX + hole2holeX/2;
    firstHoleY = padUpperRCornY + hole2holeY/2;
    
    % finding x position
    if strcmpi(hemisphere, 'left')
        myStereotaxicPositionX = bregmaOffsetX + firstHoleX + (depthPostX-1)*hole2holeX;
    elseif strcmpi(hemisphere, 'right') 
        myStereotaxicPositionX = bregmaOffsetX -(firstHoleX + (depthPostX-1)*hole2holeX);
    else 
        disp('You confused in yor x direction')
    end
    
    % finding y position
    myStereotaxicPositionY = bregmaOffsetY + firstHoleY + (depthPosY-1)*hole2holeY;
    
    % final position
    myStereotaxicPosition = [myStereotaxicPositionX, myStereotaxicPositionY];
else
    disp('I do not have this electrode configuration to map to; will give you an empty matrix for Sterotaxic Position')
    myStereotaxicPosition = [];
end

