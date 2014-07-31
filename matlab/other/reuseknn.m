
function [solvedcase] = reuseknn(ncase,weight, newcase)
accu=zeros(1,6);
for i= 1: 6
    for n = 1 : size(ncase,2)
        if cell2mat(ncase{n}(3))==i
            accu(i)=accu(i)+weight(n);
        end
    end
end
emotion = find(accu == max(accu));
solvedcase = newcase;
if size(emotion,2)>1
    random = randperm(size(emotion,2));
    solvedcase{3} = emotion(random(1));
else
solvedcase{3} = emotion;
end
end