function Mhat = slice_learning(X,r)
    % parameters and initialization 
    n    = size(X,3);
    Mhat = zeros(size(X));
    % Stage 1: leanring subspaces
    X1 = double(tenmat(X,1)); % mode-1 unfolding
    [Uhat,~,~] = svds(X1,r);  %
    X2 = double(tenmat(X,2)); % mode-2 unfolding
    [Vhat,~,~] = svds(X2,r);
    % Stage 2: projection
    PU = Uhat*Uhat';
    PV = Vhat*Vhat';
    for k = 1:n
        Mhat(:,:,k) = PU*X(:,:,k)*PV;
    end
end