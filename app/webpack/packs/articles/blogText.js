// 一般画面用markdownをhtml変換
$(function () {
  marked.setOptions({
    breaks: true,
    langPrefix: '',
    highlight: function (code, lang) {
      return hljs.highlightAuto(code, [lang]).value;
    }
  });
  var markdown = $('#general-articles-text').text();

  var html = marked(markdown)

  $('#general-articles-text').html(html);
});
