function [yy,b,a] = jp_fitpow(y,x)
%JP_FITPOW fit a power function
%
% [yy,b,a] = JP_FITPOW(Y,X);
%
% Fits yy = (ax)^k + o(x^k)
%
% By regressing a straight line on logy/logx, giving:
%
%    log(yy) = b*logx + a
%
%
% N.B. assumes all values in y are >= 0.
%
%  From https://github.com/jpeelle/jp_matlab

yflip = 0; % return yy the same as y was fed in

% make sure columns
if size(y,2) > 1
  y = y';
  yflip = 1;
end

if size(x,2) > 1
  x = x';
end



logx = log(x);

y = y + 1; % make sure no 0

logy = log(y);




B = regress(logy, [logx ones(length(y),1)]);

b = B(1);
a = B(2);

yy = b*logx + a;

yy = exp(yy);

yy = yy - 1; % subtract 1 to make up for adding it before

if yflip > 0
  yy = yy';
end


