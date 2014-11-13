function sem = jp_semwithin(D)
%JP_SEMWITHIN Within-subject standard error of the mean.
%
% SEM = JP_SEMWITHIN(D) returns the standard error of the mean (SEM) with
% between-subject variance removed, suitable for making comparisons across
% condition in repeated-measures designs.  See:
%
% Loftus GR, Masson ME (1994) Using confidence intervals in within-subject
% designs. Psychonomic Bulletin & Review, 1, 476-490.
%
% D is a matrix of numbers with each row of containing data for one
% subject, and each column data for one condition.
%
%
%  From https://github.com/jpeelle/jp_matlab

% First find the overall mean across conditions, across subjects
overallmean = mean(mean(D,2));

% Find out how far each subject's mean (across conditions) is from the
% overall mean (i.e. between subject variance).
meandiff = mean(D,2) - overallmean;

% For each subject, subtract this difference from their data; now, for each
% subject, the means across conditions should be equal.
D2 = D - repmat(meandiff,1,size(D,2));

% Calculate the SEM on this adjusted data.
sem = std(D2,0,1)/(size(D2,1)^.5);