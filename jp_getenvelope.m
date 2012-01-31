function env = jp_getenvelope(s, fs, opts)
%JP_GETENVELOPE Return the envelope of a sound.
%
% JP_GETENVELOPE(S, [FS], [OPTS]) returns the envelope of signal S using
% sampling frequency FS.  S can be a .wav file in which case FS can
% be left empty or ommitted.  If S is not a .wav file FS must be
% specified.
%
%   opts has the following fields
%    rectify    'full' or 'half' (default 'half')
%    freq       smoothing frequency for envelope in Hz (default 30)
%    edge_freqs edge frequencies for channels (see below)
%
% If opts.edge_freq is specified, the function returns one envelope
% for each of M channels, where M = length(edge_freq) - 1.  The
% default is opts.edge_freq = [], in which case the envelope for
% the unfiltered signal is returned.
%
% JP_GETENVELOPE requires the signal processing toolbox.
%  
% Jonathan Peelle


if nargin < 3
  opts = struct();
end

if ischar(s)
  [path,name,ext] = fileparts(s);
  if strcmp(lower(ext),'.wav')
    [s, fs, bits] = wavread(s);
  else
    error('If a file, S must be a .wav file.')
  end
else
  % If not a .wav file, make sure fs is specified
  if nargin < 2 || isempty(fs)
    error('If S is not a .wav file, you must specify Fs.')
  end  
end

half_sample_rate = fs/2;


% set defaults -------------------------------------------
if ~isfield(opts, 'rectify') || isempty(opts.rectify)
  opts.rectify = 'half';
end

if ~isfield(opts, 'freq') || isempty(opts.freq)
  opts.freq = 30;
end

if isfield(opts, 'edge_freqs')
  if length(opts.edge_freqs) < 2
    error('If specifying edge frequencies, must specify at least 2.');
  end
else
  opts.edge_freqs = [];
end

if ~(strcmp(opts.rectify,'full') || strcmp(opts.rectify, 'half'))
  error('opts.rectify must be ''full'' or ''half''');
end

% Create the low-pass filter
[lpB,lpA]=butter(2,opts.freq/half_sample_rate);

if isempty(opts.edge_freqs)
  if strcmp(opts.rectify,'half')
    env = filter(lpB,lpA,0.5*(abs(s)+s));
  elseif strcmp(opts.rectify,'full')
    env = filter(lpB,lpA,abs(s));
  end
else
  
  % create a matrix for holding the envelopes, one per row
  env = zeros(length(opts.edge_freqs)-1, length(s));
  
  for i=1:length(opts.edge_freqs)-1
    W1 = [opts.edge_freqs(i)/half_sample_rate, opts.edge_freqs(i+1)/half_sample_rate];
    [infilterB, infilterA] = butter(3,W1);

    % filter the sound
    yy = filter(infilterB, infilterA, s)';

    % and get the envelope of the filtered sound
    if strcmp(opts.rectify,'half')
      env(i,:) = filter(lpB,lpA,0.5*(abs(yy)+yy));
    elseif strcmp(opts.rectify,'full')
      env(i,:) = filter(lpB,lpA,abs(yy));
    end
    
  end
  
end
