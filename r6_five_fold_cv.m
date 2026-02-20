function [avg_accuracy, all_plabels, all_scores] = r6_five_fold_cv(data_pos, data_neg, kernel_type)
    n = size(data_pos, 1); 
    cv = 5;
    idx = 1:n;
    accuracy = [];
    all_plabels = zeros(n*2, 1);
    all_scores = zeros(n*2, 1);

    for i=1:cv 
      train_pos=data_pos(find(mod(idx,cv)~=(i-1)),:);
      eval_pos =data_pos(find(mod(idx,cv)==(i-1)),:);
      train_neg=data_neg(find(mod(idx,cv)~=(i-1)),:);
      eval_neg =data_neg(find(mod(idx,cv)==(i-1)),:);
    
      eval_idx = [find(mod(idx,cv)==(i-1)), find(mod(idx,cv)==(i-1)) + n];

      train=[train_pos; train_neg];
      eval=[eval_pos; eval_neg];
    
    % 修正後のラベル作成
      train_label = [ones(size(train_pos, 1), 1); ones(size(train_neg, 1), 1) * (-1)];
      eval_label  = [ones(size(eval_pos, 1), 1);  ones(size(eval_neg, 1), 1) * (-1)];
    
      %分類
      if strcmp(kernel_type, 'rbf')
          model = fitcsvm(train, train_label,'KernelFunction','rbf', 'KernelScale','auto');
          fprintf('非線形SVM\n');
      elseif strcmp(kernel_type, 'linear')
          model = fitcsvm(train, train_label,'KernelFunction','linear'); 
          fprintf('線形SVM\n');
      else
          model = fitcsvm(train, train_label,'KernelFunction','linear'); 
          fprintf('指定されませんでした。（線形SVM）\n');
      end

      [plabel, score] = predict(model, eval);

      all_plabels(eval_idx) = plabel;
      all_scores(eval_idx) = score(:, 2);

      %評価
      ac = numel(find(eval_label==plabel))/numel(eval_label);
      accuracy=[accuracy ac];
    end
    avg_accuracy = mean(accuracy);
end
