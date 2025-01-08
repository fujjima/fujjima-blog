module ArticlesHelper
  META_TAG_TEXT_MAC_SIZE = 50

  def join_with_comma(strs = [])
    return '' if strs.empty?

    strs.join(', ')
  end

  def extract_text_for_meta_tags(text = '')
    extract_text = ActionView::Base.full_sanitizer
                                   .sanitize(text)
                                   .gsub(/[\r\n]/, '')

    truncate(extract_text, length: META_TAG_TEXT_MAC_SIZE)
  end
end
