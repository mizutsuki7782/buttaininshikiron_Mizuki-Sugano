% %matlab開きなおしたときに実行する
% %ctrl+r, ctrl+shift+r
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

class = 0; % 0: curry&donut, 1: strawberry&tomato

if class == 0
    % クラス0の場合のインデックス範囲
    PosList = list(1:100);
    NegList = list(101:200);
    Training={PosList{:} NegList{:}};
    load('codebook_r6_1.mat');
    fprintf('Class 0 (Curry & Donut) selected.\n');

elseif class == 1
    % クラス1の場合のインデックス範囲
    PosList = list(201:300);
    NegList = list(301:400);
    Training={PosList{:} NegList{:}};
    load('codebook_r6_2.mat');
    fprintf('Class 1 (Strawberry & Tomato) selected.\n');
    
else
    error('class は 0 か 1 を指定してください');
end

n = 200;
k = 1000;
bof = zeros(n, k);

for j=1:n
    I=rgb2gray(imread(Training{j}));
    
    p = createRandomPoints(size(I), 2000); 
    [f,p2]=extractFeatures(I,p);

    index = knnsearch(CODEBOOK, f); 
    
    % ヒストグラムに投票
    bof(j, :) = histcounts(index, 1:k+1);
end

% sum(A,2)で行ごとの合計を求めて，それを各行の要素について割ることによって，各行の合計値を１として正規化する． 
bof = bof ./ sum(bof,2);  

true_label = [ones(100, 1); ones(100, 1) * (-1)]; 

% 関数の戻り値を [精度, 判定ラベル, スコア] に対応させる
[acc_bof, all_plabels, all_scores] = r6_five_fold_cv(bof(1:100, :), bof(101:200, :), 'rbf');

fprintf('BoF (RBF SVM) Accuracy: %.2f%%\n', acc_bof * 100);

% --- 正解・不正解画像のインデックスを特定 ---
correct_idx = find(true_label == all_plabels); % 判定が合っていたもの
wrong_idx = find(true_label ~= all_plabels); % 判定を間違えたもの

figure('Name', 'BoF Classification Results (Correct vs Wrong)');

% 1. 正解画像を表示
for i = 1:5
    if length(correct_idx) >= i
        subplot(2, 5, i);
        idx = correct_idx(i);
        imshow(Training{idx});
        % スコア（境界線からの距離）を表示
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