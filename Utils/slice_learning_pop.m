function Mhat = slice_learning_pop(X, r, item_pop)
    % Parameters and initialization 
    n    = size(X,3);
    Mhat = zeros(size(X));

    %% Popularity Feature Embedding: One-hot Coding 
    % Compute ranking percentiles
    [~, sorted_indices] = sort(item_pop, 'descend');    
    ranking_percentile = (1:length(item_pop)) / length(item_pop);
    % Generate the pop_fea vector
    item_po = zeros(size(item_pop));
    item_po(sorted_indices(ranking_percentile <= 0.2)) = 1;
    item_un = 1 - item_po;
    % Feature vectors encoding item popularity
    A = [item_po; item_un]';

    %% Stage 1: Learning subspaces
    X1 = double(tenmat(X,1)); % mode-1 unfolding
    [Uhat,~,~] = svds(X1, r);  
    X2 = double(tenmat(X,2)); % mode-2 unfolding
    [Vhat,~,~] = svds(X2, r);

    %%   
    % Compute the orthonormal basis of the column space of A
    A_orth = orth(A);
    projection_matrix = eye(size(Vhat, 1)) - A_orth * inv(A_orth' * A_orth) * A_orth';
    % Project onto the orthogonal complement of A's column space
    Vhat_orthogonal = projection_matrix * Vhat;
    % Perform orthonormalization on the projected matrix columns
    Vhat = orth(Vhat_orthogonal);

    %% Stage 2: Projection
    PU = Uhat * Uhat';
    PV = Vhat * Vhat';
    for k = 1:n
        Mhat(:,:,k) = PU * X(:,:,k) * PV;
    end
end