module Taggable
  extend ActiveSupport::Concern
  extend Memoist

  # 呼び出し元にタグ一覧を返すhelper_methodを定義しておく
  included do
    helper_method :load_tags
  end

  def load_tags
      all_tags = Tag.all.to_a
      # その他タグを配列の最後尾に並び直す
      all_tags.partition{ |tag| tag.name != 'その他' }.flatten
  end
  memoize :load_tags

  # params内のタグ名は","区切りの文字列
  def tag_names_to_ary(str)
    str.empty? ? [] : str.split(',')
  end

  def from_tag_names_ary_to_tag_instances_ary(tag_names_array)
    Tag.where(name: tag_names_array)
  end
end
