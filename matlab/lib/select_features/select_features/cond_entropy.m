function y = cond_entropy(prob, dims)
% COND_ENTROPY - entropy or conditional entropy of a probability table. 
%
% For a multidimensional probability table P, H = ENTROPY(P) computes the
% Shannon entropy.  H = ENTROPY(P,DIM), where DIM is a binary vector of the
% same length as size(P), computes the conditional entropy of those
% variables with indicator 1 in dim, given those with indicator 0.
%
% H(X|Y) = Sum P(X,Y) * log2( P(Y) / P(X,Y)).
%
% Example:
% 
% nsamples=100;
% data=zeros(nsamples,3);
% data(:,1:2) = floor(rand(nsamples,2)/0.5);
% data(:,3)=data(:,1)&data(:,2);
% prob=dimensionalize(data); 
% prob = prob ./sum(prob(:));
% cond_entropy(prob, [0 0 1]);
%
% ans =
%
%    0
%
% See also: MUTUAL_INFO

% Copyright © 3/16/2010 Stefan Schroedl

if (nargin == 1)
     % no conditionals, special case: entropy
     idx=prob(:)>0;
     y= -sum( prob(idx) .* log2( prob(idx) ) );
     return
end

dim_prob = length(size(prob));
if (length(dims) ~= dim_prob)
     error('length of dimension vector incompatible with size of probability table'); 
end

mrg = marginal(prob,~dims);
idx = (prob(:) > 0 & mrg(:) > 0);
y = sum( prob(idx) .* log2( mrg(idx) ./ prob(idx) ));
