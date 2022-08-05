class UserMailer < ApplicationMailer
  default from: Setting.email_from

  def welcome(user)
    @template = Liquid::Template.parse(Setting.email_welcome_body)  # Parses and compiles the template

    ## setup variables
    @date = Date.today.strftime('%b %e, %Y')
    @date_short = Date.today.strftime('%m-%d-%Y')
    @requestor_name = user.name
    @all_locations = Location.active.collect { |l| l.name }.join(', ')
    @application_url = root_url

    mail to: user.email, subject: Setting.email_welcome_subject if Setting.email_allow && !user.email.nil?
  end
end
