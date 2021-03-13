class AdminController < ApplicationController
  layout 'admin'

  private

  def not_authenticated
    redirect_to '/admin/login'
  end
end
