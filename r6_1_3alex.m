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

net = alexnet;
class = 1; % 0: curry&donut, 1: strawberry&tomato

if class == 0
    % クラス0の場合のインデックス範囲
    PosList = list(1:100);
    NegList = list(101:200);
    Training={PosList{:} NegList{:}};
    %load('codebook_r6_1.mat');
    fprintf('Class 0 (Curry & Donut) selected.\n');

elseif class == 1
    % クラス1の場合のインデックス範囲
    PosList = list(201:300);
    NegList = list(301:400);
    Training={PosList{:} NegList{:}};
    %load('codebook_r6_2.mat');
    fprintf('Class 1 (Strawberry & Tomato) selected.\n');
    
else
    error('class は 0 か 1 を指定してください');
end

n = 200;
F7 = zeros(n, 4096);

for j=1:n  % 各画像についての for-loop
    %j番目の画像読み込み、特徴点抽出
    img = imread(Training{j});
    reimg = imresize(img,net.Layers(1).InputSize(1:2)); 

    f7 = activations(net, reimg, 'fc7'); 
    f7 = squeeze(f7);
    f7 = f7 / norm(f7);
    F7(j, :) = f7;
end

true_label = [ones(100, 1); ones(100, 1) * (-1)]; 

% 関数の戻り値を [精度, 判定ラベル, スコア] に対応させる
[acc_alex, all_plabels, all_scores] = r6_five_fold_cv(F7(1:100, :), F7(101:200, :), 'linear');

fprintf('AlexNet DCNN (linear SVM) Accuracy: %.2f%%\n', acc_alex * 100);

% --- 正解・不正解画像のインデックスを特定 ---
correct_idx = find(true_label == all_plabels); % 判定が合っていたもの
wrong_idx = find(true_label ~= all_plabels); % 判定を間違えたもの

figure('Name', 'AlexNet DCNN Classification Results (Correct vs Wrong)');

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
