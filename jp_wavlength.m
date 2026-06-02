function jp_wavlength(S, Cfg)
%JP_WAVLENGTH Get the duration of sounds.
%
% JP_WAVLENGTH(FILE) Get the duration of a .wav file FILE.
%
% JP_WAVLENGTH(DIR) Get the duration of all .wav files in directory DIR.
%
% JP_WAVLENGTH(...,CFG) uses the following options:
%
% From https://github.com/jpeelle/jp_matlab

if nargin < 2
    Cfg = [];
end

if isfolder(S)
    D = dir(fullfile(S, '*.wav'));

    if isempty(D)
        error('No .wav files found in directory %s', S);
    end

    for k = 1:length(D)
        fname = fullfile(S, D(k).name);
        try            
            [y, fs] = audioread(fname);
            D(k).duration = size(y,1)/fs;
        catch
            error('Problem with file %s.', fname);
        end
    end

    fprintf('\nProcessed %i files.\n', length(D));

    % print output to screen
    fprintf('\n')
    for k = 1:length(D)
        fprintf('%s\t%.2f\n', D(k).name, D(k).duration);

    end
    fprintf('\n')

end

%TODO add support for a single file


