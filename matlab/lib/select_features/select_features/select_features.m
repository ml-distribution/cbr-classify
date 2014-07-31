function [varargout] = select_features(features, target, max_iter, varargin)
% SELECT_FEATURES - feature selection filter for machine learning, based on
% interaction information.
%
% SELECT_FEATURES(FEATURES, TARGET, MAX_ITER) attempts to select the
% jointly most informative features with regard to the target, according to
% the 'first-order-utility' method. FEATURES is an M*P matrix representing
% M observations of P discrete attributes each; TARGET is a P-vector
% containing the corresponding values to be predicted. In each iteration,
% the procedure greedily chooses the feature with largest incremental gain;
% it stops after at most MAX_ITER steps.
%
% The algorithm is based on the following approximation of the mutual
% information between a target Z and joint observations X1 .. Xn:
%
% I(X1,..,Xn;Z)~ sum_{i=1..n} I(Xi,Z)
%   - Sum_{S \subset {X1,..,Xn}, |S| = degree} ( alpha * I({S}) + beta *
%   I({S}|Z) )
%
% Herein, I({..}) denoted the interaction information, a generalization of
% mutual information to the case of more than two variables. The components
% in the formula above are respectively called relevance, redundancy, and
% (class-) conditional redundancy. Note that interactions of order more
% than DEGREE are discarded.
%
% Several options of the form Y=SELECT_FEATURES(...,'OPTION_NAME', OPTION_VALUE)
% can be used to modify the default behavior.
%   - 'METHOD':    A variety of feature selection criteria summarized in the
%                  reference can be instantiated.
%        * 'MIM':  pure mutual information with target, no variable
%                  interaction (Naive Bayes) * 'FOU':  first-order utility
%                  (Brown, 2009). This is the default, and identical to
%                  'MIFSU' (Kwak & Choi, 2002) and 'CIFE' (Lin & Tang,
%                  2006). Options 'RED_WEIGHT' and 'COND_RED_WEIGHT' can be
%                  specified.
%        * 'MRMR': maximum-relevance minimum-redundancy (Peng et al, 2005).
%        * 'MIFS': Mutual Information-Based Feature Selection
%                  (Battiti, 1994). Option 'RED_WEIGHT' can be specified.
%        * 'JMI':  Joint Mutual Information (Yang & Moody, 1999).
%        * 'CMIM': Conditional Mutual Information Maximization (Fleuret,
%                  2004). This is equivalent to 'IF' (Informative
%                  Fragments, Vidal-Naquet & Ullman, 2003).
%
% In addition to these methods, some generalizations are possible with
% advanced options.
%   - 'STOP_LOSS':       Stop if predicted gain is negative.
%   - 'DEGREE':          Include higher-order interaction terms (all named
%                        methods use at most DEGREE=2).
%   - 'RED_WEIGHT':      Weighting factor for redundancy terms
%                        ('alpha' in above formula).
%   - 'COND_RED_WEIGHT': Weighting factor for conditional redundancy terms
%                        ('beta' in above formula).
%   - 'INIT':            Indices of variables to be included from the
%                        outset.
%   - 'DIRECTION':       One of 'f' (forward), 'b' (backward), or 'fb'.
%                        Backward steps eliminate an existing variable,
%                        instead of adding a new one. All named methods are
%                        forward only.
%   - 'PRIOR':           Allows for smoothing of spare data. For example,
%                        PRIOR=1 means that for each combination of joint
%                        attributes values, one pseudo-sample is drawn from
%                        the product of individual marginal distributions
%                        (assumption of variable independence).
%   - 'PESSIMISTIC':     Select variable with best
%                        [relevance - max_(S}(redundancy(S) - cond_redundancy(S))],
%                        instead of the sum.
%   - 'AVERAGE':         Set alpha = RED_WEIGHT/N, where N is the number
%                        of currently selected features. Same for beta.
%
% Output arguments: Between 1 and 5 output arguments can be specified, as in
% [STEPS, SELECTED, RELEVANCE, REDUNDANCY, COND_REDUNDANCY] = SELECT_FEATURES(...).
%
% Notice that due to interaction, scores for selected variables generally
% change during the course of the algorithm. STEPS represents the snapshot
% at the time a variable is selected (or dropped), while all other
% arguments refer to the final state at termination.
%
%   - STEPS           is a (2(DEGREE+1)) * MAX_ITER matrix. STEPS(1,I) is
%                     the index of the feature selected in iteration I. The
%                     index is negative if the variable was dropped.
%                     STEPS(2,:) signifies the score; STEPS(3,:) the
%                     relevance; STEPS(4:(4+DEGREE),:) the redundancy term
%                     by degree; and the remaining rows the corresponding
%                     conditional redundancies.
%   - SELECTED        is a P-vector which is 1 for selected variables at
%                     termination, or 0 otherwise.
%   - RELEVANCE       is the P-vector containing the mutual information
%                     with TARGET.
%   - REDUNDANCY      is the redundancy by degree, i.e., a matrix of size
%                     DEGREE * P.
%   - COND_REDUNDANCY is the conditional redundancy by degree,
%                     i.e., a DEGREE * P  matrix.
%
% References: Gavin Brown, A New Perspective for Information Theoretic
% Feature Selection, In: Artificial Intelligence and Statistics, April
% 16-18 2009, Tampa, Florida.
%
% see also: DEMO_FEATURE_SELECT, INTERACTION_INFO
%

