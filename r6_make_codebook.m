n=0; list={};
k = 1000;
LIST={'curry', 'donut', 'strawberry', 'tomato'};
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

%作るコードブックごとに値を変更して利用しました。
PosList=list(201:300);   
NegList=list(301:400);
Training={PosList{:} NegList{:}};

%forループで，全画像についてSURF特徴を抽出
Features=[];
for i=1:200
  I=rgb2gray(imread(Training{i}));
  p = createRandomPoints(size(I), 2000);
  [f,p2]=extractFeatures(I,p);
  Features=[Features; f];
end

%kmeansでコードブック作成
[idx,CODEBOOK]=kmeans(Features, k);