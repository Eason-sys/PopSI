function recommendations = get_rank_new(X_rank,X_train)

% Input matrix X: 
%   a matrix with values representing relevance (preference) score

% Output matrix X_rank:
%   a matrix with values representing item rank (row-wise)
    recommendations = zeros(size(X_rank));
    for user = 1:size(X_rank, 1)
        user_interactions = find(X_train(user, :));  % 获取用户已经交互过的商品
        sorted_recommendations = setdiff(X_rank(user, :), user_interactions, 'stable');
        recommendations(user, 1:length(sorted_recommendations)) = sorted_recommendations;
    end


end



%%% 可以写成向量化版本，就是上面的，可真简洁啊
% function X_rank = get_rank(X)
% 
% % Input matrix X: 
% %   a matrix with values representing relevance (preference) score
% % Output matrix X_rank:
% %   a matrix with values representing item rank (row-wise)
% 
%     [m,n]  = size(X);
%     X_rank = zeros(m,n);
% 
%     for i = 1:m
%         % 对于矩阵A的每一行进行排序，并获取排序后的索引
%         [~,rank_order] = sort(X(i,:),'descend'); % 降序排列rank对应的商品id
%         % 通过对排序后的索引再次排序，得到排名
%         [~,ranks]      = sort(rank_order);       % 商品id对应的rank
%         X_rank(i,:)    = ranks;
%     end
% 
% end



%%%
% a quick example:

% X     = [1 4 3 2;
%          1 4 2 3];
%
% rank_order = [2 3 4 1];
% ranks      = [4 1 2 3];

% rank_order = [2 4 3 1];
% ranks      = [4 1 3 2];

% X_rank = [4 1 2 3;
%           4 1 3 2];