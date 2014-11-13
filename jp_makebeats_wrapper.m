% Wrapper script for jp_makebeats
%
%  From https://github.com/jpeelle/jp_matlab

%% Options: set these
clear all

% Where to save the .wav files at the end
outDir = '~/Desktop/patterns';

% Patterns: enter here. Using {} because they differ in length.
patterns{1} = [1 1 2 2];
patterns{2} = [2 1 1 4];

% How long should the beat be? Can have one or multiple (that get looped
% through). In seconds.
beatLengths = [.210:.01:.280];


% Configuration settings for jp_makebeats
Cfg = [];
Cfg.toneFreq = 700; % Hz
Cfg.pauseBetweenTonesSec = .05;
Cfg.endWithDownbeat = 1;
Cfg.padSoundBeginningSec = 0;
Cfg.padSoundEndSec = 0;

%% Error checking, etc.
% (make sure jp_makebeats is in your matlab path)
if ~exist('jp_makebeats', 'file')
    addpath('~/jp_matlab'); % <- change this to wherever jp_matlab exists
end

% Make sure output directory exists
if ~isdir(outDir)
    mkdir(outDir);
end

%% Make the beats

fprintf('\n\n');
for thisBeatLength = beatLengths
    Cfg.beatLengthSec = thisBeatLength;
    
    fprintf('\n\n%s Beat %.3f %s\n', repmat('=',1,10), thisBeatLength, repmat('=',1,10) ); 
    
    for patternInd = 1:length(patterns)
        fprintf('\tPattern %i/%i...', patternInd, length(patterns));
        thisPattern = patterns{patternInd};
        [y, fs, name] = jp_makebeats(thisPattern, Cfg);
        
        outName = fullfile(outDir, sprintf('patterm%03i_%s', patternInd, name));
        
        audiowrite(outName, y, fs);
        fprintf('done.\n');
    end
end

fprintf('\nAll done.\n\n');