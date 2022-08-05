class AcquisitionsMailer < ApplicationMailer
  helper ItemsHelper
  helper RequestsHelper

  def send_acquisition_request(acquisition_request, current_user, email_address)
    @template = Liquid::Template.parse(Setting.email_acquisitions_body)

    @acquisition_request = acquisition_request
    @item = acquisition_request.item
    @request = @item.request
    @course = @request.course
    @user = current_user

    if Setting.email_allow && !Setting.email_acquisitions_to.blank?
      mail to: email_address, cc: current_user.email, subject: Setting.email_acquisitions_subject
    end
  end
end
