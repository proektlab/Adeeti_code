function [ chanLabel ] = examChannelFullTrace( griddata, Fs, ns, ls, ub, lb )
%creates a vector with the numbers of the channels that correspond to noise 
%takes as matrix assumed to be (channels, samples)
% for each channel takes nS random segments of duration ls (in seconds). Makes a figure showwing these segments. Requests keyboard input of 1 -> good channel or 2- > bad channel. Will then output a set of labels (one for each channel)


% set defaults
if nargin <2
    error('Two inputs required');
elseif nargin <3
    ns=36;
    ls=1;
elseif nargin <4
    ls=1;
end

% crate layout by finding a reasonable number of rows and columns

r=floor(sqrt(ns));
c=ceil(ns/r);
h=zeros(ns,1);

% make random starts from the trace

lSeg=floor(ls*Fs);                     % length of segment in data points;
chanLabel=[];

% now loop through channels
for i=1:size(griddata,1)
    fh=figure(i);
    set(fh, 'Position', [2561,1,2560,988]);
        for j=1:ns
           start=randsample(size(griddata,2)-lSeg,1);               % choose a random start point
           h(j)=subplot(r,c,j);
           plot(griddata(i,start:start+lSeg));
           %set(h(j), 'Visible', 'off');
           %linkaxes
           set(h(j),'Ylim',[lb ub])
        end
        
       dummy=0; 
       while dummy==0 
                temp=input('Is this channel good (1 for good 2 for not) ');
                if(temp==1 || temp==2)
                    dummy=1;
                else 
                    dummy=0;
                end
                
       end
       
       if temp ==2
       chanLabel = [chanLabel, i];
       end
       
       close(fh);     
end

end

