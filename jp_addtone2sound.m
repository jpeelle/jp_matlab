function [y, fs, toneStartSec] = jp_addtone2sound(sound, Cfg)
%JP_ADDTONE2SOUND Add one or more tones to a longer soundfile.
%
% [Y, FS, TIMES] = JP_ADDTONE2SOUND(Y) adds one or more tones to a sound
% vector Y. (You must specify the sampling rate in CFG.fs.)
%
% Y returns the sound with tone added with sampling rate FS. TIMES is a
% vector of the onset time(s) of the tones.
%
% If Y is a sound file, it will be read in directly.
%
% JP_ADDTONE2SOUND(Y, CFG) allows to specify the following options:
%
%  CFG.fs                 Sampling rate (Hz) for vectors (otherwise read from soundfile)
%  CFG.toneFreq           Frequency of the tones (Hz) (default 1000)
%  CFG.toneDurationSec    Length of each tone (seconds) (default 0.1)
%  CFG.numTones           Number of tones added (1 or 2) (default 1)
%
%
%  From https://github.com/jpeelle/jp_matlab


if nargin < 1 || isempty(sound)
    error('Must specify sound vector or sound file.');
end

if nargin < 2
    Cfg = [];
end


% If sound is a file, read it in. Otherwise, assume it's a vector (and
% check that the sampling rate is specified.)
if exist(sound, 'file')
    [y, fs] = audioread(sound);
    Cfg.fs = fs;
else    
    if ~isfield(Cfg, 'fs') || isempty(Cfg.fs)
        error('If passing a vector, you must specify sample rate in Cfg.fs');
    end
    
    y = sound;
end

% Set other options

if ~isfield(Cfg, 'toneFreq') || isempty(Cfg.toneFreq)
    Cfg.toneFreq = 1200;
end

if ~isfield(Cfg, 'toneDurationMs') || isempty(Cfg.toneDurationMs)
    Cfg.toneDurationSec = 0.1;
end

if ~isfield(Cfg, 'numTones') || isempty(Cfg.numTones)
    Cfg.numTones = 1;
end

if ~isfield(Cfg, 'startToneSec') || isempty(Cfg.startToneSec)
    Cfg.startToneSec = 0.1; % earliest time to start tone
end

if ~isfield(Cfg, 'rmsToneScaling') || isempty(Cfg.rmsToneScaling)
    Cfg.rmsToneScaling = 1; % relative to the sound
end

%if ~isfield(Cfg

if ~isfield(Cfg, 'tonePaddingSec') || isempty(Cfg.tonePaddingSec)
    Cfg.tonePaddingSec = 0.1;
end

% NB may need to add a 0 tone condition if any filtering is done to sound



% Make the tone and adjust its RMS

toneCfg = [];
toneCfg.fs = Cfg.fs;

yTone = jp_maketone(Cfg.toneFreq, Cfg.toneDurationSec, toneCfg);

rmsSound = jp_rms(y);
toneTargetRMS = Cfg.rmsToneScaling * rmsSound;
rmsTone = jp_rms(yTone);
yTone = yTone * (toneTargetRMS/rmsTone);



timeOptions = (length(y)/Cfg.fs) - Cfg.toneDurationSec - Cfg.startToneSec;


% Divide the time into the number of bins
for toneInd = 1:Cfg.numTones
    
    miniTimeOptions = timeOptions/Cfg.numTones; % this many time bins
    if toneInd < Cfg.numTones
        miniTimeOptions = miniTimeOptions - Cfg.tonePaddingSec;
    end
    
    toneStartSec(toneInd) = Cfg.startToneSec + ((toneInd-1) *miniTimeOptions) + (rand * miniTimeOptions);
    
    toneStartSample = int32(toneStartSec(toneInd) * Cfg.fs);
    toneEndSample = int32(toneStartSample + length(yTone) - 1);
    y(toneStartSample:toneEndSample) = y(toneStartSample:toneEndSample) + yTone;
end

% Check for clipping
if max(y) > 1
    error('Clipping in sound (max of %.2f). Try adjusting the tone scaling, or the original sound level.', max(y));
end


fs = Cfg.fs;




