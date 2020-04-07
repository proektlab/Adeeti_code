function [wcoh,wcs,actFreq]= wcoherence_InputScale(x, y, SCALE, timeFrame, lowFreq, highFreq, ns, fs)

if nargin<7
    fs = 1000;
    ns =4;
end
if nargin<5
    highFreq = fs/2;
    lowFreq = 0.01;
end
if nargin <4
    timeFrame = length(x);
end


dt = 1/fs;

scales = SCALE;
scales = scales(:);
invscales = 1./scales;

frIndex = find(invscales>lowFreq & invscales<highFreq);
actFreq = invscales(frIndex); 

wname = 'morl';
%%


% Form signals as row vectors
x = x(:)';
y = y(:)';
nx = numel(x);
ny = numel(y);

%calculate wavelet
invscales = repmat(invscales,1,nx);
cwtx = cwtft({x,dt},'wavelet',wname,'scales',scales,'PadMode','symw');
cwty = cwtft({y,dt},'wavelet',wname,'scales',scales,'PadMode','symw');
cwtx.cfs = cwtx.cfs(:,1:nx);
cwty.cfs = cwty.cfs(:,1:ny);

%calculate cross spectrum and smooth temporally and between
%scales
cfs1 = smoothCFS(invscales.*abs(cwtx.cfs).^2,scales,dt,ns);
cfs2 = smoothCFS(invscales.*abs(cwty.cfs).^2,scales,dt,ns);
crossCFS = cwtx.cfs.*conj(cwty.cfs);
crossCFS = smoothCFS(invscales.*crossCFS,scales,dt,ns);
crosspec = crossCFS./(sqrt(cfs1).*sqrt(cfs2));
wtc = abs(crossCFS).^2./(cfs1.*cfs2);
N = size(cfs1,2);

wcoh = wtc(frIndex,:);
wcs = crosspec(frIndex,:);


function cfs = smoothCFS(cfs,scales,dt,ns)
N = size(cfs,2);
npad = 2.^nextpow2(N);
omega = 1:fix(npad/2);
omega = omega.*((2*pi)/npad);
omega = [0., omega, -omega(fix((npad-1)/2):-1:1)];

% Normalize scales by DT because we are not including DT in the
% angular frequencies here. The smoothing is done by multiplication in
% the Fourier domain
normscales = scales./dt;
for kk = 1:size(cfs,1)
    F = exp(-0.25*(normscales(kk)^2)*omega.^2);
    smooth = ifft(F.*fft(cfs(kk,:),npad));
    cfs(kk,:)=smooth(1:N);
end
% Convolve the coefficients with a moving average smoothing filter across
% scales
H = 1/ns*ones(ns,1);
cfs = conv2(cfs,H,'same');





