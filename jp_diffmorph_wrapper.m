
clear all
close all

addpath ~/software/jp_matlab

maxDistortion = 100;
nSteps = 25;



%imgDir = '/Users/jpeelle/Box/PeelleLab/research_projects/201909188_LSCfMRI/shared/materials/Experiments/LSC_Visual-Task_v03/1_Images/0_Faces_ToMorph';
%outDir = '/Users/jpeelle/Box/PeelleLab/research_projects/201909188_LSCfMRI/shared/materials/Experiments/LSC_Visual-Task_v03/1_Images/0_FacesMorphed';

imgDir = '/Users/jpeelle/Box/PeelleLab/research_projects/201909188_LSCfMRI/shared/materials/Experiments/LSC_Visual-Task_v03/1_Images/scenes';
outDir = '/Users/jpeelle/Box/PeelleLab/research_projects/201909188_LSCfMRI/shared/materials/Experiments/LSC_Visual-Task_v03/1_Images/scenesmorphed';


assert(isfolder(imgDir), 'Specified imgDir not found.');
    
if ~isfolder(outDir)
    mkdir(outDir);
end


% Get images
D = dir(fullfile(imgDir, '*.png'));

% image size based on first image
file = fullfile(D(1).folder, D(1).name);
img = imread(file);
imgSize = size(img);


nStim = length(D);


parfor indStim = 1:nStim
    file = fullfile(imgDir, D(indStim).name);
    img = imread(file);
    
    warped = jp_diffmorph(img, maxDistortion, nSteps);
    warped = imresize(warped, imgSize(1:2));
    

    % Write stimulus to file
    [pth, nm, ext] = fileparts(D(indStim).name);
    
    file = fullfile(outDir, ['warped_' nm '.png']);
    imwrite(warped, file);            
end