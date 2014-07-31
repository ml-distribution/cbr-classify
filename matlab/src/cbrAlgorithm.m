%% Function cbrAlgorithm
%
% @authors: Iosu Mendizabal & Aleksandra Piktus
% @subject: Introduction to Machine Learning
% @studies: Master in Artificial Intelligence


function correct = cbrAlgorithm(testMatrix, testClasses, trainMatrix, trainClasses, measure, reusePolicy, retentionPolicy)
    
    K = 5;
    rowTest = size(testMatrix, 1);
    predictedClasses = zeros(rowTest,1);
    
    for j = 1 : rowTest
        testInstance = testMatrix(j,:);

        %% Retrieval
        [similarInstances, numSimilars] = cbrRetrievalPhase(testInstance, trainMatrix, trainClasses, K, measure);

        %% Reuse
        predictedClasses(j) = cbrReusePhase(similarInstances, numSimilars, trainClasses, reusePolicy);
        
        %% Retention
        [trainMatrix, trainClasses] = cbrRetentionPhase(testInstance, predictedClasses(j), testClasses(j), trainMatrix, trainClasses, retentionPolicy);
        
    end
    
    %% Revision
    correct = cbrRevisionPhase(predictedClasses, testClasses);
    
end
