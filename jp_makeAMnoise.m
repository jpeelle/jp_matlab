function [y, fs] = jp_makeAMnoise(freqHz, durationSec, Cfg)
%JP_MAKEAMNOISE Make amplitude modulated (AM) noise
%
%  [Y,FS] = JP_MAKEAMNOISE(FREQ) modulates broadband noise using a sine
%  wave of the specified frequenxy (Hz).
%
%  [Y,FS] = JP_MAKEAMNOISE(FREQ, DURATION) makes sine wave modulated
%  broadband noise lasting the specified DURATION (seconds).
%
%  [Y,FS] = JP_MAKEAMNOISE(FREQ, DURATION, CFG) allows you to specify other
%  options in the CGF structure:
%
%    CFG.
%    CFG.
%    CFG.fs           Sampling rate (default 22050)
%    CFG.plot         Plot results (default 0)
%
%  From https://github.com/jpeelle/jp_matlab


if nargin < 3
    Cfg = [];
end


if nargin < 2 || isempty(durationSec)
    durationSec = 1;
end


if nargin < 1 || isempty(freqHz)
    freqHz = 4;
end


if ~isfield(Cfg, 'fs') || isempty(Cfg.fs)
    Cfg.fs = 22050;
end


if ~isfield(Cfg, 'amplitude') || isempty(Cfg.amplitude)
    Cfg.amplitude = 1;
end


if ~isfield(Cfg, 'modulationDepth') || isempty(Cfg.modulationDepth)
    Cfg.modulationIndex = .8;
end


if ~isfield(Cfg, 'plot') || isempty(Cfg.plot)
    Cfg.plot = 0;
end

fs = Cfg.fs;



% Make sine wave at appropriate frequency (which we will use to modulate
% the noise)
t = 0:1/fs:durationSec;
sineWave = Cfg.amplitude + Cfg.modulationDepth * sin(2*pi*freqHz*t);



% Make broadband noise
yNoise = rand(1, length(sineWave)) - 0.5;

% ...and modulate
y = yNoise .* sineWave;


% Plot, if desired
if Cfg.plot > 0   
   figure
   subplot(3,1,1)
   plot(t, yNoise)
   title('Noise')
    
   subplot(3,1,2)
   plot(t, sineWave);
   title('Sine wave used for modulation');
   
   subplot(3,1,3)
   plot(t, y)
   title('AM signal')
   xlabel('Time (seconds)')
end

% Put in column format to match other Matlab audio conventions
y = y';



