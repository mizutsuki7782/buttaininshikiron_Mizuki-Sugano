% % matlab開きなおしたときに実行する
% % ctrl+r, ctrl+shift+r
% n=0; list={};
% LIST={'curry', 'donut', 'strawberry', 'tomato'};
% DIR0='r6img/';
% 
% for i=1:length(LIST)
%     DIR=strcat(DIR0,LIST(i),'/')
%     W=dir(DIR{:});
% 
%     for j=1:length(W)
%         if (strfind(W(j).name,'.jpg'))
%             fn=strcat(DIR{:},W(j).name);
% 	        n=n+1;
%             fprintf('[%d] %s\n',n,fn);
% 	        list={list{:} fn};
%         end
%     end
% end

class = 1; % 0: curry&donut, 1: strawberry&tomato

if class == 0
    % クラス0の場合のインデックス範囲
    PosList = list(1:100);
    NegList = list(101:200);
    Training={PosList{:} NegList{:}};
    fprintf('Class 0 (Curry & Donut) selected.\n');

elseif class == 1
    % クラス1の場合のインデックス範囲
    PosList = list(201:300);
    NegList = list(301:400);
    Training={PosList{:} NegList{:}};
    fprintf('Class 1 (Strawberry & Tomato) selected.\n');
    
else
    error('class は 0 か 1 を指定してください');
end

n = 200;

color_hist = zeros(n, 64);

for j=1:n  % 各画像についての for-loop
    %j番目の画像読み込み、特徴点抽出
    Irgb = imread(Training{j});

    %Color Histgram
    X64 = floor(double(Irgb(:,:,1))/64)*16 + floor(double(Irgb(:,:,2))/64)*4 + floor(double(Irgb(:,:,3))/64);
    h = histcounts(X64(:), 0:64);
    color_hist(j,:) = h;

end

%正規化
color_hist = color_hist ./ sum(color_hist, 2);

% --- 評価実行 ---
true_label = [ones(100, 1); ones(100, 1) * (-1)];
[acc_color, all_plabels, all_scores] = r6_five_fold_cv(color_hist(1:100, :), color_hist(101:200, :), 'linear');

fprintf('Color Hist Accuracy: %.2f%%\n', acc_color * 100);

% --- 正解・不正解のインデックス特定 ---
correct_idx = find(true_label == all_plabels);
wrong_idx   = find(true_label ~= all_plabels);

figure('Name', 'Classification Results with SVM Scores');

% 1. 正解画像を表示
for i = 1:5
    if length(correct_idx) >= i
        subplot(2, 5, i);
        idx = correct_idx(i);
        imshow(Training{idx});
        % スコアを表示（%.4f で小数点第4位まで）
        title(sprintf('Correct Score: %.4f', all_scores(idx)));
    end
end

% 2. 不正解画像を表示
for i = 1:5
    if length(wrong_idx) >= i
        subplot(2, 5, i+5);
        idx = wrong_idx(i);
        imshow(Training{idx});
        title(sprintf('Wrong Score: %.4f', all_scores(idx)));
    end
end