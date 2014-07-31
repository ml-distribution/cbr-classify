3 main functions:

--function [ accuracy ] = entry( no,k,l,method )

no(no can be (1~100)): the number of samples to initial CBR, 100-no samples will then be used as test samples.

k(k can be 1,2,3...): how many neighbours we want to select. (if k==1, then become a 1-nn problem);

l(l can only be 1,2,3):
if l==1, then using L1 to calculate distance. L1 L2 are methods we met in lecture, L3 is to compare angle between case vectors.

method:
method can be 'random', 'typicality', 'centroid'. (in single quote).
if 'random', using random selection to choose samples with same distances. the method is used in k-nn domain.
if 'typicality', using typicality to choose samples with same distances. the method is used in k-nn domain.
if 'centroid', then using centroid method to choose nearest sample. the method is used as a hierarchy clustered methodd.  

Return value 'accuracy' is the prediction accuracy of the test samples.




--[CM,recall,precision,falpha]= where_evaluation_happens('cleandata_students.txt',k,l,method)
10 fold cross validation function. each fold initialising CBR with 90 samples and test with rest 10 samples. 
CM is the normalized confusion matrix of 10 folds.
recall is the averaged recall of 10 folds.
precision is the averaged precision of 10 folds.
falpha is the averaged falpha measurement of 10 folds.




--generate_results( k,l,method )
is the function to get results of different k-neighbours and different method.
type the function in matlab, a folder with corresponding name will be generated and the validation results will be saved in the folder. 
 
 
