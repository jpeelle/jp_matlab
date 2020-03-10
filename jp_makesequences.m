function seq = jp_makesequences(digitList, numSequences, sequenceLength, repeatProbability)
%JP_MAKESEQUENCES Make non-repeating numeric sequences, 1 per row.
%
% NB: Setting repeatProbability to 0 does not mean there is a 0% chance of
% a repeat; it simply turns off the function. I.e., if repeatProbability is
% set to 0, each digit is chosen at random from digitList.

if nargin < 1 || isempty(digitList)
    error('Must specify list of digits (e.g., [2 3 4 5].');
end

if nargin < 2 || isempty(numSequences)
    numSequences = 5;
end

if nargin < 3 || isempty(sequenceLength)
    sequenceLength = 9;
end

if nargin < 4 || isempty(repeatProbability)
    repeatProbability = 0;
end


verbose = 1;

seq = zeros(numSequences, sequenceLength);

if verbose > 0
    fprintf('\nGenerating sequences\n\n');
end

for seqCounter = 1:numSequences
    
    if verbose > 0; fprintf('Sequence %04i/%04i...', seqCounter, numSequences); end        
    
    alreadyExists = 1;
    
    while alreadyExists==1
        
        thisSeq = zeros(1, sequenceLength);
        
        % start with a random digit
        thisSeq(1) = digitList(round((rand * (length(digitList)-1))) + 1);
        
        for digitCounter = 2:sequenceLength
            if repeatProbability > 0
                if rand < repeatProbability
                    thisSeq(digitCounter) = thisSeq(digitCounter-1);
                else
                    thisSeq(digitCounter) = digitList(round((rand * (length(digitList)-1))) + 1);
                end
            else
                thisSeq(digitCounter) = digitList(round((rand * (length(digitList)-1))) + 1);
            end
        end % going through digits in this sequence
        

                
        if ~ismember(thisSeq, seq, 'rows')
            alreadyExists = 0;
        end
        
    end % checking alreadyExists in while loop
    
    seq(seqCounter,:) = thisSeq;
    
    if verbose > 0; fprintf('done.\n'); end

end % going through numSequences