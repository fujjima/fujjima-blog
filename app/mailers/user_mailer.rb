class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.activation_needed_email.subject
  #
  def activation_needed_email(user)
    @user = user
    @url  = "http://localhost:3000/admin/users/#{user.activation_token}/activate"
    @greeting = "Hi"

    mail(to: user.email, subject: 'Please Activate')
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.activation_success_email.subject
  #
  def activation_success_email(user)
    @user = user
    @url  = "http://localhost:3000/admin/login"
    @greeting = "Hi"

    mail(to: user.email, subject: 'Your account is now activated')
  end
end
