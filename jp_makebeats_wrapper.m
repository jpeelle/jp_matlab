% wrapper for jp_makebeats

% options: set these
outDir = '~/Desktop/patterns';

% patterns: enter here. Using {} because they differ in length.
patterns{1} = [1 1 2 2];

% (make sure jp_makebeats is in your matlab path)
if ~exist('jp_makebeats', 'file')
    addpath('~/jp_matlab'); % <- change this to wherever jp_matlab exists
end

% Make sure output directory exists
if ~isdir(outDir)
    mkdir(outDir);
end

Cfg = [];

fprintf('\n\n');
for patternInd = 1:length(patterns)
    fprintf('Pattern %i/%i...', patternInd, length(patterns));
   thisPattern = patterns{patternInd};
   [y, fs, name] = jp_makebeats(thisPattern, Cfg);
   
   outName = fullfile(outDir, name);
   
   audiowrite(outName, y, fs);    
   fprintf('done.\n');
end

fprintf('\nAll done.\n\n');