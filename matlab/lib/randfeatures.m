function [idx,z] = randfeatures(X,group,varargin) 
%RANDFEATURES generates a randomized subset of features
%
%   [IDX,Z] = RANDFEATURES(X,GROUP) performs a randomized subset feature
%   search reinforced by classification. RANDFEATURES randomly generates
%   subsets of features used to classify the samples. Every subset is
%   evaluated with the apparent error. Only the best subsets are kept, and
%   they are joined into a single final pool. The cardinality for every
%   feature in the pool gives the measurement of the significance. 
%
%   X contains the training samples. Every column of X is an observed
%   vector. GROUP contains the class labels. GROUP can be a numeric vector
%   or a cell array of strings; numel(GROUP) must be the same as the number
%   of columns in X, and numel(unique(GROUP)) must be greater than or equal
%   to 2. Z is the classification significance for every feature. IDX
%   contains the indices after sorting Z; i.e., the first one points to the
%   most significant feature.
%
%   RANDFEATURES(...,'CLASSIFIER',C) sets the classifier. Options are
%      'da'   (default)  Discriminant analysis
%      'knn'             K nearest neighbors
%
%   RANDFEATURES(...,'CLASSOPTIONS',CO) is a cell with extra options for
%   the selected classifier. Defaults are {5,'correlation','consensus'} for
%   KNN and {'linear'} for DA. See KNNCLASSIFY and CLASSIFY for more
%   information.
%
%   RANDFEATURES(...,'PERFORMANCETHRESHOLD',PT) sets the correct
%   classification threshold used to pick the subsets included in the final
%   pool. Default is 0.8 (i.e., 80%). 
%
%   RANDFEATURES(...,'CONFIDENCETHRESHOLD',CT) uses the posterior
%   probability of the discriminant analysis to invalidate classified
%   subvectors with low confidence. This option is only valid when
%   'CLASSIFIER' = 'da'. Using it has the same effect as using 'consensus'
%   in KNN; i.e., it makes the selection of approved subsets very
%   stringent. Default is 0.95.^(number of classes).
%
%   RANDFEATURES(...,'SUBSETSIZE',SS) sets the number of features
%   considered in every subset. Default is 20. 
%
%   RANDFEATURES(...,'POOLSIZE',PS) sets the targeted number of accepted
%   subsets for the final pool. Default is 1000. 
%
%   RANDFEATURES(...,'NUMBEROFINDICES',N) sets the number of output indices
%   in IDX. Default is the same as the number of features.
%
%   RANDFEATURES(...,'CROSSNORM',CN) applies independent normalization
%   across the observations for every feature. Cross-normalization ensures
%   comparability among different features, although it is not always
%   necessary because the selected classifier properties might already
%   account for this. Options are 
%      'none' (default)  Intensities are not cross-normalized.
%      'meanvar'         x_new = (x - mean(x))/std(x)  
%      'softmax'         x_new = (1+exp((mean(x)-x)/std(x)))^-1
%      'minmax'          x_new = (x - min(x))/(max(x)-min(x))
%
%   RANDFEATURES(...,'VERBOSE',false) turns off verbosity. Default is true. 
%
%   Example:
%
%       % Find a reduced set of genes that are sufficient for
%       % classification of all the cancer types in the t-matrix NCI60 data
%       % set: 
%       load NCI60tmatrix
%       % feature selection
%       I = randfeatures(X,GROUP,'SubsetSize',15,'Classifier','da');
%       % test features with a linear discriminant classifier
%       C = classify(X(I(1:25),:)',X(I(1:25),:)',GROUP);
%       cp = classperf(GROUP,C);
%       cp.CorrectRate
%       % Get the accession numbers of the most significant feature
%       ACCNUM3{I(1)},ACCNUM5{I(1)}
%
%   See also CLASSIFY, CLASSPERF, CROSSVALIND, RANKFEATURES, SEQUENTIALFS,
%   SVMCLASSIFY.  
 
%   Copyright 2003-2010 The MathWorks, Inc.

 
% References: 
% [1] Leping Li, David M. Umbach, Paul Terry and Jack A. Taylor (2003)
%     Application of the GA/KNN method to SELDI proteomics data. PNAS.
% [2] Huan Liu, Hiroshi Motoda (1998) Feature Selection for Knowledge
%     Discovery and Data Mining, Kluwer Academic Publishers

% Example reference:
% [3] D. T. Ross, et.al. (March, 2000) Systematic Variation in Gene
%     Expression Patterns in Human Cancer Cell Lines, Published in Nature
%     Genetics, vol. 24, no. 3, pp. 227-235  

bioinfochecknargin(nargin,2,mfilename);

% validate group and X and some consolidation of inputs

[numPoints, numSamples] = size(X);
group = group(:);

if ~isnumeric(X) || ~isreal(X)
   error(message('bioinfo:randfeatures:NotNumericAndReal')) 
end

if numel(group) ~= numSamples
   error(message('bioinfo:randfeatures:NotEqualNumberOfClassLabels'))
end

group = grp2idx(group); % at this point group is numeric only, second 
                        % output of grp2idx is not needed.
todel = find(isnan(group));
if ~isempty(todel)  % remove observations not pre-classified
    X(todel,:) = [];
    group(todel) = [];
    numSamples = numSamples - length(todel);
end

numGroups = max(group);

