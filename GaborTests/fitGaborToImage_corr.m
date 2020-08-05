function [fitParameters, score, correlation, gridX, gridY, parameters] = fitGaborToImage_corr(imageToFit, debug, expParams, lambda)

if ~exist('imageToFit') || isempty(imageToFit)
    imageToFit = rand(100, 100);
end

if ~exist('debug') || isempty(debug)
    debug = 0;
end

if ~exist('expParams') || isempty(expParams)
    expParams = [];
end

if ~exist('lambda') || isempty(lambda)
    lambda = 1;
end

%%

imagePower = abs(imageToFit);

%  imageToFit = (imageToFit - nanmin(imageToFit(:)));
%  imageToFit = imageToFit / (nanmax(imageToFit(:)) - nanmin(imageToFit(:)));

[gridX, gridY] = meshgrid(1:size(imageToFit,2), 1:size(imageToFit,1));
gridX(isnan(imageToFit)) = nan;
gridY(isnan(imageToFit)) = nan;

%Initialize parameters
if 1%isempty(expParams)
    backgroundIntensity = nanmean(imageToFit(:));
    gaussianIntensity = nanmax(imageToFit(:)) - backgroundIntensity;
    sigmaValueX = size(imageToFit,2)/4;
    sigmaValueY = size(imageToFit,1)/4;
    wavelength = 1;
    angle = pi/4;
    phi = pi/2;
    psi = pi/2;
    
    parameters(1) = (size(imageToFit,2) + 1)/2; %centerX
    parameters(2) = (size(imageToFit,1) + 1)/2; %centerY
    parameters(3) = gaussianIntensity;
    parameters(4) = backgroundIntensity;
    parameters(5) = sigmaValueX;
    parameters(6) = sigmaValueY;
    parameters(7) = wavelength;
    parameters(8) = angle;
    %parameters(9) = phi;
    %parameters(10) = psi;
else
    parameters =expParams;
end


% gaborApproximation = makeGaborTestImage(gridX, gridY, parameters(1), parameters(2), parameters(3), parameters(4), parameters(5), parameters(6), parameters(7), parameters(8), parameters(9));
% figure(1);
% clf;
% imagesc(gaborApproximation)
% return

% options =  optimset('MaxIter', 10000, 'Display', 'iter', 'TolX', 1/100000000);
% [parameters, fval] = fmincon( @doFit, parameters, [], [], [], [], ...
%     [1, 1, 0, 0, 0.1, 0.1, 0.1, -pi, -pi, -pi], ...
%     [size(imageToFit,2), size(imageToFit,1), 1, 1, size(imageToFit,2)/2, size(imageToFit,1)/2, max(size(imageToFit)), pi, pi, pi], ...
%     [], options);

lowerBound = [1, 1, nanmin(imageToFit(:)), nanmin(imageToFit(:)), 0.1, 0.1, 0.1, -pi]; %, -pi];%, -pi];
upperBound = [size(imageToFit,2), size(imageToFit,1), nanmax(imageToFit(:)), nanmax(imageToFit(:)), size(imageToFit,2)/4, size(imageToFit,1)/4, max(size(imageToFit)), pi]; %, pi];%, pi];


% options = optimoptions(@fmincon,'Algorithm','sqp');
% problem = createOptimProblem('fmincon','objective',@doFit,'x0',parameters,'lb',lowerBound,'ub',upperBound, 'options', options);
% ms = MultiStart;
% [parameters, fval] = run(ms,problem,100);


% options = optimoptions('ga', 'ConstraintTolerance',1e-6, 'FunctionTolerance', 1e-100 * sum(~isnan(imageToFit(:))), 'MaxGenerations', 2000);
% [parameters] = ga( @doFit, 9, [], [], [], [], ...
%     [-size(imageToFit,2), -size(imageToFit,1), 0, 0, 0.1, 0.1, 0.1, -pi, -pi], ...
%     [size(imageToFit,2), size(imageToFit,1), 1, 1, size(imageToFit,2), size(imageToFit,1), max(size(imageToFit)), pi, pi], ...
%     [],options);

options = optimoptions('particleswarm', 'FunctionTolerance', 1e-100 * sum(~isnan(imageToFit(:))), 'InitialSwarmMatrix', parameters);
[parameters, fval] = particleswarm( @doFit, length(parameters), ...
    lowerBound, ...
    upperBound, ...
    options);

