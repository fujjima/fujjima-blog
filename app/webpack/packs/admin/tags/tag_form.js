// tagify用
import Tagify from '@yaireo/tagify'
import '@yaireo/tagify/dist/tagify.css'

import 'src/stylesheets/admin/tags/tags.scss';

$(function () {
  let input = document.querySelector('textarea[name=tags]')
  let tagify = new Tagify(input, {
    originalInputValueFormat: values => values.map(item => item.value),
    whitelist: []
  });

  // $('form').submit(function () {
  // });
});
