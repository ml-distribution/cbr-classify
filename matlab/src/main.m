%% Main
%
% @authors: Iosu Mendizabal & Aleksandra Piktus
% @subject: Introduction to Machine Learning
% @studies: Master in Artificial Intelligence


%% Library compilation
% In order to compile functions from FSToolbox and MIToolbox
% run ../lib/FEAST/FSToolbox/CompileFEAST.m
% and ../lib/FEAST/MIToolbox/CompileMIToolbox.m;
% in order to compile Linux C shared library - use the included makefiles.


%% Imports
addpath('../lib/FEAST/FSToolbox/');
addpath('../lib/FEAST/MIToolbox/');
addpath('../lib/select_features/select_features/');

%% Code 
clc   % Clear the screen
evaluationResults = zeros(3,12);

rootDirectory = 'primary-tumor';
evaluationResults(1,1) = cbrClassifier(rootDirectory, SimilarityMeasures.eucledean, ReusePolicies.closest, RetentionPolicies.full);
evaluationResults(1,2) = cbrClassifier(rootDirectory, SimilarityMeasures.eucledean, ReusePolicies.closest, RetentionPolicies.onlyCorrect);
evaluationResults(1,3) = cbrClassifier(rootDirectory, SimilarityMeasures.eucledean, ReusePolicies.closest, RetentionPolicies.none);
evaluationResults(1,4) = cbrClassifier(rootDirectory, SimilarityMeasures.eucledean, ReusePolicies.mostPopular, RetentionPolicies.full);
evaluationResults(1,5) = cbrClassifier(rootDirectory, SimilarityMeasures.eucledean, ReusePolicies.mostPopular, RetentionPolicies.onlyCorrect);
evaluationResults(1,6) = cbrClassifier(rootDirectory, SimilarityMeasures.eucledean, ReusePolicies.mostPopular, RetentionPolicies.none);
evaluationResults(1,7) = cbrClassifier(rootDirectory, SimilarityMeasures.cosine, ReusePolicies.closest, RetentionPolicies.full);
evaluationResults(1,8) = cbrClassifier(rootDirectory, SimilarityMeasures.cosine, ReusePolicies.closest, RetentionPolicies.onlyCorrect);
evaluationResults(1,9) = cbrClassifier(rootDirectory, SimilarityMeasures.cosine, ReusePolicies.closest, RetentionPolicies.none);
evaluationResults(1,10) = cbrClassifier(rootDirectory, SimilarityMeasures.cosine, ReusePolicies.mostPopular, RetentionPolicies.full);
evaluationResults(1,11) = cbrClassifier(rootDirectory, SimilarityMeasures.cosine, ReusePolicies.mostPopular, RetentionPolicies.onlyCorrect);
evaluationResults(1,12) = cbrClassifier(rootDirectory, SimilarityMeasures.cosine, ReusePolicies.mostPopular, RetentionPolicies.none);

rootDirectory = 'glass';
evaluationResults(2,1) = cbrClassifier(rootDirectory, SimilarityMeasures.eucledean, ReusePolicies.closest, RetentionPolicies.full);
evaluationResults(2,2) = cbrClassifier(rootDirectory, SimilarityMeasures.eucledean, ReusePolicies.closest, RetentionPolicies.onlyCorrect);
evaluationResults(2,3) = cbrClassifier(rootDirectory, SimilarityMeasures.eucledean, ReusePolicies.closest, RetentionPolicies.none);
evaluationResults(2,4) = cbrClassifier(rootDirectory, SimilarityMeasures.eucledean, ReusePolicies.mostPopular, RetentionPolicies.full);
evaluationResults(2,5) = cbrClassifier(rootDirectory, SimilarityMeasures.eucledean, ReusePolicies.mostPopular, RetentionPolicies.onlyCorrect);
evaluationResults(2,6) = cbrClassifier(rootDirectory, SimilarityMeasures.eucledean, ReusePolicies.mostPopular, RetentionPolicies.none);
evaluationResults(2,7) = cbrClassifier(rootDirectory, SimilarityMeasures.cosine, ReusePolicies.closest, RetentionPolicies.full);
evaluationResults(2,8) = cbrClassifier(rootDirectory, SimilarityMeasures.cosine, ReusePolicies.closest, RetentionPolicies.onlyCorrect);
evaluationResults(2,9) = cbrClassifier(rootDirectory, SimilarityMeasures.cosine, ReusePolicies.closest, RetentionPolicies.none);
evaluationResults(2,10) = cbrClassifier(rootDirectory, SimilarityMeasures.cosine, ReusePolicies.mostPopular, RetentionPolicies.full);
evaluationResults(2,11) = cbrClassifier(rootDirectory, SimilarityMeasures.cosine, ReusePolicies.mostPopular, RetentionPolicies.onlyCorrect);
evaluationResults(2,12) = cbrClassifier(rootDirectory, SimilarityMeasures.cosine, ReusePolicies.mostPopular, RetentionPolicies.none);

