function [BW, heights, xs, ys] = find2DPeaksImage(spectrum, validIndX, validIndY)

test = abs(fftshift(spectrum)); %perlin2D(200);
if ~isempty(validIndX)||~isempty(validIndY)
cropTest = test(validIndY,validIndX);
else
    cropTest = test;
end

BW = imregionalmax(cropTest');
[xs, ys] = ind2sub(size(BW), find(BW==1));
heights = [];
for i = 1:length(xs)
    heights(i) = test(ys(i), xs(i));
end
