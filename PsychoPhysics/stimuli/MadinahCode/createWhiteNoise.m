function [blurredimage,totalFrames,blockStart]=createWhiteNoise(params,rectSize,numBlocks,numFramesPerBlock)

whitecode=1;
blackcode=0;
graycode=0.5;

%make the filter
boxKernel = ones(3,3); % Or whatever size window you want.

%make the noise ahead of time
% Set the colors of each of our squares
numSquares=rectSize*rectSize;
for ii=1:numFramesPerBlock
    bwColors{ii}=zeros(rectSize,rectSize);
    indwhite=randperm(numSquares,floor(numSquares/2));
    for j=1:length(indwhite)
        bwColors{ii}(ind2sub([rectSize,rectSize],indwhite(j)))=[whitecode];
    end
end
grayColors=graycode.*ones(rectSize,rectSize);


% put in gray screens between each block
numFramesBtwnBlocks=100;
totalFrames=numBlocks*(numFramesPerBlock+numFramesBtwnBlocks)
% get the index of block starts
for i=1:numBlocks
    if i==1
        bwstart(i)=1;
    else
        bwstart(i)=(numFramesPerBlock*(i-1))+(numFramesBtwnBlocks*(i-1))+1;
    end
    bwend(i)=bwstart(i)+numFramesPerBlock-1;
    graystart(i)=bwend(i)+1;
    grayend(i)=graystart(i)+numFramesBtwnBlocks-1;
end


for ii=1:totalFrames
    %find the closest blockstart
   
    temp=ii-bwstart;
    blkind=intersect(find(temp>=0),find(temp<numFramesPerBlock+numFramesBtwnBlocks));
    
    sinceblk=ii-bwstart(blkind)+1;
    if sinceblk<=numFramesPerBlock
        noiseimage{ii}=bwColors{sinceblk};
    else %we're in gray frames
        grayind=ii-graystart(blkind)+1;
        noiseimage{ii}=grayColors;
    end
    
    %now filter the frame
    tempimage = conv2(noiseimage{ii}, boxKernel, 'same');
    %normalize so it's on the same scale
    mintemp=min(tempimage(:)); 
    maxtemp=max(tempimage(:));
    scaledimage= whitecode.*((tempimage-mintemp) ./ (maxtemp-mintemp));
    scaledimage(scaledimage>graycode)=whitecode;
    scaledimage(scaledimage<=graycode)=blackcode;
    blurredimage{ii}=scaledimage;
    
    %put the gray back in
    if sinceblk>numFramesPerBlock
         blurredimage{ii}=grayColors;
    end

    %now switch to params coding
    temp1=find(blurredimage{ii}==whitecode);
    blurredimage{ii}(temp1)=params.white;
    temp2=find(blurredimage{ii}==graycode);
    blurredimage{ii}(temp2)=params.gray;

    clear blkind sinceblk grayind tempimage
end

blockStart=bwstart;
    
return