% Relies on jp_makesequences from http://github.com/jpeelle/jp_matlab


% Make two sets of patterns, "easy" (higher likelihood of repeating numbers)
% and "hard" (each number in the sequence chosen at random.


baseDir = '/Users/peelle/Box/PeelleLab/research_projects/201909188_LSCfMRI/shared/materials/Experiments/LSC_Motor-Task_v01';

digitList = [2:5];
numSequences = 242;
sequenceLength = 9;
repeatProbability = .4;


easySequences = jp_makesequences(digitList, numSequences, sequenceLength, repeatProbability);
dlmwrite(fullfile(baseDir, 'easySequences.csv'), easySequences, 'delimiter', '');


repeatProbability = 0;

hardSequences = jp_makesequences(digitList, numSequences, sequenceLength, repeatProbability);
dlmwrite(fullfile(baseDir, 'hardSequences.csv'), hardSequences, 'delimiter', '');

