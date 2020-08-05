function [interpSnippits] = removingArtifactAndInterpolating(dataSnippits, artifactRegion)
% [dataSnippits] = removingArtifactAndInterpolating(dataSnippits, artifactRegion)
if nargin<2
    artifactRegion = [1000:1015];
end
data = dataSnippits;
bufferPoints = [artifactRegion(1)-10:artifactRegion(1), artifactRegion(end):artifactRegion(end)+10];
data(:,:,artifactRegion) = [];

time1 = [1:artifactRegion(1)-1, artifactRegion(end)+1:size(dataSnippits,3)];
time2 = 1:size(dataSnippits,3);

for i = 1:size(data, 1)
    for j = 1:size(data,2)
        interpSnippits(i,j,:) = interp1(time1, squeeze(data(i, j, :)), time2, 'spline');
    end
end
