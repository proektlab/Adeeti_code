[coeff,score,latent, ~,explained] = pca(aveTrace(setdiff(1:64, info.noiseChannels),:));
PC1=zeros(64,3);

j=1;
for i=1:64
   if ~ismember(info.noiseChannels, i)
       PC1(i,:)=score(j,1:3);
       j=j+1;
   end
    
end

n=zeros(64,1);
for i=1:length(n); n(i)=sqrt(sum(aveTrace(i,:).^2)); end
Theta=PC1./repmat(n,1,3);

%mins=min(PC1,[],1);
%maxs=max(PC1,[],1);
%colors=2.*(PC1-repmat(mins,64,1))./(repmat(maxs,64,1)-repmat(mins,64,1))-1;
colors=Theta;
%%
gridIndicies = [[5 17 0 0 33 53]; ...
                [6 18 28 44 34 54]; ...
                [7 19 29 45 35 55]; ...
                [8 20 30 46 36 56]; ...
                [9 21 31 47 37 57]; ...
                [10 22 32 48 38 58]; ...
                [11 16 27 43 64 59]; ...
                [4 15 26 42 63 52]; ...
                [3 14 25 41 62 51]; ...
                [2 13 24 40 61 50]; ...
                [1 12 23 39 60 49]];
            
            
%%
x=zeros(64,1);
y=zeros(64,1);

for i=1:64
   [r,c]=find(gridIndicies==i);
   x(i)=c;
   y(i)=r;
    
end
figure;
scatter(x, y, 650, colors, 'filled', 's');
set(gca, 'Ydir', 'reverse');