function [pixelWidth, pixelHeight, spatialFrequencyPixelWidth, spatialFrequencyPixelHeight]...
    = AngletoPixelBox (visualAngleWidth, visualAngleHeight, spatialFrequency, params);

%Inputs
   
% visualAngleWidth: horizontal visual angle of grating 
% visualAngleHeight: vertical visual angle of grating 
% spatialFrequency: spatial frequency

% param inputs
% observerdistance: distance between eyes and monitor

% params.resolutionWidth: horizontal resolution
% params.resolutionHeight: vertical resolution

% params.screenWidth: width of screen (needs to be adjusted for different screens)
% params.screenHeight: height of screen (needs to be adjusted for different screens)

%Outputs: Pixelwith and heght to input into grating functions
 

observerdistance = params.distanceToMonitor;

resolutionWidth = params.dims(1);
resolutionHeight = params.dims(2);
screenWidth = params.phys_dims(1);
screenHeight = params.phys_dims(2);


pixelWidth = round(tan(degtorad(visualAngleWidth/2))*2*observerdistance*resolutionWidth/screenWidth);
pixelHeight = round(tan(degtorad(visualAngleHeight/2))*2*observerdistance*resolutionHeight/screenHeight);

spatialFrequencyPixelWidth = spatialFrequency/(pixelWidth*2);
spatialFrequencyPixelHeight = spatialFrequency/(pixelHeight*2);

%switch from cycles per degree to cycles per pixel
%cyc/pixel=cyc/deg*deg/piel

%how many visual degrees in 1 pixel
pixelWidthCm=screenWidth/resolutionWidth;
pixelWidthDeg = rad2deg(2*atan(pixelWidthCm/(2*observerdistance)));


return
