%
%extracts events from a neuralynx events file.
%
%urut/may04
function events = getRawTTLs(filename)

FieldSelection(1) = 1;%timestamps
FieldSelection(2) = 1;
FieldSelection(3) = 1;%ttls
FieldSelection(4) = 1;
FieldSelection(5) = 1;
ExtractHeader = 1;
ExtractMode = 1;
%ModeArray(1)=fromInd;
%ModeArray(2)=toInd;

[timestamps, test1,  ttls,test2,test3,header] = Nlx2MatEV_v3(filename, FieldSelection, ExtractHeader, ExtractMode);
header

events=zeros(size(ttls,2),2);
events(:,1) = timestamps';
events(:,2) = ttls';
