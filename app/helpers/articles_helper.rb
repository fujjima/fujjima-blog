module ArticlesHelper
  
  def join_with_comma strs = []
    return '' if strs.empty?

    strs.join(', ')
  end
end
