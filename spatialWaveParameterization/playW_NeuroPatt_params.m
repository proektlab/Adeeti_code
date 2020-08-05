
fs = 1000;

params = setNeuroPattParams(fs);
params = setNeuroPattParams(params, 'downsampleScale', 1, fs);
params = setNeuroPattParams(params, 'subtractBaseline', 0, fs);
params = setNeuroPattParams(params, 'filterData', 0, fs);
params = setNeuroPattParams(params, 'performSVD', 0, fs);

params = setNeuroPattParams(params, 'opAlpha', 0.5, fs);
params = setNeuroPattParams(params, 'opBeta', 10, fs);

params = setNeuroPattParams(params, 'planeWaveThreshold', 0.8, fs);
params = setNeuroPattParams(params, 'planeWaveThreshold', 0.8, fs);
params = setNeuroPattParams(params, 'maxDisplacement', 1, fs);
params = setNeuroPattParams(params, 'minCritRadius', 1, fs);
params = setNeuroPattParams(params, 'minEdgeDistance', 1, fs);




% Defaults
%           downsampleScale: 1
%          subtractBaseline: 1
%            zscoreChannels: 0
%                filterData: 1
%                useHilbert: 0
%               morletCfreq: 6
%               morletParam: 5
%               hilbFreqLow: 1
%              hilbFreqHigh: 4
%                   opAlpha: 0.5000
%                    opBeta: 1
%              useAmplitude: 0
%                performSVD: 1
%             useComplexSVD: 0
%                 nSVDmodes: 6
%        planeWaveThreshold: 0.8500
%        synchronyThreshold: 0.8500
%           minDurationSecs: 0.0200
%            maxTimeGapSecs: 0.0050
%           maxDisplacement: 1
%             minCritRadius: 2
%           minEdgeDistance: 2
%          combineNodeFocus: 0
%     combineStableUnstable: 0
%           maxTimeGapSteps: 5
%          minDurationSteps: 20