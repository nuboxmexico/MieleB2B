class ApplicationMailer < ActionMailer::Base
  default from: "Miele Customers <#{Rails.application.secrets.mailer_user}>"
  layout 'mailer'
end
