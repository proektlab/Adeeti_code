

if isunix
    dirIn = '/synology/adeeti/GaborTests/IsoProp/';
    dirPic = 'synology/adeeti/GaborTests/images/2DFFTMovies/IsoProp/';
elseif ispc
    dirIn = 'Z:/adeeti/GaborTests/IsoProp/';
    dirPic = 'Z:\adeeti\GaborTests\images\2DFFTMovies\IsoProp';
end

mkdir(dirPic)

cd(dirIn)
allData = dir('gab*.mat');

%%
prestimTimePoints = [1:30];
topHeightsPerExp = [];

for expInd = 1:length(allData)
    load(allData(expInd).name, 'allXs', 'allYs', 'allheights', 'allSpecShift',  'info')
    disp(allData(expInd).name)
    topHeightsPerExp
    
    % normalize heights to peak distribution
    baselineSpec = allSpecShift(prestimTimePoints,:,:);
    m_base = squeeze(mean(baselineSpec,1));

    zheights = {};
    for t = 1:length(allheights)
        for h = 1:length(allheights{t})
            zheights{t}(h) = (allheights{t}(h) - m_base(allYs{t}(h), allXs{t}(h)))/std_base(allYs{t}(h), allXs{t}(h));
        end
    end

    [topHeights ind] = cellfun(@(x)max(x), zheights);
    
end
