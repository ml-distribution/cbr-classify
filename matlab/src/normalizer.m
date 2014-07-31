%% Function normalizer
%
% @authors: Iosu Mendizabal & Aleksandra Piktus
% @subject: Introduction to Machine Learning
% @studies: Master in Artificial Intelligence
%   
%   Normalize the input matrix in a matrix called normMatrix.

function [normMatrix] = normalizer( matrix )

    minVal = min(min(matrix));
    maxVal = max(max(matrix));

    [rowM, colM] = size(matrix);
    normMatrix = zeros(rowM, colM);
    
    diff = maxVal - minVal;
    
    for i = 1 : rowM
        for j = 1 : colM
            normMatrix(i,j) = (matrix(i, j) - minVal) / diff;
        end
    end
    
end

