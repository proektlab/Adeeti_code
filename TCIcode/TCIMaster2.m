function [infusion] = TCIMaster2(dT, k, tolerance)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
close all;
% default parameter choices
if nargin == 0;
     dT = 10;                                          % default unit time during which infusion is expected to be constant (s). 
%      k = [0.0198,0.0326,0.0032,0.0016,0.0009,1.8103];  %default rate constants (1/s).
%      k = [0.0157, 0.0213, 0.0092, 0.0021, 0.0044, 3.7564];  % default rate constants (1/s) calculated using only first round TCI data.
     k = [0.0258 0.0452 0.0037 0.0007 0.0012 2.8373]; % default rate constants (1/s) calculated using all existing data (x in Fits_TCI_4.mat)
     tolerance = 0.01;
elseif nargin == 1
%      k = [0.0198,0.0326,0.0032,0.0016,0.0009,1.8103];  %default rate constants (1/s).
%      k = [0.0157, 0.0213, 0.0092, 0.0021, 0.0044, 3.7564];  % default rate contants (1/s) calculated using only first round TCI data.
     k = [0.0258 0.0452 0.0037 0.0007 0.0012 2.8373]; % default rate constants (1/s) calculated using all existing data (x in Fits_TCI_4.mat)
     tolerance = 0.05;
elseif nargin == 2;
    tolerance = 0.05;
end

%port location to be modified  
if ~isempty(instrfindall);
        fclose(instrfindall);
end
port='/dev/tty.usbmodemC300711';
% concentration of drug in solution (default for prop)
DrugConc=10;




% get the mother directory
datadir = uigetdir('matlabroot', 'Data Directory');
g = exist('Mouse.mat', 'file');                       % check if the mouse file exists
if g == 2;
    delete('Mouse.mat');                             % delete it
end
hm = MouseData;                                        % call GUI that collects mouse parameters
waitfor(hm);
load('Mouse.mat');                                   % load mouse parameters


% check if subject name already used and if so see if want to
% overwrite.
g = exist([datadir, '/' name], 'dir');
    while g == 7
        choice = questdlg('Overwrite?','Subject Already Exists', 'Yes','No', 'No');
        switch choice        
            case 'Yes'
                g = 0;           
            case 'No'
                hm = MouseData;                                        % call GUI that collects mouse parameters
                waitfor(hm);
                load('Mouse.mat');
                g = exist([datadir, '/' name], 'dir');
        end
    end
 
        
% create data directory and save mouse data into it    
if g ~= 7 || g ~= 0;
    mkdir([datadir, '/' name]);
end
save([datadir, '/' name '/Mouse.mat'], 'name', 'weight');
startFile=fopen([datadir '/' name '/StartClock.txt'], 'w+');                % open the file for recording start time
targetFile=fopen([datadir '/' name '/Target.txt'], 'w+');                   % open file for targets
pumpFile=fopen([datadir '/' name '/PumpFile.txt'], 'w+');                   % open file for targets

options = odeset('RelTol',2e-4,'AbsTol',2e-7);
% find slowest time constant
kmin = min(k);
% set the duration of the kernel to a multiple of the slowest time
% constant
dur = floor((1/kmin)*20);

% compute kernel
disp('Computing the Kernel');
[~,X] = ode23s(@kernelcalc,0:1:dur,zeros(3,1),options, k,dT);
Ce_peak = max(X(:,2)); % maximum brain concentration (brain assumed to be second compartment)
tpeak = find(X(:,2) == max(X(:,2))); % time of max brain conc


%insert code to initialize pump
disp('Initializing Pump');
[ p ] = InitializePump( port,[datadir, '/', name] );

% initialize the GUI to get target info
ht = GetTarget;
% start target by default is zero
target = 0;
% initialize empty infusion matrix;
infusion = [];

% make a figure for plotting concentrations and initialize some headers for
% plots and axes;
ax=MakePlot();
LastPlotted=[];
h=[];                                                                                                    

% wait for the first nonzero target rate
while target == 0;
    pause(0.01);
    load('Target.mat');
end

%initial state of the system is empty
Conc=zeros(3,1);


% write the files
infusionStart=clock;
fprintf(startFile, '%d\t', infusionStart);
fprintf(startFile, '\n');
fprintf(targetFile, '%d\n', target);


    while ~isnan(target)        
        [infusion, Conc, ~]=NextStep(target, infusion, Conc, tolerance, tpeak, Ce_peak, dT, X);                     % compute the next infusion step
        pumpRate=ConverToPumpRate(infusion(end)*60, weight, DrugConc);                                                           % convert to ul/min for pump control
        q=[];
        while q~=1
           [~, q]=CheckPumpTarget(p);            
        end
        disp('Ready');
        stepTime=tic;
        FixedRateInfuse(pumpRate, dT, p);
        cl=clock;
        fprintf(pumpFile, '%d\t', cl);
        fprintf(pumpFile, '\n');
        Concentration=Conc(1:length(infusion),:);                                                                   % take the concentration up until the end of current infusion
        save([datadir, '/' name '/Infusion.mat'], 'infusion', 'Concentration');                                     % save infusion and concentration to file

        oldtarget=target;                                                                                           % variable name change for current target
   
        while oldtarget==target
           if toc(stepTime)>=dT
               break 
            else
                [LastPlotted, h]=Plots(ax, infusionStart, LastPlotted, infusion, Conc, target, h);
                pause(0.01);
                load('Target.mat');
            end

        end
        
        fprintf(targetFile, '%d\n', target);
        fprintf(startFile, '%d\t', clock);
        fprintf(startFile, '\n');
    end
  pause(3);
  close(ht);
  fclose(p);
