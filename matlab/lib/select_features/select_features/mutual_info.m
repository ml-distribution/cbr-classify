function mi = mutual_info(prob,varargin)
% MUTUAL_INFO - mutual or conditional mutual information of a probability table.
%
% For a (multidimensional) probability table P and logical vectors DIM1 and
% DIM2 of the same length as size(P), MI = MUTUAL_INFO(PROB,DIM1,DIM2)
% computes the conditional mututal information between the variables with
% indicator 1 in DIM1 and those with indicator 1 in DIM2, given all others.
% DIM2 can be omitted, in which case the unconditional mutual information
% between variables with DIM1=1 and those with DIM1=0 is computed.
%
%  MI = MUTUAL_INFO(PROB,DIM1,DIM2,'prior',W) smoothes each cell of the
%  table with a probability weight of W (number of pseudo-samples) drawn
%  from the product of marginal distributions (independence assumption).
%  This is useful especially for sparse, multi-value, and high-dimensional
%  tables to avoid overfitting.
%
% The computation is based on the following formula:
% I(X,Y|Z) = Sum P(X,Y,Z) * log2( P(Z) * P(X,Y,Z) / (P(X,Z) * P(Y,Z)) ).
%
% Example:
% 
% nsamples=100;
% data=zeros(nsamples,3);
% data(:,1:2) = floor(rand(nsamples,2)/0.5);
% data(:,3)=data(:,1)&data(:,2);
% prob=dimensionalize(data); 
% prob = prob ./sum(prob(:));
% mutual_info(prob, [1 1 0], [0 0 1]);
%
% ans =
%
%    0.8113
%
% See also: COND_ENTROPY

% Copyright © 3/16/2010 Stefan Schroedl

num_dims = numel(size(prob));

optargin = size(varargin,2);
stdargin = nargin - optargin;

dim1 = 0;
dim2 = 0;
prior_wt = 0;

if (stdargin < 1)
    error('no probability table specified');
end



% parse optional arguments
i=1;
while (i <= optargin)
    if (i==1 && ~ischar(varargin{i}))
        dim1 = varargin{i};
        i = i + 1;
    elseif (i==2 && ~ischar(varargin{i}))
        dim2 = varargin{i};
        i = i + 1;
    elseif (ischar(varargin{i}) && strcmp(varargin{i},'prior'))
        if (i < optargin)
            prior_wt = varargin{i+1};
            i = i + 2;
        else
            error('missing specification of: %s', varargin{i});
        end
    else
        error('unknown option: %s', varargin{i});
    end
end


% special cases
if (sum(dim1) == 0 && sum(dim2) == 0)
    if(num_dims == 2)
        % unconditional, two variables 
        dim1 = [1 0];
        dim2 = [0 1];
    else
        error('at least 2 arguments required');
    end
elseif (sum(dim1) ~= 0 && sum(dim2) == 0)
    % unconditional, two variables
    dim2 = ~dim1;
end

if ( numel(dim1) ~= num_dims ||  numel(dim2) ~= num_dims )
    error('dimension vector incompatible with size of probability table');
end

mrg_z  = marginal(prob, ~max(dim1, dim2)); % P(Z)

if (prior_wt <= 0)
    prob_smooth = prob;
else
    % smooth with marginals
    idx=1:num_dims;
    prior = ones(size(prob));
    for i=1:num_dims
        prior = prior .* marginal(prob,(idx==i));
    end
    total_prior_wt = numel(prob) * prior_wt; % prior_wt in each cell 
    prob_smooth = (total_prior_wt * prior + prob) ./ (1 + total_prior_wt);
end

mrg_xz = marginal(prob_smooth, ~dim2);            % P(X,Z)
mrg_yz = marginal(prob_smooth, ~dim1);            % P(Y,Z)



idx    = (prob_smooth(:) > 0 & mrg_xz(:) > 0 & mrg_yz(:) > 0);
mi     = sum( prob_smooth(idx) .* log2( (prob_smooth(idx) .* mrg_z(idx))./ (mrg_xz(idx) .* mrg_yz(idx) )));
