function testImage = makeGaborTestImage(gridX, gridY, fociX, fociY, amplitude, backgroundIntensity, sigmaValueX, sigmaValueY, wavelength, theta)%, phi)%, psi)
%testImage = makeGaborTestImage(gridX, gridY, fociX, fociY, amplitude, backgroundIntensity, sigmaValueX, sigmaValueY, wavelength, theta, phi, psi)
% 
    centeredX = (gridX - fociX);
    centeredY = (gridY - fociY);
    phase = centeredX*cos(theta) + centeredY*sin(theta);
    
%     gaussianX = centeredX*cos(psi) + centeredY*sin(psi);
%     gaussianY = -centeredX*sin(psi) + centeredY*cos(psi);

    gaussianX = centeredX*cos(theta) + centeredY*sin(theta);
    gaussianY = -centeredX*sin(theta) + centeredY*cos(theta);
    
    %testImage = backgroundIntensity + amplitude * exp( -(gaussianX.^2/(2 * sigmaValueX^2) + gaussianY.^2/(2 * sigmaValueY^2))) .* cos(2*pi*phase/wavelength + phi);
    testImage = backgroundIntensity + amplitude * exp( -(gaussianX.^2/(2 * sigmaValueX^2) + gaussianY.^2/(2 * sigmaValueY^2))) .* cos(2*pi*phase/wavelength);
%         testImage = backgroundIntensity + gaborIntensity .* cos(phase/wavelength + phi);
end