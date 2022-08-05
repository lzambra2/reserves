require 'test_helper'

class RequestHistoryControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user, admin: true, role: User::MANAGER_ROLE)
    log_user_in(@user)
  end

  should 'create a new note' do
    request = create(:request)

    assert_difference('Audited::Audit.count') do
      post save_note_request_path(request), params: { audit_comment: 'Something or rather' }
      assert_equal 'Note saved', flash[:notice]
    end
  end

  should 'not create new note if too long or empty' do
    request = create(:request)

    assert_no_difference('Audited::Audit.count') do
      post save_note_request_path(request), params: { audit_comment: '' }
      assert_equal 'Note is blank. Nothing updated', flash[:alert]
    end

    assert_no_difference('Audited::Audit.count') do
      post save_note_request_path(request), params: { audit_comment: '2' * 300 }
      assert_equal 'Note is more than 255 characters!', flash[:alert]
    end
  end
end
