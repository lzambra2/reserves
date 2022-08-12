# frozen_string_literal: true

require 'test_helper'

class RequestMailerTest < ActionMailer::TestCase
  test 'new_item_notification location email' do
    Setting.email_allow = true
    user = create(:user)
    request = create(:request)
    request.location.setting_bcc_location_on_new_item = true
    item = create(:item, request: request)

    mail = RequestMailer.new_item_notification(request, item).deliver_now
    assert !ActionMailer::Base.deliveries.empty?, "Shouldn't be empty"

    assert_equal 'New Item Has Been Added To A Request', mail.subject
    assert_equal [request.location.contact_email], mail.to
  end

  test 'status_change that sends an email to current user' do
    Setting.email_allow = true
    user = create(:user)
    request = create(:request)

    mail = RequestMailer.status_change(request, user).deliver_now
    assert !ActionMailer::Base.deliveries.empty?, "Shouldn't be empty"

    assert_equal Setting.email_status_change_subject, mail.subject
    assert_equal [request.requester.email], mail.to
    assert_equal [request.reserve_location.contact_email], mail.from
  end

  test "status_change that sends an email to requester email if it's set" do
    Setting.email_allow = true
    user = create(:user)
    request = create(:request, requester_email: 'requester@requester.com')

    mail = RequestMailer.status_change(request, user).deliver_now
    assert !ActionMailer::Base.deliveries.empty?, "Shouldn't be empty"

    assert_equal [request.requester_email], mail.to
  end

  should 'not set email if allow email is false' do
    Setting.email_allow = false
    user = create(:user)
    request = create(:request)

    RequestMailer.status_change(request, user).deliver_now
    assert ActionMailer::Base.deliveries.empty?, 'Should be empty'

    Setting.email_allow = true
  end

  should 'not send email if requester_email or request.requester.email are blank' do
    Setting.email_allow = true
    user = create(:user)
    request = create(:request, requester: user)
    request.update(requester_email: nil)
    user.update(email: nil)

    assert_nil user.email, 'Email should be nil'
    assert_nil request.requester_email, 'Should be nil as well'

    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      RequestMailer.status_change(request, user).deliver_now
    end
  end

  should 'send expiry notices to both emails of request' do
    # Setting.email_allow = true

    user = create(:user)
    request = create(:request, requester: user)
    request.update(requester_email: 'test@test.com')

    mail = RequestMailer.expiry_notice(request, nil)
    assert_equal 2, mail.to.size, 'Should be two emails'
    assert_equal [request.requester_email, request.requester.email], mail.to, 'Should be those two emails'
  end

  should 'Send a bcc email to current user if location has that setting enabled' do
    loc = create(:location)
    request = create(:request, reserve_location: loc)
    user = create(:user)

    loc.setting_bcc_request_status_change = false
    loc.save
    mail = RequestMailer.status_change(request, user)
    assert_equal 0, mail.bcc.size, 'Should be no emails in BCC'

    loc.setting_bcc_request_status_change = true
    loc.save
    mail = RequestMailer.status_change(request, user)
    assert_equal 1, mail.bcc.size, 'Should be one email'
    assert_equal user.email, mail.bcc.first, 'Emails should match'
  end
end
