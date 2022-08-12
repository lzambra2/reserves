# frozen_string_literal: true

require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  should 'Send a welcome email' do
    Setting.email_allow = true
    user = create(:user)

    mail = UserMailer.welcome(user).deliver_now
    assert !ActionMailer::Base.deliveries.empty?, "Shouldn't be empty"

    assert_equal Setting.email_welcome_subject, mail.subject
    assert_equal [user.email], mail.to
    assert_equal [Setting.email_from], mail.from

    # template = Liquid::Template.parse(Setting.email_welcome_body)
    # output = template.render('requestor_name' => user.name, 'date' => Date.today.strftime("%b %e, %Y"), 'date-short' => Date.today.strftime("%m-%d-%Y"), 'application_url' => root_url)

    # assert_match output, mail.body.encoded
  end

  should 'not set email if allow email is false' do
    Setting.email_allow = false
    user = create(:user)

    UserMailer.welcome(user).deliver_now
    assert ActionMailer::Base.deliveries.empty?, 'Should be empty'

    Setting.email_allow = true
  end
end
