function jp_combinesounds(soundfiles, outfile, Cfg)
%JP_COMBINESOUNDS Takes individual soundfiles and combines to one longer
%osundfile.
%
% JP_COMBINESOUNDS(SOUNDFILES, OUTFILE) combines the soundfiles into the
% specified output file (defaulting to the same file type as the input
% files). If SOUNDFILES is a directory, all of the sound files contained in
% the directory are used (using CFG.FILETYPE as a filter, default .wav).
%
% JP_COMBINESOUNDS(SOUNDFILES, OUTFILE, CFG) uses settings in CFG:
%
%   CFG.filetype  extension on soundfiles (default .wav)
%
% JP_COMBINESOUNDS uses AUDIOREAD, so supports all of the file types
% supported by AUDIOREAD.
%
% All files should be of the same type (file type, stereo/mono, bit rate,
% etc.).
%
% From https://github.com/jpeelle/jp_matlab

% Input and error checking

if nargin < 2
    error('Must have at least two inputs: jp_combinesounds(SOUNDFILES, OUTFILE).');
end

if nargin < 3
    Cfg = [];
end

if ~isfield(Cfg, 'filetype') || isempty(Cfg.filetype)
    Cfg.filetype = '.wav';
end

if isfolder(soundfiles)
    D = dir(fullfile(soundfiles, sprintf('*%s', Cfg.filetype)));
    S = {};
    for fileInd = 1:length(D)
        S{fileInd} = fullfile(D(fileInd).folder, D(fileInd).name);
    end
end

% Initialize empty variable 
yy = [];

for thisInd = 1:length(S)
   [y, fs] = audioread(S{thisInd});
   yy = [yy;y];    
end

audiowrite(outfile, yy, fs);

%fprintf('\nSounds combined: wrote %s.\n', outfile);

