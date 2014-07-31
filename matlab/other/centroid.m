function [Case] = centroid(cbr, newcase)


if size(cbr,2) == 0
    error('retrieve:argChk','The input cbr is empty');
end
accu=zeros(1,6);

    for n= 1:6
        vector = zeros(1,45);
        for i=1: size(cbr,2)
            if cell2mat(cbr{i}(3))== n
                position = cell2mat(cbr{i}(2));
                for ii = 1:size(position,2)
                    vector(position(ii)) = vector(position(ii))+1;
                
               end
                accu(n)=accu(n)+1;
            end
        end
        vectors{n}= vector/accu(n);
    end
    for i = 1:6
        distanceArray(i) = calSimilarity_L1(vectors{i},newcase);    % Use L1-norm
    end

index = find(distanceArray == min(distanceArray));
if (size(index,2)~=1)
    Case = {newcase{1},newcase{2},index(1)};
else
     Case = {newcase{1},newcase{2},index};
end

end
function distance = calSimilarity_L1(vector, case2)
    vector2 = zeros(1,45);

for i = 1:size(case2{2},2)
    vector2(case2{2}(i)) = 1;
end

distance = sum(abs(vector - vector2),2); 



end


