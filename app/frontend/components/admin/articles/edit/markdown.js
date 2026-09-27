// 記事編集画面の markdown プレビューと画像のドラッグ&ドロップ
//
// 画像はドロップした時点ではアップロードしない。
//   1. ドロップ時: UUID を発行して本文に `![name](upload://<uuid>)` を挿入し、File はメモリ上に保持する
//   2. プレビュー: `upload://<uuid>` をブラウザ内の blob URL に差し替えて表示する
//   3. 保存時: 本文に残っている uuid のファイルだけを `article_images[<uuid>]` としてフォームに載せる
// サーバ側（ArticleImageAttacher）が R2 へアップロードし、公開 URL に置換してから保存する。

const TEXTAREA_ID = 'admin-article-text'
const FORM_ID = 'admin-article-form'
const PREVIEW_ID = 'markdown-preview'
const IMAGE_FIELD_NAME = 'article_images'
const PLACEHOLDER_PATTERN = /upload:\/\/([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})/gi

// uuid => { file, objectUrl }
const pendingImages = new Map()

const generateToken = () => {
  if (window.crypto?.randomUUID) return window.crypto.randomUUID()
  // 非セキュアコンテキスト向けのフォールバック
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) => {
    const r = (Math.random() * 16) | 0
    return (c === 'x' ? r : (r & 0x3) | 0x8).toString(16)
  })
}

// プレビュー用に、未アップロード画像のプレースホルダを blob URL へ差し替える
const resolvePlaceholders = (text) => {
  return text.replace(PLACEHOLDER_PATTERN, (match, token) => {
    const pending = pendingImages.get(token.toLowerCase())
    return pending ? pending.objectUrl : match
  })
}

// マークダウンをプレビュー画面に表示する
const preview = function (sel) {
  marked.setOptions({
    breaks: true,
    langPrefix: '',
    highlight: function (code, lang) {
      return hljs.highlightAuto(code, [lang]).value;
    }
  });
  let html = marked.parse(resolvePlaceholders(sel.val()));
  $(`#${PREVIEW_ID}`).html(html);
}

// テキストエリア内の内容をプレビュー画面に反映する
const updatePreview = () => preview($(`#${TEXTAREA_ID}`))

const imagePlaceholder = ({ title = '', token = '' }) => {
  return `![${title}](upload://${token})`
}

// insertedText: 挿入したいテキスト
const insertTextIntoTextarea = (insertedText) => {
  const textarea = document.getElementById(TEXTAREA_ID)
  let sentence = textarea.value
  let len = sentence.length
  let pos = textarea.selectionStart

  let before = sentence.substr(0, pos)
  let after = sentence.substr(pos, len)
  sentence = before + insertedText + after

  // MEMO: textarea内の文章の置き換え
  textarea.value = sentence
  textarea.selectionStart = textarea.selectionEnd = pos + insertedText.length
}

// ドロップされた画像をメモリに保持し、本文にプレースホルダを挿入する
const addPendingImage = (file) => {
  const token = generateToken()
  pendingImages.set(token, { file, objectUrl: URL.createObjectURL(file) })
  insertTextIntoTextarea(imagePlaceholder({ title: file.name, token }))
}

// 本文中に残っているプレースホルダの uuid 一覧
const referencedTokens = (text) => {
  const tokens = new Set()
  for (const match of text.matchAll(PLACEHOLDER_PATTERN)) {
    tokens.add(match[1].toLowerCase())
  }
  return tokens
}

// 保存時: 本文で参照されている画像だけを hidden な file input としてフォームに載せる
const attachPendingImagesToForm = (form) => {
  form.querySelectorAll(`input[type="file"][data-pending-image]`).forEach((input) => input.remove())

  const text = document.getElementById(TEXTAREA_ID).value
  referencedTokens(text).forEach((token) => {
    const pending = pendingImages.get(token)
    if (!pending) return

    const dataTransfer = new DataTransfer()
    dataTransfer.items.add(pending.file)

    const input = document.createElement('input')
    input.type = 'file'
    input.name = `${IMAGE_FIELD_NAME}[${token}]`
    input.hidden = true
    input.dataset.pendingImage = token
    input.files = dataTransfer.files
    form.appendChild(input)
  })
}

$(function () {
  // 遷移、ロード時に実行させる
  updatePreview();

  $(`#${TEXTAREA_ID}`).on(
    "keyup", function () {
      updatePreview()
    }
  );

  // ファイル（画像のみ）を検知し、プレースホルダを挿入してプレビューに表示する
  $(`#${TEXTAREA_ID}`).on("drop", function (e) {
    e.preventDefault()
    const files = Array.from(e.originalEvent.dataTransfer.files || [])
    if (files.length === 0) return;

    const rejected = []
    files.forEach((file) => {
      if (file.type.startsWith('image/')) {
        addPendingImage(file)
      } else {
        rejected.push(file.name)
      }
    })
    updatePreview()

    if (rejected.length > 0) {
      alert(`画像ファイルのみドロップできます: ${rejected.join(', ')}`)
    }
  });

  // 保存時に画像ファイルをフォームへ載せる
  $(`#${FORM_ID}`).on("submit", function () {
    attachPendingImagesToForm(this)
  });
});
