function DatapixxGammaCorrection(varargin)
% DatapixxGammaCorrection([screenNumber])
%
% Doing the gamma correction for a CRT monitor, using Datapixx
%
% Sept 3, 2010 Jenny Read, heavily based on code from Peter April of VPixx
% June 16, 2016 Madineh Sarvestani, modifying to use a manual photometer,
% not wired

nbits = 16; % number of bits you have - 16 for DATAPixx, 8 normally
npixvals = 9; % number of pixel values to test
timetoleavelab  = 0; % time to allow user to turn off lights, get out of lab and close doors etc.
savefile = 'ViewPixxPM100_20160613.mat';


t0=GetSecs;
try	
	AssertOpenGL;
	
	% Configure PsychToolbox imaging pipeline to use 32-bit floating point numbers.
	% Our pipeline will lumalso implement an inverse gamma mapping to correct for display gamma.
	PsychImaging('PrepareConfiguration');
	PsychImaging('AddTask', 'General', 'FloatingPoint32Bit');
	PsychImaging('AddTask', 'General', 'EnableDataPixxM16Output');
	PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'SimpleGamma');
	
	% Open our window.
	if nargin>0
		screenNumber=varargin{1};
	else
		% Assume that the DATAPixx is connected to the highest number screen.
		screenNumber=max(Screen('Screens'));
	end
	
	%NB You may need this if you have not used the Pipeline before:
	%BitsPlusImagingPipelineTest(screenNumber)length(relpixvals)
	
	oldVerbosity = Screen('Preference', 'Verbosity', 1);   % Don't log the GL stuff
	[win, winRect] = PsychImaging('OpenWindow', screenNumber);
	Screen('Preference', 'Verbosity', oldVerbosity);
	winWidth = RectWidth(winRect);
	winHeight = RectHeight(winRect);
	
	% Ensure that the graphics board's gamma table does not transform our pixels
    % Update: not needed, PsychImaging already calls LoadIdentityClut(),
    % which is better than manually setting up the identity Gamma table
    % below.
	%Screen('LoadNormalizedGammaTable', win, linspace(0, 1, 256)' * [1, 1, 1]);
    
%     % Open a serial port to the photometer: - NB dev/ttyUSB1 is  the USB port on
%     % the front of the PC

    %Madineh's photometer can't be read by matlab, so change code below to
    %enter values manually from the photometer display readout
    
% 	port = serial('/dev/ttyUSB1', 'BaudRate', 4800,'databits',7,'parity','even','stopbits',2,'terminator','CR/LF','FlowControl','hardware');
%     fopen(port);

	whitelevel = 2^nbits-1;
	relpixvals  = linspace(0,whitelevel,npixvals)/whitelevel;
	
	unitfield = ones(winHeight,winWidth);
	
	WaitSecs('UntilTime', t0+timetoleavelab);
	
	relpixvals = relpixvals(randperm(npixvals));
	
	figure
	for k=1:2
		if k==1
			% On the first pass, get a pixval/luminance table with gamma=1:
			gamma = 1;
		else
			% On the second pass, we should have a fit available from the
			% first pass:/root
			gamma = fittedpower;
		end
		
		% Specify the window's inverse gamma value to be applied in the imaging pipeline
		PsychColorCorrection('SetEncodingGamma', win, 1/gamma);
		
		% Do it in random order
		relpixvals = relpixvals(randperm(npixvals));
		
		for j=1:npixvals
			fprintf('measuring luminance for value %5.3f',relpixvals(j));
			lumvals(j) = DisplayGanzfeld(relpixvals(j),unitfield,win);
			fprintf(', got %5.3f cd/m^2.\n',lumvals(j));
			save(savefile)		
		end
		if k==1
			[relpixvals_findgamma,kk]=sort(relpixvals);
			lumvals_findgamma=lumvals(kk);
		else
			[relpixvals_testgamma,kk]=sort(relpixvals);
			lumvals_testgamma=lumvals(kk);
		end			
		save(savefile)
			
		subplot(1,2,k)
		plot(relpixvals,lumvals,'ro')
		xlabel('pixel value (0=black, 1=white)')
		ylabel('luminance')
		
		% Fit a power-law to this:
		[fit,fval,exitflag,output ] = fminsearch(@rmserr,[1 1 0],[],relpixvals,lumvals);
		[fit,fval,exitflag,output ] = fminsearch(@rmserr,fit,[],relpixvals,lumvals);
		
		hold on
		xx=[0:0.001:1];
		plot(xx,powerlaw(xx,fit),'b');
		fittedpower = fit(1);
		title(sprintf('Using gamma=%5.3f; fitted power=%5.3f',gamma,fittedpower))

	end
	
	
	% Restore any system gamma tables we modified
	Screen('CloseAll');
	
	% Close port to photometer:
	%fclose(port);delete(port);clear port
	
		
catch
	lasterr
% 	if Datapixx('IsReady')
% 		Datapixx('Close');
% 	end
 	RestoreCluts;
%	fclose(port);delete(port);clear port
	sca
	clear all	

end

return;

function err = rmserr(params,relpixvals,lumvals)
predlumvals = powerlaw(relpixvals,params);
err = sqrt(mean( (predlumvals-lumvals).^2));

function y = powerlaw(x,params)
power = params(1) ;
scale = params(2);
offset = params(3);
y = offset + (scale*x).^power;

function lumval = DisplayGanzfeld(relpixval,unitfield,win)
% Relpixval is a number between 0 (black) and 1 (white)

% Fill the whole screen with uniform luminance:
ganzfeld = relpixval*unitfield;
% Use floatprecision=2:
tex = Screen('MakeTexture', win, ganzfeld, [], [], 2);

% Draw the floating point texture
% Specify filter mode = 0 (nearest neighbour), so that GL doesn't interpolate pixel values.
Screen('DrawTexture', win, tex, [], [], [], 0);
Screen('Flip',win,GetSecs);
Screen('Close',tex);

% % Read photometer:
% fprintf(port,'MES');
% [line, nlin] = fscanf(port);
% j=min(findstr(line,' '));
% val = str2num(line(j+1:end));
% if isempty(val)
% 	val = 0;
% end

% instead of reading the photometer, ask for input:
fprintf('Value? ');
val= GetNumber;
fprintf('\n');
lumval = val;
