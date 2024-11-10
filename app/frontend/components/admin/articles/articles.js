const fullPathWithOutQuery = () => {
  return `${location.protocol}//${location.host}${location.pathname}`
}

$(function () {
  // NOTE: 画面読み込み時にクエリを消去する
  history.replaceState({}, '', fullPathWithOutQuery());

  // TODO: ロードされた段階で、クエリストリングを読んでソート対象のヘッダーに対してアイコンを追加する
  $('.thead-light th.sortable').on('click', (e) => {
    const sortTarget = e.target.textContent
    if (!sortTarget) return;

    let searchParams = new URLSearchParams(window.location.search);
    let sortBy = searchParams.get('sort_by');
    let orderBy = searchParams.get('order');

    if (sortTarget === sortBy) {
      searchParams.set('order', `${orderBy == 'asc' ? 'desc' : 'asc'}`);
      history.replaceState({},
        '',
        `${fullPathWithOutQuery()}?${searchParams.toString()}`
      );
    } else {
      // orderが付いていないパターン（初回 or ソート対象の変更）
      history.replaceState({}, '', `${location.pathname}?sort_by=${sortTarget}&order=asc`)
    }

    // TODO: 任意にajax通信（jsでの書き換えを希望のケース）する時の書き方
    // TODO: ブログ記事
    $.ajax({
      url: window.location.href,
      dataType: 'script'
    })
  })
});
