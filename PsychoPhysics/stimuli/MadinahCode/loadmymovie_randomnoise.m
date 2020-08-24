
addpath('/home/diegoc/Desktop/movie5/');

for file=0:19
        
    number=num2str(file,'%02d');
    nameload=(['s',number,'.144x96x1']);
    namesave=['noisefile_',number];
    
fn=(nameload);
cd
fid = fopen(fn,'r');
H = fread(fid,15);
SX=144;
SY=96;

fid = fopen(fn,'r');
HEADER = setstr(H')

TT=901;
tmp0=0;
fseek(fid,SX*SY*tmp0*1,0);
[G,COUNT] = fread(fid,[SX,SY*TT],'uchar');

movie=zeros(SX,SY,TT);
for tmpi=(tmp0+1):(tmp0+TT)
    %[F,COUNT] = fread(fid,[SX,SY],'uchar');
    frame=G(:,1+(tmpi-1)*SY:(tmpi+0)*SY);
    movie(:,:,tmpi)=frame;
    % h=imagesc(F,[0 255]);axis('equal');colormap('gray');
    %axis([0.5 SX+0.5 0.5 SY+0.5])
    %pause
end

movie=movie./255;

ix=size(movie,1);
iy=size(movie,2);
totalframes=size(movie,3);



return
