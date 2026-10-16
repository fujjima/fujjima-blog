// 記事検索（入力に応じて検索結果を表示する）
// NOTE: 検索語は URL の ?q= に反映し、リロード・共有時も同じ結果を表示する
const DEBOUNCE_MS = 300;

document.addEventListener('DOMContentLoaded', () => {
  const input = document.querySelector('.searchbox__input');
  const results = document.querySelector('.search-results');
  if (!input || !results) return;

  let timer = null;
  let controller = null;

  const render = (articles) => {
    results.replaceChildren(
      ...articles.map((article) => {
        const item = document.createElement('li');
        const link = document.createElement('a');
        link.href = article.url;
        link.textContent = article.title;
        item.appendChild(link);
        return item;
      })
    );
  };

  const renderMessage = (message) => {
    const item = document.createElement('li');
    item.className = 'search-results__message';
    item.textContent = message;
    results.replaceChildren(item);
  };

  const updateUrl = (query) => {
    const url = new URL(window.location.href);
    if (query) {
      url.searchParams.set('q', query);
    } else {
      url.searchParams.delete('q');
    }
    window.history.replaceState(null, '', url);
  };

  const search = async () => {
    const query = input.value.trim();
    updateUrl(query);

    controller?.abort();
    if (!query) {
      results.replaceChildren();
      return;
    }

    controller = new AbortController();
    const url = new URL(input.dataset.url, window.location.origin);
    url.searchParams.set('q', query);

    try {
      const response = await fetch(url, {
        headers: { Accept: 'application/json' },
        signal: controller.signal,
      });
      if (!response.ok) throw new Error(response.statusText);

      const articles = await response.json();
      if (articles.length === 0) {
        renderMessage('該当する記事はありません');
      } else {
        render(articles);
      }
    } catch (e) {
      if (e.name === 'AbortError') return;
      renderMessage('検索に失敗しました');
    }
  };

  input.addEventListener('input', () => {
    clearTimeout(timer);
    timer = setTimeout(search, DEBOUNCE_MS);
  });

  if (input.value.trim()) search();
});
