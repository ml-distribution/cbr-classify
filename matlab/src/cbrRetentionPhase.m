%% Function cbrRetentionPhase
%
% @authors: Iosu Mendizabal & Aleksandra Piktus
% @subject: Introduction to Machine Learning
% @studies: Master in Artificial Intelligence
%
%   Implements three retention policies (more details in the description of
%   each retention function):
%       policy = 1 - full retention
%       policy = 2 - retains only correctly classified instances
%       policy = other - no retention
%
%   Output
%       trainMatrix - updated train martix
%       trainClasses - updated train classes vector
%
%   Input
%       testInstance - currently analysed test instance
%       predictedClass - instance's class calculated in reuse phase
%       realClass - real instance's class obtained from .arff file
%       trainMatrrix - current train matrix
%       trainClasses - current train classes vector
%       retentionPolicy - indicates which policy to use


function [trainMatrix, trainClasses] = cbrRetentionPhase(testInstance, predictedClass, realClass, trainMatrix, trainClasses, retentionPolicy)
    
    switch retentionPolicy
        case RetentionPolicies.full
            cbrFullRetentionPhase();
        case RetentionPolicies.onlyCorrect
            cbrOnlyCorrectRetentionPhase();
        otherwise
            cbrNoRetentionPhase();
    end


    %% Function cbrFullRetentionPhase
    %
    %   Retains all the instances.

    function cbrFullRetentionPhase()

        trainMatrix = [trainMatrix; testInstance];
        trainClasses = [trainClasses; predictedClass];

    end


    %% Function cbrOnlyCorrectRetentionPhase
    %
    %   Retains only correctly assigned instances.

    function cbrOnlyCorrectRetentionPhase()
    
        if (realClass == predictedClass)
            trainMatrix = [trainMatrix; testInstance];
            trainClasses = [trainClasses; predictedClass];
        end
    
    end


    %% Function cbrNoRetentionPhase
    %
    %   Doesn't retain any test instances.

    function cbrNoRetentionPhase()
    end

end