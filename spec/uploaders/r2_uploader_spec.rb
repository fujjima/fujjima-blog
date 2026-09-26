require 'rails_helper'

RSpec.describe Uploader::R2Uploader do
  include ActiveSupport::Testing::TimeHelpers

  let(:config) do
    {
      account_id: 'test-account-id',
      access_key_id: 'test-access-key-id',
      secret_access_key: 'test-secret-access-key',
      bucket: 'test-bucket',
      public_base_url: 'https://images.example.com'
    }
  end
  # NOTE: stub_responses: true なので実際の通信は行わず、api_requests に記録されるだけ
  let(:client) { Aws::S3::Client.new(stub_responses: true, region: 'auto') }
  let(:uploader) { described_class.new(file:, client:, config:) }

  # NOTE: Marcel はマジックバイトのみで判定するため、先頭バイトだけ実物に合わせたダミーデータで十分
  let(:png_bytes)  { "\x89PNG\r\n\x1a\n".b + ('x' * 16) }
  let(:jpeg_bytes) { "\xFF\xD8\xFF\xE0\x00\x10JFIF\x00".b + ('x' * 16) }
  let(:gif_bytes)  { 'GIF89a'.b + ('x' * 16) }
  let(:webp_bytes) { "RIFF\x00\x00\x00\x00WEBP".b + ('x' * 16) }

  def build_uploaded_file(content, filename:, content_type:)
    tempfile = Tempfile.new(['upload', File.extname(filename)])
    tempfile.binmode
    tempfile.write(content)
    tempfile.rewind
    ActionDispatch::Http::UploadedFile.new(tempfile:, filename:, type: content_type)
  end

  before { travel_to Time.zone.local(2026, 9, 22, 10, 0, 0) }
  after { travel_back }

  describe '#upload!' do
    subject { uploader.upload! }

    context 'png ファイルの場合' do
      let(:file) { build_uploaded_file(png_bytes, filename: 'sample.png', content_type: 'image/png') }

      it 'articles/YYYY/MM/<hex>.<ext> のキーで R2 に put_object し、公開 URL を返すこと' do
        url = subject

        request = client.api_requests.first
        expect(request[:operation_name]).to eq :put_object
        expect(request[:params][:bucket]).to eq 'test-bucket'
        expect(request[:params][:key]).to match(%r{\Aarticles/2026/09/\h{32}\.png\z})
        expect(request[:params][:content_type]).to eq 'image/png'
        expect(request[:params][:cache_control]).to eq 'public, max-age=31536000, immutable'
        expect(request[:params][:body]).to eq file.tempfile

        expect(url).to eq "https://images.example.com/#{request[:params][:key]}"
      end

      it '元のファイル名をキーに含めないこと' do
        subject

        expect(client.api_requests.first[:params][:key]).not_to include 'sample'
      end
    end

    context 'jpeg ファイルの場合' do
      let(:file) { build_uploaded_file(jpeg_bytes, filename: 'photo.jpeg', content_type: 'application/octet-stream') }

      it 'ファイル名や Content-Type ではなく中身から判定した拡張子（jpg）とタイプを使うこと' do
        subject

        request = client.api_requests.first
        expect(request[:params][:key]).to end_with '.jpg'
        expect(request[:params][:content_type]).to eq 'image/jpeg'
      end
    end

    context 'gif ファイルの場合' do
      let(:file) { build_uploaded_file(gif_bytes, filename: 'anime.gif', content_type: 'image/gif') }

      it 'アップロードできること' do
        expect(subject).to match(%r{\Ahttps://images\.example\.com/articles/2026/09/\h{32}\.gif\z})
      end
    end

    context 'webp ファイルの場合' do
      let(:file) { build_uploaded_file(webp_bytes, filename: 'photo.webp', content_type: 'image/webp') }

      it 'アップロードできること' do
        expect(subject).to match(%r{\Ahttps://images\.example\.com/articles/2026/09/\h{32}\.webp\z})
      end
    end

    context 'public_base_url の末尾にスラッシュがある場合' do
      let(:config) { super().merge(public_base_url: 'https://images.example.com/') }
      let(:file) { build_uploaded_file(png_bytes, filename: 'sample.png', content_type: 'image/png') }

      it 'スラッシュが重複しないこと' do
        expect(subject).to match(%r{\Ahttps://images\.example\.com/articles/})
      end
    end

    context '拡張子と Content-Type を画像に偽装したテキストファイルの場合' do
      let(:file) { build_uploaded_file("hello world\n", filename: 'evil.png', content_type: 'image/png') }

      it 'ValidationError になり、R2 にリクエストしないこと' do
        expect { subject }.to raise_error(described_class::ValidationError, /対応していないファイル形式/)
        expect(client.api_requests).to be_empty
      end
    end

    context 'svg ファイルの場合' do
      let(:file) { build_uploaded_file('<svg xmlns="http://www.w3.org/2000/svg"></svg>', filename: 'icon.svg', content_type: 'image/svg+xml') }

      it 'ValidationError になること' do
        expect { subject }.to raise_error(described_class::ValidationError, /対応していないファイル形式/)
      end
    end

    context 'サイズ上限を超えている場合' do
      let(:file) { build_uploaded_file(png_bytes, filename: 'sample.png', content_type: 'image/png') }

      before { stub_const('Uploader::R2Uploader::MAX_FILE_SIZE', png_bytes.bytesize - 1) }

      it 'ValidationError になり、R2 にリクエストしないこと' do
        expect { subject }.to raise_error(described_class::ValidationError, /ファイルサイズ/)
        expect(client.api_requests).to be_empty
      end
    end

    context 'ファイルではなく文字列が渡された場合' do
      let(:file) { 'not a file' }

      it 'ValidationError になること' do
        expect { subject }.to raise_error(described_class::ValidationError, /ファイルが指定されていません/)
      end
    end
  end

  describe 'S3 クライアントの設定' do
    let(:file) { build_uploaded_file(png_bytes, filename: 'sample.png', content_type: 'image/png') }
    let(:uploader) { described_class.new(file:, config:) }

    it 'credentials の値から R2 向けのクライアントを組み立てること' do
      client_config = uploader.client.config

      expect(client_config.endpoint.to_s).to eq 'https://test-account-id.r2.cloudflarestorage.com'
      expect(client_config.region).to eq 'auto'
      expect(client_config.credentials.access_key_id).to eq 'test-access-key-id'
      expect(client_config.credentials.secret_access_key).to eq 'test-secret-access-key'
      expect(client_config.request_checksum_calculation).to eq 'when_required'
      expect(client_config.response_checksum_validation).to eq 'when_required'
    end
  end
end
