function [SF_cyclesPerPixel]...
    = AngletoPixelSF (SF_cyclesPerDeg, params)
%6/24/2016
%The grating functions I use (based off of the driftdemo series) take the
%spatial frequency as pixels per degree. Units relevant to me are cycles
%per degree, so this file converts between the two assuming some parameters
%like size and resolution of the screen, and distance from monitor.

%Inputs   
% SF_cyclesPerDeg: spatial frequency in cycles per degree 


% param inputs
% observerdistance: distance between eyes and monitor

% params.resolutionWidth: horizontal resolution
% params.resolutionHeight: vertical resolution

% params.screenWidth: width of screen (needs to be adjusted for different screens)
% params.screenHeight: height of screen (needs to be adjusted for different screens)

%Outputs: spatial frequency in pixels per degre
 
%if no param structure is provided, use defaults
if nargin<2
observerdistance = 30; %cm
resolutionWidth = 1920; %cm
resolutionHeight = 1200;
screenWidth = 48.6;
screenHeight = 30.29;   
%calculate how many visual degrees are in a pixel
pixelCm=screenWidth/resolutionWidth;
pixelDeg = rad2deg(2*atan(pixelCm/(2*observerdistance)));

else
pixelCm=params.pixelCm;
pixelDeg = params.pixelDeg;

end

%switch from cycles per degree to cycles per pixel
%cyc/pixel=cyc/deg*deg/pixel

SF_cyclesPerPixel=SF_cyclesPerDeg*pixelDeg;
return
