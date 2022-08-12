# frozen_string_literal: true

require 'test_helper'

class AcquisitionsMailerTest < ActionMailer::TestCase
  should 'send_acquisition_request' do
    Setting.email_allow = true
    user = create(:user)
    r = create(:acquisition_request)

    mail = AcquisitionsMailer.send_acquisition_request(r, user, Setting.email_acquisitions_to).deliver_now
    assert !ActionMailer::Base.deliveries.empty?, "Shouldn't be empty"

    assert_equal [Setting.email_acquisitions_to], mail.to
    assert_equal Setting.email_acquisitions_subject, mail.subject
  end

  should 'send to multiple emails if they are specified' do
    emails = ['acq@me.ca', 'acq2@me.ca']

    Setting.email_allow = true
    Setting.email_acquisitions_to = emails.join(', ')
    user = create(:user)
    r = create(:acquisition_request)

    mail = AcquisitionsMailer.send_acquisition_request(r, user, emails).deliver_now
    assert_equal emails, mail.to

    Setting.email_acquisitions_to = 'acq@me.ca'
  end

  should 'send to bookstore email if bookstore is set to true' do
    Setting.email_allow = true
    user = create(:user)
    r = create(:acquisition_request)

    mail = AcquisitionsMailer.send_acquisition_request(r, user, Setting.email_acquisitions_to_bookstore).deliver_now
    assert !ActionMailer::Base.deliveries.empty?, "Shouldn't be empty"

    assert_equal [Setting.email_acquisitions_to_bookstore], mail.to
  end
end
