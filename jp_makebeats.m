function [y, fs, name] = jp_makebeats(pattern, Cfg);
%JP_MAKEBEATS Create rhythmic stimuli.
%
%  [Y,FS] = JP_MAKEBEATS(PATTERN) creates beats with the specified
%  durations. For example a pattern of [1 1 2] will contain 3 notes, two
%  short and a third that is twice is long. The duration of a 'beat' is set
%  in CFG.beatLengthSec (see below).
%
%  [Y,FS] = JP_MAKEBEATS(PATTERN,CFG) allows setting configuration options
%  including:
%
%    CFG.beatLengthSec  Corresponding to one "beat" (deafult 0.25 sec)
%    CFG.pauseBetweenTonesSec  Does not change beat length, but inserts pause between beats (default .05)
%    CFG.toneFreq              Frequency of the tone in Hz (default 700)
%    CFG.fs                    Sampling rate (default 22050)
%    CFG.endWithDownbeat       Add final beat (default 1)
%
%  [Y,FS,NAME] = JP_MAKEBEATS... returns a name that could be used for
%  saving the result to a sound file.

%pattern = [1 1 2 1 1 2 2 2];

if nargin < 2
    Cfg = [];
end

if ~isfield(Cfg, 'beatLengthSec') || isempty(Cfg.beatLengthSec)
    Cfg.beatLengthSec = .250;
end

if ~isfield(Cfg, 'pauseBetweenTonesSec') || isempty(Cfg.pauseBetweenTonesSec)   
    Cfg.pauseBetweenTonesSec = .05;
end

if ~isfield(Cfg, 'toneFreq') || isempty(Cfg.toneFreq)
    Cfg.toneFreq = 700; % Hz
end

if ~isfield(Cfg, 'fs') || ismpety(Cfg.fs)
    Cfg.fs = 22050;
end

if ~isfield(Cfg, 'endWithDownbeat') || isempty(Cfg.endWithDownbeat)
    Cfg.endWithDownbeat = 1;
end


pauseBetweenTones = zeros(round(Cfg.pauseBetweenTonesSec*Cfg.fs),1);

toneDuration = Cfg.beatLengthSec - Cfg.pauseBetweenTonesSec;

fs = Cfg.fs;

% initialize vector for holding things. It would be more efficient to not
% resize this all the time but it's probably ok for the size sounds we are
% dealing with here.
y = [];

toneCfg = [];
toneCfg.fs = fs;

for note=pattern
   tone = jp_maketone(Cfg.toneFreq, toneDuration*note, toneCfg);
   y = [y; tone; pauseBetweenTones];        
end

% If requested, add one more beat at end
if Cfg.endWithDownbeat
    tone = jp_maketone(Cfg.toneFreq, toneDuration, toneCfg);
    y = [y; tone];
end

tmpName = regexprep(num2str(pattern), '[ ]*', '_'); % replace whitespace with _
name = sprintf('sound_%s.wav', tmpName);
