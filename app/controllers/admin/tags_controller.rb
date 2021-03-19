class Admin::TagsController < AdminController

  def index
    @tags_name = Tag.pluck(:name)
  end

  def update
  end

  private

  # タグ更新時、作成時など、基本は[str, str]のように配列でくることが予想される
  def tags_params
  end
end
