module Taggable
  extend ActiveSupport::Concern

  included do
  end

  class_methods do
  end

  # params内のタグ名は","区切りの文字列
  def tag_names_to_ary(str)
    str.empty? ? [] : str.split(',')
  end

  def from_tag_names_ary_to_tag_instances_ary(tag_names_ary)
    Tag.where(name: tag_names_ary)
  end
end
