function [corners] = findCornersGrid(info)
% will give 4 channels at each corner of the grid 
%[UL, UR, LL, LR] 4 by 4 matrix

gridIndicies = info.gridIndicies;

corners = nan(4, 4);

%upper left
counter = 1;
for i = 1:2
   for  j =1:2
       corners(1, counter) = sub2ind(size(info.gridIndicies), i,j);
       counter = counter+1;
   end
end

%upper right 
counter = 1;
for i = 1:2
   for  j = 5:6
       corners(2, counter) = sub2ind(size(info.gridIndicies), i,j);
       counter = counter+1;
   end
end

%lower left 
counter = 1;
for i = 10:11
   for  j = 1:2
       corners(3, counter) = sub2ind(size(info.gridIndicies), i,j);
       counter = counter+1;
   end
end

%lower right 
counter = 1;
for i = 10:11
   for  j = 5:6
       corners(4, counter) = sub2ind(size(info.gridIndicies), i,j);
       counter = counter+1;
   end
end

%putting back into channels 
[corners] = gridIndicies(corners);

end
