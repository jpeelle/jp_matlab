function [y, fs] = jp_stringtogethersounds(files, Cfg)
%JP_STRINGTOGETHERSOUNDS Make one long sound file from shorter ones.
%
% JP_STRINGTOGETHERSOUNDS(FILES) takes individual sound files and puts
% them togehter into a long sound (e.g., for presenting during an
% experiment). FILES is assumed to be a cell array of sound file names (all
% with the same sampling rate).
%
% Cfg has the following fields to set options:
%
%  pauseBetweenSec   Pause between the end of one sound and the beginning of the next (sec) (default 2)
%  noiseFile         If not empty, add consistent noise throughout (will concatenate if too short)
%  SNR               SNR to use for noise
%  noisePreSoundSec  How long noise plays before sounds start
%  noisePostSoundSec How long noise plays after sounds stop
%
%
% From https://github.com/jpeelle/jp_matlab

if nargin < 2
    Cfg = [];
end

if ~isfield(Cfg, 'pauseBetweenSec') || isempty(Cfg.pauseBetweenSec)
    Cfg.pauseBetweenSec = 2;
end

if ~isfield(Cfg, 'noiseFile')
    Cfg.noiseFile = '';
end

if ~isfield(Cfg, 'noisePreSoundSec') || isempty(Cfg.noisePreSoundSec)
    Cfg.noisePreSoundSec = 1;
end


if ~isfield(Cfg, 'noisePostSoundSec') || isempty(Cfg.noisePostSoundSec)
    Cfg.noisePostSoundSec = 1;
end

% Read in the first file just to get the sampling rate to make sure this is
% consistent across everything
[y, fs] = audioread(files{1});

% If we are using noise, read it in
if ~isempty(Cfg.noiseFile)
    assert(exist(Cfg.noiseFile, 'file')>0, 'Specified noise file %s not found.', Cfg.noiseFile);
    [yNoise, fsNoise] = audioread(Cfg.noiseFile);
    assert(fsNoise==fs, 'Sampling rate of the noise (%i) does not match the sounds (%i).', fsNoise, fs);
end

% Read in sounds but don't do anything
for fileInd = 1:length(files)
    thisFile = files{fileInd};
    [ySounds{fileInd}, fsSound] = audioread(thisFile);
    assert(fsSound==fs, 'Sampling rate of sound %s (%i) does not match that of the first sound (%i).', thisFile, fsSound, fs);    
end


% String together the sounds
pauseSamp = zeros(Cfg.pauseBetweenSec * fs, 1);

y = [];
for soundInd = 1:length(ySounds)
    y = [y; ySounds{soundInd}; pauseSamp];
end

% If we are adding noise, do that
if ~isempty(Cfg.noiseFile)
    % Make sure the noise is long enough. If not, repeat it.
    while length(yNoise) < length(y)
        warning('The noise file was not long enough to cover all the sounds; repeating it with a little bit of crossfade.');
        yNoise = jp_crossfade(yNoise, yNoise, fs, 0.1);
    end

    % If the noise is TOO long, trim it. (Doing so now helps make sure that
    % the SNR calculations only take into account the important parts of
    % the noise.
    noisePreSoundSamples = Cfg.noisePreSoundSec*fs;
    noisePostSoundSamples = Cfg.noisePostSoundSec*fs;
    totalLengthSamples = length(y) + noisePreSoundSamples + noisePostSoundSamples;
    yNoise = yNoise(1:totalLengthSamples);
    
    % get level for noise file
    rmsNoise = jp_rms(yNoise);
    dbNoise = jp_mag2db(rmsNoise);
    
    % get level for sounds
    dbSignal = zeros(1,length(ySounds));
    for soundInd = 1:length(ySounds)
        dbSignal(soundInd) = jp_mag2db(jp_rms(ySounds{soundInd}));
    end
    
    dbSignalAvg = mean(dbSignal);
    
    % Scale noise to get right SNR
    targetDb = dbSignalAvg - Cfg.SNR; % target for noise dB
    targetRMS = 10^(targetDb/20);
    scaleFactor = targetRMS/rmsNoise;    
    yNoise = yNoise * scaleFactor;
                   
    y = [zeros(noisePreSoundSamples,1); y; zeros(noisePostSoundSamples,1)] + yNoise;    
end


end % main function

% rms function


