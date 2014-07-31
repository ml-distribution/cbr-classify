function distance = calSimilarity_L2(case1,case2)
%% distance = calSimilarity_L2(case1, case2)
%   Calculates the similarity(distance) base on L2-norm method

% Initialize vector for each case
vector1 = zeros(1,45);
vector2 = zeros(1,45);

% Set the AUs which 
for i = 1:size(case1{2},2)
    vector1(case1{2}(i)) = 1;
end
for i = 1:size(case2{2},2)
    vector2(case2{2}(i)) = 1;
end
difference= vector1-vector2;
distance =0;
for i=1:45
distance = distance + difference(i)^2;
end