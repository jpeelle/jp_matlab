% wrapper for jp_makebeats

%% Options: set these
clear all

% where to save the .wav files at the end
outDir = '~/Desktop/patterns';

% patterns: enter here. Using {} because they differ in length.
patterns{1} = [1 1 2 2];

% Bow long should the beat be? Can have one or multiple (that get looped
% through). In seconds.
beatLengths = [.250 .280];


% Configuration settings for jp_makebeats
Cfg = [];
Cfg.toneFreq = 700; % Hz
Cfg.pauseBetweenTonesSec = .05;
Cfg.endWithDownbeat = 1;


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
    
    for patternInd = 1:length(patterns)
        fprintf('Pattern %i/%i...', patternInd, length(patterns));
        thisPattern = patterns{patternInd};
        [y, fs, name] = jp_makebeats(thisPattern, Cfg);
        
        outName = fullfile(outDir, name);
        
        audiowrite(outName, y, fs);
        fprintf('done.\n');
    end
end

fprintf('\nAll done.\n\n');