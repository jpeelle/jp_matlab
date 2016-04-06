function [wave, fs] = jp_vocode(soundfile, num_channels, opts)
% JP_VOCODE Vocode a sound with the option to shift frequencies.
%   [Y, FS, BITS] = JP_VOCODE(sound, num_channels, [opts])
%   will return a sound vector Y at sampling rate FS with BITS bits
%   sampling rate, suitable for being played with the SOUND function or
%   written with audiowrite.  This is noise vocoding with logarithmic
%   spacing between frequency bands.
%
%   Input arguments:
%    soundfile       file we read in
%    num_channels    number of channels for vocoding
%
%   opts has the following fields
%    input_range     Two-element vector with min and max frequencies (Hz) (default [100 10000])
%    output_range    Two-element vector with min and max frequencies (Hz) (default same as input)
%    outputmapping   Low-to-high mapping of filters (see below) (default same as input)
%    rmsmapping      Low-to-high mapping of RMS power from each envelope (see below) (default same as outputmapping)
%    high_freq       Lowpass cutoff for the very end (Hz)(default 10000) (set to 0 to skip)
%    smoothing_freq  For the smoothing envelope (Hz) (default 30)
%    infilter_ord    Order of the input filter (default 6)
%    outfilter_ord   Order of the output filter (default same as input)
%    rectify         'full' or 'half' for each channel (default 'half')
%    verbose         If 1, print more info to screen (default 0).
%    save_output     If 1, save all variables to vocode_vars.mat (useful for debugging) (default 0).
%
%   The frequency range [MIN MAX] is divided into num_channels number of
%   channels using a logrithmic scale.
%
%   The default is to vocode each input channel and output it at
%   the same channel number; i.e., the lowest channel of input gets
%   saved as the lowest channel of output (even if the frequencies
%   are shifted).  However, this assignment is arbitrary.  If you
%   have 4 channels the default opts.outputmapping is [1 2 3 4].
%   For 'rotated' speech, you would specify [4 3 2 1], as this will
%   take the lowest input channel (1) and map it to the highest
%   ouput channel (4).  Any variation should work.  As a shortcut
%   to rotating, you can also specify 'rotate' for
%   opts.outputmapping.
%
%   Generally the power (RMS) of each output channel is matched to that of
%   the filtered input signal for that channel.  This is specified by the
%   rmsmapping option.  The default is to be equal to opts.outputmapping,
%   that is, scale each channel by the envelope that was used to modulate
%   the signal.  Another option is to scale the power of an output channel
%   by whatever the power was at that frequency in the original, for
%   example, to preserve the overall frequency power spectrum of the
%   original speech.  opts.rmsmapping can be any arbitrary mapping.
%   Specifying 'original' uses the original frequency for the same
%   frequency band, regardless of which envelope is used.
%
%
%   JP_VOCODE requires the signal processing toolbox.
%
%
% To vocode a group of .wav files (say, in a directory called
% 'soundfiles'), you might try something like this:
%
%     inputDirectory = '/path/to/input/soundfiles/';
%     outputDirectory = '/path/to/output/soundfiles/';
%     numChannels = 8;  % how many channels in vocoding
%
%     % Check to make sure output directory exists
%     if ~isdir(outputDirectory)
%         mkdir(outputDirectory);
%     end
%
%     % Get a list of all the .wav files in the input directory
%     D = dir(fullfile(inputDirectory,'*.wav'));
%
%     % Go through each file, vocode it, and save it in the output directory
%     fprintf('Vocoding %d files...', length(D));
%     for fileInd = 1:length(D)
%         inputFullPath = fullfile(inputDirectory, D(fileInd).name);
%         [inputPath, inputName, inputExt] = fileparts(inputFullPath);
%
%         [wave, fs, bits] = jp_vocode(inputFullPath, numChannels);
%         outputFullPath = fullfile(outputDirectory, sprintf('%s_%02dchannels.wav', inputName, numChannels));
%         audiowrite(outputFullPath, wave, fs);
%     end
%
%     fprintf('done. %d files written.\n', length(D));
%
%
%  See also JP_VOCODE_WRAPPER.
%
%   Jonathan Peelle
%   Based on code from Stuart Rosen, based on work of Philip Loizou
%   (I think).
%
%  From https://github.com/jpeelle/jp_matlab

% error checking
if num_channels < 1; error('Must have at least 1 channel.'); end

[pathstr, filename, fileext] = fileparts(soundfile);

if ~strcmp(fileext,'.wav')
  error('Must input a .wav file for now.')
end


