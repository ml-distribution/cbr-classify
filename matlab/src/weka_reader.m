%% Function cbrClassifier
%
% @authors: Iosu Mendizabal & Aleksandra Piktus
% @subject: Introduction to Machine Learning
% @studies: Master in Artificial Intelligence
%
%   
%   Output:
%       data - data of the file in a matrix.
%       nominalValues - cells with the number of nominal values that has
%       each column.
%       attributeTypes - type of the columns in the arff file. (nominal, numerical...)
%       attributeNames - name of the attribute in the arff file.
%       real_assignment - pertaining class of the row.
%
%   Input:
%       fName - path where the .arff file is. 
%    
% NOTE: The weka .jar should be in the matlab working path!
%   reference http://weka.wikispaces.com/Use+WEKA+in+your+Java+code

function [data, nominalValues, attributeTypes, attributeNames, real_assignment] = weka_reader(fName)
    
    WEKA_HOME = '../lib/weka/';
    javaaddpath([WEKA_HOME 'weka.jar']);
    import weka.core.converters.ArffLoader.*;
    import java.io.File;
    
    %% READ FILE
    loader = weka.core.converters.ArffLoader();
    loader.setFile( java.io.File(fName) );
    D = loader.getDataSet();
    % Set the class index. The las column of attributes
    D.setClassIndex( D.numAttributes() - 1 );
    
    %% GET INFORMATION dataset
    numAttr = D.numAttributes;
    numInst = D.numInstances;
    
    % attribute names
    attributeNames = arrayfun(@(k) char(D.attribute(k).name), 0 : numAttr - 1, 'Uni', false);

    % attribute types
    types = {'numeric' 'nominal' 'string' 'date' 'relational'};
    attributeTypes = arrayfun(@(k) D.attribute(k - 1).type, 1 : numAttr);
    attributeTypes = types(attributeTypes + 1);

    % Create cell with nominal attribute values
    nominalValues = cell(numAttr,1);
    for i = 1 : numAttr - 1
        if strcmpi(attributeTypes{i},'nominal')
            nominalValues{i} = arrayfun(@(k) char(D.attribute(i-1).value(k-1)), 1:D.attribute(i-1).numValues, 'Uni',false);
        end
    end

    %% Create the matrix to save the data and feed it with all the rows except the class one.
    data = zeros(numInst, numAttr - 1);
    for i = 1 : numAttr - 1
        data(:,i) = D.attributeToDoubleArray(i - 1);
    end
    % Pertaining class
    real_assignment = D.attributeToDoubleArray(numAttr - 1);

    %% Data standarization

    % Treating missing data in nominal case (http://bb.shufe.edu.cn/bbcswebdav/institution/%E4%BF%A1%E6%81%AF%E5%AD%A6%E9%99%A2/teacherweb/2000000629/mypapers/A_Review_of_Missing_Data_Treatment_Methods.pdf)
    %   Nominal Data = Replace the missing data with the most frequent data in its class.
    %   Numerical Data = Replace the missing data with the mean of its class. 
 
    nominalValue = 0;
    for i = 1 : numAttr - 1
        if strcmpi(attributeTypes{i},'nominal')
            nominalValue = 1;
            i = numAttr - 1;
        end
    end
    
    if(nominalValue)
        l = max(real_assignment);
        for i = 1 : l + 1
            A = [];
            index_matrix = find(real_assignment == i - 1);
            % Copy the data rows of the i class to the A matrix.
            for j = 1 : length(index_matrix) 
                A(j,:) = data(index_matrix(j),:);
            end
            
            %create a vector for each class, containing the most recurrent value of the class if the attribute
            %(mode) if the attribute type is nominal, the mean value if the
            %attribute is numeric, and then substitute the NaN in the data matrix
            %in this way.
            %If all the attributes of a given class are NaN, use all the data mode
            %for that class

            %Enter if A is not an empty array
            if ~isempty(A)
                % most repeated value in each column of A
                M = mode(A);

                % Check if there is any NaN in the M (mode) vectore
                if any(isnan(M))
                   f = isnan(M);
                   M_ = mode(data); %%if there is a nan change it for the most repeated element of the column.
                   M(f) = M_(f);
                end

                % find if there is any numerical attribute in the data
                num_idx = find(strcmp([attributeTypes], 'numeric'));

                % take the means of the columns of the A matrix
                mean_matrix = mean(A);

                % Use the mean in the numerical attributes.
                M(num_idx) = mean_matrix(num_idx);

                % Get the matrix with 1 in the position of NAN's.
                matrixNaNs = isnan(A);

                % If there is any number of non zero (so we know there are NAN's) in the NAN's matrix do:
                if nnz(matrixNaNs) ~= 0
                    matrixIntermediate = matrixNaNs * diag(M);
                    A(matrixNaNs)= matrixIntermediate(matrixNaNs);
                    % Copy to the dataMatrix the parsed classes datas.
                    for j = 1 : length(index_matrix)
                        data(index_matrix(j),:) = A(j,:);
                    end
                end
            end
        end
    end
    %%in java index starts from 0, we add 1 to the real assignment since vector index in matlab start from 1
    real_assignment = real_assignment + 1; 


end
%  