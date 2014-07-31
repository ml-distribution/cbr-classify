function y = interaction_info(prob, varargin)
% INTERACTION_INFO - compute interaction information.
%
%  II = INTERACTION_INFO(P) computes the interaction information
% for a probability table PROB. Interaction information is a generalization
% of mutual information for more than two variables. The following
% recursive definition is used:
%
% I({X1,..,Xn})=I({X2,..,Xn}|X1) - I(X2,..,Xn)
% I({X1,X2}|Z)= I(X1;X2|Z) (mutual information base case)
%
% II = INTERACTION_INFO(P,N), for an integer N, returns the conditional
% interaction info of the variables corresponding to dimensions (N+1):end,
% given those in dimensions 1:N.
%
% II = INTERACTION_INFO(P,N,'prior',W) smoothes each cell of the table with
% a probability weight of W (number of pseudo-samples) drawn from the
% product of marginal distributions (independence assumption). This is
% useful especially for sparse, multi-value, and high-dimensional tables to
% avoid overfitting.
%
% Note that the run time is exponential in the number of variables.
%
% References:
% For more background on interaction information, see e.g.
% * http://en.wikipedia.org/wiki/Interaction_information.
%
% The standard reference for interaction information is
% * McGill W J (1954): Multivariate information transmission,
%   Psychometrika  19, 97-116.
%
%
% Example:
%
% nsamples=100;
% data=zeros(nsamples,3);
% data(:,1:2) = floor(rand(nsamples,2)/0.5);
% data(:,3)=data(:,1)&data(:,2);
% prob=dimensionalize(data); 
% prob = prob ./sum(prob(:));
% interaction_info(prob);
%
% ans =
%
%    0.2082
%
% See also: DEMO_FEATURE_SELECT, MUTUAL_INFO

% Copyright © 3/16/2010 Stefan Schroedl

optargin = size(varargin,2);
stdargin = nargin - optargin;

ncond = 0;
prior_wt = 0;

if (stdargin < 1)
    error('no probability table specified');
end

% parse optional arguments
i=1;
while (i <= optargin)
    if (i==1 && ~ischar(varargin{i}))
        ncond = varargin{i};
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


sz = numel(size(prob));
if nargin == 1
    ncond = 0;
end

if (sz-ncond<2)
    error('not enough dimensions');
end

if (sz-ncond==2)
    % two variables left -> ordinary mutual info
    z0 = (1:sz);
    y = mutual_info(prob, z0==(ncond+1), z0==(ncond+2),'prior',prior_wt);
    return;
end

% recursion:
% I({X1,..,Xn})=I({X2,..,Xn}|X1) - I(X2,..,Xn)

t1 = interaction_info(prob, ncond+1, 'prior', prior_wt);

mask = ones(sz, 1);

mask(ncond+1)=0;

prob2=marginal(prob, mask, 1);

t2 = interaction_info(prob2, ncond, 'prior', prior_wt);

y= (t1 - t2);
