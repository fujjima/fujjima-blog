// マークダウンをプレビュー画面に表示する
$(function () {
  $('#articleText').keyup(function () {
    // https://qiita.com/samuraibrass/items/d40d54aa0754692d5439
    // 1改行を改行にしたい
    marked.setOptions({
      breaks: true,
      langPrefix: '',
      highlight: function (code, lang) {
        return hljs.highlightAuto(code, [lang]).value;
      }
    });
    let html = marked($(this).val());
    // エリア内のhtmlをmarkedで生成され直したhtmlに置き換える
    $('#markdown_preview').html(html);
  });
});
