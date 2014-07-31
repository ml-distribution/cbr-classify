%% Function cbrRetrievalPhase
%
% @authors: Iosu Mendizabal & Aleksandra Piktus
% @subject: Introduction to Machine Learning
% @studies: Master in Artificial Intelligence
%
%   Retrieves train instacnes most similat to the current test instance.
%   
%   Output:
%       similarInstances - matrix of train instances most similar to
%       current instance
%       numSimilars - column vector of indexes of most similar train
%       instanecs
%
%   Input:
%       testInstance - current row from the testMatrix
%       trainMatrix - matrix of train instances
%       K - number of retrieved instances (K nearest neighbors)
%       measure - indicates similarity measure used (1 - eucleadean, 2 - cosine)


function [similarInstances, numSimilars] = cbrRetrievalPhase(testInstance, trainMatrix, trainClasses, K, measure)

    [colTrain] = size(trainMatrix,2);
    similarInstances = zeros(K, colTrain); 
    numSimilars = zeros(K,1);
    
    switch measure
        case SimilarityMeasures.eucledean
            eucledeanCbrRetrivalPhase();
        case SimilarityMeasures.cosine
            dist = cosineCbrRetrievalPhase();
        case SimilarityMeasures.mi
            miWeightedCbrRetrievalPhase();
        otherwise
            relieffWeightedCbrRetrievalPhase();
    end

    
    %% Function eucledeanCbrRetrivalPhase
    %
    %   finds the most similar train instances based on the Eucledean
    %   distance
    
    function eucledeanCbrRetrivalPhase()
    
        for k = 1 : K            
            [rowTrain] = size(trainMatrix,1);
            dist = zeros(rowTrain, 1);            
            for j = 1 : rowTrain
                dist(j) = norm(trainMatrix(j,:) - testInstance);
            end            
            proceedWithEucledean(dist,k);            
        end
    end


    %% Function cosineCbrRetrievalPhase
    %
    %   finds most similar train instances based on the cosine similarity
    
    function dist = cosineCbrRetrievalPhase()
        
        for k = 1 : K            
            [rowTrain] = size(trainMatrix,1);
            dist = zeros(rowTrain, 1);
            
            for j = 1 : rowTrain
                dist(j) = dot(trainMatrix(j,:), testInstance) / (norm(trainMatrix(j,:)) * norm(testInstance));
            end        
            proceedWithCosine(dist, k);
        end
    end


    %% Function miWeightedCbrRetrievalPhase
    %
    %   finds most similar train instances based on the mutual information
    %   measue
    %   ( http://www.cs.man.ac.uk/~gbrown/fstoolbox/ )
    
    function miWeightedCbrRetrievalPhase()
        
        [IDX Z] = MIM(size(trainMatrix,2),trainMatrix,trainClasses);
        for k = 1 : K            
            [rowTrain] = size(trainMatrix,1);
            dist = zeros(rowTrain, 1);            
            for j = 1 : rowTrain
                dist(j) =  dot(times(Z', (trainMatrix(j,:))), testInstance) / (norm(times(Z', (trainMatrix(j,:)))) * norm(times(Z', (testInstance))));
               % sqrt(sum(times(Z', (trainMatrix(j,:) - testInstance)).^2));
            end         
            
            %dist(isnan(dist)) = 0;
            proceedWithCosine(dist, k);
           % proceedWithEucledean(dist,k);
        end
    end


    %% Function relieffWeightedCbrRetrievalPhase
    %
    %   finds most similar train instances based on the weighted
    %   similarity measue, based on the using the ReliefF algorithm
    %   ( http://www.mathworks.es/es/help/stats/relieff.html )
    
    function relieffWeightedCbrRetrievalPhase()
        
        [IDX,Z] = relieff(trainMatrix, trainClasses, K);
        
        for k = 1 : K            
            [rowTrain] = size(trainMatrix,1);
            dist = zeros(rowTrain, 1);            
            for j = 1 : rowTrain
                dist(j) =  dot(times(Z, (trainMatrix(j,:))), testInstance) / (norm(times(Z, (trainMatrix(j,:)))) * norm(times(Z, (testInstance))));
                %dist(j) = sqrt(sum(times(Z, (trainMatrix(j,:) - testInstance)).^2));
            end
            %proceedWithEucledean(dist,k);    
            proceedWithCosine(dist, k);
        end
        
    end


    %% Function proceedWithEucledean
    %
    %   helper function for euclidean distance calculations
    %
    %   Input
    %       dist - vector of distances between the current instance and
    %       training instances
    %       k - we're retrievint k'th instance
    
    function proceedWithEucledean(dist, k)
        
        dist(isnan(dist)) = 0;
        minDist = min(dist);     
        minDistNot = ~(dist-minDist);
        minimum_centroid = find(minDistNot);
        min_index = minimum_centroid(end);
        
        similarInstances(k,:) = trainMatrix(min_index,:);
        numSimilars(k) = min_index;
        trainMatrix(min_index, : ) = [];
        
    end


    %% Function proceedWithCosine
    %
    %   helper function for euclidean distance calculations
    %
    %   Input
    %       dist - vector of distances between the current instance and
    %       training instances
    %       k - we're retrievint k'th instance
    
    function proceedWithCosine(dist, k)
        
        dist(isnan(dist)) = 0;
        maxDist = max(dist);
        maxDistNot = ~(dist-maxDist);        
        maximum_centroid = find(maxDistNot);
        max_index = maximum_centroid(end);
        
        similarInstances(k,:) = trainMatrix(max_index,:);
        numSimilars(k) = max_index;
        trainMatrix(max_index, : ) = [];           
        
    end
end
