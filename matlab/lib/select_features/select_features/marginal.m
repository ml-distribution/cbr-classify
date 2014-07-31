function mrg = marginal(prob, dim, do_squeeze)
% MARGINAL - compute marginal probability table.
%
% For a (multidimensional) probability table P and a logical vector DIM of
% the same length as size(P), MRG = MARGINAL(PROB, DIM) gives the marginal
% probability including only those variables whose corresponding flag is
% set to one; zeros represent variables that are summed over. DIM(1)
% corresponds to the first dimension of PROB, DIM(2) to the second, and so
% on. 
%
% By default, MRG has the same dimensionality as PROB. MRG =
% MARGINAL(PROB, DIM, DO_SQUEEZE) allows to shrink the resulting table
% to the dimensions of the surviving marginal variables only (DO_SQUEEZE=1).
%
% Example:
%
% P = [ 0.25 0.1 0.15; 0.05 0.45 0]; M1 = marginal(P,[0 1]), M2=marginal(P,[0 1],1)
%
% M1 =
% 
%     0.3000    0.5500    0.1500
%     0.3000    0.5500    0.1500
% 
% M2 =
% 
%     0.3000    0.5500    0.1500

% Copyright © 3/16/2010 Stefan Schroedl

if (nargin < 2)
    error('at least two arguments required')
end

sz  = size(prob);

if numel(dim) ~= numel(sz)
    error('length of dimension vector incompatible with size of probability table');

end

if (nargin <=2)
    % default: no squeeze
    do_squeeze = 0;
end

mrg = prob;

% check for special cases
if isempty(find(dim<=0, 1))
    % no marginalization needed
    return;
elseif sum(dim) <= 0
    % 'complete' marginalization
    mrg = 1;
    if (~do_squeeze)
        mrg = ones(sz);
    end
    return;
end

% general case
idx=find(dim<=0);
for i=1:length(idx)
    mrg=sum(mrg,idx(i));
end
if (do_squeeze)
    mrg=squeeze(mrg);
else
    % expand to full size of original matrix
    missing_dim = ones(length(sz),1);
    missing_dim(dim<=0)=sz(dim<=0);
    mrg = repmat(mrg,missing_dim);
end
