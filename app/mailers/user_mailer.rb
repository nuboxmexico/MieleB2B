class UserMailer < ApplicationMailer
  def welcome_mail(user)
    @user      = user
    mail to: @user.email , subject: "Bienvenido a Miele Portal de Partners"
  end

  def report_notification_sync_with_core(subject, email, response_sync)
    @message = response_sync[:message]
    @errors = response_sync[:errors]
    mail(to: email, subject: subject)
  end
end
