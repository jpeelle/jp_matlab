%
%  From https://github.com/jpeelle/jp_matlab

clear all

% The original files are in originalDir; the thinking is that these should
% be read-only and never modified. If you want to add noise, change the
% scaling, etc., you probably want to do this in a new directory (outDir).
orginalDir = '/Volumes/oto_secure$/Peelle_Lab/stimuli/Peelle_Lab_Sentences/original';
outDir = '/Volumes/oto_secure$/Peelle_Lab/stimuli/Peelle_Lab_Sentences/babble_8talker_2014-11';


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

cfg = [];
cfg.noisefile = '/Users/peelle/Desktop/Heinrich_8talker_babble.wav';
cfg.prestim = .5; % how much noise before stimulus, seconds
cfg.poststim = .5;
cfg.snrs = [-5 0 5 10 15];
cfg.outdir = ''; % if specified, save files here (otherwise, saved to input directory)

jp_addnoise(originalDir, cfg);
