function jp_wavlengthen(A, time_beg_ms, time_end_ms, suffix)
%JP_WAVLENGTHEN Make wav files longer.
%
%  JP_WAVLENGTHEN(A, TIME_BEG, TIME_END) adds the specified silence (in
%  milliseconds) to the beginning and end of the .wav file(s) specified.  A
%  can be a .wav file, a directory, or a cell array of directories.  New
%  files have "_L" appended to the filename, saved in the same directory.
%
%  For example, if you want to add 500 ms to the beginning and end of files
%  in the 'sounds' directory:
%
%      jp_wavlengthen('sounds', 500, 500)
%
%  A can also be a list of directories:
%
%      jp_wavlengthen({'sounds1', 'sounds2'}, 500, 0)
%
%  JP_WAVLENGTHEN(A, TIME_BEG, TIME_END, SUFFIX) appends anything you
%  specify instead of "_L".
%
%  $Rev$
%  $Date$

if nargin < 4
    suffix = '_L';
end

if exist(A, 'file') && ~isdir(A) && strcmp(lower(A(end-4:end)), '.wav')
   addtime(A, time_beg_ms, time_end_ms, suffix);     
elseif isdir(A)
    processdir(A, time_beg_ms, time_end_ms, suffix);    
elseif iscell(A)    
    for i=1:length(A)
        processdir(A{i}, time_beg_ms, time_end_ms, suffix);
    end
else
   error('Unrecognized input argument.') 
end

fprintf('Done.\n');

end % main function


function processdir(A, time_beg, time_end, suffix)
    fprintf('Lengthening files in directory %s...', A);
    d = dir(A);
    for i=1:length(d)
        [pth, n, ext] = fileparts(d(i).name);
        if strcmp(lower(ext), '.wav')
           addtime(fullfile(A, d(i).name), time_beg, time_end, suffix); 
        end        
    end    
    fprintf('done.\n');
end


function addtime(A, time_beg, time_end, suffix)
    [pth, fname] = fileparts(A);    
    newname = fullfile(pth, sprintf('%s%s.wav', fname, suffix));    
    [y, fs, bits] = wavread(A);
    
    time_beg_s = time_beg/1000;
    time_end_s = time_end/1000;
    
    y2 = [zeros(time_beg_s*fs,1); y; zeros(time_end_s*fs,1)];
    
    wavwrite(y2, fs, bits, newname);
end % addtime
