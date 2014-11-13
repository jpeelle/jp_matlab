function jp_makemono(inputDirs);
% Make sure all .wav files are mono.
%
% If 2 (or more) channels, just use the first channel, and re-write.
%
%  From https://github.com/jpeelle/jp_matlab

for i=1:length(inputDirs)
    d = dir(inputDirs{i});
    for j = 1:length(d)
        fileName = d(j).name;
        if length(fileName)>4 && strcmpi(fileName(end-3:end),'.wav')

            wavFile = fullfile(inputDirs{i},fileName);

            [y,fs,bits] = audioread(wavFile);

            if size(y,1) > 1
                audiowrite(y(:,1), fs, bits, wavFile);
            end
        end
    end
end % going through inputDirs to get files
