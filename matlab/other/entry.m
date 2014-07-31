function [ accuracy ] = entry( no,k,l,method )
[x y]=loaddata('cleandata_students.txt');
x_train=x(1:no,:);
x_test=x(no+1:100,:);
y_test=y(no+1:100,:);
y_train=y(1:no,:);
cbr = CBRinit(x_train,y_train);
for i=1:100-no
    newcase = x_test(i,:);
    newcase = createCase(newcase, []);
    if strcmp(method,'centroid')
        solvedcase = centroid(cbr,newcase);
    else
    [ncase,weight] = retriveknn(cbr,newcase,k,l,method);
    solvedcase = reuseknn(ncase,weight, newcase);
    end
    result(i) = solvedcase{3};
    cbr = retain(cbr, solvedcase);
end
difference = y_test- result';
accuracy = (100-no-size(find(difference),1))/(100-no);

end

