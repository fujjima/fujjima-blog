const axios = require('axios');

// TODO: getリクエストなので不要かもしれない
// csrf対策通過用にaxiosにheaderを設定する
// const setAxiosHeader = () => {
//   axios.defaults.headers.common = {
//     'X-Requested-With': 'XMLHttpRequest',
//     'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
//     'Content-Type': 'application/json'
//   }
// }


$(function () {
  // 帰ってきた内容でコンテンツ部分を書き換える
  $('.thead-light th.sortable').on('click', (e) => {
    // TODO: クリックしたheader要素をソート対象とする
    const sortTarget = e.target.textContent
    if (!sortTarget) return;

    // TODO: axiosでsortのgetリクエストを飛ばす
    axios.get(`${location.href}/sort`, {
      params: {
        sort: sortTarget
      }
    }).then(response => {
      console.log(response);
    });
  })
});
