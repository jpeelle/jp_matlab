function [l, c, u] = jp_getfrequencies(low, high, n, opts)
%JP_GETFREQUENCIES Given a range, return spaced frequencies.
%
% [L,C,U] = JP_GETFREQUENCIES(LOW, HIGH, N, [OPTS]) returns lower,
% center, and upper frequencies for each of N channels.  The
% optional opts has the following fields:
%
%  method  'log' or 'greenwood' (default 'log')
% 
%
% If the method is Greenwood, the equation from Greenwood (1961) is
% used to approximate equal spacing along the basilar membrane.
% This is similar to logrithmic but not identical.
%
% Jonathan Peelle



if nargin < 4
  opts = struct();
end

if ~isfield(opts, 'method') || isempty(opts.method)
  opts.method = 'log';
else
  if ~(strcmp(opts.method,'log') || strcmp(opts.method,'greenwood'))
    error('The method must be ''log'' or ''greenwood''.');
  end
end 
  

l = zeros(n); % lower frequencies
c = zeros(n); % center frequencies
u = zeros(n); % upper frequencies



if strcmp(opts.method,'log')
  range = log10(high/low);
  interval = range/n;

  edges = [0:1:n];
  c = [0:1:n]+.5;
  
  for i=1:length(edges)
    edges(i) = low * 10^(interval*edges(i));
    if i<length(edges)
      c(i) = low * 10^(interval*c(i));
    end
  end
  l = edges(1:n);  
  u = edges(2:n+1);
  
elseif strcmp(opts.method,'greenwood')
  edges = [0:1:n]*(freq2mm(high)-freq2mm(low))/n + freq2mm(low);
  l = edges(1:n);
  u = edges(2:n+1);
  c = edges(1:n) + edges(2:n+1)/2;
 
  % change back to frequencies
  l = mm2freq(l);
  u = mm2freq(u);
  c = mm2freq(c);
  
else
  error('Unsupported method for conversion.');
end

% round to nearest hz
l = round(l);
u = round(u);
c = round(c);




end % of main function


function mm = freq2mm(freq)
% Greenwood's function for converting frequency to mm on the
% basilar membrane
% (from Stuart Rosen)
a = .06;
k = 165.4;
mm = (1/a) * log10(freq/k + 1);
end

function freq = mm2freq(mm)
% Converting the other way using Greenwood's equation
% (ditto)
a = .06;
k = 165.4;
freq = k * (10.^(a * mm) - 1);
end
