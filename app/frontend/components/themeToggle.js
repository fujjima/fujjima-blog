// ダーク / ライトテーマの切り替え
// NOTE: 初期テーマは layouts/application.html.haml の head 内で設定している
document.addEventListener('DOMContentLoaded', () => {
  const button = document.querySelector('.theme-toggle');
  if (!button) return;

  button.addEventListener('click', () => {
    const root = document.documentElement;
    const next = root.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
    root.setAttribute('data-theme', next);
    try {
      localStorage.setItem('theme', next);
    } catch (e) {
      // プライベートブラウズ等で保存できない場合は今回の表示のみ切り替える
    }
  });
});
