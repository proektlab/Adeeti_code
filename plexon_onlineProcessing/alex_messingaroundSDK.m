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
%%
h = OPX_InitClient(OPX_CHANNEL_FORMAT_SOURCE_RELATIVE); 



%%
OPX_ClearData(h, 1000); % clear any backlogged data
%%
[retFromGetData, numSpikes, spikeHeaders, spikeTimes, spikeWaveforms, ...
                       numCont, contHeaders, contTimes, contSamples, ...
                       numEvents, events, eventTimes] = OPX_GetNewData(h);
                   
                   events
                   numEvents