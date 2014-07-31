function [confusionMatrix,recall,precision] = train_and_test(training_sample,test_sample,class,actual_class,k,l,method)

cbr = CBRinit(training_sample,class);

for i=1:size(test_sample,1)
 newcase = test_sample(i,:);
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



confusionMatrix = zeros(6,6) ;
for index = 1:10
    if (actual_class(index) == result(index))
        confusionMatrix(actual_class(index),result(index))= confusionMatrix(actual_class(index),actual_class(index)) + 1 ;
    else 
   confusionMatrix(actual_class(index),result(index))= confusionMatrix(actual_class(index),result(index)) + 1 ;
    end
end


%% producing recall and precision values
for n = 1:6
    sumvector=sum(confusionMatrix,2);
    recall(1,n)=confusionMatrix(n,n)/sumvector(n);
    sumvector=sum(confusionMatrix,1);
    precision(1,n)=confusionMatrix(n,n)/sumvector(n);
end





