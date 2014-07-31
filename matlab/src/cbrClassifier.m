%% Function cbrClassifier
%
% @authors: Iosu Mendizabal & Aleksandra Piktus
% @subject: Introduction to Machine Learning
% @studies: Master in Artificial Intelligence

function [averageAcc, normTestMatrix, normTrainMatrix] = cbrClassifier(rootDirectory, measure, reusePolicy, retentionPolicy)

    correct = zeros(10,1);
    testCount = 0;
    disp(['Processing dataset ',rootDirectory,' ...']);

    for i = 0 : 9
        
        disp(['fold ', int2str(i+1),' ...']);
        %% Preprocessing
        
        % Read and parse data
        pathTest = ['../ten_fold/', rootDirectory, '/', rootDirectory, '.fold.00000', int2str(i), '.test.arff'];
        pathTrain = ['../ten_fold/', rootDirectory, '/', rootDirectory, '.fold.00000', int2str(i), '.train.arff'];   
        
        [TestMatrix, TestNominalValues, TestAttributeTypes, TestAttributeNames, TestClasses] = weka_reader(pathTest);
        [TrainMatrix, TrainNominalValues, TrainAttributeTypes, TrainAttributeNames, TrainClasses] = weka_reader(pathTrain);
        
        % Normalize the data matrix
        normTestMatrix = normalizer(TestMatrix);
        normTrainMatrix = normalizer(TrainMatrix);
    
        rowTest = size(normTestMatrix,1);
        testCount = testCount + rowTest;
    
        %% Classification
        
        correct(i+1) = cbrAlgorithm(normTestMatrix, TestClasses, normTrainMatrix, TrainClasses, measure, reusePolicy, retentionPolicy);
        
    end

    %% Evaluation
    averageAcc = sum(correct) / testCount;
    averageAcc 
    disp('classified');

end