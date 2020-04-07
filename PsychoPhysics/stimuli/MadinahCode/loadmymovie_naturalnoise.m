% function [movie,ix,iy,totalframes]=loadmymovie_naturalnoise(n)
% if nargin<1
%     n=1;
% end

addpath('/home/diegoc/Desktop/movie5/');

    fn='i00';
    %fn=['i',n];
    cd
    fid = fopen(fn,'r');
    H = fread(fid,15);
    SX=720;
    SY=480;
    

fid = fopen(fn,'r');
HEADER = setstr(H');

TT=1802;
tmp0=0;
fseek(fid,SX*SY*tmp0*1,0);
[G,COUNT] = fread(fid,[SX,SY*TT],'uchar');

movie=zeros(SX,SY,TT);
for tmpi=(tmp0+1):(tmp0+TT)
    %[F,COUNT] = fread(fid,[SX,SY],'uchar');
    frame=G(:,1+(tmpi-1)*SY:(tmpi+0)*SY);
    movie(:,:,tmpi)=frame./255;
    % h=imagesc(F,[0 255]);axis('equal');colormap('gray');
    %axis([0.5 SX+0.5 0.5 SY+0.5])
    %pause
end
%fn=sprintf('n%.2d.mat',n);
%save(fn);

%movie=movie./255;

ix=size(movie,1);
iy=size(movie,2);
totalframes=size(movie,3);

moviemat00=movie; clear movie;
clearvars -except ix iy totalframes moviemat00

save('moviefile_00.mat','-v7.3');


%return
