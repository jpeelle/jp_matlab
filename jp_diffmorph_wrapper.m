
clear all
close all

addpath ~/software/jp_matlab

maxDistortion = 100;
nSteps = 25;

imgDir = '/Users/peelle/Box/PeelleLab/research_projects/201909188_LSCfMRI/shared/materials/Experiments/LSC_Visual-Task_v03/1_Images';
outDir = '/Users/peelle/Box/PeelleLab/research_projects/201909188_LSCfMRI/shared/materials/Experiments/LSC_Visual-Task_v03/warped';

if ~isdir(outDir)
    mkdir(outDir);
end


% Get images
D = dir(fullfile(imgDir, '*.jpg'));





% image size based on first image
file = fullfile(D(1).folder, D(1).name)
img = imread(file);
imgSize = size(img);


nStim = length(D);


for indStim = 1:1   %1:nStim
    file = fullfile(imgDir, D(1).name);
    img = imread(file);
    
    warped = jp_diffmorph(img, maxDistortion, nSteps);
    warped = imresize(warped, imgSize(1:2));
    
    % Identify background pixels
  %  bkgrdPix = (warped(:,:,1)==0) .* (warped(:,:,2)==0) .* (warped(:,:,3)==0);
    
    % Random background image
    %randInds = randperm(nStim);
    %file = fullfile(bkgrdDir, ['bkgrd_' stims{randInds(1)} '.jpg']);
    %bkgrdImg = imread(file);

    % Object pixels
   % objInds = bkgrdPix == 0;
    %inds = repmat(objInds, 1, 1, 3);
    %objPix = warped(inds);
    
    % Background pixels
%     PAD_SIZE = (BKGRD_SIZE-imgSize(1:2)) / 2;
%     inds = padarray(objInds, PAD_SIZE, 0);
%     inds = repmat(inds, 1, 1, 3);
%     inds = inds == 1;
%     warped = bkgrdImg;
%     warped(inds) = objPix(:);
    
    % Write stimulus to file
    [pth, nm, ext] = fileparts(D(1).name);
    
    file = fullfile(outDir, ['warped_' nm '.jpg']);
    imwrite(warped, file);
    
    
    
end