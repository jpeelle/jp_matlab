function [sem] = sem(X,dim)
% SEM(X) Standard Error of the Mean for X along dimension
% dim.  See STD for more info.
%
% by Jonathan Peelle

if nargin<2
    dim = min(find(size(X)~=1));
    if isempty(dim), dim = 1; end
end

sem = std(X,0,dim)/length(X)^.5;