% set default options --------------------------------------
if nargin < 3
  opts = struct();
end

% set default values
if ~isfield(opts, 'input_range')
  opts.input_range = [100 10000];
end

if ~isfield(opts, 'output_range')
  opts.output_range = opts.input_range;
end

if ~isfield(opts, 'outputmapping') || isempty(opts.outputmapping)
  opts.outputmapping = [1:num_channels];
elseif ischar(opts.outputmapping)
  if strcmp(opts.outputmapping, 'rotate')
    opts.outputmapping = [num_channels:-1:1];
  else
    error('opts.outmapping must be a numeric vector or ''rotate''')
  end
else
  % Make sure each input channel is in outputmapping
  if sum((sort(opts.outputmapping)==[1:num_channels])==0) > 0
    error('Each channel must be represented in opts.outputmapping.')
  end
end


if ~isfield(opts, 'rmsmapping') || isempty(opts.rmsmapping)
    opts.rmsmapping = opts.outputmapping;
elseif ischar(opts.rmsmapping)
    if strcmp(opts.rmsmapping, 'original')
        opts.rmsmapping = [1:num_channels];
    else
        error('opts.rmsmapping must be a numeric vector or ''original''')
    end
end



%if ~isfield(opts, 'low_freq') || isempty(opts.low_freq)
%  opts.low_freq = 0;
%end

if ~isfield(opts, 'high_freq') || isempty(opts.high_freq)
  opts.high_freq = 10000;
end

if ~isfield(opts, 'smoothing_freq') || isempty(opts.smoothing_freq)
  opts.smoothing_freq = 30;
end

if ~isfield(opts, 'infilter_ord') || isempty(opts.infilter_ord)
  opts.infilter_ord = 6;
end

if ~isfield(opts, 'outfilter_ord') || isempty(opts.outfilter_ord)
  opts.outfilter_ord = opts.infilter_ord;
end

if ~isfield(opts, 'rectify') || isempty(opts.rectify)
  opts.rectify = 'half';
end

if ~isfield(opts, 'verbose') || isempty(opts.verbose)
  opts.verbose = 0;
end

if ~isfield(opts, 'save_output') || isempty(opts.save_output)
  opts.save_output = 0;
end


if opts.verbose > 0
  fprintf('Running with these options:\n')
  opts
end

% open the sound file
[y, fs] = audioread(soundfile);
num_samples = length(y);
half_sample_rate = fs/2;


if opts.verbose > 0
  fprintf('%s:\n\t%i samples\n\tFs = %i\n\t%i bits\n', soundfile, num_samples, fs, bits);
end


% calculate input level, in terms of root sum squared
input_level = jp_rms(y);

% decide logarithmic spacing based on lowest frequency requested
low_freq = opts.input_range(1);

% inputs
inRange=log10(opts.input_range(2)/low_freq);
inInterval=inRange/num_channels;
inCenter=zeros(1,num_channels);

% outputs
outRange=log10(opts.output_range(2)/low_freq);
outInterval=outRange/num_channels;
outCenter=zeros(1,num_channels);


% Figure out the center frequencies for all channels
for i=1:num_channels
    inUpper(i) = low_freq * 10^(inInterval*i);
    inLower(i) = low_freq * 10^(inInterval*(i-1));
    inCenter(i) = 0.5 * (inUpper(i)+inLower(i));

    outUpper(i) = low_freq * 10^(outInterval*i);
    outLower(i) = low_freq * 10^(outInterval*(i-1));
    outCenter(i) = 0.5 * (outUpper(i)+outLower(i));
end


% Design the input filters
if opts.verbose==1; fprintf('Designing input filters...'); end
infilterA=zeros(num_channels,opts.infilter_ord+1);
infilterB=zeros(num_channels,opts.infilter_ord+1);

for i=1:num_channels
    W1=[inLower(i)/half_sample_rate, inUpper(i)/half_sample_rate];
    [b,a]=butter(3,W1);
    infilterB(i,1:opts.infilter_ord+1) = b;
    infilterA(i,1:opts.infilter_ord+1) = a;
end
if opts.verbose==1; fprintf('done.\n'); end


% Design the output filters
if opts.verbose==1; fprintf('Designing output filters...'); end
outfilterA=zeros(num_channels,opts.outfilter_ord+1);
outfilterB=zeros(num_channels,opts.outfilter_ord+1);

for i=1:num_channels
    W1 = [outLower(i)/half_sample_rate, outUpper(i)/half_sample_rate];
    [b,a] = butter(3,W1);
    outfilterB(i,1:opts.outfilter_ord+1) = b;
    outfilterA(i,1:opts.outfilter_ord+1) = a;
