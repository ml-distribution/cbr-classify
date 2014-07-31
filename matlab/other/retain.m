function [cbr] = retain(cbr, solvedcase)
%% [cbr] = retain(cbr, solvedcase)
%   Updates the CBR system cbr by storing the solved case solvedcase

for i=1:size(cbr,2)
    if isequal(cbr{i}{2},solvedcase{2}) && isequal(cbr{i}{3},solvedcase{3})
        %   Increment typicality
        cbr{i}{1} = cbr{i}{1} + 1;
        return
    end
end

% Update solvedcase into CBR system
cbr{size(cbr,2)+1} = solvedcase;