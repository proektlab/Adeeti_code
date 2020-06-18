function [ff, pTable, compTitle] = deconstPspreadTable(P_RS_Spread, comp, thresh, compTitle, titleThresh, xTitles)
%[ff, pTable] = deconstPspreadTable(P_RS_Spread, titleString, comp)

if nargin<2 || isempty(comp)
    comp = [1:size(P_RS_Spread,4)];
end

if nargin<3 || isempty(thresh)
    thresh =[1:size(P_RS_Spread,2)];
end

screensize=get(groot, 'Screensize');

pTable = [];
allComp = [];

countComp = 0;
%%
for i = 1:length(comp)
    for j = i+1:length(comp)
        countComp =  countComp +1;
        disp(['i =',  num2str(i), ' j=', num2str(j), ' countComp=', num2str(countComp)]) 
        eval(['comp' num2str(comp(i)), '_', num2str(comp(j)), ' = P_RS_Spread(:,thresh,', ....
            num2str(comp(i)), ',' num2str(comp(j)), ');'])
        
        allComp(countComp,:) = [i, j];
        eval(['tempComp = comp', num2str(comp(i)), '_', num2str(comp(j)), ';'])
        pTable(countComp,:,:) = tempComp;
    end
end


%%
ff= figure;
ff.Position = screensize;
ff.Color = 'white';
for c = 1:countComp
    subplot(countComp,1,c)
    
    plot([1:size(pTable,2)],squeeze(pTable(c,:,:)))
    set(gca, 'xlim', [1,size(pTable,2)])
     set(gca,'xticklabel',xTitles)
   title(['Comparing ', cell2mat(compTitle(allComp(c,1))), ' and ',...
       cell2mat(compTitle(allComp(c,2)))])
   legend(titleThresh);
  

end


%%
