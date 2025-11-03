clear;clc;close all
addpath(genpath(cd))

% 10000*2876947~12256906 [data]
% 10000*2876947~ 5291166 [data_unique]
%% raw data
% browse  -1
% collect -2
% cart    -3
% buy     -4

data = readtable('user_action.csv');
data = removevars(data, {'item_category','time'});
data_unique = unique(data, 'rows');     %  5291166*3 table
data_matrix = table2array(data_unique); %  5291166*3 matrix

%% Data Pre-processing
% 0. Extract entries corresponding to purchase behaviors
% Among 5 million interaction records: 100k are purchases, 200k are "add-to-cart",
% 200k are favorites, and 4.6M are browsing actions.
% 8,886 users have made purchases; 92,753 items have been purchased,
% and 6,412 items have been purchased at least twice.
filtered_data = data_unique(data_unique.behavior_type == 4, :); % 102996*3 table
filtered_user = filtered_data.user_id; % 102996*1 double
filtered_item = filtered_data.item_id; % 102996*1 double

% Get unique user_id values and their occurrence counts
[unique_uids, ~, uidx] = unique(filtered_user);
countsu = histcounts(uidx, 1:numel(unique_uids) + 1); % 8886
% Create a two-column matrix: first column = unique user_id, second = occurrence count
result_matrix_u = [unique_uids, countsu'];
% Sort rows in descending order by occurrence count
sorted_result_u = sortrows(result_matrix_u, -2);

% Get unique item_id values and their occurrence counts
[unique_iids, ~, iidx] = unique(filtered_item);
countsi = histcounts(iidx, 1:numel(unique_iids) + 1); % 92753
% Create a two-column matrix: first column = unique item_id, second = occurrence count
result_matrix_i = [unique_iids, countsi'];
% Sort rows in descending order by occurrence count
sorted_result_i = sortrows(result_matrix_i, -2);

useridx_4   = sorted_result_u(:,1); %  8886
itemidx_4   = sorted_result_i(:,1); % 92753
itemidx_4_2 = itemidx_4(1:6412);    %  6412 items purchased by at least two users

%% 
logical_indices = ismember(data_unique.item_id, itemidx_4_2);
data_unique_select = data_unique(logical_indices, :);

num_user = numel(unique(data_unique_select.user_id))
num_item = numel(unique(data_unique_select.item_id))

logical_indices2 = ismember(data_unique_select.user_id, useridx_4);
data_unique_select2 = data_unique_select(logical_indices2, :);

num_user = numel(unique(data_unique_select2.user_id))
num_item = numel(unique(data_unique_select2.item_id))

%%
m   = 1463;
n   = 800;
R_1 = zeros(m,n);
R_2 = zeros(m,n);
R_3 = zeros(m,n);
R_4 = zeros(m,n);

selected_users = useridx_4(1:m);
selected_items = itemidx_4_2(1:n);
%% 1
tic
for i = 1:m
    for j = 1:n
        if any(data_unique_select2.user_id == selected_users(i) ...
                & data_unique_select2.item_id == selected_items(j) ...
                & data_unique_select2.behavior_type == 1)
            R_1(i, j) = 1;
        end
    end
end
toc
nnz(R_1)/numel(R_1)
%% 2 
tic
for i = 1:m
    for j = 1:n
        if any(data_unique_select2.user_id == selected_users(i) ...
                & data_unique_select2.item_id == selected_items(j) ...
                & data_unique_select2.behavior_type == 2)
            R_2(i, j) = 1;
        end
    end
end
toc 
nnz(R_2)/numel(R_2)
%% 3 
tic
for i = 1:m
    for j = 1:n
        if any(data_unique_select2.user_id == selected_users(i) ...
                & data_unique_select2.item_id == selected_items(j) ...
                & data_unique_select2.behavior_type == 3)
            R_3(i, j) = 1;
        end
    end
end
toc
nnz(R_3)/numel(R_3)
%% 4 
tic
for i = 1:m
    for j = 1:n
        if any(data_unique_select2.user_id == selected_users(i) ...
                & data_unique_select2.item_id == selected_items(j) ...
                & data_unique_select2.behavior_type == 4)
            R_4(i, j) = 1;
        end
    end
end
toc
nnz(R_4)/numel(R_4)

R_4123 = zeros(m,n,4);
R_4123(:,:,1) = R_1;
R_4123(:,:,2) = R_2;
R_4123(:,:,3) = R_3;
R_4123(:,:,4) = R_4;
save('R_4123_n7.mat','R_4123')