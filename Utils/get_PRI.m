function PRI_value = get_PRI(item_pop, preference, relevance_score)

    [~,n] = size(relevance_score);

    [~,rank_order] = sort(preference,2,'descend'); 
    [~,ranks] = sort(rank_order,2);
    item_rank = ranks;
    avg_rank = zeros(1,n);

    for i = 1:n
        idx = find(relevance_score(:,i)~=0);
        num = length(idx);
        item_rank_1 = item_rank(:,i);
        item_rank_1 = item_rank_1(idx);
        avg_rank(i) = sum(item_rank_1)/num;
    end
    idx = find(~isnan(avg_rank));
    
    PRI_value = -corr(item_pop(idx)', avg_rank(idx)', 'Type', 'Spearman');

end