%I used H264 video compression to turn Dawei's matrices into .avi videos. 
%I need to make sure that the compression doesn't leave huge artifacts.
% So I need to check each frame before and after the video comrpession.
% This means i need to capture video frames and turn them back into
% matrices.

%read video and capture frames?
if ismac
    addpath('/Users/madsarv/Dropbox/Mouse/stimuli/Natural Noise Movies/');
else
    addpath('C:\Users\Madineh\Dropbox\Mouse\stimuli\Natural Noise Movies\');
end

outputFolder = cd;
% Read in the movie.
vidObj= VideoReader('moviefile_00.mp4');
vidHeight = vidObj.Height;
vidWidth = vidObj.Width;
s = struct('cdata',zeros(vidHeight,vidWidth,3,'uint8'),...
    'colormap',[]);
% Determine how many frames there are.
k = 1;
while hasFrame(vidObj)
    s(k).cdata = readFrame(vidObj);
    k = k+1;
end
whos s

%% load pre-compression movies
load moviefile_00.mat
%% plot each frame side by side
f1=figure('outerposition',[57 131 1067 620]);
for i=1600:1802
subplot(1,3,1);
preimage=(circshift(moviemat00(:,:,i)',[0,-15,0]));
imagesc(preimage); 
caxis([0 1]);colormap('gray'); colorbar;
title('Pre Compression');
subplot(1,3,2);
temp=s(i).cdata;
post_image=(double(temp(:,:,1)))./255;
imagesc(post_image); 
caxis([0 1]);colormap('gray'); colorbar;
title('Post Compression');
subplot(1,3,3);
diffimage=preimage-post_image;
imagesc(diffimage); 
caxis([0 1]);colormap('gray'); colorbar;
title('Pre - Post');
pause
end