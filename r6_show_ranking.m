% ==========================================================
% HTML生成: Before / After 切り替え機能付き
% ==========================================================
html_filename = 'reranking_comparison_guitar_n50.html';
fid = fopen(html_filename, 'w');

% --- 1. HTMLヘッダー (CSS & JavaScript) ---
fprintf(fid, '<html><head><meta charset="UTF-8"><title>Re-ranking Comparison (guitar n=50)</title>');
fprintf(fid, '<style>');
fprintf(fid, 'body { font-family: "Helvetica Neue", Arial, sans-serif; background-color: #f4f4f9; margin: 0; padding: 20px; }');
fprintf(fid, 'h1 { text-align: center; color: #333; }');
% タブボタンのスタイル
fprintf(fid, '.tab-container { text-align: center; margin-bottom: 20px; position: sticky; top: 0; background: #f4f4f9; padding: 10px; z-index: 100; border-bottom: 1px solid #ddd; }');
fprintf(fid, '.btn { padding: 10px 20px; font-size: 16px; cursor: pointer; border: none; border-radius: 5px; margin: 0 10px; transition: 0.3s; }');
fprintf(fid, '.btn-active { background-color: #007bff; color: white; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }');
fprintf(fid, '.btn-inactive { background-color: #ddd; color: #333; }');
fprintf(fid, '.btn:hover { opacity: 0.8; }');
% 画像グリッドのスタイル
fprintf(fid, '.grid-container { display: flex; flex-wrap: wrap; justify-content: center; gap: 15px; }');
fprintf(fid, '.card { background: white; padding: 10px; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); width: 180px; text-align: center; transition: transform 0.2s; }');
fprintf(fid, '.card:hover { transform: translateY(-5px); box-shadow: 0 5px 15px rgba(0,0,0,0.2); }');
fprintf(fid, 'img { width: 100%%; height: 150px; object-fit: cover; border-radius: 4px; }');
fprintf(fid, '.rank-badge { display: inline-block; background: #333; color: white; padding: 2px 8px; border-radius: 10px; font-size: 0.8em; margin-bottom: 5px; }');
fprintf(fid, '.score { color: #555; font-size: 0.85em; margin-top: 5px; font-weight: bold; }');
fprintf(fid, '.filename { color: #999; font-size: 0.7em; word-break: break-all; margin-top: 3px; }');
fprintf(fid, '.hidden { display: none; }');
fprintf(fid, '</style>');

% JavaScript (切り替えロジック)
fprintf(fid, '<script>');
fprintf(fid, 'function showTab(tabName) {');
fprintf(fid, '  document.getElementById("view-original").classList.add("hidden");');
fprintf(fid, '  document.getElementById("view-reranked").classList.add("hidden");');
fprintf(fid, '  document.getElementById("btn-org").classList.remove("btn-active");');
fprintf(fid, '  document.getElementById("btn-org").classList.add("btn-inactive");');
fprintf(fid, '  document.getElementById("btn-rank").classList.remove("btn-active");');
fprintf(fid, '  document.getElementById("btn-rank").classList.add("btn-inactive");');
fprintf(fid, '  document.getElementById("view-" + tabName).classList.remove("hidden");');
fprintf(fid, '  document.getElementById("btn-" + (tabName=="original"?"org":"rank")).classList.add("btn-active");');
fprintf(fid, '  document.getElementById("btn-" + (tabName=="original"?"org":"rank")).classList.remove("btn-inactive");');
fprintf(fid, '}');
fprintf(fid, '</script>');
fprintf(fid, '</head><body>');

% --- 2. ページ上部のボタン ---
fprintf(fid, '<h1>Flickr Re-ranking Result (guitar n=50)</h1>');
fprintf(fid, '<div class="tab-container">');
fprintf(fid, '<button id="btn-org" class="btn btn-inactive" onclick="showTab(''original'')">Original Order (Before)</button>');
fprintf(fid, '<button id="btn-rank" class="btn btn-active" onclick="showTab(''reranked'')">SVM Re-ranked (After)</button>');
fprintf(fid, '</div>');

num_check = 100; % 表示枚数

% --- 3. Original (Before) のリスト作成 ---
% display: none (hidden) で初期化
fprintf(fid, '<div id="view-original" class="grid-container hidden">');
for i = 1:num_check
    fname = testList{i};
    % 元のスコアを取得 (score変数の順番はtestListと一致しているため)
    s = score(i, 2); 
    
    fprintf(fid, '<div class="card">');
    fprintf(fid, '<span class="rank-badge" style="background:#777">Original #%d</span><br>', i);
    fprintf(fid, '<img src="%s" loading="lazy"><br>', fname);
    fprintf(fid, '<div class="score">Score: %.4f</div>', s);
    fprintf(fid, '<div class="filename">%s</div>', fname);
    fprintf(fid, '</div>\n');
end
fprintf(fid, '</div>'); % end view-original

% --- 4. Re-ranked (After) のリスト作成 ---
% こちらを初期表示にする
fprintf(fid, '<div id="view-reranked" class="grid-container">');
for i = 1:num_check
    idx = sorted_idx(i);      % ソート後のインデックス
    fname = testList{idx};
    s = sorted_score(i);      % ソート後のスコア
    
    fprintf(fid, '<div class="card">');
    % 上位ほど赤くする演出（1-10位は赤バッジ）
    if i <= 10
        color = '#d32f2f'; 
    else
        color = '#1976d2';
    end
    fprintf(fid, '<span class="rank-badge" style="background:%s">Rank #%d</span><br>', color, i);
    
    fprintf(fid, '<img src="%s" loading="lazy"><br>', fname);
    fprintf(fid, '<div class="score">Score: %.4f</div>', s);
    fprintf(fid, '<div class="filename">%s</div>', fname);
    fprintf(fid, '</div>\n');
end
fprintf(fid, '</div>'); % end view-reranked

fprintf(fid, '</body></html>');
fclose(fid);

fprintf('HTMLファイルを生成しました: %s\n', html_filename);
web(html_filename, '-browser'); % ブラウザで開く