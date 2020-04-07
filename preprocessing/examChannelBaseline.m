function [ noiseChannels ] = examChannelBaseline( baselineData, finalTime, sizeSnippit, numbOfSamp, finalSampR, upperBound, lowerBound )
%creates a vector with the numbers of the channels that correspond to noise 
%takes as matrix assumed to be (channels, samples)
% for each channel takes nS random segments of duration ls (in seconds). Makes a figure showwing these segments. Requests keyboard input of 1 -> good channel or 2- > bad channel. Will then output a set of labels (one for each channel)


% set defaults
if nargin <2
    error('Two inputs required');
elseif nargin <3
    sizeSnippit = 3; %in seconds 
    numbOfSamp = 8;
    finalSampR = 1000;
    upperBound = max(baselineData(:));
    lowerBound = min(baselineData(:));
elseif  nargin < 5
    finalSampR = 1000;
    upperBound = max(baselineData(:));
    lowerBound = min(baselineData(:));
end

% crate layout by finding a reasonable number of rows and columns

r=floor(sqrt(numbOfSamp));
c=ceil(numbOfSamp/r);
h=zeros(numbOfSamp,1);
screensize=get(groot, 'Screensize');

% make random starts from the trace

chanLabel=zeros(size(baselineData,1));

lSeg=floor(sizeSnippit*finalSampR);

% now loop through channels
channelIndex = 1;
% for chan=1:size(dataSnippits,1)
while channelIndex <= size(baselineData,1)
    fh=figure(channelIndex);
    set(fh, 'Position', screensize);
        for j=1:numbOfSamp
           start =randi([finalSampR*sizeSnippit, size(baselineData,2)-finalSampR*sizeSnippit]);               % choose a random start point
           h(j)=subplot(r,c,j);
           plot(finalTime(start: start+lSeg), squeeze(baselineData(channelIndex,start:start+lSeg)));
           %set(h(j), 'Visible', 'off');
           %linkaxes
           set(h(j),'Ylim',[lowerBound upperBound])
        end
        
       dummy=0; 
       while dummy==0 
                temp=input(['Is channel ', num2str(channelIndex), ' good (1 for good 2 for not 3 for back up) ']);
                if isempty(temp)
                    dummy = 0;
                elseif(temp==1 || temp==2 || temp == 3)
                    dummy=1;
                else
                    dummy=0;
                end
                
       end
       
       if temp == 1
       channelIndex = channelIndex + 1;
       elseif temp ==2
       chanLabel(channelIndex) = 1;
       channelIndex = channelIndex + 1;
       elseif temp ==3
           channelIndex = channelIndex - 1;
           if channelIndex < 1
               channelIndex = 1;
           end
       end
       
       close(fh);     
end
       noiseChannels = find(chanLabel == 1);
end

