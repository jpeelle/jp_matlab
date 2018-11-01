function [y, fs] = jp_maketoneinnoise(delayToneSec, SNR, Cfg)
%JP_MAKETONEINNOISE Make tone in noise (possibly following AM noise).
%
% Y = JP_MAKETONEINNOISE(DELAY) presents the tone after DELAY (seconds).
%
% JP_MAKETONEINNOISE(DELAY,CFG) allows specifying copius amount of other
% options in CFG. Not documented yet (sorry), so just look at the code for
% options.
%
%
%
% [Y, FS] = JP_MAKETONEINENOISE... also returns the sampling rate FS.
%
%
%
%
% See also JP_MAKETONEINNOISE_WRAPPER.

if nargin < 2
    SNR = 0;
end

if nargin < 3
    Cfg = [];
end

if ~isfield(Cfg, 'fs') || isempty(Cfg.fs)
    Cfg.fs = 22050;
end

if ~isfield(Cfg, 'toneFreqHz') || isempty(Cfg.toneFreqHz)
    Cfg.toneFreqHz = 1000;
end

if ~isfield(Cfg, 'toneDurationSec') || isempty(Cfg.toneDurationSec)
    Cfg.toneDurationSec = 0.25;
end

if ~isfield(Cfg, 'AMFreqHz') || isempty(Cfg.AMFreqHz)
    Cfg.AMFreqHz = 3;
end

if ~isfield(Cfg, 'AMdurationSec') || isempty(Cfg.AMdurationSec)
    Cfg.AMdurationSec = 3;
end

if ~isfield(Cfg, 'steadyNoiseDurationSec') || isempty(Cfg.steadyNoiseDurationSec)
    Cfg.steadyNoiseDurationSec = 3;
end



yMax = 0.4; % +/- max of noise
yMaxTone = .1; % max of tone


AMCfg = [];
AMCfg.plot = 0;
AMCfg.modulationDepth = .8;
AMCfg.fs = Cfg.fs;



%% Make a tone
toneCfg = [];
toneCfg.fs = Cfg.fs;
[yTone, fs] = jp_maketone(Cfg.toneFreqHz, Cfg.toneDurationSec, toneCfg);

yTone = yTone / (max(yTone)/yMaxTone);


%% Make the AM noise
[yAM, fs] = jp_makeAMnoise(Cfg.AMFreqHz, Cfg.AMdurationSec, AMCfg);
yAM = yAM / (max(yAM)/yMax);


yNoise = yMax * (2*rand(Cfg.steadyNoiseDurationSec * fs, 1) - 1);


%% Figure out dB, scale

rmsTone = jp_rms(yTone);
dbTone = jp_mag2db(rmsTone);

rmsNoise = jp_rms(yNoise);
dbNoise = jp_mag2db(rmsNoise);


targetDb = dbTone - SNR; % target for noise dB
targetRMS = 10^(targetDb/20);

scaleFactor = targetRMS/rmsNoise;

scaledNoise = yNoise * scaleFactor;

rmsScaledNoise = jp_rms(scaledNoise);
dbScaledNoise = jp_mag2db(rmsScaledNoise);
fprintf('SNR %g:\tsignal = %.1f, noise = %.1f dB\n', SNR, dbTone, dbScaledNoise);

yNoiseTone = scaledNoise;
delayToneSamples = round(delayToneSec * fs);
lengthToneSamples = length(yTone);
yNoiseTone(delayToneSamples:delayToneSamples+lengthToneSamples-1) = yNoiseTone(delayToneSamples:delayToneSamples+lengthToneSamples-1) + yTone;

%% Add
y = [yAM; yNoiseTone];

if max(y) > 1
    warning('Signal clipping at %g.', max(yNoiseTone));
end



%%
% figure
% 
% plot(yNoiseTone)

% you can play this: soundsc(y, fs)

