function [xCircle, yCircle] = plotCircle(x,y,r,angleDelta,plotOn)
% syntax: [x+xp, y+yp] = plotCircle(x,y,r, angleDelta, plotOn)
%x and y are the coordinates of the center of the circle
%r is the radius of the circle
%angleDelta is the angle step, bigger values will draw the circle faster but
%you might notice imperfections (not very smooth), defualt is 0.01, plotOn
%= 1 will plot, if empty or plotOn = 0, will not plot 

if nargin <5 
    plotOn = 0;
end

if nargin <4
    angleDelta = 0.1;
end

ang=0:angleDelta:2*pi; 
xCircle=r*cos(ang);
yCircle=r*sin(ang);

xCircle = x + xCircle;
yCircle = y+ yCircle;

if plotOn == 1
plot(xCircle, yCircle);
end
