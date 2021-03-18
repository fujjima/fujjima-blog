class ArticleTag < ApplicationRecord
  # 記事が削除された際には、削除された記事のidを持つものを軒並み消す
  # カテゴリが削除された際には、削除されたカテゴリのidを持つものを軒並み消す  
end
