%
%  From https://github.com/jpeelle/jp_matlab

inputDirectory = '/Users/peelle/Dropbox/work/stimuli/ORSR_6word_2001_vocoded2012';
outputDirectory = '/Users/peelle/Desktop/DELETEME';
channels = [8]; % you can have multiple levels here, e.g. [16 8 4]


%% NB You probably don't have to change anything after this point

% Make sure jp_vocode is in your matlab path - if not, you'll need to add
% it using the addpath function. You may need to download the jp_matlab
% code from: https://github.com/jpeelle/jp_matlab

assert(exist('jp_vocode', 'file')==2, 'Required function jp_vocode is not found on your Matlab path.')



% Check to make sure output directory exists
if ~isdir(outputDirectory)
    mkdir(outputDirectory);
end

% Get a list of all the .wav files in the input directory
D = dir(fullfile(inputDirectory,'*.wav'));

% Go through each file, vocode it, and save it in the output directory
fprintf('Vocoding %d files...\n', length(D));
for fileInd = 1:length(D)
    fprintf('File %d/%d...', fileInd, length(D));
    inputFullPath = fullfile(inputDirectory, D(fileInd).name);
    [inputPath, inputName, inputExt] = fileparts(inputFullPath);

    % Do multiple channels for each file
    for numChannels = channels
        [wave, fs] = jp_vocode(inputFullPath, numChannels);
        outputFullPath = fullfile(outputDirectory, sprintf('%s_%02dch.wav', inputName, numChannels));
        audiowrite(outputFullPath, wave, fs);
    end
    fprintf('done.\n');
end

fprintf('All done. %d files written to %s.\n', length(D), outputDirectory);
