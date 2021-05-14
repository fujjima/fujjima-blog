// 一般画面用markdownをhtml変換
$(function () {
  marked.setOptions({
    breaks: true,
    langPrefix: '',
    highlight: function (code, lang) {
      return hljs.highlightAuto(code, [lang]).value;
    }
  });

  $('.article-text').each(function (index, val) {
    var text = $(val).text();
    var html = marked(text);
    $(val).html(html);
  })
});