% options = optimoptions('simulannealbnd', 'FunctionTolerance', 1e-100 * sum(~isnan(imageToFit(:))));
% [parameters] = simulannealbnd( @doFit, parameters, ...
%     [-size(imageToFit,2), -size(imageToFit,1), 0, 0, 0.1, 0.1, 0.1, -pi, -pi], ...
%     [size(imageToFit,2), size(imageToFit,1), 1, 1, size(imageToFit,2), size(imageToFit,1), max(size(imageToFit)), pi, pi], ...
%     options);

gaborApproximation = makeGaborTestImage(gridX, gridY, parameters(1), parameters(2), parameters(3), parameters(4), parameters(5), parameters(6), parameters(7), parameters(8)); %, parameters(9));%, parameters(10));

gainedGabor = gaborApproximation;
% gainedGabor = (gainedGabor - nanmin(gainedGabor(:)));
% gainedGabor = gainedGabor / (nanmax(gainedGabor(:)) - nanmin(gainedGabor(:)));

%Crop out fit gaussian from original image
croppedImage = imageToFit;
% croppedImage = (croppedImage - nanmin(croppedImage(:)));
% croppedImage = croppedImage / (nanmax(croppedImage(:)) - nanmin(croppedImage(:)));
% croppedImage(gainedGabor < 0.1) = 0;

imageTotal = sqrt(nansum(croppedImage(:)));
guassianTotal = sqrt(nansum(gainedGabor(:)));

croppedImage(isnan(croppedImage)) = 0;
gainedGabor(isnan(gainedGabor)) = 0;

fitScore = corr(croppedImage(:), gainedGabor(:));

correlation = fitScore;
score = fval;

fitParameters = struct;
fitParameters.centerX = parameters(1);
fitParameters.centerY = parameters(2);
fitParameters.sigmaX = parameters(5);
fitParameters.sigmaY = parameters(6);
fitParameters.amplitude = parameters(3);
fitParameters.background = parameters(4);
fitParameters.wavelength = parameters(7);
fitParameters.theta = parameters(8);
%fitParameters.phi = parameters(9);
%fitParameters.psi = parameters(10);

if debug
    gaborApproximation = makeGaborTestImage(gridX, gridY, ...
        parameters(1), parameters(2), parameters(3), parameters(4), parameters(5), ...
        parameters(6), parameters(7), parameters(8));%, parameters(9));%, parameters(10));
    figure(1);
    clf;
    subplot(1,2,1)
    imagesc(imageToFit)
    subplot(1,2,2)
    imagesc(gaborApproximation)
    sgtitle(fitScore);
end

    function error = doFit(parameters)
        % doFit : does the gaussian fit to the foci and calculates the
        % error.
        %parameters are :
        %parameter(1) - Sub-pixel resolution of foci position X
        %parameter(2) - Sub-pixel resolution of foci position Y
        %parameter(3) - Intensity of the gaussian
        %parameter(4) - background intensity
        %parameter(5) - sigma of gaussian X
        %parameter(6) - sigma of gaussian Y
        %parameter(7) - wavelength
        %parameter(8) - spatial angle
        %parameter(9) - spatial phase
        %parameter(10) - gaussian spatial phase
        gabor = makeGaborTestImage(gridX, gridY, parameters(1), parameters(2), parameters(3), parameters(4), parameters(5), parameters(6), parameters(7), parameters(8));%, parameters(9));%, parameters(10));
%         tempImage = (double(imageToFit) - gabor);
%         errorImage = nansum((abs(tempImage(:)) .* imagePower(:)).^2);
%         SSReg = nansum(gabor(:) - nanmean(imageToFit(:)).^2);
%         SSRes = nansum(gabor(:) - nanmean(imageToFit(:)).^2);
%         SST =nansum((imageToFit(:) - gabor(:)).^2);
%         %R2ed = SSReg/SST;
%         R2ed = 1- (SSRes/SST);
       errorImage = -corr(imageToFit(:), gabor(:)); %nansum(abs((1-R2ed)*imagePower(:).^2));
        if isempty(expParams)
            errorParams = 0;
        else
            paramDiffs = abs(parameters - expParams);
            paramDiffs(8) = abs(angleDiff(parameters(8), expParams(8)));
            
            %paramDiffs(8:9) = abs(angleDiff(parameters(8:9), expParams(8:9)));
            %paramDiffs(8:10) = abs(angleDiff(parameters(8:10), expParams(8:10)));
            errorParams = mean(paramDiffs ./ (upperBound - lowerBound));% * numel(imageToFit);
        end
        error = errorImage + lambda*errorParams;
    end
end