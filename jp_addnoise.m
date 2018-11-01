function jp_addnoise(soundfiles, cfg)
%JP_ADDNOISE Adds noise to some soundfiles at specific SNRs.
%
% JP_ADDNOISE(SOUNDFILES, CFG) loops through .wav files in a cell array and
% adds noise to each based on settings in CFG:
%
%   CFG.noisefile  full path to file with noise
%   CFG.prestim    how much noise before stimulus (seconds) [default .5]
%   CFG.poststim   how much noise after stimulus (seconds) [default .5]
%   CFG.snrs       SNRs used to add signal and noise (dB)
%   CFG.extraText  text added in file name before "SNR". [default '']
%   CFG.outdir     Make a new directory for output files by specifying path
%
% If SOUNDFILES is a directory, all of the .wav files in that directory are
% treated as the input files.
%
% The noise and signal files must have the same sampling rate, and are
% assumed to be mono. If the noise file is not long enough to match the
% signal, things will break.
%
% The level of the target (signal) files is unchanged; the noise level is
% adjusted to arrive at different SNRs.
%
% Example usage:
%
%  inDir = '/Users/peelle/Desktop/soundfiles';
%
%  cfg = [];
%  cfg.snrs = [0 5 10];
%  cfg.noisefile = '/Users/peelle/Desktop/noise.wav';
%
%  jp_addnoise(inDir, cfg);
%
% From https://github.com/jpeelle/jp_matlab


if ~isfield(cfg, 'prestim') || isempty(cfg.prestim)
    cfg.prestim = 0.5;
end

if ~isfield(cfg, 'poststim') || isempty(cfg.poststim)
    cfg.poststim = 0.5;
end

if ~isfield(cfg, 'outdir')
    cfg.outdir = '';
end

if ~isfield(cfg, 'snrs')
    error('Must specify CFG.snrs');
end

if ~isfield(cfg, 'extraText')
    cfg.extraText = '';
end

if ~isfield(cfg, 'noisefile')
    error('Must specify path to noise file in CFG.noisefile');
end

% error checking
if ~exist(cfg.noisefile)
    error('Noise file %s not found.', cfg.noisefile);
end

if ~isempty(cfg.outdir) && ~isdir(cfg.outdir)
    mkdir(cfg.outdir);
end

% if soundfiles is a directory, get .wav files
if ischar(soundfiles) && isdir(soundfiles)
   soundDir = soundfiles;
   D = dir(fullfile(soundfiles, '*.wav'));
   soundfiles = {D.name};

   for i=1:length(soundfiles)
       soundfiles{i} = fullfile(soundDir, soundfiles{i});
   end
else
    % if string, make a cell
    if ischar(soundfiles)
        soundfiles = cellstr(soundfiles);
    end
end


% Get noise
[yNoise, fsNoise] = audioread(cfg.noisefile);


% Loop through soundfiles and add noise
for i = 1:length(soundfiles);

    thisSound = soundfiles{i};

    [y, fs] = audioread(thisSound);

    assert(fs==fsNoise, 'Sampling rate of sentence %s (%i) does not match that of noise (%i).', thisSound, fs, fsNoise);

    rmsSignal = jp_rms(y);
    dbSignal = jp_mag2db(rmsSignal);

    % get the part of noise we need, and it's RMS and dB
    tmpNoise = yNoise(1:(length(y)+cfg.prestim*fs+cfg.poststim*fs));
    rmsNoise = jp_rms(tmpNoise);
    dbNoise = mag2db(rmsNoise);

    for thisSNR = cfg.snrs

        targetDb = dbSignal - thisSNR; % target for noise dB
        targetRMS = 10^(targetDb/20);
        scaleFactor = targetRMS/rmsNoise;

        scaledNoise = tmpNoise * scaleFactor;

        rmsScaledNoise = jp_rms(scaledNoise);
        dbScaledNoise = jp_mag2db(rmsScaledNoise);
        fprintf('SNR %g:\tsignal = %.1f, noise = %.1f dB\n', thisSNR, dbSignal, dbScaledNoise);

        yNew = [zeros(cfg.prestim*fs,1); y; zeros(cfg.poststim*fs,1)] + scaledNoise;

        if max(yNew) > 1
            warning('Signal %s clipping at %g.', thisSound, max(yNew));
        end

        % write new file
        [pth, nm, ext] = fileparts(thisSound);

        % decide where to save it - is cfg.outdir specified?
        if ~isempty(cfg.outdir)
            outDir = cfg.outdir;
        else
            outDir = pth;
        end

        fileName = fullfile(outDir, sprintf('%s_%sSNR%d%s', nm, cfg.extraText, thisSNR, ext));
        audiowrite(fileName, yNew, fs);

    end % going through SNRs
end % looping through soundfiles

end % main function