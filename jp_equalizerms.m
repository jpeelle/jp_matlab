function jp_equalizerms(inputDir,outputDir,verbose)
%JP_EQUALIZERMS Equalize RMSs for a directory containing sound files.
%
%   JP_EQUALIZERMS(INPUTDIR,OUTPUTDIR) takes all of the sound files in the
%   input directory, gets the mean RMS, and then saves copies in the output
%   directory that have been adjusted to the equal RMS.  If the output
%   directory doesn't exist, it is created.  If the adjusted RMS is not
%   within 1% of the goal RMS a warning message is displayed to the screen,
%   but the copy is written anyway.
%
%   JP_EQUALIZERMS(INPUTDIR,OUTPUTDIR,'verbose') outputs some information
%   as the files are adjusted so you can monitor the process.  May be
%   helpful if you encounter errors or to keep track of progress for really
%   large groups of files.
%
%   See also JP_EQUALIZEMAX.



% Error checking
if nargin<2; error('Two arguments are required.'); end
if nargin==2; verbose=0; end
if nargin==3
    if ischar(verbose) && strcmp(lower(verbose),'verbose')
        verbose=1;
    else
        error('Third argument not recognized.  If you want verbose output, the third argument should be ''verbose''.')
    end
end

if verbose; fprintf('\n'); end

if ~ischar(inputDir) || ~ischar(outputDir)
    error('The input directory and output directory must be strings.')
elseif ~isdir(inputDir)
    error('Input directory %s not found.',inputDir);
elseif ~isdir(outputDir)
    % If the output directory doesn't exist, try making it
    if verbose; fprintf('Output directory not found, creating it...'); end
    [success,message,messageid] = mkdir(outputDir);
    if success==0; error(messageid,message); end
    if verbose; fprintf('done.\n'); end % done creating the output directory
end


% Get information from the input directory
if verbose; fprintf('Getting information from the input directory...'); end
D = dir(inputDir);
if verbose; fprintf('done.\n'); end

% Go through D the first time to get the mean RMS
rmsTotal=0;
rmsCount=0;

if verbose; fprintf('Looping through files the first time to get RMSs...'); end
for i=1:length(D)
    fileName = D(i).name;
    % If it is a WAV file, get the RMS
    if length(fileName)>4 && strcmp(lower(fileName(end-3:end)),'.wav')
        [y,fs,bits] = wavread(fullfile(inputDir,fileName));
        rmsTotal = rmsTotal + rms(y);
        rmsCount = rmsCount+1;
    end
end % going through D the first time

% Get the mean
rmsMean = rmsTotal/rmsCount;
if verbose; fprintf('done.\n'); end



% Since we have the mean RMS, go through again and equalize the files
if verbose; fprintf('Looping through to adjust mean RMSs...\n'); end
fileNumber = 0;
for i=1:length(D)
    fileName = D(i).name;
    if length(fileName)>4 && strcmp(lower(fileName(end-3:end)),'.wav')
        % Keep track of how many 'real' files
        fileNumber = fileNumber + 1;

        [y,fs,bits] = wavread(fullfile(inputDir,fileName));
        thisRms = rms(y);

        y2 = y * (rmsMean/thisRms);

        
        % Scale if over 1 or under -1
        if max(y2) > 1 || min(y2) < -1
            fprintf('File %s: MIN = %.3f, MAX = %.3f, scaling so as not to clip.\n', fileName, min(y2), max(y2));
            biggest = max([abs(min(y2)) max(y2)]);
            y2 = (y2/biggest) * .99;
        end
        
  
        % Make sure we were within error range
        if rms(y2)-rmsMean > .01*rmsMean
            fprintf('Warning for %s: Equalized RMS is %.3f, goal RMS is %.3f...\n',fileName,rms(y2),rmsMean);
        end
        
        
        % Write the new .wav file
        wavwrite(y2,fs,bits,fullfile(outputDir,fileName));

        % Note how far along we are
        if verbose && rmsCount>20 && mod(fileNumber,round(rmsCount/10))==0
            fprintf('\t%i%% done...\n',round(100*(fileNumber/rmsCount)));
        end

    end
end
if verbose; fprintf('done.\nEqualization completed.\n'); end

end % main function


function x = rms(y)
%RMS Root mean square.
%
%   X = RMS(Y) where Y is a 1-by-N (or N-by-1) vector returns the root mean
%   square value of Y.

if min(size(y))>1; error('RMS requires a 1-by-N or N-by-1 vector.'); end
x = sqrt(sum(y.^2)/length(y));
end % rms function