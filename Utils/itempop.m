function recommended_items = itempop(implicit_matrix)

% ItemPop. This method simply recommends the most popular items to all users,
%          based on the implicit user-item interaction records (training dataset),
%          where items are ranked by the number of times they are interacted.

% Output: Matrix elements represent item IDs.

    % Calculate the total number of interactions for each item
    item_popularity = sum(implicit_matrix, 1);
    
    % Sort items by interaction count and obtain their indices
    [~, sorted_indices] = sort(item_popularity, 'descend');
    
    % Get the indices (IDs) of the most popular items
    top_items = sorted_indices;
    
    % Recommend these most popular items to each user
    num_users = size(implicit_matrix, 1);
    recommended_items = repmat(top_items, num_users, 1);
end

%                      1 2 3

% implicit_matrix   = [1 0 0;
%                      1 0 1;
%                      1 1 1]

% item_popularity   = [3 1 2];

% sorted_indices    = [1 3 2];

% recommended_items = [1 3 2;
%                      1 3 2;
%                      1 3 2];

% recommended_items = [3 2 0;
%                      2 0 0;
%                      0 0 0];