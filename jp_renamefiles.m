function jp_renamefiles(baseDir, prefix, fileExt)
%JP_RENAMEFILES Rename files in a directory

if nargin < 3
    fileExt = '';
end

if nargin <2
    prefix = '';
end

if nargin < 1 || isempty(baseDir)
    baseDir = uigetdir;
end

if isempty(fileExt)
    files = dir(baseDir)
else
    files = dir(fullfile(baseDir, sprintf('*.%s', fileExt)));
end

for fileInd = 1:1  %length(files)
    % Rename files
    thisFile = files(fileInd).name;
    
    if length(thisFile) > 3
        
        [nm, ext] = fileparts(files(fileInd).name);
        
        originalFile = fullfile(baseDir, [nm ext])
        newFile = fullfile(baseDir, [prefix nm ext])
        
    end
end