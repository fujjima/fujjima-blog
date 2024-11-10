// markdownをhtmlに変換する
// https://qiita.com/samuraibrass/items/d40d54aa0754692d5439
$(function () {
  marked.setOptions({
    breaks: true,
    langPrefix: '',
    highlight: function (code, lang) {
      return hljs.highlightAuto(code, [lang]).value;
    }
  });

  $('.article-text').each(function (_, val) {
    var text = $(val).text();
    var html = marked.parse(text);
    $(val).html(html);
    // ref) app/webpack/src/stylesheets/articles/index.scss
    //  .article-text
    $(val).css('visibility', 'visible');
  })
});
