clear all
clc

% [moviemat04,ix,iy,totalframes]=loadmymovie('04');
% save moviefile_04.mat -v7.3; clear all
% [moviemat05,ix,iy,totalframes]=loadmymovie('05');
% save moviefile_05.mat -v7.3; clear all
% [moviemat06,ix,iy,totalframes]=loadmymovie('06');
% save moviefile_06.mat -v7.3; clear all
% [moviemat07,ix,iy,totalframes]=loadmymovie('07');
% save moviefile_07.mat -v7.3; clear all
% % [moviemat08,ix,iy,totalframes]=loadmymovie('08');
% save moviefile_08.mat -v7.3; clear all
% [moviemat09,ix,iy,totalframes]=loadmymovie('09');
% save moviefile_09.mat -v7.3; clear all
% [moviemat10,ix,iy,totalframes]=loadmymovie('10');
% save moviefile_10.mat -v7.3; clear all
% [moviemat11,ix,iy,totalframes]=loadmymovie('11');
% save moviefile_11.mat -v7.3; clear all
% [moviemat12,ix,iy,totalframes]=loadmymovie('12');
% save moviefile_12.mat -v7.3; clear all
% [moviemat13,ix,iy,totalframes]=loadmymovie('13');
% save moviefile_13.mat -v7.3; clear all
% [moviemat14,ix,iy,totalframes]=loadmymovie('14');
% save moviefile_14.mat -v7.3; clear all
% [moviemat15,ix,iy,totalframes]=loadmymovie('15');
% save moviefile_15.mat -v7.3; clear all
% [moviemat16,ix,iy,totalframes]=loadmymovie('16');
% save moviefile_16.mat -v7.3; clear all
% [moviemat17,ix,iy,totalframes]=loadmymovie('17');
% save moviefile_17.mat -v7.3; clear all
% [moviemat18,ix,iy,totalframes]=loadmymovie('18');
% save moviefile_18.mat -v7.3; clear all
% [moviemat19,ix,iy,totalframes]=loadmymovie('19');
% save moviefile_19.mat -v7.3; clear all




