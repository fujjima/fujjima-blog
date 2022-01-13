$(function () {

  // 帰ってきた内容でコンテンツ部分を書き換える
  $('.thead-light th.sortable').on('click', (e) => {
    const sortTarget = e.target.textContent
    if (!sortTarget) return;

    // TODO: ajaxでsortのgetリクエストを飛ばす
    $.get(`${location.href}/sort`, { sort: sortTarget })
  })
});