end


% function that integrates the equations with a unit infusion
    function dX = kernelcalc(t,X,k,dt)        
        k12 = k(1,1); % rate constant for blood to brain
        k21 = k(1,2); % blood to other
        k13 = k(1,3); % brain to blood
        k31 = k(1,4); % other to blood
        k10 = k(1,5); % clearance
        kInf = k(1,6);
        
        dX(1,1) = -(k12+k13+k10)*X(1,1) + k21*X(2,1) + k31*X(3,1) +kInf*I(t,dt);
        dX(2,1) = k12*X(1,1) - k21*X(2,1);
        dX(3,1) = k13*X(1,1) - k31*X(3,1);
        
        function y = I(t,dt)
            if t <= dt
                y = 1;
            else
                y = 0;
            end
        end
    end
   % this is the TCI algorithm as per Shafer. Computes the next infusion to achieve target.  
    function [infusion, Conc, Tpeak]=NextStep(target, infusion, Conc, tolerance, tpeak, Ce_peak, dT, X)
        if isempty(infusion)                                                                % if this is the first infusion
                %infusion = [(target/Ce_peak)*ones(dT,1); zeros(tpeak-dT,1)];                % Bolus dose necessary to reach target concentration
                infusion=(target/Ce_peak)*ones(dT,1);
                Conc = conv2(infusion, X)./dT;
                Tpeak=tpeak;
        else
                ERR = tolerance*2;                                                     % make error bigger than tolerance to enter the loop
                Tpeak = tpeak;                                                         % make the first guess based on Kernell
                while ERR > tolerance                                                  % loop while not within tolerance           
                    i = length(infusion);
                    Imaybe = max(0,(target - Conc(i+Tpeak,2))/Ce_peak);                % make initial guess based on tpeak from kernell
                    tempInfusion = infusion;                                           % make temporary infusion sequence
                    tempInfusion = [tempInfusion; Imaybe*ones(dT,1)];                  % add the guess for the infusion rate
                    tempConc = conv2(tempInfusion, X)./dT;                             % compute convolution of kernell with the guess for infusion 
                    temppeak = max(tempConc(i:end,2));                                 % find the real peak brain concentration (after the previous time step)
                    Tpeak = find(tempConc(i:end,2) == max(tempConc(i:end,2)));         % find the time of this peak
                    if Imaybe>0;
                        ERR = abs((temppeak-target)./target);                           % compute the error 
                    else
                        ERR = tolerance;
                    end
                end 
                infusion = tempInfusion;                                                % update infusion 
                Conc = tempConc;                                                        % update the concentration
        end
     
    end
    

%creates a figure outline and passes handles to plots    
function [ax2]= MakePlot()
    scrsz = get(0,'ScreenSize');
    ff=figure;
    set(ff, 'Position',[1 scrsz(4)/4 scrsz(3)/4 scrsz(4)/4], 'Color', 'k')
    ax1=subplot(1,2,1);
    set(ax1, 'Color', 'k', 'Xcolor', 'k', 'Ycolor', 'k', 'Position', [0.1, 0.1, 0.2, 0.8])
    text( 0.1, 1, 'Time since start', 'FontSize', 16, 'Color', 'w');
    text(0.1, 0.8, 'Blood Concentration', 'FontSize', 16,'Color', 'w');
    text(0.1, 0.6, 'Brain Concentration', 'FontSize', 16,'Color', 'w');
    text(0.1, 0.4, 'Fat Concentration', 'FontSize', 16,'Color', 'w');
    text(0.1, 0.2, 'Infusion rate', 'FontSize', 16,'Color', 'w');
    text(0.1, 0, 'Current Target', 'FontSize', 16,'Color', 'w');

    ax2=subplot(1,2,2);
    set(ax2,  'Color', 'k', 'Position', [0.45, 0.1, 0.2, 0.8],'Xcolor', 'k', 'Ycolor', 'k');         
end


function [LastPlotted, h]=Plots(ax, infusionStart, LastPlotted, infusion, Conc, target, h)
    ltime=clock;
    if isempty(LastPlotted)
       LastPlotted=infusionStart; 
    end

    if etime(ltime, LastPlotted)>=1;
        fullSeconds=floor(etime(ltime, infusionStart));
        if ~isempty(h);
            delete(h);
        end
        h=zeros(6,1);
        h(1)=text( 0.1, 1, [num2str(fullSeconds) ' seconds'], 'FontSize', 16, 'Color', 'w', 'Parent', ax);
        h(2)=text(0.1, 0.8, [num2str(Conc(fullSeconds,1)) ' ug/g'], 'FontSize', 16,'Color', 'w','Parent', ax);
        h(3)=text(0.1, 0.6, [num2str(Conc(fullSeconds,2)) ' ug/g'], 'FontSize', 16,'Color', 'w','Parent', ax);
        h(4)=text(0.1, 0.4,  [num2str(Conc(fullSeconds,3)) ' ug/g'], 'FontSize', 16,'Color', 'w', 'Parent', ax);
        h(5)=text(0.1, 0.2, [num2str(60*infusion(end)), ' ug/min'], 'FontSize', 16,'Color', 'w','Parent', ax);
        h(6)=text(0.1, 0, [num2str(target), ' ug/g'], 'FontSize', 16,'Color', 'w','Parent', ax);
    end


end





