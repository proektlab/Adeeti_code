%Grabbing FP data around flash

clear
close all
clc

%% setting up parameters

% time in sec for time that warning is before event and time after event warning to query
warnTime = 0.5;
endEvent = 1.5;

% only interested in this continuous source
contSourceToDraw = 'FP';

% channel to draw within the continuous source
contChanToDraw = 1;

% used with OPX_GetOPXSystemStatus
OPX_DAQ_STOPPED = 1;
OPX_DAQ_STARTED = 2;

% used with OPX_ExcludeAllSourcesOfType - the three source types
SPIKE_TYPE = 1;
EVENT_TYPE = 4;
CONT_TYPE = 5;

% used with OPX_WaitForOPXDAQReady
OPX_ERROR_TIMEOUT = -13;

% used with OPX_GetNewData
OPX_ERROR_NOT_ALL_DATA_WAS_RETURNED = -16;

% used with OPX_InitClient:
% source-relative format: channel numbers start at 1 for each source
% (e.g. WB, SPKC, SPK, EVT, AI)
OPX_CHANNEL_FORMAT_SOURCE_RELATIVE = 2;

%% basically just initializing clinent to use relative source numbering
h = OPX_InitClient(OPX_CHANNEL_FORMAT_SOURCE_RELATIVE);

% clear data from data grab
OPX_ClearData(h, 1000); % clear any backlogged data

%%
if h <= 0
    fprintf('error: OPX_InitClient failed (%d) - is OmniPlex running?\n', h);
else
    fprintf('Waiting for data acquisition to start in OmniPlex (5 second timeout)...\n');
    [ret] = OPX_WaitForOPXDAQReady(h, 5000);
    if ret == OPX_ERROR_TIMEOUT
        fprintf('Timed out waiting for OmniPlex to start data acquisition!\n');
    else
        [ret, sourceLFPNum, rateFP] = OPX_GetContSourceInfoByName(h, contSourceToDraw);
        assert(ret == 0);
        dtFP = 1.0/double(rateFP);
        endEventInd = endEvent*rateFP;
        warnTimeInd = warnTime*rateFP;
        
        eventTimeAxis = -warnTime:dtFP:endEvent;
        
        fprintf('Reading from OmniPlex Server...\n');
        OPX_ClearData(h, 1000); % clear any backlogged data
        %%
        
        trialStart = [];
        allContTimes = [];
        timeIndex = [];
        LFP = [];
        eventLFP = [];
        i = 1;
        while 1 % run until interrupted by Ctrl-C, or data acquisition stops
            [retFromGetData, numSpikes, spikeHeaders, spikeTimes, spikeWaveforms, numCont, contHeaders, contTimes, contSamples, numEvents, events, eventTimes] = OPX_GetNewData(h);
            
            if numEvents ~= 0
                warningInd = find(events(:,2) ==2);
                trialStart = [trialStart, eventTimes(warningInd)];
            end
            
            allContTimes = [allContTimes, contTimes(1)];
            
            if isempty(contHeaders)||contHeaders(3,1) ==1
                if retFromGetData == OPX_ERROR_NOT_ALL_DATA_WAS_RETURNED
                    fprintf('buffer was full - need to poll more frequently (shorter pause)\n');
                elseif retFromGetData == 0
                    pause(0.5);
                    [ret, OPXStatus] = OPX_GetOPXSystemStatus(h);
                    assert(ret == 0);
                    if OPXStatus == OPX_DAQ_STOPPED
                        fprintf('OmniPlex data acquisition was stopped, exiting...\n');
                        pause(1.0);
                        break;
                    end
                else
                    assert(retFromGetData == 0);
                end
                continue
            end
            
            numSamples = contHeaders(3,1);
            timeSeg = 0.0:double(numSamples)-1.0;
            timeSeg = (timeSeg*dtFP)+contTimes(1); % sample times
            timeIndex = [timeIndex, timeSeg];
            
            LFPSeg =contSamples(:,(find(contHeaders(1,:)==sourceLFPNum)));
            LFP = [LFP, LFPSeg'];
            
            if size(LFP,2)>3*length(eventTimeAxis)
                for i = i:length(trialStart)
                    eventIndex = find(round(timeIndex,3)==round(trialStart(i),3));
                    if eventIndex+endEventInd+warnTimeInd<size(LFP,2)
                        eventLFP(i,:,:) = LFP(:,eventIndex:eventIndex+endEventInd+warnTimeInd);
                    end
                end
            end
            
            if size(eventLFP,1)>1
                evTrigAvg = squeeze(nanmean(eventLFP,1));
                figure(1); clf;
                plot(eventTimeAxis,evTrigAvg)
                hold on 
                plot([0,0], [min(evTrigAvg(:)), max(evTrigAvg(:))], 'k', 'LineWidth', 2.5)
            end
            
            %             %least one channel of continuous data
            %             for chanIndex = 1:numCont
            %                 % excluded all but one source, so we only need to find the right channel
            %                 channel = contHeaders(2, chanIndex);
            %                 if channel == contChanToDraw
            %                     numSamples = contHeaders(3,chanIndex);
            %                     timeSeg = 0.0:double(numSamples)-1.0;
            %                     timeSeg = (timeSeg*dtFP)+contTimes(chanIndex); % sample times
            %                     plot(timeSeg,contSamples(1:numSamples,chanIndex),'Color','k');
            %                     set(gca, 'ylim', [-1*10^-4, 10^-4])
            %                     xlabel(sprintf('%s%03d', contSourceToDraw, contChanToDraw));
            %                     break;
            %                 end
            %             end
            
            %disp(['contTimes = ', num2str(contTimes(chanIndex))]);
            %disp(['retFromGetData = ', num2str(retFromGetData)]);
            % if we didn't read all the available data, don't wait before the next read
            if retFromGetData == OPX_ERROR_NOT_ALL_DATA_WAS_RETURNED
                fprintf('buffer was full - need to poll more frequently (shorter pause)\n');
            elseif retFromGetData == 0
                pause(0.5);
                [ret, OPXStatus] = OPX_GetOPXSystemStatus(h);
                assert(ret == 0);
                if OPXStatus == OPX_DAQ_STOPPED
                    fprintf('OmniPlex data acquisition was stopped, exiting...\n');
                    pause(1.0);
                    break;
                end
            else
                assert(retFromGetData == 0);
            end
        end
    end
end

OPX_CloseClient(h);







