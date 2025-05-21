function jp_LI(imgDir, Cfg)
%JP_LI Produce lateralization indices for several images.
%
% JP_LI(IMGDIR) saves LIs with default options.
%
% JP_LI(IMGDIR, OPTIONS) allows you to set options (form LI toolbox):
%
%   B1      ROI (default gray matter)
%   C1      exclusive mask (default 5 mm)
%   thr1    threshold (default -5: bootstrap)
%
%
% LI toolbox from: https://www.medizin.uni-tuebingen.de/de/das-klinikum/einrichtungen/kliniken/kinderklinik/forschung/forschung-iii/software/formular-li
%
% Assumes SPM8 or later installed (as required by the LI toolbox).
%
%  From https://github.com/jpeelle/jp_matlab


% Check arguments

if nargin < 2
    Cfg = [];
end

if ~isfield(Cfg, 'B1') || isempty(Cfg.B1)
    Cfg.B1 = 8;
end


if ~isfield(Cfg, 'C1') || isempty(Cfg.C1)
    Cfg.C1 = 1;
end

if ~isfield(Cfg, 'thr1') || isempty(Cfg.thr1)
    Cfg.thr1 = -5;
end


if ~isfield(Cfg, 'outfile') || isempty(Cfg.outfile)
    Cfg.outfile = fullfile(imgDir, 'LI.txt');
end


D = dir(fullfile(imgDir, '*.nii'));

imgfiles = {};
  
for i=1:length(D)
    imgfiles{i} = fullfile(imgDir, D(i).name);
end



fid = fopen(Cfg.outfile, 'w');


for fileInd = 1:length(imgfiles)

    fprintf('LI for image %i/%i...', fileInd, length(imgfiles));

    thisImg = imgfiles{fileInd};

    assert(exist(thisImg), sprintf('%s not found.', thisImg));
    [pth, nm, ext] = fileparts(thisImg);

    LIcfg = struct('A', thisImg,...
        'B1', Cfg.B1,...
        'C1', Cfg.C1, ...
        'thr1', Cfg.thr1, ...
        'outfile', fullfile(pth, sprintf('%s.txt', nm)));

    LI(LIcfg);


    fprintf('done.\n')

end

fprintf('All done.\n\n');

fclose(fid);
