addpath(genpath(cd))
rng('default')
clear;clc

%% Data transformation: 'R_full'
% Since we focus on implicit recommendation (Top-N recommendation), 
% we consider interactions to be 1 if the original ratings are non-zero, otherwise 0.
load('R_4123_n7.mat'); 
R_full = R_4123(:,:,4);

%% Dataset split：'R_train'，'R_test'
[i,j] = find(R_full);
num_ratings = length(i);
test_idx = randperm(num_ratings, round(0.2 * num_ratings));

R_train = R_full;
R_test  = zeros(size(R_full));

for k = 1:length(test_idx)
    R_test(i(test_idx(k)), j(test_idx(k))) = R_full(i(test_idx(k)), j(test_idx(k)));
    R_train(i(test_idx(k)), j(test_idx(k))) = 0;
end

%% 'R_train'-->'Rhat'-->'List'
%  implicit feedback --> predicted preference --> recommended list
item_pop = sum(R_train,1);

    tic
    Xhat_sl = slice_learning(R_train,15);   
    list_sl = get_rank(Xhat_sl);    
    toc

    tic
    Xhat_sl_pop = slice_learning_pop(R_train,15,item_pop);
    list_sl_pop = get_rank(Xhat_sl_pop);
    toc

    R_train_4 = R_4123;
    R_train_4(:,:,1) = R_train;
    R_train_4(:,:,2) = R_4123(:,:,1);
    R_train_4(:,:,3) = R_4123(:,:,2);
    R_train_4(:,:,4) = R_4123(:,:,3);

    tic
    Xhat_sl_4 = slice_learning(R_train_4, 300);
    Xhat_sl_1 = Xhat_sl_4(:, :, 1);
    list_sl_1 = get_rank(Xhat_sl_1);
    toc

    %%
    tic
    Xhat_sl_4_pop = slice_learning_pop(R_train_4,300,item_pop);
    Xhat_sl_1_pop = Xhat_sl_4_pop(:,:,1);
    list_sl_1_pop = get_rank(Xhat_sl_1_pop);
    list_sl_1_pop_new = get_rank_new(list_sl_1_pop,R_train);
    toc

%% recommendation accuracy
N = 50;

NDCG_sl       = computeNDCG(list_sl,       R_test, N)
NDCG_sl_pop   = computeNDCG(list_sl_pop,   R_test, N)
NDCG_sl_1     = computeNDCG(list_sl_1,     R_test, N)
NDCG_sl_1_pop = computeNDCG(list_sl_1_pop, R_test, N)

Recall_sl       = computeRecall(list_sl,       R_test, N)
Recall_sl_pop   = computeRecall(list_sl_pop,   R_test, N)
Recall_sl_1     = computeRecall(list_sl_1,     R_test, N)
Recall_sl_1_pop = computeRecall(list_sl_1_pop, R_test, N)

%% debias performance 
PRI_sl       = get_PRI(item_pop, Xhat_sl,       R_test)
PRI_sl_pop   = get_PRI(item_pop, Xhat_sl_pop,   R_test)
PRI_sl_1     = get_PRI(item_pop, Xhat_sl_1,     R_test)
PRI_sl_1_pop = get_PRI(item_pop, Xhat_sl_1_pop, R_test)