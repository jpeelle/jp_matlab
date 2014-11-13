function [y, fs] = jp_maketone(freq, durationSec, Cfg)
%JP_MAKETONE Make sinewave tone
%
%  [Y,FS] = JP_MAKETONE(FREQ, DURATION) makes a sine wave tone of the
%  specified frequency (Hz) and duration (seconds).
%
%  [Y,FS] = JP_MAKETONE(FREQ, DURATION, CFG) allows you to specify other
%  options in the Cfg structure:
%
%    CFG.rampUpSec    How long to linear ramp down for (default .005)
%    CFG.rampDownSec  How long to linear ramp down for (default same as rampUpSec)
%    CFG.fs           Sampling rate (default 22050)
%
%  From https://github.com/jpeelle/jp_matlab

if nargin < 3
    Cfg = [];
end

if nargin < 2 || isempty(durationSec)
    durationSec = 1;
end

if nargin < 1 || isempty(freq)
    freq = 700;
end

if ~isfield(Cfg, 'rampUpSec') || isempty(Cfg.rampUpSec)
    Cfg.rampUpSec = .005;
end

if ~isfield(Cfg, 'rampDownSec') || isempty(Cfg.rampDownSec)
    Cfg.rampDownSec = Cfg.rampUpSec;
end

if ~isfield(Cfg, 'fs') || isempty(Cfg.fs)
    Cfg.fs = 20050;
end


fs = Cfg.fs;
rampUpSamples = round(Cfg.rampUpSec * fs);
rampDownSamples = round(Cfg.rampDownSec * fs);
durationSamples = durationSec * fs;

% Make sine tone
t = 0:1/fs:durationSec;
y = sin(freq*2*pi*t);

% Ramp
if rampUpSamples > 0
    step = 1/rampUpSamples;
    ramp = step:step:1;
    y(1:rampUpSamples) = y(1:rampUpSamples).*ramp;
end

if rampDownSamples > 0
    step = 1/rampDownSamples;
    ramp = 1:-step:step;
    y(end-rampDownSamples+1:end) = y(end-rampDownSamples+1:end).*ramp;
end

% Put in column format to match other Matlab audio conventions
y = y';