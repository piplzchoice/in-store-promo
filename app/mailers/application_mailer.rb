class ApplicationMailer < ActionMailer::Base
  default from: "from@example.com"

  def welcome_email(email, fullname, password)
    @email = email
    @password = password
    mail(to: email, subject: 'Welcome to In Store Marketing')
  end

  def reset_password(email, fullname, password)
    @email = email
    @password = password
    mail(to: email, subject: 'Your new password')
  end  
end
