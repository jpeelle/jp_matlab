

% inDir = '/Users/peelle/Dropbox/work/stimuli/audiobooks_30s/Harry_Potter_original/book1/chapter1';
% outDir = '/Users/peelle/Dropbox/work/stimuli/audiobooks_30s/Harry_Potter_original_combined_chapters';
% outFile = fullfile(outDir, 'chapter01.wav');

fprintf('\n\n');
for chapInd = 2:17
    tic
    fprintf('Chapter %d...', chapInd);
    inDir = sprintf('/Users/peelle/Dropbox/work/stimuli/audiobooks_30s/Harry_Potter_original/book1/chapter%d', chapInd);
    outFile = sprintf('/Users/peelle/Dropbox/work/stimuli/audiobooks_30s/Harry_Potter_original_combined_chapters/chapter%02d.wav', chapInd);    
    jp_combinesounds(inDir, outFile);
    fprintf('done in %.1f seconds.\n', toc);
end