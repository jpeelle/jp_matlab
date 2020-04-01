function jp_strrepfiles(baseDir, fileExt, strToFind, strReplacement)
%JP_STRREPFILES Rename files in a directory

if nargin < 4
    strReplacement = {};
end

if nargin < 3
    strToFind = {};
end

if nargin < 2
    fileExt = '';
end

if nargin < 1 || isempty(baseDir)
    baseDir = uigetdir;
end

if isempty(fileExt)
    files = dir(baseDir);
else
    files = dir(fullfile(baseDir, sprintf('*.%s', fileExt)));
end

if ischar(strToFind)
    strToFind = {strToFind};
end

if ischar(strReplacement)
    strReplacement = {strReplacement};
end

assert(isdir(baseDir), 'Selected directory does not exist.');

assert(length(files)>0, 'Must select at least one file.');

assert(length(strToFind)==length(strReplacement), 'Strings to find, and strings to replace, must be the same length.');



for fileInd = 1:length(files)
    % Rename files
    thisFile = files(fileInd).name;
    
    if length(thisFile) > 3
        
        [pth, nm, ext] = fileparts(files(fileInd).name);
        
        originalFile = fullfile(baseDir, [nm ext]);    
        
        newnm = nm;
        
        for numRep = 1:length(strToFind)
            newnm = replace(newnm, strToFind{numRep}, strReplacement{numRep});
        end
        
        newFile = fullfile(baseDir, [newnm ext]);
        
        % escape spaces
        originalFile = replace(originalFile, ' ', '\ ');
        
        cmd = sprintf('mv %s %s', originalFile, newFile);
        [status, ~] = system(cmd);
        
        if status > 0
            warning('mv command failed with %s', cmd);
        end
        
    end
end