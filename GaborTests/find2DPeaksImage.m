function [BW, heights, xs, ys] = find2DPeaksImage(image)
test = abs(fftshift(image)); %perlin2D(200);
BW = imregionalmax(test');
[xs, ys] = ind2sub(size(BW), find(BW==1));
heights = [];
for i = 1:length(xs)
    heights(i) = test(ys(i), xs(i));
end
