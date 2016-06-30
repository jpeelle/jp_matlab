% Example wrapper function for jp_addtone2sound.m function.
%
%  From https://github.com/jpeelle/jp_matlab

% (This script assumes the above matlab scripts are in your matlab path!
%  You may need to do this, e.g.:
%
%    addpath('~/jp_matlab')

originalDir = '/Volumes/OTO_Secure/Peelle_Lab/resources/stimuli/private/sentences/VanEngen_F01_Sentences_Level65';

outputDir = '/Volumes/OTO_Secure/Peelle_Lab/research_projects/201606046_Dual-TaskT35/DualTaskExperiment/DualTask01/inputs/soundfiles';


% Configuration for tones
toneCfg = [];

% Configuration for noise
noiseCfg = [];


%% Copy sounds over

% make sure output directory exists
if ~isdir(outputDir)
    mkdir(outputDir);
    
    % Copy all of the original files - but not the noise file
    cmd = sprintf('cp -f %s/*_F01.wav %s/', originalDir, outputDir);
    system(cmd)
end



%% Add the tones 
D = dir(sprintf('%s/*_F01.wav', outputDir));

% (Here is where we could normalize them all or change the orignal volume)


% Go through all wav files. For each, make a 1 tone and 2 tone version and
% save the file name appropriately.
%
% Also, create a .txt file for each with the tone onset times, and a
% spreadsheet that collates them.

fname = fullfile(outputDir, 'soundfile_info.txt');
fid = fopen(fname, 'w');

fprintf('\n');

for soundInd = 1:length(D)
    
    fprintf('File %d/%d...', soundInd, length(D));
    
    soundName = D(soundInd).name(1:end-4);
     
    sound = fullfile(outputDir, D(soundInd).name);
    
    for toneInd = 1:2
        toneCfg.numTones = toneInd;
        [y, fs, toneStartSec] = jp_addtone2sound(sound, toneCfg) ;
        
        outFile = fullfile(outputDir, sprintf('%s_%dtone.wav', soundName, toneInd));
        audiowrite(outFile, y, fs);
        
        outFileTxt = fullfile(outputDir, sprintf('%s_%dtone.txt', soundName, toneInd));
        dlmwrite(outFileTxt, toneStartSec, 'delimiter', '\n');
        
        % Write to the text file
        fprintf(fid, '%s\t', sprintf('%s_%dtone.wav', soundName, toneInd));
        fprintf(fid, '%f\t', toneStartSec(1));
        if toneInd==2
            fprintf(fid, '%f\t', toneStartSec(2));
        else
            fprintf(fid, '\t');
        end
        
        fprintf(fid, '\n');
        
    end % going through how many tones we want
    
    fprintf('\n');
end


fclose(fid);

%% Now add noise to these files at the specified SNRs (optional)


Cfg = [];
Cfg.noisefile = '/Volumes/OTO_Secure/Peelle_Lab/resources/stimuli/private/sentences/VanEngen_F01_Sentences_Level65/CSP_F01_speech_shaped65.wav';
Cfg.prestim = .5; % how much noise before stimulus, seconds
Cfg.poststim = .5;
Cfg.snrs = [5 10 15];
Cfg.outdir = ''; % if specified, save files here (otherwise, saved to input directory)

jp_addnoise(outputDir, Cfg);





