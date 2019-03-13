function cmap = jp_cmap2(hotColor, coolColor, midColor, nSteps)
%JP_CMAP2 Colormap generator for two colors ("hotcmap" and "cold").
%
% CMAP = JP_CMAP2 provides default red/blue colormap.
%
% CMAP = JP_CMAP2(hotcmap, coolcmap) lets you specify the RGB values for the max
% hotcmap and coolcmap values. If any number in a color is > 1, the values are
% divided by 255. (This allows you to specify in standard RGB values 0-255,
% or Matlab values 0-1.)
%
% CMAP = JP_CMAP2(hotcmap, coolcmap, MID) uses the specified color for the middle
% color (i.e., a 0 value). Default is white.
%
% CMAP = JP_CMAP2(hotcmap, coolcmap, MIDCOLOR, NSTEPS) uses the specified number of steps to
% go from MIDCOLOR to hotcmap or coolcmap (default 100)/


if nargin < 4 || isempty(nSteps)
    nSteps = 100;
end

if nargin < 3 || isempty(midColor)
    midColor = [1 1 1];
end

if nargin < 2 || isempty(coolColor)
    coolColor = [51 153 255]/255;
end

if nargin < 1 || isempty(hotColor)
    hotColor = [205 102 102]/255;
end

if max(coolColor) > 1
    coolColor = coolColor/255;
end

if max(hotColor) > 1
    hotColor = hotColor/255;
end

hotcmap = zeros(nSteps,3);
coolcmap = zeros(nSteps,3);

hotcmapStep = (hotColor - midColor)/nSteps;
coolcmapStep = (coolColor - midColor)/nSteps;

hotcmap(1,:) = hotColor;
coolcmap(1,:) = coolColor;


for q = 2:nSteps
    hotcmap(q,:) = hotcmap(q-1,:) - hotcmapStep;
    coolcmap(q,:) = coolcmap(q-1,:) - coolcmapStep;
end
    
cmap = flipud([hotcmap; midColor; flipud(coolcmap)]);
