%for some reason ubuntu doesn't have the codecs for videowriter, so I'll
%convert mat files into videos on my desktop machine
cd('C:\Users\Madineh\Dropbox\Mouse\stimuli\Natural Noise Movies\');
addpath('C:\Users\Madineh\Dropbox\Mouse\stimuli\');


for file=1:19
     file

    
    number=num2str(file,'%02d');
    nameload=(['s',number,'.144x96x1']);
    namesave=['noisefile_',number];
    
    fn=(nameload);
    fid = fopen(fn,'r');
    H = fread(fid,15);
    SX=24;
    SY=16;
    
    fid = fopen(fn,'r');
    HEADER = setstr(H')
    
    TT=901;
    tmp0=0;
    fseek(fid,SX*SY*tmp0*1,0);
    [G,COUNT] = fread(fid,[SX,SY*TT],'uchar');
    
    movie_small=zeros(SX,SY,TT);
    for tmpi=(tmp0+1):(tmp0+TT)
        frame=G(:,1+(tmpi-1)*SY:(tmpi+0)*SY);
        movie_small(:,:,tmpi)=frame;
    end
    
    movie_small=movie_small./255;
    
    %now turn it into a bigger matrix (720x480)
    factor=720/24;
    movie=zeros(720,480,TT);
    for t=1:TT
       
        for i=1:SX
            for j=1:SY   
                movie((i-1)*factor+1:i*factor,(j-1)*factor+1:j*factor,t)=movie_small(i,j,t);
            end
        end
        
    end
    
    ix=size(movie,1);
    iy=size(movie,2);
    totalframes=size(movie,3);
    
    
    clearvars -except file movie ix iy totalframes namesave
    %same the mat file
    save([namesave,'.mat'],'-v7.3');

    %now turn into a movie
    v=VideoWriter([namesave,'.mp4'],'MPEG-4');
    v.FrameRate = 60;
    open(v);
    
    colormap('gray');
    
    for i=1:totalframes 
        img=imagesc(movie(:,:,i)');
        frame=img.CData;
        writeVideo(v,frame);
    end
    
    % now close
    close(v);
    
    clear v img frame 
    
end

