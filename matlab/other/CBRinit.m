function [cbr] = CBRinit(x, y)
%% [cbr] = CBRinit(x,y)
%   x is n*45 example matrix
%   y is n*1 label

numOfExample = size(y,1);
index = 2;
tempcase = createCase(x(1,:), y(1));
cbr{1} = tempcase;

for i = 2:numOfExample
       bool =0;
        tempcase = createCase(x(i,:), y(i));
        
        for j = 1:index-1
            if isequal(cbr{j}{2},tempcase{2}) && isequal(cbr{j}{3},tempcase{3})
                % Increment typicality
                cbr{j}{1} = cbr{j}{1} + 1;
                bool =1;
                % Skip this case
                break
            end
        end
        
        if bool==0
            cbr{index} = tempcase;
            index = index + 1;
        end
          
end
            