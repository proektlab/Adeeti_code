function [SVDout, SpatialAmp, SpatialPhase, TemporalAmp, TemporalPhase,GridOut ] = WaveSVD(data, N, rearrange2Gr, Grid, BadChannels, Channels)
%UNTITLED2 Summary of this function goes here
% data is space by time matrix;
%  N is the number of components to take.
% Grid is an array where every element is the position
% of an electrode in the array.
% Channels is the total number of channels.
% BadChannels are missing or noisy channels. It is assumed that those were
% eliminated from data.

H=zeros(size(data));
for i=1:size(data,1)
    H(i,:)=hilbert(data(i,:));
end
[U, S,V]=svd(H);
SVDout.U=U;
SVDout.S=S;
SVDout.V=V;
% now lets compute the spatial modes
A=U*S;
A=A(:, 1:N);                % only take N-modes
SpatialAmp=real(A);
SpatialPhase=angle(A);
B=V*S';
B=B(:,1:N);             % only take N-modes
TemporalAmp=real(B);
TemporalPhase=angle(B);
%% now we can plot the modes onto electrode grid.

if rearrange2Gr ==1
    goodChannels=setdiff(1:Channels, BadChannels);
    %     rows=[];
    %     columns=[];
    %     for i=1:length(goodChannels)
    %         [r,c]=find(Grid==goodChannels(i));       % identify positions of all electroes.
    %         rows(end+1)=r;
    %         columns(end+1)=c;
    %     end
    GridOut.data=rearrangeData(data, data,  Grid, goodChannels);
    GridOut.SpatialAmp=rearrangeData(SpatialAmp, data, Grid, goodChannels);
    GridOut.SpatialPhase=rearrangeData(SpatialPhase, data, Grid, goodChannels);
    
else
    GridOut = [];
end

    function [X]=rearrangeData(D, data, GR, goodChannels)
        %function [X]=rearrangeData(D, data, row, column, GR, goodChannels)
        % identify which dimension is space
        
        SpaceDim=find(size(D)==size(data,1));          % identify space dimension in D
        TimeDim=setdiff(1:2, SpaceDim);                % the other dimension is "time"
        X=NaN(size(GR,1), size(GR,2), size(D,TimeDim));
        % now iterate over space dimension
        %         for ii=1:length(goodChannels) %size(D, SpaceDim)
        %             if SpaceDim==1
        %                 X(row(ii), column(ii), :)=D(ii,:);
        %             elseif SpaceDim==2
        %                 X(row(ii), column(ii), :)=D(:,ii);
        %             end
        %         end
        
        for xs = 1:size(GR,1)
            for ys = 1:size(GR,2)
                if ismember(GR(xs,ys), goodChannels)
                    if SpaceDim==1
                        X(xs,ys,:) = D(GR(xs,ys),:);
                    elseif SpaceDim==2
                        X(xs,ys,:) = D(:,GR(xs,ys));
                    end
                end
            end
        end
        
    end
end