try

  
    
    PsychDefaultSetup(2);
    PsychImaging('PrepareConfiguration');
    PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'SimpleGamma');
   % [params.window, params.windowRect]= PsychImaging('OpenWindow',max(Screen('Screens')));
        [params.window, params.windowRect]= PsychImaging('OpenWindow',0);


    
        
 tic
 
    load moviefile_00.mat
    mm=matfile('moviefile_00.mat');
    for frame=1:1802
        imagetex00(frame)=Screen('MakeTexture', params.window, mm.moviemat00(:, :,frame)');
    end
    clear moviemat00 mm
    
    
    load moviefile_01.mat
    mm=matfile('moviefile_01.mat');
    for frame=1:1802
        imagetex01(frame)=Screen('MakeTexture', params.window, mm.moviemat01(:, :,frame)');
    end
    clear moviemat01 mm
    
%   
%     
%     load moviefile_02.mat
%     mm=matfile('moviefile_02.mat');
%     for frame=1:1802
%         imagetex02(frame)=Screen('MakeTexture', params.window, mm.moviemat02(:, :,frame)');
%     end
%     clear moviemat02 mm
%     
%     
%     load moviefile_03.mat
%     mm=matfile('moviefile_03.mat');
%     for frame=1:1802
%         imagetex03(frame)=Screen('MakeTexture', params.window, mm.moviemat03(:, :,frame)');
%     end
%     clear moviemat03 mm
%     
%     
%     load moviefile_04.mat
%     mm=matfile('moviefile_04.mat');
%     for frame=1:1802
%         imagetex04(frame)=Screen('MakeTexture', params.window, mm.moviemat04(:, :,frame)');
%     end
%     clear moviemat04 mm
%     
%     load moviefile_05.mat
%     mm=matfile('moviefile_05.mat');
%     for frame=1:1802
%         imagetex05(frame)=Screen('MakeTexture', params.window, mm.moviemat05(:, :,frame)');
%     end
%     clear moviemat05 mm
%     
%     load moviefile_06.mat
%     mm=matfile('moviefile_06.mat');
%     for frame=1:1802
%         imagetex06(frame)=Screen('MakeTexture', params.window, mm.moviemat06(:, :,frame)');
%     end
%     clear moviemat06 mm
%     
%     
%     
%     load moviefile_07.mat
%     mm=matfile('moviefile_07.mat');
%     for frame=1:1802
%         imagetex07(frame)=Screen('MakeTexture', params.window, mm.moviemat07(:, :,frame)');
%     end
%     clear moviemat07 mm
%     
%     load moviefile_08.mat
%     mm=matfile('moviefile_08.mat');
%     for frame=1:1802
%         imagetex08(frame)=Screen('MakeTexture', params.window, mm.moviemat08(:, :,frame)');
%     end
%     clear moviemat08 mm
%     
%     
%     load moviefile_09.mat
%     mm=matfile('moviefile_09.mat');
%     for frame=1:1802
%         imagetex09(frame)=Screen('MakeTexture', params.window, mm.moviemat09(:, :,frame)');
%     end
%     clear moviemat09 mm
%     
%     
%     load moviefile_10.mat
%     mm=matfile('moviefile_10.mat');
%     for frame=1:1802
%         imagetex10(frame)=Screen('MakeTexture', params.window, mm.moviemat10(:, :,frame)');
%     end
%     clear moviemat10 mm
    
    toc
    
    %                load moviefile_11.mat
    %     mm=matfile('moviefile_11.mat');
    %     for frame=1:1802
    %         imagetex11(frame)=Screen('MakeTexture', params.window, mm.moviemat11(:, :,frame)');
    %     end
    %     clear moviemat11 mm
    %
    %
    %
    %     load moviefile_12.mat
    %     mm=matfile('moviefile_12.mat');
    %     for frame=1:1802
    %         imagetex12(frame)=Screen('MakeTexture', params.window, mm.moviemat12(:, :,frame)');
    %     end
    %     clear moviemat12 mm
    %
    %
    %    load moviefile_13.mat
    %     mm=matfile('moviefile_13.mat');
    %     for frame=1:1802
    %         imagetex13(frame)=Screen('MakeTexture', params.window, mm.moviemat13(:, :,frame)');
    %     end
    %     clear moviemat13 mm
    %
    %
    %
    %     load moviefile_14.mat
    %     mm=matfile('moviefile_14.mat');
    %     for frame=1:1802
    %         imagetex14(frame)=Screen('MakeTexture', params.window, mm.moviemat14(:, :,frame)');
    %     end
    %     clear moviemat14 mm
    %
    %
    %        load moviefile_15.mat
    %     mm=matfile('moviefile_15.mat');
    %     for frame=1:1802
    %         imagetex15(frame)=Screen('MakeTexture', params.window, mm.moviemat15(:, :,frame)');
    %     end
    %     clear moviemat15 mm
    %
    %     load moviefile_16.mat
    %     mm=matfile('moviefile_16.mat');
    %     for frame=1:1802
    %         imagetex16(frame)=Screen('MakeTexture', params.window, mm.moviemat16(:, :,frame)');
    %     end
    %     clear moviemat16 mm
    %
    %
    %
    %            load moviefile_17.mat
    %     mm=matfile('moviefile_17.mat');
    %     for frame=1:1802
    %         imagetex17(frame)=Screen('MakeTexture', params.window, mm.moviemat17(:, :,frame)');
    %     end
    %     clear moviemat17 mm
    %
    %     load moviefile_18.mat
    %     mm=matfile('moviefile_18.mat');
    %     for frame=1:1802
    %         imagetex18(frame)=Screen('MakeTexture', params.window, mm.moviemat18(:, :,frame)');
    %     end
    %     clear moviemat18 mm
    %
    %
    %    load moviefile_19.mat
    %     mm=matfile('moviefile_19.mat');
    %     for frame=1:1802
    %         imagetex19(frame)=Screen('MakeTexture', params.window, mm.moviemat19(:, :,frame)');
    %     end
    %     clear moviemat19 mm
    
    
    %%

   
        
    ix=720;
    iy=480;
    totalframes=1802;
    %[ix,iy,totalframes]=size(moviemat);
    scale = 2.5; % Don't up- or downscale patch by default.
    objRect =SetRect(0,0, ix, iy);
   % dstRect(1,:)=CenterRectOnPoint(objRect * scale, 960, 600);
        dstRect(1,:)=CenterRectOnPoint(objRect * scale, 500, 300);

    
    
    %setup frame frequency
    frameRefresh=1/60;
    % Query, or hardwire, the screen's frame update
    %fps= 120;
    fps= 60;

    waitframes = round(frameRefresh *fps );
    
    %Setup Datapixx for sending TTLs
% PsychDataPixx('Open'); %check to see that DataPixx is ope    
%     oldmode = PsychDataPixx('SetDummyMode', [1]);
% 
% Datapixx('StopAllSchedules');
% Datapixx('SetDoutValues', 0);
% Datapixx('RegWrRd');
    
    % Define TTL trigger pulse time series with 2 samples hi(1) -> low(0)
doutWave1 = [1 0 ];
bufferAddress1 = 1e6;
%Datapixx('WriteDoutBuffer', doutWave1, bufferAddress1);
    
    
    frame=0;
    missed=zeros(1,totalframes);
    
    
    % Bump priority for speed
    priorityLevel=MaxPriority(params.window);
    Priority(priorityLevel);
    [ifi]= Screen('GetFlipInterval', params.window, 100, 0.00005, 20);
    clearflag=2;
    
    
    
    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%         Animation Loop         %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Blank sceen
    Screen('FillRect',params.window, 0.5);
    vbl=Screen('Flip', params.window);
    for frame=1:1802
        
        Screen('DrawTexture', params.window, imagetex00(frame), [], dstRect(1,:), [], 0);
        Screen('DrawingFinished', params.window,clearflag);
        
        %write out TTL (uncommenting this section produces dropped frames)
%         
%         Datapixx('SetDoutSchedule', 0, [0.008, 3], 2, bufferAddress1);
%         Datapixx('StartDoutSchedule');
%         PsychDataPixx('RequestPsyncedUpdate')
%         
        
        [vbl, ~, ~, missed(1,frame)]  = Screen('Flip', params.window, vbl + (waitframes - 0.5) * (ifi),clearflag);
        
    end
    display(['missed: ',num2str(length(find(missed>0)))]);
    clear imagetex00
    
    
    
    vbl=Screen('Flip', params.window);
    for frame=1:1802
        
        Screen('DrawTexture', params.window, imagetex01(frame), [], dstRect(1,:), [], 0);
        Screen('DrawingFinished', params.window,clearflag);
        %write out TTL (uncommenting this section produces dropped frames)
% Datapixx('SetDoutSchedule', 0, [0.008, 3], 2, bufferAddress1);
% Datapixx('StartDoutSchedule');
% PsychDataPixx('RequestPsyncedUpdate')

        [vbl, ~, ~, missed(1,frame)]  = Screen('Flip', params.window, vbl + (waitframes - 0.5) * (ifi),clearflag);
        
    end
num_missed=length(find(missed>0))
ind_missed=find(missed>0)
display(['missed ',num2str(num_missed),' out of ',num2str(frame),' frames.']);
    clear imagetex01
%     
%     
%     vbl=Screen('Flip', params.window);
%     for frame=1:1802
%         Screen('DrawTexture', params.window, imagetex02(frame), [], dstRect(1,:), [], 0);
%         Screen('DrawingFinished', params.window,clearflag);
%         %write out TTL (uncommenting this section produces dropped frames)
%         Datapixx('SetDoutValues', [1]); %indicate frame startmo
%         Datapixx('RegWrRd');
%         Datapixx('SetDoutValues', [0]);
%         Datapixx('RegWrRd');
%         [vbl, ~, ~, missed(1,frame)]  = Screen('Flip', params.window, vbl + (waitframes - 0.5) * (ifi),clearflag);
%         
%     end
%     display(['missed: ',num2str(length(find(missed>0)))]);
%     clear imagetex02
%     
%     
%     vbl=Screen('Flip', params.window);
%     for frame=1:1802
%         Screen('DrawTexture', params.window, imagetex03(frame), [], dstRect(1,:), [], 0);
%         Screen('DrawingFinished', params.window,clearflag);
%         %write out TTL (uncommenting this section produces dropped frames)
%         Datapixx('SetDoutValues', [1]); %indicate frame startmo
%         Datapixx('RegWrRd');
%         Datapixx('SetDoutValues', [0]);
%         Datapixx('RegWrRd');
%         [vbl, ~, ~, missed(1,frame)]  = Screen('Flip', params.window, vbl + (waitframes - 0.5) * (ifi),clearflag);
%         
%     end
%     display(['missed: ',num2str(length(find(missed>0)))]);
%     clear imagetex03
%     
%     
%     vbl=Screen('Flip', params.window);
%     for frame=1:1802
%         Screen('DrawTexture', params.window, imagetex04(frame), [], dstRect(1,:), [], 0);
%         Screen('DrawingFinished', params.window,clearflag);
%         %write out TTL (uncommenting this section produces dropped frames)
%         Datapixx('SetDoutValues', [1]); %indicate frame startmo
%         Datapixx('RegWrRd');
%         Datapixx('SetDoutValues', [0]);
%         Datapixx('RegWrRd');
%         [vbl, ~, ~, missed(1,frame)]  = Screen('Flip', params.window, vbl + (waitframes - 0.5) * (ifi),clearflag);
%         
%     end
%     display(['missed: ',num2str(length(find(missed>0)))]);
%     clear imagetex04
%     
%     
%     
%     vbl=Screen('Flip', params.window);
%     for frame=1:1802
%         Screen('DrawTexture', params.window, imagetex05(frame), [], dstRect(1,:), [], 0);
%         Screen('DrawingFinished', params.window,clearflag);
%         %write out TTL (uncommenting this section produces dropped frames)
%         Datapixx('SetDoutValues', [1]); %indicate frame startmo
%         Datapixx('RegWrRd');
%         Datapixx('SetDoutValues', [0]);
%         Datapixx('RegWrRd');
%         [vbl, ~, ~, missed(1,frame)]  = Screen('Flip', params.window, vbl + (waitframes - 0.5) * (ifi),clearflag);
%         
%     end
%     display(['missed: ',num2str(length(find(missed>0)))]);
%     clear imagetex05
%     
%     
%     
%     vbl=Screen('Flip', params.window);
%     for frame=1:1802
%         Screen('DrawTexture', params.window, imagetex06(frame), [], dstRect(1,:), [], 0);
%         Screen('DrawingFinished', params.window,clearflag);
%         %write out TTL (uncommenting this section produces dropped frames)
%         Datapixx('SetDoutValues', [1]); %indicate frame startmo
%         Datapixx('RegWrRd');
%         Datapixx('SetDoutValues', [0]);
%         Datapixx('RegWrRd');
%         [vbl, ~, ~, missed(1,frame)]  = Screen('Flip', params.window, vbl + (waitframes - 0.5) * (ifi),clearflag);
%         
%     end
%     display(['missed: ',num2str(length(find(missed>0)))]);
%     clear imagetex06
%     
%     
%     
%     
%     vbl=Screen('Flip', params.window);
%     for frame=1:1802
%         Screen('DrawTexture', params.window, imagetex07(frame), [], dstRect(1,:), [], 0);
%         Screen('DrawingFinished', params.window,clearflag);
%         %write out TTL (uncommenting this section produces dropped frames)
%         Datapixx('SetDoutValues', [1]); %indicate frame startmo
%         Datapixx('RegWrRd');
%         Datapixx('SetDoutValues', [0]);
%         Datapixx('RegWrRd');
%         [vbl, ~, ~, missed(1,frame)]  = Screen('Flip', params.window, vbl + (waitframes - 0.5) * (ifi),clearflag);
%         
%     end
%     display(['missed: ',num2str(length(find(missed>0)))]);
%     clear imagetex07
%     
%     
%     vbl=Screen('Flip', params.window);
%     for frame=1:1802
%         Screen('DrawTexture', params.window, imagetex08(frame), [], dstRect(1,:), [], 0);
%         Screen('DrawingFinished', params.window,clearflag);
%         %write out TTL (uncommenting this section produces dropped frames)
%         Datapixx('SetDoutValues', [1]); %indicate frame startmo
%         Datapixx('RegWrRd');
%         Datapixx('SetDoutValues', [0]);
%         Datapixx('RegWrRd');
%         [vbl, ~, ~, missed(1,frame)]  = Screen('Flip', params.window, vbl + (waitframes - 0.5) * (ifi),clearflag);
%         
%     end
%     display(['missed: ',num2str(length(find(missed>0)))]);
%     clear imagetex08
%     
%     
%     vbl=Screen('Flip', params.window);
%     for frame=1:1802
%         Screen('DrawTexture', params.window, imagetex09(frame), [], dstRect(1,:), [], 0);
%         Screen('DrawingFinished', params.window,clearflag);
%         %write out TTL (uncommenting this section produces dropped frames)
%         Datapixx('SetDoutValues', [1]); %indicate frame startmo
%         Datapixx('RegWrRd');
%         Datapixx('SetDoutValues', [0]);
%         Datapixx('RegWrRd');
%         
%         [vbl, ~, ~, missed(1,frame)]  = Screen('Flip', params.window, vbl + (waitframes - 0.5) * (ifi),clearflag);
%         
%     end
%     display(['missed: ',num2str(length(find(missed>0)))]);
%     clear imagetex09
%     
%     
%     vbl=Screen('Flip', params.window);
%     for frame=1:1802
%         Screen('DrawTexture', params.window, imagetex10(frame), [], dstRect(1,:), [], 0);
%         Screen('DrawingFinished', params.window,clearflag);
%         %write out TTL (uncommenting this section produces dropped frames)
%         Datapixx('SetDoutValues', [1]); %indicate frame startmo
%         Datapixx('RegWrRd');
%         Datapixx('SetDoutValues', [0]);
%         Datapixx('RegWrRd');
%         
%         [vbl, ~, ~, missed(1,frame)]  = Screen('Flip', params.window, vbl + (waitframes - 0.5) * (ifi),clearflag);
%         
%     end
%     display(['missed: ',num2str(length(find(missed>0)))]);
%     clear imagetex10
    
    
    
    
    
    clear all
    sca
    
catch
    sca
    rethrow(lasterror)
end