% Copyright © 3/16/2010 Stefan Schroedl

optargin = size(varargin, 2);
stdargin = nargin - optargin;

if (stdargin < 2)
    error('at least two argument required');
end

num_samples = size(features, 1);
num_vars    = size(features, 2);

if stdargin < 3
    max_iter = num_vars;
end

max_iter = min(max_iter, num_vars);

% defaults for optional arguments
degree        = 2;
dir_fwd       = 1;
dir_bwd       = 0;
prior_wt      = 0;
sel_init      = [];
red_wt        = 1;
cond_red_wt   = 1;
method        = '';
verbose       = 1;
use_pessim    = 0;
use_stop_loss = 0;
use_avg       = 0;

% parse optional arguments
i = 1;
while (i <= optargin)
    if (strcmp(varargin{i}, 'degree') && i < optargin)
        degree = varargin{i+1};
        i = i + 2;
    elseif (strcmp(varargin{i}, 'verbose'))
        verbose = varargin{i+1};
        i = i + 2;
    elseif (strcmp(varargin{i}, 'pessimistic'))
        use_pessim = varargin{i+1};
        i = i + 2;
    elseif (strcmp(varargin{i}, 'stop_loss'))
        use_stop_loss = varargin{i+1};
        i = i + 2;
    elseif (strcmp(varargin{i}, 'init') && i < optargin)
        sel_init = varargin{i+1};
        i = i + 2;
    elseif (strcmp(varargin{i}, 'prior') && i < optargin)
        prior_wt = varargin{i+1} / num_samples; % convert from number of samples to probability
        i = i + 2;
    elseif (strcmp(varargin{i}, 'red_weight') && i < optargin)
        red_wt = varargin{i+1};
        i = i + 2;
    elseif (strcmp(varargin{i}, 'cond_red_weight') && i < optargin)
        cond_red_wt = varargin{i+1};
        i = i + 2;
    elseif (strcmp(varargin{i}, 'method') && i < optargin)
        % parse later
        method = varargin{i+1};
        i = i + 2;
    elseif (strcmp(varargin{i}, 'average') && i < optargin)
        use_avg = varargin{i+1};
        i = i + 2;
    elseif (strcmp(varargin{i}, 'direction') && i < optargin)
        dir_str = varargin{i+1};
        if (strcmp(dir_str, 'fb') || strcmp(dir_str, 'bf'))
            dir_fwd = 1;
            dir_bwd = 1;
        elseif (strcmp(dir_str, 'f'))
            dir_fwd = 1;
            dir_bwd = 0;
        elseif (strcmp(dir_str, 'b'))
            dir_fwd = 0;
            dir_bwd = 1;
        else
            error('unknown direction argument: %s', dir_str);
        end
        i = i + 2;
    elseif (ischar(varargin{i}))
        error('unrecognized attribute: %s', varargin{i});
    else
        error('usage: select_features(features, target, max_iter, ''option1'', option1, ...)');
    end
end

if (~isempty(sel_init) && ((max(sel_init) > num_vars) || (min(sel_init) < 1)))
    disp('error: init index out of bound, ignoring');
    sel_init = sel_init(sel_init>=1 & sel_init <= num_vars);
end

% set special case options for specified method
if (~isempty(method))
    degree = 2;
    if (strcmp(method, 'mim'))
        degree = 1;
        red_wt = 0;
        cond_red_wt = 0;
    elseif (strcmp(method, 'mifs'))
        cond_red_wt = 0;
    elseif (strcmp(method, 'mrmr'))
        cond_red_wt = 0;
        use_avg = 1;
    elseif (strcmp(method, 'jmi'))
        use_avg = 1;
    elseif (strcmp(method, 'fou') || strcmp(method, 'mifsu') || strcmp(method, 'cife') )
        % default
        method = 'fou'; % identical
    elseif (strcmp(method, 'cmim') || strcmp(method, 'if'))
        method = 'cmim'; %identical
        use_pessim = 1;
    else
        error('unknown method: %s', method);
    end
end

degree = min(degree, num_vars);

