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
    files = dir(baseDir);
else
    files = dir(fullfile(baseDir, sprintf('*.%s', fileExt)));
end

assert(isdir(baseDir), 'Selected directory does not exist.');

assert(length(files)>0, 'Must select at least one file.');


% If no prefix supplied, add the directory name
if isempty(prefix)
    [pth, nm] = fileparts(baseDir);
    prefix = [nm '_'];
end

for fileInd = 1:length(files)
    % Rename files
    thisFile = files(fileInd).name;
    
    if length(thisFile) > 3
        
        [pth, nm, ext] = fileparts(files(fileInd).name);
        
        originalFile = fullfile(baseDir, [nm ext]);        
        newFile = fullfile(baseDir, [prefix nm ext]);
        
        cmd = sprintf('mv %s %s', originalFile, newFile);  
        [status, ~] = system(cmd);
        
        if status > 0
            warning('mv command failed with %s', cmd);
        end
        
    end
end