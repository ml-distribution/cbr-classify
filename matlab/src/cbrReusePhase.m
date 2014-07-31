%% Function cbrRetrievalPhase
%
% @authors: Iosu Mendizabal & Aleksandra Piktus
% @subject: Introduction to Machine Learning
% @studies: Master in Artificial Intelligence
%   
%   Reuses the retrieved similar instances and deduces the class of the
%   current instance with respect to one of the following two policies:
%
%   policy = ReusePolicies.closest - the test instance belongs to the most similar retrieved 
%   case class. 
%   policy = ReusePolicies.mostPopular - the class of the majority of the retrieved cases will
%   be the final one.
%   
%   Output:
%       pertainingClass - the id number of the class to which the test
%       instane is assumed to belong
%
%   Input:
%       similarInstances - matrix of retrieved train instances
%       numSilimard - vector of indices of similarInstances in trainMatrix
%       trainWithClasses - trainMatrix appenede with the column of classes'
%       ids of particular train instances
%       policy - number of policy chosen


function pertainingClass = cbrReusePhase(similarInstances, numSimilars, trainClasses, policy)

    pertainingClass = 0;
    
    if (policy == ReusePolicies.closest)
        pertainingClass = trainClasses(numSimilars(1,:));
        
    elseif (policy == ReusePolicies.mostPopular)
        rowSI = size(similarInstances, 1);
        pertainingClasses = zeros(rowSI, 1);
        
        for i = 1 : rowSI
            pertainingClasses(i) = trainClasses(numSimilars(i,:));
        end
        
        % Get the most repeating class
        pertainingClass =  mode(pertainingClasses);
    end
    
end






