// tagify用
import 'src/stylesheets/admin/tags/index.scss';

$(function () {
  let input = document.querySelector('textarea[name=tags]')
  let tagify = new Tagify(input, {
    originalInputValueFormat: values => values.map(item => item.value),
    whitelist: []
  });

  // $('form').submit(function () {
  // });
});
