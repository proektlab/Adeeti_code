function [expIDNum] = findExpIDNum(mouseID)
% [expIDNum] = findExpIDNum(mouseID)
% mouseID is a string of mouse name 

if contains(mouseID, 'GL')
    expIDNum = str2num(mouseID(3:end));
    expIDNum = -expIDNum;
elseif contains(mouseID, 'CB')
    expIDNum = str2num(mouseID(3:end));
elseif contains(mouseID, 'IP')
    expIDNum = 0;
end