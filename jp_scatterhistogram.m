function jp_scatterhistogram(X,Y,cfg)
%JP_SCATTERHISTOGRAM Make a color-scaled scatterplot.
%
%
%  From https://github.com/jpeelle/jp_matlab

%% setup

if ~any(size(X)==1) || ~any(size(Y)==1)
  error('X and Y must both be row or column vectors.')
end

if length(X)~=length(Y)
  error('X and Y must be the same length.');
end

if nargin < 3
  cfg = [];
end

if ~isfield(cfg, 'cmap')
  cfg.cmap = 'jet';
end

if ~isfield(cfg, 'numbins')
  cfg.numbins = 50;
end

if ~isfield(cfg, 'xlabel')
  cfg.xlabel = 'X';
end

if ~isfield(cfg, 'ylabel')
  cfg.ylabel = 'Y';
end

if ~isfield(cfg, 'title')
  cfg.title = 'Scatter plot of X vs. Y';
end

if ~isfield(cfg, 'colorbar')
  cfg.colorbar = 1;
end


set(0,...
    'DefaultAxesLineWidth',1, ...
    'DefaultAxesFontSize',12, ...
    'DefaultLineLineWidth',1.5 ...
    )



%% get a couple of things

minX = min(X);
minY = min(Y);

numbins = cfg.numbins;

xstep = (max(X)-min(X))/numbins;
ystep = (max(Y)-min(Y))/numbins;


%% do it

D = zeros(numbins);

for i=1:length(X)
   xind = ceil(((X(i)-minX)/xstep) + eps);
   yind = ceil(((Y(i)-minY)/ystep) + eps);

%     xind = round(((X(i)-minX)/xstep));
%     yind = round(((Y(i)-minY)/ystep));

    if xind==0; xind=1; end
    if yind==0; yind=1; end


    D(yind,xind) = D(yind,xind)+1;

end


%% plot
%figure

%h = imagesc(D);

h = surf(D);
set(gca, 'View', [0 90])
shading flat
colormap(cfg.cmap);
cmap = colormap;
set(gca, 'color', cmap(1,:)); % make sure background is right
xticklabel = minX:xstep:max(X);
yticklabel = minY:ystep:max(Y);

binstep = round(numbins/5);

set(gca, 'XTick', 1:binstep:numbins, 'XTickLabel', xticklabel(1:binstep:numbins), 'YTick', 1:binstep:numbins, 'YTickLabel', yticklabel(1:binstep:numbins));

if cfg.colorbar > 0
  colorbar
end

xlabel(cfg.xlabel);
ylabel(cfg.ylabel);
title(cfg.title);

