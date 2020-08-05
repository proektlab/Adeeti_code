function params = configureScreens_pipeline(params)
% Checks how many monitors are connected, and which of them are VPixx
% displays. Makes sure that the connected monitors have the expected
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

%modifying drew's code (5/16/2015)

SCREEN_DIMS = [1920 1200];
params.dims=SCREEN_DIMS;
FPS_VPIXX = 120;

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
%save screen and screen colors
params.screenNumber = screens;
params.white = 1;
params.black = 0;
params.gray = 0.5;


% load gamma info
%load latest gamma correction
%current_dir=cd;
%cd('/Users/contreras/Dropbox/Mouse/stimuli/expStimuli/');
matfiles=dir('ViewPixx*.mat'); %get a listi
%then sort by date
dates(size(matfiles))=matfiles(:).datenum;
[~,ind]=sort(dates,'descend');
gammafile={matfiles(ind(1)).name};
display(['Using Gamma Correction from',gammafile]);
load(gammafile{:}, 'fittedpower');
params.gamma=fittedpower;


% Note here: win_ptr and rect need to be the size of the number of screens
% used
window = cell(1,length(screens));
rect = cell(1,length(screens));
for i = 1:length(screens)
    [window{i}, rect{i}] = PsychImaging('OpenWindow', screens(i),params.gray);
    Screen('Preference', 'VisualDebugLevel', 0);
    PsychColorCorrection('SetEncodingGamma', window{i},1/params.gamma),
    %Screen('BlendFunction', win_ptr{i}, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); %alpha blending for circles
end

%save the vpixx window parameters for later use

params.window=window{1};
params.windowRect=rect{1};



% Set window colors to the Vpixx standard
for i = 1:length(screens)
    Screen('FillRect', window{i}, params.gray, rect{i}); %repmat(params.gray,3,1)
    Screen('Flip', window{i});
end

% Do this for all screens - check that they all have correct dims
dims = zeros(1,2);
for i = 1:length(screens)
    [dims(1), dims(2)] = Screen('WindowSize',screens(i));
    
    if ~isequal(dims,SCREEN_DIMS)
        warning(...
        ['Monitor ' num2str(i) ' does not have the correct dimensions.'])
    end
end

% Check that VPixx monitor refreshes at 120 Hz, all others at 60 Hz.
for i = 1:length(screens)    
    fps_i = Screen('FrameRate',window{i});
    
    if i == 1
        if params.vpixx_monitor
            %fps_i=Screen('FrameRate',win_ptr{i},2,FPS_VPIXX); % To attempt
            % to force it - doesn't seem to work correctly
            assert(round(fps_i) == FPS_VPIXX, ...
                ['FPS for ViewPixx monitor must be ' num2str(FPS_VPIXX) '.'])
        else
            if round(fps_i) ~= FPS_VPIXX/2
                warning(...
                    ['FPS for non-ViewPixx monitors must be ' num2str(FPS_VPIXX/2) '.'])                
            end
        end
        
        fps = fps_i; % Use the framerate of the first one as the master
    else
        if round(fps_i) ~= FPS_VPIXX/2
            warning(...
                ['FPS for non-ViewPixx monitors must be ' num2str(FPS_VPIXX/2) '.'])                
        end
    end        
end

% Hard code the physical screen size for later lookup
if params.vpixx_monitor
    params.phys_dims = [48.46 30.29]; % In cm
elseif ~ismac % dell monitor dimensions
    params.phys_dims = [59.79 33.63];
else 
    params.phys_dims = [33.02 30.48];
    % Figure this out for my monitor at home.
end


observerdistance = params.distanceToMonitor;
resolutionWidth = params.dims(1);
resolutionHeight = params.dims(2);
screenWidth = params.phys_dims(1);
screenHeight = params.phys_dims(2);


%how many visual degrees in 1 pixel (pixels are square, so height and width
%can be interchanged)
params.pixelCm=screenWidth/resolutionWidth;
params.pixelDeg = rad2deg(2*atan(params.pixelCm/(2*observerdistance)));



params.dims = dims;
params.fps = fps;
params.rect = rect;
[params.center(1), params.center(2)] = RectCenter(params.rect{1});

%sca
end