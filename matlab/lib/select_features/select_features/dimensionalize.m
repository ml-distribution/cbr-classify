function [varargout] = dimensionalize(vars, vals, which_stats)

% DIMENSIONALIZE - generate multi-dimensional frequency table from instance
% list.
%
% The most common use of this function is to convert a list of M instances,
% each with a vector of P attributes, into a frequency count table. For the
% call Y = DIMENSIONALIZE(X), X is matrix of size M*P, Y is a
% multidimensional array of P dimensions corresponding to the attributes in
% the columns of X; hence it will hold that
% SIZE(Y,K)=LENGTH(UNIQUE(X(:,K))). X(I1,I2,..Ip) contains the number of
% instances in X where attribute X(:,K) is at level Ik, jointly.
%
% Y = DIMENSIONALIZE(X,V), additionally supplies a vector (length P) of
% values (or weights) to be summed. If V is a M*N matrix, Y has dimension
% P+N-1, extending the results for the additional columns at the right (least
% significant) positions. Thus, Y(..,2) contains the results for V(:,2),
% and so on.
%
% It is possible to apply different functions as in
% DIMENSIONALIZE(VARS,VALS,WHICH_STATS), where WHICH_STATS can be a function
% handle, a string in ('SUM', 'NUMEL', 'MEAN', 'MIN', 'MAX'), or a cell
% array with several of these (in this case, a corresponding number of
% return arguments are expected).
%
% A special case is the specification 'DIRECT', which just copies VALS into
% corresponding cells. Note that in this case, the tie-breaking behavior
% between competing elements depends on Matlab assignment implementation.
%
% The function is similar to GRPSTATS, except that the latter one returns a
% 'flat' representation.
%
% Example:
%
% X=[1 1; 1 2; 1 1; 2 2]; P=DIMENSIONALIZE(X)
%
% P =
%
%     2     1
%     0     1

% Copyright © 3/16/2010 Stefan Schroedl

num_samples=size(vars,1);
num_vars=size(vars,2);

if nargin == 1
    vals=ones(num_samples,1);
elseif size(vals,1) ~= num_samples
    error('vars and vals must have same number of rows');
end

num_vals = size(vals,2);

if nargin<=2
    if ischar(vals) || iscell(vals)
        % omitted second argument, but functions specified
        which_stats = vals;
        vals=ones(num_samples,1);
    else
        which_stats = {};
    end
end

% Get list of statistics functions to call
if isempty(which_stats)
    % Default list
    which_stats = {'sum','numel','mean','max','min','direct'};
    initstats  = {0, 0, nan, -inf, inf, nan};
    which_stats = which_stats(1:max(length(which_stats),nargout));
else
    if ~iscell(which_stats)
        which_stats = {which_stats};
    end
    initstats = {};
    % Convert keywords to function handles
    for j=1:numel(which_stats)
        hfun = which_stats{j};
        init = nan;
        if ischar(hfun)
            switch(hfun)
                % functions have to be instructed to operate along columns,
                % in case of multiple singleton variables
                case 'sum',   hfun = @(x)sum(x,1);  init = 0;
                case 'numel', hfun = @(x)size(x,1); init = 0;
                case 'mean',  hfun = @(x)mean(x,1); init = nan;
                case 'max',   hfun = @(x)max(x,[],1);  init = -inf;
                case 'min',   hfun = @(x)min(x,[],1);  init = inf;
                    %otherwise, may be a function name
            end
            which_stats{j} = hfun;
            initstats{j}  = init;
        end
    end

    if max(1,nargout)~=numel(which_stats)
        warning('stats:grpstats:ArgumentMismatch',...
            'Number of outputs does not match number of statistics.')
    end
end

% compute mapping
sz = ones(1,num_vars);
idx = zeros(num_samples,num_vars);
for i=1:num_vars
    [B,I,J] = unique(vars(:,i));
    sz(i)=length(B);
    idx(:,i)=J;
end

% sub2ind with variable number of dims
k = [1 cumprod(sz(1:end-1))];
ndx = idx * k' - sum(k) + 1;

% append dimension corresponding to input column
total_sz=prod(sz);

ndx_exp = reshape(repmat(0:(num_vals-1),num_samples,1),num_samples*num_vals,1).*total_sz +repmat(ndx,num_vals,1);


% special case: if only 'direct' is required, iteration over unique values
% not required
if nargout==1 && strcmp(which_stats{1},'direct')
    y = initstats{1} * ones([sz num_vals]);

    y(ndx_exp) = vals;
    varargout{1} = y;
else
    [u,ui,uj] = unique(ndx);

    for k=1:nargout
        y = initstats{k} .* ones([sz num_vals]);
        if ischar(which_stats{k}) && strcmp(which_stats{k},'direct')
            y(ndx_exp) = vals;
        else
            for i = 1:length(u)
                y(u(i) + total_sz .* (0:(num_vals-1))) = feval(which_stats{k},vals(uj==i,:));
            end
        end
        varargout{k} = y;
    end
end


