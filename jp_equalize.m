function jp_equalize(inputDirs, outputDirs, Cfg)
%JP_EQUALIZE Equalize sound files in directories.
%
% JP_EQUALIZE(INPUTDIRS, OUTPUTDIRS, CFG)
%  CFG.equaltype = 'rms' | 'max' | 'dB' (default rms)
%  CFG.targetDb = optional if CFG.equaltype='dB' (default -25)
%
%  From https://github.com/jpeelle/jp_matlab


if nargin < 2 || isempty(outputDirs)
    outputDirs = inputDirs;
elseif ischar(outputDirs)
    tmpout = outputDirs;
    outputdirs = {};
    for i=1:length(inputDirs)
        outputDirs = {outputdirs{:} tmpout};
    end
else
    error('Not sure how to handle outputDirs');
end

if nargin < 3
    Cfg = [];
end

if ~isfield(Cfg, 'equaltype') || isempty(Cfg.equaltype)
    Cfg.equaltype = 'rms';
end

if ~isfield(Cfg, 'targetDb') || isempty(Cfg.targetDb)
    Cfg.targetDb = -25;
end


% Make sure directories are cell arrays
if ischar(inputDirs) && size(inputDirs,1)==1
    inputDirs = {inputDirs};
end

if ischar(outputDirs) && size(outputDirs,1)==1
    outputDirs = {outputDirs};
end


% Make sure input directories exist
for i = 1:length(inputDirs)
    if ~isdir(inputDirs{i})
        error('Input directory %s not found.', inputDirs{i})
    end
end

verbose = 1;

% Make sure the output directories exist - if not, create
for i = 1:length(outputDirs)
    if ~isdir(outputDirs{i})
        mkdir(outputDirs{i});
    end
end

% Get .wav files from each directory and get the RMS and max volume

% Go through D the first time to get the mean RMS
rms_total = 0;
rms_count = 0;
max_amplitude = 0;
num_wav = 0; % keep track of how many wav files

% If not going for target dB, loop through to get info.
if ~strcmp(lower(Cfg.equaltype, 'db'))
    
    if verbose > 0; fprintf('Looping through files to get info...'); end
    
    for i=1:length(inputDirs)
        d = dir(inputDirs{i});
        for j = 1:length(d)
            fileName = d(j).name;
            if length(fileName)>4 && strcmpi(fileName(end-3:end),'.wav')
                
                num_wav = num_wav + 1;
                
                [y,fs] = audioread(fullfile(inputDirs{i},fileName));
                rms_total = rms_total + jp_rms(y);
                rms_count = rms_count+1;
                if max(y) > max_amplitude
                    max_amplitude = max(y);
                end
            end
        end
    end % going through inputDirs to get files
    
    if verbose > 0; fprintf('done.\n Found %i files.\n', num_wav); end
    
    rmsMean = rms_total/rms_count;
    
end


% Keep track of what we adjust
max_amps_before = zeros(1,num_wav);
max_amps_after = zeros(1,num_wav);
rms_before = zeros(1,num_wav);
rms_after = zeros(1,num_wav);
this_wav = 1;

% Loop through again to change the files

if verbose > 0; fprintf('Looping through files again to adjust info...'); end

for i=1:length(inputDirs)
    
    
    d = dir(inputDirs{i});
    for j = 1:length(d)
        fileName = d(j).name;
        if length(fileName)>4 && strcmpi(fileName(end-3:end),'.wav')
            
            infile = fullfile(inputDirs{i}, fileName);
            
            [y,fs] = audioread(infile);
            
            thisRms = jp_rms(y);
            rms_before(this_wav) = thisRms;
            
            switch lower(Cfg.equaltype)
                case 'rms'
                    y2 = y * (rmsMean/thisRms);
                    rms_after(this_wav) = jp_rms(y2);
                    
                case 'max'
                    max_amp_before(this_wav) = max(y);
                    y2 = y / (max_amplitude/.98);
                    max_amp_after(this_wav) = max(y2);
                    
                case 'db'
                    targetRMS = 10^(Cfg.targetDb/20);
                    scaleFactor = targetRMS/thisRms;
                    y2 = y * scaleFactor;
                    
            end % switch
            
            this_wav = this_wav + 1;
            
            %       if strcmp(equaltype, 'rms')
            %         thisRms = jp_rms(y);
            %         rms_before(this_wav) = thisRms;
            %         y2 = y * (rmsMean/thisRms);
            %         rms_after(this_wav) = jp_rms(y2);
            %         this_wav = this_wav + 1;
            %
            %         % Scale if over 1 or under -1
            %         if max(y2) > 1 || min(y2) < -1
            %           fprintf('File %s: MIN = %.3f, MAX = %.3f, scaling so as not to clip.\n', fileName, min(y2), max(y2));
            %           biggest = max([abs(min(y2)) max(y2)]);
            %           y2 = (y2/biggest) * .99;
            %         end
            %
            %       elseif strcmp(equaltype, 'max')
            %         if max(y)==max_amplitude && verbose > 0
            %           fprintf('Maximum amplitude of %.3f found in %s.\n', max_amplitude, infile);
            %         end
            %
            %         max_amp_before(this_wav) = max(y);
            %         y2 = y / (max_amplitude/.98);
            %         max_amp_after(this_wav) = max(y2);
            %         this_wav = this_wav + 1;
            %       end
            
            outfile = fullfile(outputDirs{i}, fileName);
            
            audiowrite(outfile, y2, fs);
        end
    end
end





fprintf('done.\n');

