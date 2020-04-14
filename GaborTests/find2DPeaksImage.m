function [BW, heights] = find2DPeaksImage(image)
test = abs(fftshift(image)); %perlin2D(200);
BW = imregionalmax(test');
[xs, ys] = ind2sub(size(BW), find(BW==1));
heights = [];
for i = 1:length(xs)
    heights(i) = test(ys(i), xs(i));
end

% subplot(1,4,4)
% surf(test);
% hold on;
% scatter3(xs, ys, heights, 'rx');
end
