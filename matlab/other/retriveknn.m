
function [kcase,weight] = retriveknn(cbr, newcase,k,l,method)
if size(cbr,2) == 0
    error('retrieve:argChk','The input cbr is empty');
end

if l==1
    for i = 1:size(cbr,2)
        distanceArray(i) = calSimilarity_L1(cbr{i},newcase); 
    end


elseif l==2
    for i = 1:size(cbr,2)
        distanceArray(i) = calSimilarity_L2(cbr{i},newcase); 
    end
    
elseif l==3
    for i = 1:size(cbr,2)
        distanceArray(i) = calSimilarity_L3(cbr{i},newcase); 
    end
end








if strcmp(method , 'random')
Array = distanceArray;
temp = sort(Array); %%size(temp,2)=k 
cbrCopy= cbr;
for i = 1:k
    if size(cbr,2)<i
        error('retrieve:argChk','The input cbr is empty************');
    end
index = find(distanceArray == temp(i));
number = size(index,2);
random = randperm(number);
position= index(random(1));
kcase{i}=cbrCopy{position};
endPoint = size(distanceArray,2);
distanceArray=[distanceArray(1:position-1), distanceArray(position+1:endPoint)];
cbrCopy=[cbrCopy(1:position-1),cbrCopy(position+1:endPoint)];
weight(i)=1/temp(i).^5;
end





elseif strcmp(method ,'typicality')

Array = distanceArray;
temp = sort(Array); %%size(temp,2)=k 
cbrCopy= cbr;
for i = 1:k
    if size(cbr,2)<i
        error('retrieve:argChk','The input cbr is empty************');
    end
    
 indecesWithMin = find(distanceArray == temp(i));

casecluster = cbrCopy(indecesWithMin);   

typi_max= 0;

for n=1:size(indecesWithMin,2)
    if typi_max < cell2mat(casecluster{n}(1))
        typi_max = cell2mat(casecluster{n}(1));
        pos=n;
    end
end
kcase{i} = casecluster{pos};    
position = indecesWithMin(pos);
endPoint = size(distanceArray,2);
distanceArray=[distanceArray(1:position-1), distanceArray(position+1:endPoint)];
cbrCopy=[cbrCopy(1:position-1),cbrCopy(position+1:endPoint)];
weight(i)=1/temp(i).^5;
end


end