rootDirectory = 'iris';
evaluationResults(3,1) = cbrClassifier(rootDirectory, SimilarityMeasures.eucledean, ReusePolicies.closest, RetentionPolicies.full);
evaluationResults(3,2) = cbrClassifier(rootDirectory, SimilarityMeasures.eucledean, ReusePolicies.closest, RetentionPolicies.onlyCorrect);
evaluationResults(3,3) = cbrClassifier(rootDirectory, SimilarityMeasures.eucledean, ReusePolicies.closest, RetentionPolicies.none);
evaluationResults(3,4) = cbrClassifier(rootDirectory, SimilarityMeasures.eucledean, ReusePolicies.mostPopular, RetentionPolicies.full);
evaluationResults(3,5) = cbrClassifier(rootDirectory, SimilarityMeasures.eucledean, ReusePolicies.mostPopular, RetentionPolicies.onlyCorrect);
evaluationResults(3,6) = cbrClassifier(rootDirectory, SimilarityMeasures.eucledean, ReusePolicies.mostPopular, RetentionPolicies.none);
evaluationResults(3,7) = cbrClassifier(rootDirectory, SimilarityMeasures.cosine, ReusePolicies.closest, RetentionPolicies.full);
evaluationResults(3,8) = cbrClassifier(rootDirectory, SimilarityMeasures.cosine, ReusePolicies.closest, RetentionPolicies.onlyCorrect);
evaluationResults(3,9) = cbrClassifier(rootDirectory, SimilarityMeasures.cosine, ReusePolicies.closest, RetentionPolicies.none);
evaluationResults(3,10) = cbrClassifier(rootDirectory, SimilarityMeasures.cosine, ReusePolicies.mostPopular, RetentionPolicies.full);
evaluationResults(3,11) = cbrClassifier(rootDirectory, SimilarityMeasures.cosine, ReusePolicies.mostPopular, RetentionPolicies.onlyCorrect);
evaluationResults(3,12) = cbrClassifier(rootDirectory, SimilarityMeasures.cosine, ReusePolicies.mostPopular, RetentionPolicies.none);

%% Statistical comparison of classifiers

[p,table,stats] = friedman(evaluationResults,1);
c = multcompare(stats, 'ctype', 'bonferroni', 'estimate', 'friedman');


%% Feature selection
weightedEvaluationResults = zeros(3,2);

rootDirectory = 'primary-tumor';
weightedEvaluationResults(1,1) = cbrClassifier(rootDirectory, SimilarityMeasures.mi, ReusePolicies.closest, RetentionPolicies.none);
weightedEvaluationResults(1,2) = cbrClassifier(rootDirectory,  SimilarityMeasures.relieff, ReusePolicies.closest, RetentionPolicies.none);

rootDirectory = 'glass';
weightedEvaluationResults(2,1) = cbrClassifier(rootDirectory, SimilarityMeasures.mi, ReusePolicies.closest, RetentionPolicies.none);
weightedEvaluationResults(2,2) = cbrClassifier(rootDirectory, SimilarityMeasures.relieff, ReusePolicies.closest, RetentionPolicies.none);

rootDirectory = 'iris';
weightedEvaluationResults(3,1) = cbrClassifier(rootDirectory, SimilarityMeasures.mi, ReusePolicies.closest, RetentionPolicies.none);
weightedEvaluationResults(3,2) = cbrClassifier(rootDirectory, SimilarityMeasures.relieff, ReusePolicies.closest, RetentionPolicies.none);

%% End
input('Press ENTER to continue...');
