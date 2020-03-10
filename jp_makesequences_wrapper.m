% Relies on jp_makesequences from http://github.com/jpeelle/jp_matlab


% Make two sets of patterns, "easy" (higher likelihood of repeating numbers)
% and "hard" (each number in the sequence chosen at random.


digitList = [2:5];
numSequences = 500;
sequenceLength = 9;
repeatProbability = .3;


easySequences = jp_makesequences(digitList, numSequences, sequenceLength, repeatProbability);
dlmwrite('~/easySequences.tsv', easySequences, '\t');


repeatProbability = [];

hardSequences = jp_makesequences(digitList, numSequences, sequenceLength, repeatProbability);
dlmwrite('~/hardSequences.tsv', easySequences, '\t');

