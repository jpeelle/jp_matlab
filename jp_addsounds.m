function y3 = jp_addsounds(y1, y2, fs, cfg)
% Add sounds
%
% y1 target
% y2 distractor
%
% cfg.offsetSecs: + values mean distractor after target, - values before
% cfg.trimDistractorSecs = Inf; % If < Inf, run for this many seconds after target finishes
%
%  From https://github.com/jpeelle/jp_matlab

if nargin < 4
    cfg = [];
end


if ~isfield(cfg, 'offsetSecs') || isempty(cfg.offsetSecs)
    cfg.offsetSecs = 0;
end

if ~isfield(cfg, 'trimDistractorSecs')
    cfg.trimDistractorSecs = Inf;
end

if ~isfield(cfg, 'distractorFadeSecs')
    cfg.distractorFadeSecs = 0;
end


offsetSecs = cfg.offsetSecs;
trimDistractorSecs = cfg.trimDistractorSecs;
distractorFadeSecs = cfg.distractorFadeSecs;

% If the distractor is shorter than the target, issue a warning
if length(y2) < length(y1)
    fprintf('\nWARNING: Distractor is shorter than target.\n');
end


% If there is an offset, add some zeros
if offsetSecs < 0
    y1 = [zeros(abs(offsetSecs)*fs,1); y1];
elseif offsetSecs > 0
    y2 = [zeros(abs(offsetSecs)*fs,1); y2];
end


% If the distractor goes on longer than the target, see if we should trim
% it. And if so, do it.
if length(y2) > length(y1) && trimDistractorSecs < Inf
   extra = trimDistractorSecs * fs;

   % If there isn't enough distractor this won't work anyway
   try
       y2 = y2(1:(length(y1)+extra));
   catch
   end

   if distractorFadeSecs > 0
       error('fade out not implemented yet');

   end

end


% make sure sounds are the same length, and then add them
if length(y1)~=length(y2)
    if length(y2) > length(y1)
        lengthDiff = length(y2) - length(y1);
        y1 = [y1; zeros(lengthDiff,1)];
    else
        lengthDiff = length(y1) - length(y2);
        y2 = [y2; zeros(lengthDiff,1)];
    end
end

y3 = y1 + y2;