if (verbose)
    fprintf('using settings: degree %d, pessimistic %d, dir_fwd %d, dir_bwd %d, prior %f, red_wt %f, cond_red_wt %f\n', degree, use_pessim, dir_fwd, dir_bwd, prior_wt, red_wt, cond_red_wt);
    tic;
end

rel      = zeros(1,      num_vars);  % relevance
red      = zeros(degree, num_vars);  % redundancy
cond_red = zeros(degree, num_vars);  % conditional redundancy

if (use_pessim)
    red      =  -inf * ones(degree, num_vars);
    cond_red =   inf * ones(degree, num_vars);
end

% compute mutual information between each feature and target

for i = (1:num_vars)
    p = dimensionalize([features(:, i) target]); % convert to freq table
    p = p ./ sum(p(:)); % normalize
    rel(i) = mutual_info(p,'prior',prior_wt);
end

steps  = zeros(3+2*degree, 0); % score + rel + red + cond_red
flag_sel = zeros(num_vars, 1); % 1 for currently selected variables

% initialization with specified variables

red_wt_it      = red_wt;
cond_red_wt_it = cond_red_wt;

if (~isempty(sel_init))
    
    % replay all selections
    for j=1:length(sel_init)
        jj = sel_init(j);
        
        % scaling with number of features ( at this point, only matters for use_pessim=1
        red_wt_it      = red_wt;
        cond_red_wt_it = cond_red_wt;
        n = length(find(flag_sel));
        if (use_avg && n > 1)
            red_wt_it      = red_wt / n;
            cond_red_wt_it = cond_red_wt / n;
        end
        
        for i=1:num_vars
            if (i ~= jj)
                for d=2:degree
                    update_degree(i, jj, 1, flag_sel, d);
                end
            end
        end
        flag_sel(jj) = 1;
    end
    if (verbose)
        fprintf('done initial selection\n');
    end
end


% main loop
iter = 1;
while (iter <= max_iter)
    
    idx_sel  = find(flag_sel);
    idx_cand = find(~flag_sel);
    
    % scaling with number of features?
    red_wt_it      = red_wt;
    cond_red_wt_it = cond_red_wt;
    n = length(idx_sel);
    if (use_avg && n>1)
        red_wt_it       = red_wt / n;
        cond_red_wt_it  = cond_red_wt / n;
    end
    
    diff_red = - red_wt_it * red + cond_red_wt_it * cond_red;
    
    % try forward step
    if (dir_fwd && ~isempty(idx_cand))
        if (~use_pessim)
            [score_best, best] = max(sum([rel(:, idx_cand); diff_red(:,idx_cand)], 1));
        else
            min_diff = min(diff_red(:,idx_cand));
            min_diff(~isfinite(min_diff)) = 0; % for first iteration with use_pessim=1
            [score_best, best] = max(sum([rel(:, idx_cand); min_diff], 1));
        end
    else
        score_best = -inf;
        best       = -1;
    end
    
    % try backward step
    if (dir_bwd && ~isempty(idx_sel))
        if (~use_pessim)
            [score_worst, worst] = min(sum([rel(:, idx_sel); diff_red(:, idx_sel)], 1));
        else
            min_diff = min(diff_red(:,idx_sel));
            min_diff(~isfinite(min_diff)) = 0; % for first iteration with use_pessim=1
            [score_worst, worst]  = min(sum([rel(:, idx_sel); min_diff], 1));
        end
    else
        score_worst = inf;
        worst       = -1;
    end
    
    
    if (score_best == -inf && score_worst == inf)
        % no step possible
        break;
        
    elseif (use_stop_loss && score_worst > 0 && score_best < 0)
        if (verbose)
            fprintf('no further improvement at step %d %f %f\n', iter, score_best, score_worst);
        end
        break;
        
    elseif (score_best >= -score_worst)
        % forward step is better
        sel = idx_cand(best);
        score_sel = score_best;
        sgn = 1;
        
    else
        % backward step is better
        sel = idx_sel(worst);
        score_sel = -score_worst;
        sgn = -1;
        
    end
    
    if (verbose)
     
        red_total      = red_wt_it   * sum(red(:,sel));
        cond_red_total = cond_red_wt * sum(cond_red(:,sel));
        
        if (use_pessim)
            [m,i]=min(diff_red(:,sel));
            red_total      = red_wt_it * red(i,sel);
            cond_red_total = cond_red_wt_it * cond_red(i,sel);
        end
        if (sgn > 0)
            fprintf('%d. select %d, score %f (relevance %f, redundancy %f, conditional redundancy %f, red weight %f, cond red weight %f)\n', iter, sel, score_best, rel(sel), red_total, cond_red_total, red_wt_it, cond_red_wt_it);
        else
            
            fprintf('%d. drop %d, score %f (relevance %f, redundancy %f, conditional redundancy %f, red weight %f, cond red weight %f)\n', iter, sel, -score_worst, rel(sel), red_total, cond_red_total, red_wt_it, cond_red_wt_it);
        end
        
    end
    
    % update red/cond_red
    
    for i = 1:num_vars
        % for all variables
        if (i == sel)
            continue;
        end
        
        for d = 2:degree
            % for all degrees
            
            needs_full = update_degree(i, sel, sgn, flag_sel, d);
            
            if (needs_full)
                
                % for backward direction with pessim=1, we might need
                % to recompute redundancy from scratch if the maximum
                % redundancy was attained using a variable combination
                % containing the dropped one.
                
                flag_sel2 = flag_sel;
                if (sgn > 0)
                    flag_sel2(sel) = 1;
                else
                    flag_sel2(sel) = 0;
                end
                
                idx_sel2    = find(flag_sel2);
                flag_sel_it = zeros(num_vars, 1);
                
                % replay all selections
                for j=1:length(idx_sel2)
                    jj = idx_sel2(j);
                    if (jj ~= i)
                        update_degree(i, jj, 1, flag_sel_it, d);
                    end
                    flag_sel_it(jj) = 1;
                end
            end
        end
    end
    
    flag_sel(sel)     = 1;
    if (sgn < 0)
        % variable dropped
        flag_sel(sel) = 0;
    end
    
    % log results for output arguments
    steps = [steps [sgn*sel; score_sel; rel(i); red(:, sel); cond_red(:, sel)]];
    iter = iter + 1;
end

% fill output arguments
varargout{1} = steps;

if nargout >= 2
    varargout{2} = flag_sel;
end

if nargout >= 3
    varargout{3} = rel;
end
if nargout >= 4
    varargout{4} = red;
end
if nargout >= 5
    varargout{5} = cond_red;
end

if (verbose)
    toc;
end;


%----------------------------------------

    function use_full = update_degree(var_update, var_sel, var_sgn, var_flag_sel, deg)
        % update (cond_)red(deg,var_update) when var_sel has been newly
        % selected, var_flag_sel have been previously selected
        use_full = 0;
        if (var_update == var_sel)
            % shouldn't happen!
            error('duplicate variables!');
        end
        if (d == 2)
            use_full = update_comb(var_update, var_sel, var_sgn, [], deg);
        else
            % enumerate all combinations of (deg-2) selected variables
            % (var_update and var_sel are fixed)
            others = find(var_flag_sel & ~ofn([var_update var_sel], num_vars));
            
            if (length(others) >= deg - 2)
                others = nchoosek(others, deg - 2);
                
                for oi = 1:size(others,1)
                    other = others(oi,:);
                    
                    use_full = update_comb(var_update, var_sel, var_sgn, other, deg);
                    if (use_full)
                        return;
                    end
                end
            end
        end
    end

    function use_full = update_comb(var_update, var_sel, var_sgn, var_other, deg)
        % update red(deg,var_update) for I({var_update,var_sel,var_other})
        % update cond_red(deg,var_update) for I({var_update,var_sel,var_other}|target)
        use_full = 0;
        
        if (length(unique([var_update var_sel var_other])) ~= deg)
            % shouldn't happen!
            error('duplicate variables!');
        end
        % construct probability tables
        p_zxy = dimensionalize( [target features(:, [var_sel var_update var_other])]); % convert to freq table
        p_zxy = p_zxy ./ sum(p_zxy(:)); % normalize
        
        p_xy  = marginal(p_zxy, ~ofn(1, deg+1), 1); % all variables except target
        
        red_new       =  interaction_info(p_xy, 'prior', prior_wt);
        cond_red_new  =  interaction_info(p_zxy, 1, 'prior', prior_wt);
        
        if (~use_pessim)
            
            red(deg, var_update)      = red(deg, var_update)      + var_sgn * red_new;
            cond_red(deg, var_update) = cond_red(deg, var_update) + var_sgn * cond_red_new;
            
        elseif ((red_wt_it * red_new - cond_red_wt_it * cond_red_new) >= red_wt_it * red(deg, var_update) - cond_red_wt_it * cond_red(deg, var_update))
            % use_pessim = 1, higher redundancy
            if (var_sgn > 0)
                red(deg, var_update)      = red_new;
                cond_red(deg, var_update) = cond_red_new;
            else
                % this variable interaction led to the maximum; 
                % since it was dropped, variable i has to be completely re-evaluated
                
                use_full                  = 1;
                red(deg, var_update)      = -inf;
                cond_red(deg, var_update) = inf;
            end
        end
    end
 
    function z = ofn(x, l)
        % convert indices to binary 1-of-n vector
        z = zeros(l, 1);
        for nn = (1:length(x))
            z(x(nn)) = 1;
        end
    end

end

