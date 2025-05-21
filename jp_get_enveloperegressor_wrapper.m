% Script for geting the acoustic amplitude envelope from a sound file and
% downsampling to a specific TR (for use as a regressor in an fMRI
% analysis).
%
% Requires JP_GETENVELOPE from http://github.com/jpeelle/jp_matlab

close all; clear all

addpath ~/software/jp_matlab/
addpath ~/software/spm/


%% Set options (this is the part to edit for new movies)


wavFile =  'nndb/back_to_the_future/back_to_the_future.wav';
outFile = 'bttf_envelope.csv'; % % where to save regressor (leave empty to not save)
TRsec = 1.1; % fMRI TR in seconds

% these options are passed to jp_getenveloperegressor
Cfg = [];
Cfg.plotTimeSec = [30 40];  % leave empty [] to skip plotting




%% Error checking

assert(exist(wavFile), sprintf('File not found: %s', wavFile))
assert(exist('jp_getenveloperegressor'), 'JP_GETENVELOPEREGRESSOR not found (need to make sure jp_matlab folder is in your path).')


%% Get sound and envelope

% read in the sound file
[y, fs] = audioread(wavFile);

% get the regressor
reg = jp_getenveloperegressor(y, fs, TRsec, Cfg);


%% Save the file
if ~isempty(outFile)
    dlmwrite(outFile, reg, 'delimiter', ',');
end % saving file

fprintf('\nDone.\n')
