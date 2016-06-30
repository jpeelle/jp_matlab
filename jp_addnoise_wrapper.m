%
%  From https://github.com/jpeelle/jp_matlab

% (This script assumes the above matlab scripts are in your matlab path!
%  You may need to do this, e.g.:
%
%    addpath('~/jp_matlab')

clear all

% The original files are in originalDir; the thinking is that these should
% be read-only and never modified. If you want to add noise, change the
% scaling, etc., you probably want to do this in a new directory (outDir).
orginalDir = '/Volumes/OTO_Secure/Peelle_Lab/stimuli/Peelle_Lab_Sentences/original';
outDir = '/Volumes/OTO_Secure/Peelle_Lab/stimuli/Peelle_Lab_Sentences/babble_8talker_2014-11';


%% Error checking: make sure these directories exist
% (Not required but can save time if anything goes wrong later)
assert(isdir(originalDir), 'The specified sound directory %s does not exist.', originalDir)

if ~isdir(outDir)
    mkdir(outDir);
end

%% This reduced the volume to avoid clipping:
jp_maxvol(originalDir, outDir, .5)


%% Equalize RMS (optional)
jp_equalizerms(outDir);


%% Add noise

Cfg = [];
Cfg.noisefile = '/Users/peelle/Desktop/Heinrich_8talker_babble.wav';
Cfg.prestim = .5; % how much noise before stimulus, seconds
Cfg.poststim = .5;
Cfg.snrs = [-5 0 5 10 15];
Cfg.outdir = ''; % if specified, save files here (otherwise, saved to input directory)

jp_addnoise(outDir, Cfg);
