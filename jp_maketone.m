function [y, fs] = jp_maketone(freq, durationSec, cfg)
%JP_MAKETONE Make sinewave
%
%  [Y,FS] = JP_MAKETONE(FREQ, DURATION) makes a sine wave tone of the
%  specified frequency (Hz) and duration (seconds).
%
%  [Y,FS] = JP_MAKETONE(FREQ, DURATION, CFG) allows you to specify other
%  options in the CFG structure:
%
%    CFG.rampUpSec
%    CFG.rampDownSec
%    CFG.fs


if nargin < 3
    cfg = [];
end


if ~isfield(cfg, 'rampUpSec') || isempty(cfg.rampUpSec)
    cfg.rampUpSec = .005;
end

if ~isfield(cfg, 'rampDownSec') || isempty(cfg.rampDownSec)
    cfg.rampDownSec = cfg.rampUpSec;
end

if ~isfield(cfg, 'fs') || isempty(cfg.fs)
    cfg.fs = 20050;
end


fs = cfg.fs;
rampUpSamples = round(cfg.rampUpSec * fs);
rampDownSamples = round(cfg.rampDownSec * fs);
durationSamples = durationSec * fs;

% make tone
t = 0:1/fs:durationSec;
y = sin(freq*2*pi*t);

% ramp
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

y = y';