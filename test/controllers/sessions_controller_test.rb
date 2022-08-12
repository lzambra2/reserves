# frozen_string_literal: true

require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  include Warden::Test::Helpers
  include Devise::Test::IntegrationHelpers
  setup do
    @cas_header = 'HTTP_PYORK_USER'
    @cas_alt_header = 'HTTP_PYORK_CYIN'
  end

  should 'not throw authorization not performed error when using the controller' do
    assert_nothing_raised do
      get login_url
    end
  end

  should 'create a new session information if user logs in' do
    user = create(:user, uid: 'test', admin: true, role: User::MANAGER_ROLE)

    get login_url, headers: { @cas_header.to_s => user.uid }

    assert_equal user.id, session[:user_id]
    assert_redirected_to root_url
    assert_equal 'Logged in!', flash[:notice]
  end

  should 'test redirection to a dashboard if the staff is logged in' do
    staff = create(:user, uid: '123123123', admin: true, role: User::STAFF_ROLE)
    get login_url, headers: { @cas_header.to_s => staff.uid }

    assert_equal staff.id, session[:user_id]
    assert_redirected_to root_url
  end

  should 'test redirection to a requests_user_url if the regulard user is logged in' do
    user = create(:user, uid: '123123123', admin: false)
    get login_url, headers: { @cas_header.to_s => user.uid }

    assert_equal user.id, session[:user_id]
    assert_redirected_to requests_user_url(user)
  end

  should 'redirect to inactive if user is not active' do
    user = create(:user, uid: '123123123', admin: false, active: false)
    get login_url, headers: { @cas_header.to_s =>  user.uid }
    assert_redirected_to inactive_user_url, 'Shold redirect to invalid login url'
  end

  should "NEW USER, redirect to new user signup if user doesn't exist, no email should be sent yet" do
    ActionMailer::Base.deliveries.clear
    get logout_url
    get login_url, headers: { @cas_header.to_s => 'something_or_other', 'HTTP_PYORK_TYPE' => User::FACULTY }
    assert ActionMailer::Base.deliveries.empty?, "Should be empty, since we didn't get any details about user"
    assert_not_nil session[:user_id], 'Make sure user is logged in'

    assert_redirected_to edit_user_url(session[:user_id]), 'Should redirect to edit user page, for brand new user'
  end

  should 'destroy session information when logout is present' do
    get logout_url

    assert_nil session[:user_id]
    assert_redirected_to 'http://www.library.yorku.ca'
  end

  context 'logged in actions' do
    setup do
      @user = create(:user, admin: true, role: User::MANAGER_ROLE)
      log_user_in(@user)
    end

    should 'be able to login as requestor' do
      requestor = create(:user)

      assert_difference('Audited::Audit.count') do
        get login_as_url, params: { who: requestor.id }
        assert_redirected_to requests_user_url(requestor), 'Should be redirected to user'
        assert_equal requestor.id, session[:user_id], 'New user '
        assert_equal @user.id, session[:back_to_id], 'Record where to return back to'
      end
    end

    should 'not be able to login as staff user' do
      staff_user = create(:user, admin: true, role: User::MANAGER_ROLE)

      get login_as_url, params: { who: staff_user.id }
      assert_redirected_to root_url, 'should redirect to root url'
      assert_equal @user.id, session[:user_id], 'same user still logged in'
      assert_nil session[:back_to_id], 'Back to id should be nil'
    end

    should 'go back to my login' do
      requestor = create(:user)

      # session[:back_to_id] = @user.id
      # session[:user_id] = requestor.id

      get login_as_url, params: { who: requestor.id }

      assert_difference('Audited::Audit.count') do
        get back_to_my_login_url

        assert_equal @user.id, session[:user_id], "user id should be #{@user.id}"
        assert_nil session[:back_to_id], 'Back to id should be nil'
      end
    end
  end
end
