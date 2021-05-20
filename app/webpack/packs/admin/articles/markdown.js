// マークダウンをプレビュー画面に表示する
const preview = function (sel) {
  marked.setOptions({
    breaks: true,
    langPrefix: '',
    highlight: function (code, lang) {
      return hljs.highlightAuto(code, [lang]).value;
    }
  });
  let html = marked(sel.val());
  $('#markdown-preview').html(html);
}

$(function () {
  // 遷移、ロード時に実行させる
  preview($('#article-text'));

  $('#article-text').on(
    "keyup", function () {
      let sel = $(this)
      preview(sel)
    }
  );
});
