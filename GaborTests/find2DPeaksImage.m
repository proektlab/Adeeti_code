function [BW, heights, xs, ys] = find2DPeaksImage(spectrum, validIndX, validIndY)

%image = abs(fftshift(spectrum)); %perlin2D(200);
if ~isempty(validIndX)||~isempty(validIndY)
cropImage = image(validIndY,validIndX);
else
    cropImage = image;
end

BW = imregionalmax(cropImage');
[xs, ys] = ind2sub(size(BW), find(BW==1));
heights = [];
for i = 1:length(xs)
    heights(i) = cropImage(ys(i), xs(i));
end
