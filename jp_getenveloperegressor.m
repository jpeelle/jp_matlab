function reg = jp_getenveloperegressor(s, fs, TRsec, opts)
%JP_GETENVELOPEREGRESSOR Returns a resampled envelope of a sound.
%
% JP_GETENVELOPEREGRESSOR(S, TR, [FS], [OPTS]) returns a regressor of
% envelope values resampled from the sampling rate of the sound (FS) to the
% sampling rate of a model (TR). Intended to provide a scan-by-scan
% regressor of the envelope for use in an fMRI analysis but could be used
% for other purposes.
% 
% S can be a .wav file in which case FS can
% be left empty or ommitted.  If S is not a .wav file FS must be
% specified.
%
% TR is the sampling rate of the output, in seconds.
%
%   opts has the following fields
%    hrf            0 or 1 to convolve with HRF (default 1)
%    plotTimeSec    [startTime endTime] for plotting(default [])
%    
%
%   including some passed directly to JP_GETENVELOPE:
%    rectify    'full' or 'half' (default 'half')
%    freq       smoothing frequency for envelope in Hz (default 30)
%    edge_freqs edge frequencies for channels (see below)
%
% If opts.edge_freq is specified, the function returns one envelope
% for each of M channels, where M = length(edge_freq) - 1.  The
% default is opts.edge_freq = [], in which case the envelope for
% the unfiltered signal is returned.
%
% JP_GETENVELOPEREGRESSOR requires the signal processing toolbox, and SPM
% if HRF convolution is needed.
%
%
%  From https://github.com/jpeelle/jp_matlab

if nargin < 4
  opts = struct();
end

% set defaults -------------------------------------------

if ~isfield(opts, 'hrf') || isempty(opts.hrf)
  opts.hrf = 1;
end

if ~isfield(opts, 'plotTimeSec') || isempty(opts.plotTimeSec)
  opts.plotTimeSec = [];
end


    
% make sure the sound is mono
if min(size(s))>1
    error('Sound file needs to be mono (size nx1 or 1xn)');
end

env = jp_getenvelope(s, fs);


% scale envelope to match height of the sound
env = (env/max(env)) * max(s);
                

t = (1:length(s))/fs; % time in seconds
plotTimeSamples = round(opts.plotTimeSec * fs);
plotTimeSamples(plotTimeSamples==0) = 1; % make sure no index of 0 




%% Downsample the envelope to match the TR

%reg = resample(env, TRsec, fs);

% The ratio should be TRsec/fs. But needs to be an integer. If TRsec isn't
% an integer, then multiply by 1000? why wouldn't that work?

% if mod(TRsec,1) ~= 0
%     reg = resample(env, TRsec*1000, fs*1000);
% else
%     reg = resample(env, TRsec, fs);
% end


reg = resample(env, TRsec, fs);

tTR = (1:length(reg)) * TRsec;
plotTimeTR = opts.plotTimeSec * TRsec;




%% Plot

if ~isempty(opts.plotTimeSec)
    plot(t(plotTimeSamples(1):plotTimeSamples(2)), s(plotTimeSamples(1):plotTimeSamples(2)), 'k-', 'LineWidth', 0.5, 'Color', [.7 .7 .7])
    hold on
    plot(t(plotTimeSamples(1):plotTimeSamples(2)), env(plotTimeSamples(1):plotTimeSamples(2)), 'k-', 'LineWidth', 1)  

    plot(tTR(plotTimeTR(1):plotTimeTR(2)), reg(plotTimeTR(1):plotTimeTR(2)), 'ro', 'linewidth', 2)
end % plotting envelope

xlabel('Time (seconds)')
ylabel('Amplitude (a.u.)')
legend('Sound file', 'Envelope', 'TR-sampled Envelope')