function jp_maxvol(input_dirs, output_dirs, maxvol)
%JP_MAXVOL Increase maximum volume to a set amount.
%
% JP_MAXVOL(INPUTDIR, OUTPUTDIR, [MAXVOL]) where MAXVOL defaults to .97.
%
%


if nargin < 2 || isempty(output_dirs)
    output_dirs = input_dirs;
elseif ischar(output_dirs)
        tmpout = output_dirs;
        outputdirs = {};
        for i=1:length(input_dirs)
            output_dirs = {outputdirs{:} tmpout};
        end

else
    error('Not sure how to handle output_dirs');    
end



if nargin < 3 || isempty(maxvol)
    maxvol = .97;
end

verbose = 1;


% Make sure directories are cell arrays
if ischar(input_dirs) && size(input_dirs,1)==1
    input_dirs = {input_dirs};
end

if ischar(output_dirs) && size(output_dirs,1)==1
    output_dirs = {output_dirs};
end


% Make sure input directories exist
for i = 1:length(input_dirs)
    if ~isdir(input_dirs{i})
        error('Input directory %s not found.', input_dirs{i})
    end
end


% Make sure the output directories exist
for i = 1:length(output_dirs)
   if ~isdir(output_dirs{i})
       mkdir(output_dirs{i});
   end
end

% Get .wav files from each directory

% Go through D the first time to get the mean RMS
max_amplitude = 0;


if verbose > 0; fprintf('Looping through files to get info...'); end

num_wav = 0;

for i=1:length(input_dirs)
    d = dir(input_dirs{i});
    for j = 1:length(d)
        fileName = d(j).name;
        if length(fileName)>4 && strcmp(lower(fileName(end-3:end)),'.wav')
            
            [y,fs,bits] = wavread(fullfile(input_dirs{i},fileName));
            num_wav = num_wav + 1;
            if max(abs(y)) > max_amplitude
                max_amplitude = max(abs(y));
            end
        end        
    end
end % going through input_dirs to get files

if verbose > 0; fprintf('done.\n Found %i files.\n', num_wav); end



% Loop through again to change the files

if verbose > 0; fprintf('Looping through files again to adjust info...'); end

g = maxvol./max_amplitude;

fprintf('Maximum absolute amplitude found was %.3f; multiplying each sound file by %.3f.\n', max_amplitude, g);

for i=1:length(input_dirs)

    d = dir(input_dirs{i});
    for j = 1:length(d)
        fileName = d(j).name;
        if length(fileName)>4 && strcmp(lower(fileName(end-3:end)),'.wav')

            infile = fullfile(input_dirs{i}, fileName);
            movefile = fullfile(input_dirs{i}, sprintf('OLD%s',fileName));

            [y,fs,bits] = wavread(infile);

            y2 = y .* g;
            
            outfile = fullfile(output_dirs{i}, fileName);
            wavwrite(y2, fs, bits, outfile)

        end
    end
end

fprintf('done.\n');

