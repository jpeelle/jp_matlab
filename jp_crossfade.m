function [y, fs] = jp_crossfade(y1, y2, fs, rampSec)
%JP_CROSSFADE Very basic crossfade for two sounds.
%
% JP_CROSSFADE(Y1, Y2, FS) fades sound Y1 to sound Y2 using a linear ramp.
%
% JP_CROSSFADE(Y1, Y2, FS, RAMPSEC) uses a specified ramp duration (default
% is 0.1 seconds).
%
% From https://github.com/jpeelle/jp_matlab

if nargin < 4 || isempty(rampSec)
    rampSec = 0.1;
end

rampSamples = rampSec*fs;
fadeIn = [1:rampSamples]'/rampSamples;
fadeOut = flipud(fadeIn);

y1(end-rampSamples+1:end) = y1(end-rampSamples+1:end) .* fadeOut;
y2(1:rampSamples) = y2(1:rampSamples) .* fadeIn;

y = zeros(length(y1)+length(y2)-rampSamples, 1);
y(1:length(y1)) = y1;
y(length(y1)+1-rampSamples:end) = y(length(y1)+1-rampSamples:end) + y2;