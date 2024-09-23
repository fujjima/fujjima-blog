import Tagify from '@yaireo/tagify'
import '@yaireo/tagify/dist/tagify.css'

import '@/stylesheets/admin/tags/tags.scss';

$(function () {
  let input = document.querySelector('textarea[name=tags]')

  // タグの候補をリスト表示させたい場合、view側でdata-tagに値を設定しておく
  let tags = $('#tag-area').data('tag')
  let tagify = new Tagify(input, {
    originalInputValueFormat: values => values.map(item => item.value),
    whitelist: tags,
    dropdown: {
      classname: "tags-look",
      enabled: 0,
      closeOnSelect: false
    }
  });
});