end
if opts.verbose==1; fprintf('done.\n'); end


% Design low-pass envelope filter
if opts.verbose==1; fprintf('Designing envelope filter...'); end
[lpB,lpA]=butter(2,opts.smoothing_freq/half_sample_rate);
if opts.verbose==1; fprintf('done.\n'); end


% create vectors for the necessary waveforms
% 'x' is the original output waveform
% not using!!!! ?? % 'y' contains a single output waveform,
%	the original after filtering through a bandpass filter
% 'ModCarriers' contains the complete set of num_channel modulated white noises or
%  	sine waves, crreated by low-pass filtering the 'y' waveform,
% 	and multiplying the resultant by an appropriate carrier
% 'band' contains the waveform associated with a single output channel, the modulated white
%	noise or sinusoid after filtering
% 'wave' contains the final output waveform constructing by adding together the ModCarriers,
%	which are first filtered by a filter matched to the input filter
%

envelopes = zeros(num_channels,num_samples);
analysisSounds = zeros(num_channels,num_samples);
ModCarriers = zeros(num_channels,num_samples);
wave = zeros(1,num_samples);
band = zeros(1,num_samples);

% rms levels of the original filter-bank signals
levels = zeros(1, num_channels);


% ----------------------------------------------------------------------%
% First construct the component modulated carriers for all channels  	%
% ----------------------------------------------------------------------%
if opts.verbose==1; fprintf('Designing modulated carriers...\n'); end
for i=1:num_channels
    % filter the original waveform into one channel
    analysisSounds(i,:) = filter(infilterB(i,:),infilterA(i,:),y)';

    % calculate its level
    levels(i) = jp_rms(analysisSounds(i,:));

    % rectify and lowpass filter the channel filter output, to obtain an envelope
    %-- half-wave rectify and smooth the filtered signal
    if strcmp(opts.rectify,'half')
      envelopes(i,:) = filter(lpB,lpA,0.5*(abs(analysisSounds(i,:))+analysisSounds(i,:)));
    elseif strcmp(opts.rectify,'full')
      envelopes(i,:) = filter(lpB,lpA,abs(analysisSounds(i,:)));
    else
      error('opts.rectify must be ''half'' or ''full''.')
    end

    % -- excite with noise ---
    ModCarriers(i,:) = envelopes(i,:) .* sign(rand(1,num_samples)-0.5);
end




% ----------------------------------------------------------------------%
% Now filter the components and add together in the appropriate order,
% scaling for equal rms per channel
% ----------------------------------------------------------------------%

if opts.verbose > 1; fprintf('Filtering components...\n'); end

for i=1:num_channels

    out_band = opts.outputmapping(i);
    band = filter(outfilterB(out_band,:),outfilterA(out_band,:), ModCarriers(i,:));

    % scale component output waveform to have equal rms to input component,
    % as specified by opts.rmsmapping
    %fprintf('Dividing band %i by levels(%i), which is %.2f\n', i, opts.rmsmapping(i), levels(opts.rmsmapping(i)));
    band = band * levels(opts.rmsmapping(i))/jp_rms(band);

    % accumulate waveforms
    wave = wave + band;
end


if opts.high_freq > 0
  if opts.verbose==1; fprintf('Lowpass filtering final sound...\n'); end
  % Design a lowpass filter and use it
  [blpf, alpf] = ellip(6,0.5,35,opts.high_freq/half_sample_rate);
  wave = filtfilt(blpf,alpf,wave);
end


% Now make the whole sound level equal to the input level
wave = wave * input_level/jp_rms(wave);


% correct for possible sample overloads
max_sample = max(abs(wave));
if max_sample > 0.999
    fprintf('Scaling to avoid clipping...\n');
    ratio = 0.999/max_sample;
    wave = wave * ratio;
end


if opts.save_output==1
  if opts.verbose > 0; fprintf('Saving all variables to vocode_vars.mat...\n'); end
  save vocode_vars
end

if opts.verbose > 0
  fprintf('Done.\n');
end

end % main function


function x = jp_rms(y)
%JP_RMS Root mean square.
%
%   X = JP_RMS(Y) where Y is a 1-by-N (or N-by-1) vector returns the root mean
%   square value of Y:
%
%   x = sqrt(sum(y.^2)/length(y));

if min(size(y))>1; error('RMS requires a 1-by-N or N-by-1 vector.'); end
x = sqrt(sum(y.^2)/length(y));
end % rms function
