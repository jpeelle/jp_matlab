ø% function [y, fs] = jp_addtone2sound(sound, Cfg)
% %JP_ADDTONE2SOUND Add one or more tones to a longer soundfile.
% %
% % JP_ADDTONE2SOUND(Y) adds one or more tones to a sound vector Y. (You must
% % specify the sampling rate in CFG.fs.)
% %
% % JP_ADDTONE2SOUND(WAVFILE) reads in a soundfile.
% %
% % JP_ADDTONE2SOUND(Y, CFG) allows to specify the following options:
% %
% %  CFG.fs               Sampling rate (Hz) for vectors (otherwise read from soundfile)
% %  CFG.toneFreq         Frequency of the tones (Hz) (default 1000)
% %  CFG.toneDurationSec   Length of each tone (seconds) (default 0.1)
% %  CFG.numTones           Number of tones added (1 or 2) (default 1)
% %
% %
% %  From https://github.com/jpeelle/jp_matlab
% 
% 
% if nargin < 1 || isempty(sound)
%     error('Must specify sound vector or sound file.');
% end
% 
% if nargin < 2
%     Cfg = [];
% end


sound = '
Cfg = [];

if exist(sound, 'file')
    [y, fs] = audioread(sound);
    Cfg.fs = fs;
else
    % assume vector
    
    if ~isfield(Cfg, 'fs') || isempty(Cfg.fs)
        error('If passing a vector, you must specify sample rate in cfg.fs');
    end
    
    y = sound;
end

if ~isfield(Cfg, 'toneFreq') || isempty(Cfg.toneFreq)
    Cfg.toneFreq = 1000;
end

if ~isfield(Cfg, 'toneDurationMs') || isempty(Cfg.toneDurationMs)
    Cfg.toneDurationSec = 100;
end

if ~isfield(Cfg, 'numTones') || isempty(Cfg.numTones)
    Cfg.numTones = 1;
end


% NB may need to add a 0 tone condition if any filtering is done to sound


toneCfg = [];
toneCfg.fs = Cfg.fs;

yTone = jp_maketone(Cfg.toneFreq, Cfg.toneDurationSec, toneCfg);



switch Cfg.numTones
    case 1
        
        toneStartSec = (rand * timeOptions) + Cfg.startTone;
        toneStartSample = round(toneStartSec * Cfg.fs);
        
        
    case 2
        
        
end % switch




fs = cfg.fs;


