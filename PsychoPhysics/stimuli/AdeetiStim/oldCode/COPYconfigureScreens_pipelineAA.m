function params = COPYconfigureScreens_pipelineAA(window, params)
% Like info file for the stimulation paradigm 
% Checks how many monitors are connected. Makes sure that the connected monitors have the expected
% dimensions and are running at the expected frame rates.
%
% Input:
% vpixx_monitor - a boolean indicating whether a VPixx monitor is
%   connected.
%
% Output:
% screens - a 1xn array containing the indices of the monitors that the
% stimulus will be displayed on. Sorted by the display order (screens(1)
% will be refreshed first, followed by screens(2),...).
%
% dims - A 1x2 array specifying the x and y dimensions of the screen, in pixels.
%
% fps - the refresh rate in frames per second 

%modifying Medinah's code (5/24/2018)

all_screens = Screen('Screens');

% If more than one monitor connected, display stimuli on all
% non-primary monitors. If only one monitor connected, display stimuli
% on that monitor.

if max(all_screens) == 0
   screens = all_screens;
   warning('No external monitors are connected. Are you sure you want to continue?')
else
    screens = all_screens(all_screens > 0);
end
screenNumber = max(screens);

%save screen and screen colors
params.screenNumber = screenNumber;
params.white = 1;
params.black = 0;
params.gray = 0.5;

% getting screen dimensions
%[window, windowRect] = PsychImaging('OpenWindow', screenNumber, params.gray);

[width, height]=Screen('WindowSize', window);
windowRect=[0 0 width height];

SCREEN_DIMS = [windowRect(3), windowRect(4)];

params.dims=SCREEN_DIMS;
params.window=window;
params.windowRect=windowRect;

FRAME_REFRESH_RATE = 60;

%other stuff
params.drawmask=1;
params.maskStd=50;
params.toneFs=44100;
params.delay = .5;
%% Gamma correctiion info

% load gamma info
%load latest gamma correction
gammaDir='/home/adeeti/';
cd(gammaDir);
if strcmpi(params.monitorInUse, 'testing')
    load('gammaCorrectTestingMonitor.mat')
elseif strcmpi(params.monitorInUse, 'experiment')
    load('gammaCorrectionExpMonitor.mat')
end

% matfiles=dir('ViewPixx*.mat'); %get a listi
% % %then sort by date
% dates(size(matfiles))=matfiles(:).datenum;
% [~,ind]=sort(dates,'descend');
% gammafile={matfiles(ind(1)).name};
% display(['Using Gamma Correction from',gammafile]);
% load(gammafile{:}, 'fittedpower');

params.gamma=gammaTable;

%% testing gamma correction on monitor
% Note here: win_ptr and rect need to be the size of the number of screens
% used
% window = cell(1,length(screenNumber));
% rect = cell(1,length(screenNumber));
% for i = 1:length(screenNumber)
%     [window{i}, rectWindow{i}] = PsychImaging('OpenWindow', screenNumber(i),params.gray);
%     Screen('Preference', 'VisualDebugLevel', 0);
%     PsychColorCorrection('SetEncodingGamma', window{i},1/params.gamma),
%     %Screen('BlendFunction', win_ptr{i}, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); %alpha blending for circles
% end

%%
Screen('FillRect', window, params.gray, params.windowRect); %repmat(params.gray,3,1)
Screen('Flip', window);

% Do this for all screens - check that they all have correct dims
dims = zeros(1,2);
[dims(1), dims(2)] = Screen('WindowSize', screenNumber);

if ~isequal(dims,SCREEN_DIMS)
    warning(...
        ['Monitor does not have the correct dimensions.'])
end

% Check that VPixx monitor refreshes at 120 Hz, all others at 60 Hz.
fps = Screen('FrameRate',window);

% if round(fps) ~= FRAME_REFRESH_RATE
%     warning(...
%         ['FPS for non-ViewPixx monitors must be ' num2str(FPS_VPIXX/2) '.'])
% end

% Hard code the physical screen size for later lookup
[width, height] = Screen('DisplaySize', screenNumber); %in mm

params.phys_dims = [width/10 height/10]; % In cm

observerdDistance = params.distanceToMonitor;
resolutionWidth = params.dims(1);
resolutionHeight = params.dims(2);
screenWidth = params.phys_dims(1);
screenHeight = params.phys_dims(2);


%how many visual degrees in 1 pixel (pixels are square, so height and width
%can be interchanged)
params.pixelCm=screenWidth/resolutionWidth;
params.pixelDeg = rad2deg(2*atan(params.pixelCm/(2*observerdDistance)));



params.dims = dims;
params.fps = fps;
[params.center(1), params.center(2)] = RectCenter(params.windowRect);


end