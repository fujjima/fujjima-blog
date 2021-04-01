class Admin::TagsController < AdminController
  include Taggable

  def index
    @tag_names = all_tag_names
  end

  def update
    tag_names = tag_names_to_ary(tag_params)

    new_tag_names = tag_names - all_tag_names
    delete_tag_names = all_tag_names - tag_names
    ActiveRecord::Base.transaction do
      new_tag_names.present? && Tag.insert_new_tag(new_tag_names)
      # TODO: destroy_allでは例外を発生できないので、例外を検出したいなら別の方法で
      Tag.where(name: delete_tag_names).destroy_all
    end
    redirect_to admin_tags_url, notice: 'seucessed to update'
  end

  private

  def tag_params
    params.require(:tags)
  end

  def all_tag_names
    Tag.pluck(:name)
  end

  def tags_to_hash(ary)
    ary.map do |val|
      {"name": val, created_at: Time.current, updated_at: Time.current}
    end
  end
end
