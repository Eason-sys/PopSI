addpath(genpath(cd))
rng('default')
clear;clc;close all

%% Data transformation: 'R_full'
% Since we focus on implicit recommendation (Top-N recommendation), we consider
% interactions to be 1 if the original ratings are non-zero, otherwise 0.
load('R.mat'); 
R_full = R_4123(:,:,4);

%% Dataset split：'R_train'，'R_test'

% [i,j] = find(R_full);
%
% num_ratings = length(i);
% test_idx = randperm(num_ratings, round(0.2 * num_ratings));
%
% R_train = R_full;
% R_test  = zeros(size(R_full));
% 
% for k = 1:length(test_idx)
%     R_test(i(test_idx(k)), j(test_idx(k))) = R_full(i(test_idx(k)), j(test_idx(k)));
%     R_train(i(test_idx(k)), j(test_idx(k))) = 0;
% end

[i,j] = find(R_full);

num_ratings = length(i);
test_idx = randperm(num_ratings, round(0.2 * num_ratings));

R_train = R_full;
R_test1  = zeros(size(R_full));

for k = 1:length(test_idx)
    R_test1(i(test_idx(k)), j(test_idx(k))) = R_full(i(test_idx(k)), j(test_idx(k)));
    R_train(i(test_idx(k)), j(test_idx(k))) = 0;
end

[i,j] = find(R_test1);

num_ratings = length(i);
test_idx = randperm(num_ratings, round(0.5 * num_ratings));

R_vali = R_test1;
R_test = zeros(size(R_test1));

for k = 1:length(test_idx)
    R_test(i(test_idx(k)), j(test_idx(k))) = R_test1(i(test_idx(k)), j(test_idx(k)));
    R_vali(i(test_idx(k)), j(test_idx(k))) = 0;
end

%% main algorithms: 'R_train'-->'Rhat'-->'List'
%  implicit feedback --> predicted preference --> recommended list

item_pop = sum(R_train,1); % item popularity
N        = 50;

% 1. ItemPop
list_ItemPop = itempop(R_train);
list_ItemPop_new = get_rank_new(list_ItemPop,R_train);

% 2. Slice Learning (SL)
    % 2.1 SL on a single slice (alipay slice)
    tic
    Xhat_sl = slice_learning(R_train,15);   
    list_sl = get_rank(Xhat_sl);    
    list_sl_new = get_rank_new(list_sl,R_train);
    toc
    % 2.2 popularity-aware SL on a single slice (alipay slice)
    tic
    Xhat_sl_pop = slice_learning_pop(R_train,15,item_pop);
    list_sl_pop = get_rank(Xhat_sl_pop);
    list_sl_pop_new = get_rank_new(list_sl_pop,R_train);
    toc

% 3. Slice Learning on tensor
    R_train_4 = R_4123;
    R_train_4(:,:,1) = R_train;
    R_train_4(:,:,2) = R_4123(:,:,1);
    R_train_4(:,:,3) = R_4123(:,:,2);
    R_train_4(:,:,4) = R_4123(:,:,3);
    
    % 3.1 SL
    NDCG_values = zeros(1, 19);
   
    index = 1;
    for r = 30:30:600
        tic
        Xhat_sl_4 = slice_learning(R_train_4, r);
        Xhat_sl_1 = Xhat_sl_4(:, :, 1);
        list_sl_1 = get_rank(Xhat_sl_1);
        NDCG_values(index) = computeNDCG(list_sl_1, R_test, N);
        index = index + 1;
        toc
    end
    
    disp(NDCG_values);

    tic
    Xhat_sl_4 = slice_learning(R_train_4, 300);
    Xhat_sl_1 = Xhat_sl_4(:, :, 1);
    list_sl_1 = get_rank(Xhat_sl_1);
    list_sl_1_new = get_rank_new(list_sl_1,R_train);
    toc
    NDCG_sl_1    = computeNDCG(list_sl_1, R_test, 50)
    PRI_sl_1     = get_PRI(item_pop, Xhat_sl_1, R_test)

    % 3.2 popularity-aware SL
    tic
    Xhat_sl_4_pop = slice_learning_pop(R_train_4,300,item_pop);
    Xhat_sl_1_pop = Xhat_sl_4_pop(:,:,1);
    list_sl_1_pop = get_rank(Xhat_sl_1_pop);
    list_sl_1_pop_new = get_rank_new(list_sl_1_pop,R_train);
    toc
    NDCG_sl_1_pop    = computeNDCG(list_sl_1_pop, R_test, N)
    PRI_sl_1_pop   = get_PRI(item_pop, Xhat_sl_1_pop, R_test)


%% scatter plot
    [~,n] = size(R_test);

    [~,rank_order] = sort(Xhat_sl_1_pop,2,'descend');  
    [~,ranks] = sort(rank_order,2); 
    item_rank = ranks;
    avg_rank = zeros(1,n);

    for i = 1:n
        idx = find(Xhat_sl_1_pop(:,i)~=0);
        num = length(idx);
        item_rank_1 = item_rank(:,i);
        item_rank_1 = item_rank_1(idx);
        avg_rank(i) = sum(item_rank_1)/num;
    end
    idx = find(~isnan(avg_rank));

scatter(item_pop(idx), avg_rank(idx));

title('Scatter Plot of Item Popularity vs Rank');
xlabel('Item Popularity');
ylabel('Rank');

legend('Data Points');
%% performance

% accuracy
NDCG_ItemPop  = computeNDCG(list_ItemPop, R_test, N)
NDCG_sl       = computeNDCG(list_sl, R_test, N)
NDCG_sl_pop   = computeNDCG(list_sl_pop, R_test, N)
NDCG_sl_1     = computeNDCG(list_sl_1, R_test, N)
NDCG_sl_1_pop = computeNDCG(list_sl_1_pop, R_test, N)

Recall_ItemPop = computeRecall(list_ItemPop, R_test, N);
Recall_sl_1    = computeRecall(list_sl_1, R_test, N);

% popularity bias
PRI_sl        = get_PRI(item_pop, Xhat_sl, R_test)
PRI_sl_pop    = get_PRI(item_pop, Xhat_sl_pop, R_test)
PRI_sl_1      = get_PRI(item_pop, Xhat_sl_1, R_test)
PRI_sl_1_pop  = get_PRI(item_pop, Xhat_sl_1_pop, R_test)

%%
    [~,n] = size(list_ItemPop);
    [~,ranks] = sort(list_ItemPop,2);  
    item_rank = ranks;
    avg_rank = zeros(1,n);
    for i = 1:n
        idx = find(R_test(:,i)~=0);
        num = length(idx);
        item_rank_1 = item_rank(:,i);
        item_rank_1 = item_rank_1(idx);
        avg_rank(i) = sum(item_rank_1)/num;
    end
    idx = find(~isnan(avg_rank));
    PRI_ItemPop = -corr(item_pop(idx)', avg_rank(idx)', 'Type', 'Spearman')