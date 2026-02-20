

%matlab開きなおしたときに実行する
%ctrl+r, ctrl+shift+r
n=0; list={};
LIST={'donut50', 'bgimg'};
DIR0='r6img/';

for i=1:length(LIST)
    DIR=strcat(DIR0,LIST(i),'/')
    W=dir(DIR{:});

    for j=1:length(W)
        if (strfind(W(j).name,'.jpg'))
            fn=strcat(DIR{:},W(j).name);
	        n=n+1;
            fprintf('[%d] %s\n',n,fn);
	        list={list{:} fn};
        end
    end
end

class = 50; % 25 or 50
if class == 25
    % クラス25の場合のインデックス範囲
    PosList=list(1:25);
    NegIdx=[51:1165];
    NegList=list(NegIdx(randperm(length(NegIdx),1000)));
    Training={PosList{:} NegList{:}};
    n=1025;
    fprintf('n=25 selected.\n');

elseif class == 50
    % クラス50の場合のインデックス範囲
    PosList=list(1:50);
    NegIdx=[51:1165];
    NegList=list(NegIdx(randperm(length(NegIdx),1000)));
    Training={PosList{:} NegList{:}};
    n=1050;
    fprintf('n=50 selected.\n');
    
else
    error('class は 25 か 50 を指定してください');
end

net = alexnet;
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

pos_num = class;
neg_num = 1000;
training_label = [ones(pos_num, 1); ones(neg_num, 1) * (-1)];

%線形SVMによる学習
SVMModel = fitcsvm(F7, training_label, 'KernelFunction','linear'); %モデル作成完了


%300枚のtest画像読み込み
n=0; testList={};
LIST2={'donut300'};
DIR0='r6img/';

for i=1:length(LIST2)
    DIR2=strcat(DIR0,LIST2(i),'/')
    W2=dir(DIR2{:});

    for j=1:length(W2)
        if (strfind(W2(j).name,'.jpg'))
            fn=strcat(DIR2{:},W2(j).name);
	        n=n+1;
            fprintf('[%d] %s\n',n,fn);
	        testList={testList{:} fn};
        end
    end
end

% 特徴量を用いて新しい画像の分類を行う
testF7 = zeros(300, 4096);
for j=1:300  % 各テスト画像についての for-loop
    img = imread(testList{j});
    reimg = imresize(img, net.Layers(1).InputSize(1:2));

    f7 = activations(net, reimg, 'fc7');
    f7 = squeeze(f7);
    f7 = f7 / norm(f7);
    testF7(j, :) = f7;
end

[label,score] = predict(SVMModel,testF7);

% 降順 ('descent') でソートして，ソートした値とソートインデックスを取得します．
[sorted_score,sorted_idx] = sort(score(:,2),'descend');

% list{:} に画像ファイル名が入っているとして，
% sorted_idxを使って画像ファイル名，さらに
% sorted_score[i](=score[sorted_idx[i],2])の値を出力します．
for i=1:numel(sorted_idx)
  fprintf('%s %f\n',testList{sorted_idx(i)},sorted_score(i));
end
