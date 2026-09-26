require 'rails_helper'

RSpec.describe ArticleImageAttacher do
  let(:token) { 'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c5d' }
  let(:other_token) { 'ffffffff-1111-4222-8333-444444444444' }
  let(:file) { build_uploaded_file('sample.png') }
  let(:other_file) { build_uploaded_file('other.png') }
  let(:uploader_class) { class_double(Uploader::R2Uploader) }
  let(:uploader) { instance_double(Uploader::R2Uploader, upload!: 'https://images.example.com/articles/2026/09/abc.png') }

  def build_uploaded_file(filename)
    tempfile = Tempfile.new(['upload', '.png'])
    tempfile.binmode
    tempfile.write("\x89PNG\r\n\x1a\n".b)
    tempfile.rewind
    ActionDispatch::Http::UploadedFile.new(tempfile:, filename:, type: 'image/png')
  end

  before { allow(uploader_class).to receive(:new).and_return(uploader) }

  subject(:call) { described_class.new(text:, images:, uploader_class:).call }

  context 'プレースホルダとファイルが対応している場合' do
    let(:text) { "前置き\n![sample.png](upload://#{token})\n後書き" }
    let(:images) { { token => file } }

    it 'アップロードして公開 URL に置換すること' do
      expect(call).to eq "前置き\n![sample.png](https://images.example.com/articles/2026/09/abc.png)\n後書き"
      expect(uploader_class).to have_received(:new).with(file:)
    end
  end

  context '同じプレースホルダが複数回登場する場合' do
    let(:text) { "![a](upload://#{token}) ![b](upload://#{token.upcase})" }
    let(:images) { { token => file } }

    it '1 回だけアップロードし、両方を置換すること' do
      expect(call).to eq '![a](https://images.example.com/articles/2026/09/abc.png) ![b](https://images.example.com/articles/2026/09/abc.png)'
      expect(uploader).to have_received(:upload!).once
    end
  end

  context '本文で参照されていないファイルが送られてきた場合' do
    let(:text) { "![a](upload://#{token})" }
    let(:images) { { token => file, other_token => other_file } }

    it '参照されているものだけアップロードすること' do
      call

      expect(uploader_class).to have_received(:new).with(file:).once
      expect(uploader_class).not_to have_received(:new).with(file: other_file)
    end
  end

  context 'プレースホルダが無い場合' do
    let(:text) { '画像なしの本文 https://example.com/foo.png' }
    let(:images) { { token => file } }

    it '本文をそのまま返し、アップロードしないこと' do
      expect(call).to eq text
      expect(uploader_class).not_to have_received(:new)
    end
  end

  context 'プレースホルダに対応するファイルが無い場合' do
    let(:text) { "![a](upload://#{token})" }
    let(:images) { {} }

    it 'MissingImageError を投げること' do
      expect { call }.to raise_error(described_class::MissingImageError, /upload:\/\/#{token}/)
    end
  end

  context 'text が nil の場合' do
    let(:text) { nil }
    let(:images) { {} }

    it '空文字を返すこと' do
      expect(call).to eq ''
    end
  end
end
