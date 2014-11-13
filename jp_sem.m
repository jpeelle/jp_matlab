function sem = jp_sem(X,dim)
% SEM(X,DIM) Standard Error of the Mean for X along dimension
% dim.  See STD for more info.
%
%  From https://github.com/jpeelle/jp_matlab

if nargin<2
    dim = min(find(size(X)~=1));
    if isempty(dim), dim = 1; end
end

sem = std(X,0,dim)/length(X)^.5;
