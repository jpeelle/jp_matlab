function [y, fs, name] = jp_makebeats(pattern, Cfg)
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
%    CFG.beatLengthSec         Corresponding to one "beat" (deafult 0.25 sec)
%    CFG.pauseBetweenTonesSec  Does not change beat length, but inserts pause between beats (default .05)
%    CFG.toneFreq              Frequency of the tone in Hz (default 400)
%    CFG.fs                    Sampling rate (default 22050)
%    CFG.endWithDownbeat       Add final beat? (default 1)
%    CFG.padSoundBeginningSec  Add silence at the beginning of the sound? (default 0)
%    CFG.padSoundEndSec        Add silence at the end of the sound? (default 0)
%
%  [Y,FS,NAME] = JP_MAKEBEATS... returns a name including the beat duration
%  and pattern that could be used for saving the result to a sound file.
%
%  JP_MAKEBEATS uses JP_MAKETONE. For an example of how to loop through and
%  create several stimuli, see JP_MAKEBEATS_WRAPPER.
%
%  From https://github.com/jpeelle/jp_matlab

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
    Cfg.toneFreq = 400; % Hz
end

if ~isfield(Cfg, 'fs') || ismpety(Cfg.fs)
    Cfg.fs = 22050;
end

if ~isfield(Cfg, 'endWithDownbeat') || isempty(Cfg.endWithDownbeat)
    Cfg.endWithDownbeat = 1;
end

if ~isfield(Cfg, 'padSoundBeginningSec') || isempty(Cfg.padSoundBeginningSec)
    Cfg.padSoundBeginningSec = 0;
end

if ~isfield(Cfg, 'padSoundEndSec') || isempty(Cfg.padSoundEndSec)
    Cfg.padSoundEndSec = 0;
end

pauseBetweenTones = zeros(round(Cfg.pauseBetweenTonesSec*Cfg.fs),1);
toneDurationSec = Cfg.beatLengthSec - Cfg.pauseBetweenTonesSec;
fs = Cfg.fs;

% Initialize vector for holding things. It would be more efficient to not
% resize this all the time but it's probably ok for the size sounds we are
% dealing with here.
y = [];

toneCfg = [];
toneCfg.fs = fs;

for note=pattern
   tone = jp_maketone(Cfg.toneFreq, toneDurationSec * note, toneCfg);
   y = [y; tone; pauseBetweenTones];        
end

% If requested, add one more beat at end
if Cfg.endWithDownbeat
    tone = jp_maketone(Cfg.toneFreq, toneDurationSec, toneCfg);
    y = [y; tone];
end

% If requested, add some silence before or after the sound
if Cfg.padSoundBeginningSec > 0
   pad = zeros(round(Cfg.padSoundBeginningSec * fs), 1);
   y = [pad; y];
end

if Cfg.padSoundEndSec > 0
   pad = zeros(round(Cfg.padSoundEndSec * fs), 1);
   y = [y; pad];
end


tmpName = regexprep(num2str(pattern), '[ ]*', '_'); % replace whitespace with _
name = sprintf('beat%.03f_%s.wav', Cfg.beatLengthSec, tmpName);
