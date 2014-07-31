function [newcase] = createCase(x, label)
%% createCase(x, label)
%   x is a row vector (an example)
%   label is solution for that example

% AUVec is a row vector contains non-zero AU
AUVec = find(x);
% Initialise Typicality to 1
Typicality = 1;
newcase = {Typicality, AUVec, label};   % If no solution, label=NaN