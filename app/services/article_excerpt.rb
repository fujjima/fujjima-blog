# ------------------------------------------------------------

# 記事一覧に表示する抜粋（markdown）を生成する
#
# markdown を文字数で単純に切ると、画像やリンク、コードブロックの記法が途中で
# 壊れてしまうため、空行区切りのブロック単位で先頭から積み上げていく。
# 上限を超えるブロックは行単位（段落中の長い行は句点単位）で切り詰め、
# コードブロックの場合は閉じフェンスを補う。
#
# - 文字数は画像・リンクの URL や記法の記号を除いた「見た目の文字数」で数える
# - 画像は最初の 1 枚のみ残す
#
# 引数
#   text:   記事本文（markdown）
#   length: 抜粋の目安文字数
# 戻り値
#   #text       抜粋した本文（markdown）
#   #truncated? 本文の一部を省略したかどうか

# ------------------------------------------------------------
class ArticleExcerpt
  DEFAULT_LENGTH = 200

  IMAGE_PATTERN = /!\[[^\]]*\]\([^)]*\)/
  LINK_PATTERN = /\[([^\]]*)\]\([^)]*\)/
  FENCE_PATTERN = /\A\s{0,3}(`{3,}|~{3,})/
  BLOCK_MARKER_PATTERN = /^\s*(?:\#{1,6}|>|[-*+]|\d+\.)\s+/
  TABLE_SEPARATOR_PATTERN = /^[\s|:-]+$/
  SENTENCE_END_PATTERN = /[。！？]/

  def initialize(text, length: DEFAULT_LENGTH)
    @source = text.to_s.gsub("\r\n", "\n")
    @length = length
    @truncated = false
    @text = build
  end

  attr_reader :text

  def truncated?
    @truncated
  end

  private

  def build
    remaining = @length
    image_kept = false
    excerpt = []

    blocks.each do |block|
      if remaining <= 0
        @truncated = true
        break
      end

      block, image_kept = drop_extra_images(block, image_kept)
      next if block.strip.empty?

      size = visible_length(block)
      if size <= remaining
        excerpt << block
        remaining -= size
      else
        cut = cut_block(block, remaining)
        excerpt << cut
        @truncated ||= cut != block
        remaining = 0
      end
    end

    excerpt.join("\n\n")
  end

  # 空行区切りでブロックに分割する
  # コードブロックは前後の行と空行なしで続いていても独立したブロックとし、内部の空行では区切らない
  def blocks
    result = []
    current = []
    fence = nil

    @source.each_line(chomp: true) do |line|
      if fence
        current << line
        if line.strip.start_with?(fence)
          fence = nil
          result << current.join("\n")
          current = []
        end
      elsif line.strip.empty?
        result << current.join("\n") if current.any?
        current = []
      else
        if line =~ FENCE_PATTERN
          fence = Regexp.last_match(1)
          result << current.join("\n") if current.any?
          current = []
        end
        current << line
      end
    end
    result << current.join("\n") if current.any?

    result
  end

  # 最初の 1 枚以外の画像を取り除く
  def drop_extra_images(block, image_kept)
    return [block, image_kept] if fenced?(block)

    replaced = block.gsub(IMAGE_PATTERN) do |image|
      if image_kept
        @truncated = true
        ''
      else
        image_kept = true
        image
      end
    end

    [replaced, image_kept]
  end

  def cut_block(block, remaining)
    fenced?(block) ? cut_fenced_block(block, remaining) : cut_lines(block, remaining)
  end

  def cut_fenced_block(block, remaining)
    lines = block.lines(chomp: true)
    opening = lines.first
    fence = opening[FENCE_PATTERN, 1]
    body = lines[1..]
    body = body[0...-1] if body.last&.strip&.start_with?(fence)

    taken = take_within(body, remaining) { |line| line.gsub(/\s/, '').length }
    [opening, *taken, fence].join("\n")
  end

  def cut_lines(block, remaining)
    taken = []

    block.lines(chomp: true).each do |line|
      size = visible_length(line)
      if size < remaining
        taken << line
        remaining -= size
      else
        taken << (paragraph_line?(line) ? cut_at_sentence_end(line, remaining) : line)
        break
      end
    end

    taken.join("\n")
  end

  # 残り文字数に達した位置以降で最初の句点まで切り出す（句点がなければ行全体）
  def cut_at_sentence_end(line, remaining)
    line.to_enum(:scan, SENTENCE_END_PATTERN).each do
      prefix = line[0...Regexp.last_match.end(0)]
      return prefix if visible_length(prefix) >= remaining
    end

    line
  end

  def take_within(lines, remaining)
    taken = []
    lines.each do |line|
      break if remaining <= 0

      taken << line
      remaining -= yield(line)
    end
    taken
  end

  def fenced?(block)
    block.match?(FENCE_PATTERN)
  end

  def paragraph_line?(line)
    !line.match?(BLOCK_MARKER_PATTERN) && !line.lstrip.start_with?('|')
  end

  def visible_length(text)
    text.gsub(IMAGE_PATTERN, '')
        .gsub(LINK_PATTERN, '\1')
        .gsub(FENCE_PATTERN, '')
        .gsub(BLOCK_MARKER_PATTERN, '')
        .gsub(TABLE_SEPARATOR_PATTERN, '')
        .gsub(/[*_`~|]/, '')
        .gsub(/\s/, '')
        .length
  end
end
