function jp_equalize(input_dirs, output_dirs, equaltype, verbose)
%JP_EQUALIZE Equalize sound files in directories.
%
%  equaltype = rms or max
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



if nargin < 3 || isempty(equaltype)
  equaltype = 'rms';
end

if nargin < 4 || isempty(verbose)
  verbose = 1;
end


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

% Get .wav files from each directory and get the RMS and max volume

% Go through D the first time to get the mean RMS
rms_total = 0;
rms_count = 0;
max_amplitude = 0;
num_wav = 0; % keep track of how many wav files

if verbose > 0; fprintf('Looping through files to get info...'); end

for i=1:length(input_dirs)
  d = dir(input_dirs{i});
  for j = 1:length(d)
    fileName = d(j).name;
    if length(fileName)>4 && strcmp(lower(fileName(end-3:end)),'.wav')

      num_wav = num_wav + 1;

      [y,fs,bits] = wavread(fullfile(input_dirs{i},fileName));
      rms_total = rms_total + jp_rms(y);
      rms_count = rms_count+1;
      if max(y) > max_amplitude
        max_amplitude = max(y);
      end
    end
  end
end % going through input_dirs to get files

if verbose > 0; fprintf('done.\n Found %i files\n.', num_wav); end

rmsMean = rms_total/rms_count;

% Keep track of what we adjust
max_amps_before = zeros(1,num_wav);
max_amps_after = zeros(1,num_wav);
rms_before = zeros(1,num_wav);
rms_after = zeros(1,num_wav);
this_wav = 1;

% Loop through again to change the files

if verbose > 0; fprintf('Looping through files again to adjust info...'); end

for i=1:length(input_dirs)

  if ~isdir(input_dirs{i})
    error('Can''t find input directory %s.', input_dirs{i})
  end

  d = dir(input_dirs{i});
  for j = 1:length(d)
    fileName = d(j).name;
    if length(fileName)>4 && strcmp(lower(fileName(end-3:end)),'.wav')

      infile = fullfile(input_dirs{i}, fileName);
      movefile = fullfile(input_dirs{i}, sprintf('OLD%s',fileName));

      [y,fs,bits] = wavread(infile);

      if strcmp(equaltype, 'rms')
        thisRms = jp_rms(y);
        rms_before(this_wav) = thisRms;
        y2 = y * (rmsMean/thisRms);
        rms_after(this_wav) = jp_rms(y2);
        this_wav = this_wav + 1;

        % Scale if over 1 or under -1
        if max(y2) > 1 || min(y2) < -1
          fprintf('File %s: MIN = %.3f, MAX = %.3f, scaling so as not to clip.\n', fileName, min(y2), max(y2));
          biggest = max([abs(min(y2)) max(y2)]);
          y2 = (y2/biggest) * .99;
        end

      elseif strcmp(equaltype, 'max')
        if max(y)==max_amplitude && verbose > 0
          fprintf('Maximum amplitude of %.3f found in %s.\n', max_amplitude, infile);
        end

        max_amp_before(this_wav) = max(y);
        y2 = y / (max_amplitude/.98);
        max_amp_after(this_wav) = max(y2);
        this_wav = this_wav + 1;
      end

      outfile = fullfile(output_dirs{i}, fileName);

      if strcmp(input_dirs{i}, output_dirs{i})
        system(sprintf('mv %s %s', infile, movefile));
      end

      wavwrite(y2, fs, bits, outfile)
    end
  end
end


if verbose > 0
  if strcmp(equaltype, 'rms')
    figure
    subplot(1,2,1)
    hist(rms_before)
    title('RMS before')

    subplot(1,2,2)
    hist(rms_after)
    title('RMS after')
  elseif strcmp(equaltype, 'max')
    figure
    subplot(1,2,1)
    hist(max_amp_before)
    title('Max Amplitude Before')

    subplot(1,2,2)
    hist(max_amp_after)
    title('Max Amplitude After')

  end

end

fprintf('done.\n');

