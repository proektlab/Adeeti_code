function [filtnoise,totalFrames,blockStart]=LoadWhiteNoise(numRFpixelsx,numRFpixelsy,numBlocks)

load whitenoise.mat blurredimage numFramesPerBlock blockStart

blockStart=blockStart(1:numBlocks);
numFramesBtwnBlocks=100;
totalFrames=numBlocks*(numFramesPerBlock+numFramesBtwnBlocks)
for i=1:totalFrames
    filtnoise{i}(1:numRFpixelsx,1:numRFpixelsy)=blurredimage{i}(2:numRFpixelsx+1,2:numRFpixelsy+1);
end

return