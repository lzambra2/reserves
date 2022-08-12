# frozen_string_literal: true

class RequestMailer < ApplicationMailer
  default from: Setting.email_from

  def new_item_notification(request, item)
    return if request.nil? || request.location.nil?

    @request = request
    @item = item
    @location_email = request.reserve_location.contact_email
    if Setting.email_allow == true && request.location.setting_bcc_location_on_new_item
      mail to: @location_email, subject: 'New Item Has Been Added To A Request'
    end
  end

  def status_change(request, current_user)
    @template = Liquid::Template.parse(Setting.email_status_change_body) # Parses and compiles the template

    ## setup variables
    @date = Date.today.strftime('%b %e, %Y')
    @date_short = Date.today.strftime('%m-%d-%Y')
    @requestor_name = request.requester.name
    @application_url = root_url

    @current_user_email = current_user.email
    @current_user_name = current_user.name
    @status = request.status
    @course_name = request.course.name
    @location_name = request.reserve_location.name
    @location_email = request.reserve_location.contact_email
    @request_url = request_url(request)
    @all_locations = Location.active.collect(&:name).join(', ')

    @request_comm_email = if request.requester_email.blank?
                            request.requester.email
                          else
                            request.requester_email
                          end

    bcc = []
    bcc << current_user.email if request.reserve_location.setting_bcc_request_status_change

    if Setting.email_allow == true && !@request_comm_email.blank?
      mail to: @request_comm_email, from: @location_email, bcc: bcc, subject: Setting.email_status_change_subject
    end
  end

  def expiry_notice(request, current_user = nil)
    # parses the expiry notice template
    @template = Liquid::Template.parse(Setting.email_request_expiry_notice_body)

    ## setup variables
    @date = Date.today.strftime('%b %e, %Y')
    @date_short = Date.today.strftime('%m-%d-%Y')
    @requestor_name = request.requester.name
    @application_url = root_url

    @current_user_email = current_user.email if current_user
    @current_user_name = current_user.name if current_user

    @status = request.status
    @course_name = request.course.name
    @location_name = request.reserve_location.name
    @location_email = request.reserve_location.contact_email
    @request_url = request_url(request)
    @rollover_url = rollover_confirm_request_url(request)
    @all_locations = Location.active.collect(&:name).join(', ')

    @request_comm_email = if request.requester_email.blank?
                            request.requester.email
                          else
                            [request.requester_email, request.requester.email]
                          end

    if Setting.email_allow == true && !@request_comm_email.blank?
      mail to: @request_comm_email, from: @location_email, subject: Setting.email_request_expiry_notice_subject
    end
  end
end
