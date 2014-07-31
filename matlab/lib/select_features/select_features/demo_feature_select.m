% DEMO_FEATURE_SELECT - demonstrate feature selection algorithms on some
% toy examples.

%% Introduction
% The problem of Feature Selection is: Given a (usually large) number of
% noisy and partly redundant variables and a target that we would like to
% predict, choose a small but indicative subset as input to a
% classification or regression technique. While _wrappers_ employ one
% specific such technique, _filters_ try to come up with a "most
% informative subset" (in some sense to be defined). Several such criteria
% are based on Shannon information (_mutual information_ between two
% variables, or _interaction information_ between larger subsets). The
% Matlab function |select_features| captures several criteria previously
% proposed in the literature, and some generalizations thereof. For some
% more background and comparisons, see e.g.: 
% Gavin Brown, A New Perspective for Information Theoretic Feature
% Selection, Artificial Intelligence and Statistics, 2009.

%%
%  In the first example, we generate a very simple dependence: X1,X2,X3 are
%  normally distributed variables. Our target, X3, is a noisy observation
%  of X1. X2 is uncorrelated with either of them.
%
%       X1
%        \ 
%     X2  X3

nsamples      = 1000;
data          = zeros(nsamples,3);
data(:,[1 2]) = randn(nsamples,2);
data(:,3)    =  0.5*data(:,1) + 0.5*randn(nsamples,1);

%%
% For calculating mutual information, continuous variables have to be
% _discretized_. The function |quantize| offers several options to do this.
% We choose the simplest case of binary variables.

data_quant=quantize(data,'levels',2);

%%
% Then, we run the default feature selection algorithm, called 'first order
% utility'. It is based on approximating the mutual information between the
% set of selected variables and the target by expanding interaction
% information terms of up to degree 2. In each step, the variable with the
% highest estimated _incremental_ gain is selected greedily. The output
% distinguishes between _relevance_, i.e., mutual information between a
% feature and the target; _redundancy_, i.e., mutual information between
% different variables; and _conditional redundancy_, which measures the
% increase of mutual information between the previously selected variables
% and the target, conditional on a selected variable.

[steps,sel_flag,rel,red,cond_red] = select_features(data_quant(:,1:2),data_quant(:,3),2);

%%
% As expected, X1 gets a significantly higher score than X2. You can
% inspect the results more closely in the output arguments (|steps| for the
% sequence of selections, scores, and (conditional) redundancies;
% |sel_flag| for the finally selected variables; and the final values of
% relevance and conditional redundancy, for all variables. The final scores
% are computed as sum([rel; - red; cond_red]). 

%% Smoothing
% A general issue with (especially higher-order) interaction information is
% sparsity of data. By subdividing our observed data into many categories,
% we are led to believe spurious associations. For example, look what
% happens to the above example if we increase the quantization level and
% decrease the number of samples:

nsamples      = 100;
data          = zeros(nsamples,3);
data(:,[1 2]) = randn(nsamples,2);
data(:,3)    =  0.5*data(:,1) + 0.5*randn(nsamples,1);
data_quant=quantize(data,'levels',5);
[steps,sel_flag,rel,red,cond_red] = select_features(data_quant(:,1:2),data_quant(:,3),2);

%%
% Notice that the conditional redundancy of the uncorrelated variable X2
% (after addition of X1) now seems to be higher than the mutual information
% between X1 and X2. Several remedies have been suggested, e.g.,
% downweighting the (conditional) redundancy terms (You can explore these
% options in the select_features function). In contrast, we propose to use
% a common method in Bayesian statistics, namely adding a prior in the form
% of "pseudo-samples' drawn from the marginal distributions. 

[steps,sel_flag,rel,red,cond_red] = select_features(data_quant(:,1:2),data_quant(:,3),2,'prior',1);

%%
% In this case, we are adding one pseudo-sample to each possible
% combination of joint variable values. As a result, while all scores
% (including the one for X1) decrease, the irrelevant X2 is reduced much
% more rapidly.

%% Diamond
% This example contains 4 variables in the well-known diamond shape. X4 is
% our target.
%
%      X1
%     /  \ 
%    X2   X4
%     \   /
%      X3

nsamples=10000;
data=zeros(nsamples,4);
data(:,1)=randn(nsamples,1);
data(:,2)= 0.5*data(:,1) + 0.5*randn(nsamples,1);
data(:,4)= 0.5*data(:,1) + 0.5*randn(nsamples,1);
data(:,3)= 0.5*data(:,2) + 0.5*data(:,4) + 0.5*randn(nsamples,1);

data_quant=quantize(data,'levels',2);
[steps,sel_flag,rel,red,cond_red] = select_features(data_quant(:,1:3),data_quant(:,4),3, 'degree', 3);

%%
% Since X3 depends on X2 as well, X1 receives a higher score. Clearly, due
% to the common dependency, X2 bears some mutual information on X4. Note,
% however, how this is outweighed by the interaction term (redundancy -
% conditional redundancy): In fact, once we know X1, X2 cannot provide any
% additional information about X4.


%% Higher-Order interaction
% Assume binary variables X1 .. X5, where our target, X5, is the logical
% _exclusive or_ of X1..X3. We include the independent X4 for illustration.
%
%       X1   X2  X3  X4
%        \   |  /
%           X5
% 

data=zeros(nsamples,5);
data(:,1:4) = floor(rand(nsamples,4)/0.5);
data(:,5)   = xor(xor(data(:,1),data(:,2)),data(:,3));
[steps,sel_flag,rel,red,cond_red] = select_features(data(:,1:4),data(:,5),4);

%%
% The default algorithm only considers interactions of degree 2, and
% therefore cannot find the relationship. We have to switch to degree 3:

[steps,sel_flag,rel,red,cond_red] = select_features(data(:,1:4),data(:,5),4,'degree', 3);

%%
% The algorithm selects variables more or less randomly, until two of the
% three determinants have been included. At this point, it discovers the
% strong significance of the missing one. In cases like this, the function
% will have more guidance when _going backwards_, i.e., starting with all
% variables, and iteratively dropping the least significant one. It will
% delay discarding any of the relevant variables as long as possible: 

[steps,sel_flag,rel,red,cond_red] = select_features(data(:,1:4),data(:,5),4,'degree', 3, 'init', [ 1 2 3 4], 'direction', 'b');

%%
% This concludes our simple selection of feature selection examples. There
% is a lot to explore - hope you have fun with your own experiments!

% Copyright © 3/16/2010 Stefan Schroedl  