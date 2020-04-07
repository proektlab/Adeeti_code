%% decimate all channels
dF=10;      % decimation factor;
s1=size(noPreStimData,1);
s2=size(noPreStimData,2);
s3=size(decimate(rand(size(noPreStimData,3),1), dF),1);     % get size of decimated vector;

Ddata=zeros(s1,s2,s3);

for i=1:s1
   for j=1:s2
       Ddata(i,j,:)=decimate(squeeze(noPreStimData(i,j,:)), dF);
   end           
end

%%

dF=10;      % decimation factor;
s1=size(noPreStimData,1);
s2=size(noPreStimData,2);
s3=size(decimate(rand(size(noPreStimData,3),1), dF),1);     % get size of decimated vector;

AddData=zeros(s1,s2,s3);

for i=1:s1
   for j=1:s2
       AddData(i,j,:)=decimate(squeeze(noPreStimData(i,j,:)), dF);
   end           
end

Ddata = horzcat(AddData,Ddata);

%%
RData=zeros(size(Ddata,1)*size(Ddata,3),size(Ddata,2));
for i=1:size(RData,2)
   RData(:,i)=reshape(squeeze(Ddata(:,i,:)),[],1); 
    
    
end
%%
[T,PVAR,W,L] = Alexpca(RData-repmat(mean(RData,2), 1, size(RData,2)));

%%
[T,PVAR,W,L] = Alexpca(RData);


%%
%%PCA on concatatated data 

noPreStimData = meanSubData(setdiff(1:64, info.noiseChannels),:, 1001:2001);

useData = squeeze(reshape(permute(noPreStimData, [1, 3, 2]), size(noPreStimData, 2), (size(noPreStimData, 1)*size(noPreStimData,3))));
%concatonated data within channels

%useData = squeeze(reshape(permute(noPreStimData, [3, 2, 1]), 1, (size(noPreStimData, 1)*size(noPreStimData, 2)*size(noPreStimData,3))));
%all data concatonated into single vector

covData = useData*useData';

[coeff,score,latent, ~,explained] = pca(covData);

%%

plotData = squeeze(noPreStimData(1,:,:));

plotData = reshape(plotData', 1, size(plotData,1)*size(plotData,2));
