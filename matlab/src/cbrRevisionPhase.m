%% Function cbrRevisionPhase
%
% @authors: Iosu Mendizabal & Aleksandra Piktus
% @subject: Introduction to Machine Learningcal
% @studies: Master in Artificial Intelligence
%   
%   Calculates the accuracy of classification tasks and stores the results.
%
%   Output
%       correct - number of correct assignments
%
%   Input
%       predictedClasses
%       testClasses

function correct = cbrRevisionPhase(predictedClasses, testClasses)
    
    diff = testClasses - predictedClasses;
    correct = size(testClasses, 1) - nnz(diff);
    
end






