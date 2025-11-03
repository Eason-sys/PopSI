function recall_at_k = computeRecall(list_algo, R_test, k)

    num_users = size(list_algo, 1);
    true_positives_at_k = 0;
    total_actual_positives = 0;

    for user = 1:num_users
        top_k_recommendations = list_algo(user, 1:k);
        actual_positives = find(R_test(user, :) == 1);
        true_positives_at_k = true_positives_at_k + numel(intersect(top_k_recommendations, actual_positives));
        total_actual_positives = total_actual_positives + numel(actual_positives);
    end
    recall_at_k = true_positives_at_k / total_actual_positives;
end

% list_algo = [5 3 1 2 4;
%              5 1 3 4 2];
% R_test = [1 0 1 0 1;
%              0 1 0 1 0];
% k=4;
