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
  // ajaxでのリクエストを再現するため、jsを指定する
  // .js.erbでの置換を考える
  axios.defaults.headers.common = {
    'Content-Type': 'application/javascript'
  };

  // 帰ってきた内容でコンテンツ部分を書き換える
  $('.thead-light th.sortable').on('click', (e) => {
    const sortTarget = e.target.textContent
    if (!sortTarget) return;

    // TODO: axiosでsortのgetリクエストを飛ばす
    // 再描画はjs.erb側で行う
    axios.get(`${location.href}/sort`, {
      params: {
        sort: sortTarget
      }
    })
  })
});
