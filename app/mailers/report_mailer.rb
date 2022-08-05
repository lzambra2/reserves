class ReportMailer < ApplicationMailer
  default from: Setting.email_from

  def mail_report(who, subject, report)
    mail(to: who, subject: subject, body: report)
  end
end
