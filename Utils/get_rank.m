function X_rank = get_rank(X)

% Input matrix X: 
%   a matrix with values representing relevance (preference) score

% Output matrix X_rank:
%   a matrix with values representing item rank (row-wise)

    [~,rank_order] = sort(X,2,'descend'); 
    X_rank = rank_order;

end

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