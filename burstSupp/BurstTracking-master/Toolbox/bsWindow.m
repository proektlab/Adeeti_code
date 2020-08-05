function res = bsWindow(signal,varargin)

%set default params
p = inputParser;
p.StructExpand = false;
p.addParameter('windowSize', 700, @isnumeric)
p.addParameter('step', 5, @isnumeric)
p.addParameter('type','power',@ischar)
p.addParameter('interpolate',true, @(x)((islogical(x))||(isempty(x))))
p.addParameter('padding','none',@ischar)

p.parse(varargin{:});
windowSize = p.Results.windowSize;
step = p.Results.step;
type = p.Results.type;
padding = p.Results.padding;
interpolate = p.Results.interpolate;

dataLength = length(signal);

len = ceil((dataLength - windowSize)/step);

query = linspace(1,len,(dataLength - windowSize));

res = zeros(1,len);

%creates different windows of size windowSize moving forward by step.
%returns average into array res
for idx = 1:(len)
    
    shift = step*(idx-1);
    
    dT = signal( (1:windowSize) + shift );
    
    switch type
        case 'mean'
            res(idx) = mean(dT);
        case 'abs'
            res(idx) = mean(abs(dT));
        case 'power'
            res(idx) = mean(dT.^2);
        case 'dev'
            res(idx) = std(dT);
        otherwise
            error('type should be one of: mean / abs / dev / power')
    end
end

%interpolates if the step size is small
if step > 1 && interpolate
    res = interp1(1:len,res,query);
end

%padding
switch padding(1:3)
    case 'nan'
        pads = NaN(1,windowSize);
    otherwise
        pads = zeros(1,windowSize);
end

switch padding((length(padding)-3):length(padding))
    case 'ront'
        res = [ pads interp1(1:len,res,query)];
    case 'back'
        res = [ interp1(1:len,res,query) pads];
    case 'atch'
        res = [ pads(1:floor(windowSize/2)) interp1(1:len,res,query) pads(1:ceil(windowSize/2))];
    case 'none'
        return
    otherwise
        error("pad should be: front/nanfront, back/nanback, match/nanmatch or none")
end

end