require 'rails_helper'

RSpec.describe ArticleExcerpt do
  subject(:excerpt) { described_class.new(text, length:) }

  let(:length) { 20 }

  context '本文が上限以下の場合' do
    let(:text) { "# 見出し\n\n短い本文です。" }

    it '本文をそのまま返し、省略なしとすること' do
      expect(excerpt.text).to eq text
      expect(excerpt).not_to be_truncated
    end
  end

  context '本文が空の場合' do
    let(:text) { nil }

    it '空文字を返すこと' do
      expect(excerpt.text).to eq ''
      expect(excerpt).not_to be_truncated
    end
  end

  context '改行コードが CRLF の場合' do
    let(:text) { "一段落目\r\n\r\n二段落目" }

    it 'ブロックを正しく分割すること' do
      expect(excerpt.text).to eq "一段落目\n\n二段落目"
    end
  end

  context '上限を超える場合' do
    let(:text) { "一段落目の文章です。\n\n二段落目の文章です。\n\n三段落目の文章です。" }

    it '上限に達したブロックまでで切り、省略ありとすること' do
      expect(excerpt.text).to eq "一段落目の文章です。\n\n二段落目の文章です。"
      expect(excerpt).to be_truncated
    end
  end

  context '1 つの段落が上限を超える場合' do
    let(:text) { '一文目はここまでです。二文目はここまでです。三文目はここまでです。' }

    it '上限に達した位置以降の最初の句点で切ること' do
      expect(excerpt.text).to eq '一文目はここまでです。二文目はここまでです。'
      expect(excerpt).to be_truncated
    end
  end

  context '段落内に改行がある場合' do
    let(:length) { 13 }
    let(:text) { "一行目です。\n二行目です。\n三行目です。\n四行目です。" }

    it '上限に達した行までで切ること' do
      expect(excerpt.text).to eq "一行目です。\n二行目です。\n三行目です。"
      expect(excerpt).to be_truncated
    end
  end

  context '最後のブロックの最終行でちょうど上限を超える場合' do
    let(:length) { 7 }
    let(:text) { "一行目です。\n二行目です。" }

    it '本文をすべて含む場合は省略なしとすること' do
      expect(excerpt.text).to eq text
      expect(excerpt).not_to be_truncated
    end
  end

  context 'リストが上限を超える場合' do
    let(:length) { 10 }
    let(:text) { "- 項目その一\n- 項目その二\n- 項目その三" }

    it '行単位で切ること' do
      expect(excerpt.text).to eq "- 項目その一\n- 項目その二"
      expect(excerpt).to be_truncated
    end
  end

  context '画像・リンクを含む場合' do
    let(:text) { "![画像](https://images.example.com/articles/2026/10/very-long-file-name.png)\n\n[リンク](https://example.com/very/long/path)の説明" }

    it 'URL や記法の記号を文字数に含めないこと' do
      expect(excerpt.text).to eq text
      expect(excerpt).not_to be_truncated
    end
  end

  context '画像が複数ある場合' do
    let(:text) { "![a](https://example.com/a.png)\n\n本文\n\n![b](https://example.com/b.png)\n\n本文 ![c](https://example.com/c.png) 続き" }

    it '最初の 1 枚のみ残し、省略ありとすること' do
      expect(excerpt.text).to eq "![a](https://example.com/a.png)\n\n本文\n\n本文  続き"
      expect(excerpt).to be_truncated
    end
  end

  context 'コードブロックが上限を超える場合' do
    let(:length) { 10 }
    let(:text) { "```ruby\nputs 'a'\n\nputs 'b'\nputs 'c'\n```\n\n後書き" }

    it 'コードブロック内の空行では区切らず、閉じフェンスを補って切ること' do
      expect(excerpt.text).to eq "```ruby\nputs 'a'\n\nputs 'b'\n```"
      expect(excerpt).to be_truncated
    end
  end

  context 'コードブロック内に画像記法がある場合' do
    let(:text) { "![a](https://example.com/a.png)\n\n```\n![b](https://example.com/b.png)\n```" }

    it 'コードブロック内は画像として扱わないこと' do
      expect(excerpt.text).to eq text
    end
  end

  context '段落の直後に空行なしでコードブロックが続く場合' do
    let(:length) { 5 }
    let(:text) { "前置き\n```\ncode line one\ncode line two\n```" }

    it 'コードブロックを独立したブロックとして扱うこと' do
      expect(excerpt.text).to eq "前置き\n\n```\ncode line one\n```"
    end
  end
end
