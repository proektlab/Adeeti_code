function [L, P]= projOnLDA_softmax(W_LDA, data2project)
% [L, P]= projOnLDA_softmax(W_LDA, data2project)

% project train data on LDA
L = [ones(size(data2project,1),1) data2project]*W_LDA';

P = exp(L) ./ repmat(sum(exp(L),2),[1 size(W_LDA,1)]);

if size(W_LDA,1)<3
    P(:,3) = zeros(size(P,1),1);
end