% set defaults for varargin
classifier = 'da';
knnOptions = {5,'correlation','consensus'};
daOptions = {'linear'};
performanceThreshold = 0.8;
confidenceThreshold = 0.95.^max(group);
subsetSize = 20;  
poolSize = 1000;  
numIndices = numPoints;
cnorm = 'none';
verbose = true;

nvarargin = numel(varargin);
if nvarargin
    if rem(nvarargin,2)
        error(message('bioinfo:randfeatures:IncorrectNumberOfArguments', mfilename));
    end
    okargs = {'classifier','classoptions','performancethreshold',...
              'confidencethreshold','subsetsize','poolsize',...
              'numberofindices','crossnorm','verbose'};
    for j=1:2:nvarargin
        pname = varargin{j};
        pval = varargin{j+1};
        k = find(strncmpi(pname, okargs,length(pname)));
        if isempty(k)
            error(message('bioinfo:randfeatures:UnknownParameterName', pname));
        elseif length(k)>1
            error(message('bioinfo:randfeatures:AmbiguousParameterName', pname));
        else
            switch(k)
                case 1 % classifiers
                    [~,classifier] = bioinfoprivate.optPartialMatch(pval,{'knn','da'}, okargs{k}, mfilename);
                case 2 % classifier options
                    if iscell(pval)
                        knnOptions = pval(:);
                        daOptions = pval(:);
                    else % one single extra argument
                        knnOptions = {pval};
                        daOptions = {pval};
                    end
                case 3 % performance threshold
                    performanceThreshold  = pval(1);
                    if performanceThreshold <0 || performanceThreshold >1
                        error(message('bioinfo:randfeatures:NotValidPerformanceThreshold'))
                    end
                case 4 % confidence threshold
                    confidenceThreshold  = pval(1);
                    if confidenceThreshold <0 || confidenceThreshold >1
                        error(message('bioinfo:randfeatures:NotValidConfidenceThreshold'))
                    end
                case 5 % subset size
                    subsetSize = round(pval(1));
                case 6 % Number of valid groups
                    poolSize = round(pval(1));
                case 7 % Number of indices
                    numIndices = round(pval(1));
                    if ~isnumeric(numIndices) || numIndices<1 || numIndices>numPoints
                        error(message('bioinfo:randfeatures:NotValidN'))
                    end
                case 8 % cross normalization
                    [~,cnorm] =  bioinfoprivate.optPartialMatch(pval,{'none','meanvar','softmax','minmax'}, okargs{k}, mfilename);
                case 9 % verbose
                    verbose = bioinfoprivate.opttf(pval,okargs{k},mfilename);
            end
        end
    end
end

if min(accumarray(group,1))<1 || numGroups<2
    error(message('bioinfo:randfeatures:MissingObservations'))
end
if subsetSize>=size(X,1)
    error(message('bioinfo:randfeatures:MissingFeatures', subsetSize))
end
% perform cross-normalization if required
switch cnorm
    case 'meanvar'
        X=(X-repmat(mean(X,2),1,numSamples))./repmat(std(X,[],2),1,numSamples);
    case 'softmax'
        X=1./(1+exp(-(X-repmat(mean(X,2),1,numSamples))./repmat(std(X,[],2),1,numSamples)));
    case 'minmax'
        X=(X-repmat(min(X,[],2),1,numSamples))./repmat(max(X,[],2)-min(X,[],2),1,numSamples);
    otherwise
        % do nothing
end

% allocate space for the list accepted subsets
discSets = zeros(poolSize,subsetSize);

% set a global flag to check for Nans
featWithNans = isnan(sum(X,2));
checkNans = isequal(classifier,'da') && any(featWithNans);

% set up a counters
numGood = 0;
numTried = 0;
testAcceptanceRate = true;

% The main loop
while (numGood < poolSize)
    % Warn in case acceptance rate is too low
    if testAcceptanceRate && (numTried>poolSize) && (numGood==0)
        warning(message('bioinfo:randfeatures:subsetAcceptance'))
         testAcceptanceRate = false;
    end
    
    numTried = numTried + 1;
    % Extract a random sample of numVal points from the data
    thePerm = randsample(numPoints,subsetSize);

    % check that no NaN's are fed to classify
    if checkNans && any(featWithNans(thePerm))
        continue
    end
    switch classifier
        case 'knn'
            c = knnclassify(X(thePerm,:)',X(thePerm,:)',group,knnOptions{:});
        otherwise % linear or quadratic
            [c,~,pos] = classify(X(thePerm,:)',X(thePerm,:)',group,daOptions{:});
            c(max(pos,[],2)<confidenceThreshold) = 0;
    end
    classPerformance = sum(group==c)/numSamples;
    %disp(sprintf('Tried %d subsets, accepted %d, %f.',numTried,numGood,classPerformance));
    if classPerformance>=performanceThreshold
        numGood = numGood+1;
        discSets(numGood,:) = thePerm;
        if verbose
            fprintf('Tried %d subsets, accepted %d.\n',numTried,numGood);
        end
    end
end
if verbose 
    disp('Finished'); 
end

% Return the best numIndices features
z = accumarray(discSets(:),1,[numPoints,1]);
[~,idx] = sort(z,1,'descend');
idx = idx(1:numIndices);

% Check that features were found at least once, if not trim idx
if z(idx(end))==0
   idx = idx(z(idx)>0);
   warning(message('bioinfo:randfeatures:NotEnoughPoints', numel( idx )))
end

