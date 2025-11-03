function avgNDCG = computeNDCG(recMatrix, testMatrix ,k)

% Input:
% listMatrix：  recommendation list
% testMatrix：  serves as gain or relevance score
% k：           NDCG@k 

    % Get the number of users and recommended items
    [numUsers, ~] = size(recMatrix);
    
    % Initialize total NDCG
    totalNDCG = 0;
    
    for u = 1:numUsers
        DCG = 0;
        IDCG = 0;
        
        % Get the recommendation list for user u
        recommendations = recMatrix(u, :);
        
        % Compute DCG for the top-k recommendations
        for i = 1:k
            item = recommendations(i);
            if testMatrix(u, item) == 1
                DCG = DCG + 1 / log2(i + 1);
            end
        end
        
        % Compute IDCG for user u
        numRelevantItems = sum(testMatrix(u, :));
        for i = 1:min(k, numRelevantItems)
            IDCG = IDCG + 1 / log2(i + 1);
        end
        
        % Compute NDCG for the user
        if IDCG ~= 0
            NDCG = DCG / IDCG;
            totalNDCG = totalNDCG + NDCG;
        end
    end
    
    % Compute the average NDCG across all users
        avgNDCG = totalNDCG / numUsers;
end