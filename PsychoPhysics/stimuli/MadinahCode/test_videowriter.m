%load matrix (run this after you've run loadmymovie_randomnoise, which
%creates and saves mat files to be used here)


for file=0
    file 
    clearvars -except file
    
    number=num2str(file,'%02d');
    name=(['moviefile_',number]);
    matfilename= ([name,'.mat']);
    T=load( matfilename, ['moviemat',number])
    moviemat=T.(['moviemat',number]);
    clear T
    
    % now rite video file
    v=VideoWriter([name,'.mp4'],'MPEG-4');
    v.FrameRate = 60;
    open(v);
    
    colormap('gray');
    
    for i=1:1802  
        img=imagesc(circshift(moviemat(:,:,i)',[0,-15,0]));
        frame=img.CData;
        writeVideo(v,frame);
    end
    
    % now close
    close(v);
    
end