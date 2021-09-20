const axios = require('axios');

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

// csrf対策通過用にaxiosにheaderを設定する
const setAxiosHeader = () => {
  axios.defaults.headers.common = {
    'X-Requested-With': 'XMLHttpRequest',
    'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
    'Content-Type': 'application/json'
  }
}

const replacedImageUrl = ({ title = '', id = '' }) => {
  return `![${title}](https://drive.google.com/uc?export=view&id=${id})`
}

// insertedText: 挿入したいテキスト
const insertImageUrlIntoTextarea = (insertedText) => {
  const textarea = document.getElementById('article-text')
  let sentence = textarea.value
  let len = sentence.length
  let pos = textarea.selectionStart

  let before = sentence.substr(0, pos)
  let after = sentence.substr(pos, len)
  sentence = before + insertedText + after

  // MEMO: textarea内の文章の置き換え
  textarea.value = sentence
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

  // ファイル（画像のみ）を検知、バックにaxios等でリクエストを送信する
  $('#article-text').on("drop", function (e) {
    e.preventDefault()
    f = e.originalEvent.dataTransfer.files[0];
    let formData = new FormData();
    formData.append('image', f);
    setAxiosHeader()

    axios.post(`${location.origin}/admin/articles/upload_image`, formData)
      .then(response => {
        // response.data内に、"https://drive.google.com/file/d/1JQYr8ruFUdmWNFsSw7zCgckOgGJP1C0G/view?usp=drivesdk"のようなデータが入っている
        if (!response.data) returns
        const id = response.data.id
        const title = response.data.title
        const imageUrl = replacedImageUrl({ title: title, id: id })
        insertImageUrlIntoTextarea(imageUrl)
      })
  });
});
