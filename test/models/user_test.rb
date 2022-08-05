require 'test_helper'

class UserTest < ActiveSupport::TestCase
  should 'create a valid User' do
    user = build(:user)

    assert_difference 'User.count', 1 do
      user.save
    end
  end

  should 'not create an invalid user' do
    # common validations
    assert !build(:user, email: nil).valid?, 'Should have email'
    assert !build(:user, uid: nil).valid?, 'Should have uid'
    assert !build(:user, name: nil).valid?, 'Should have a name'
    assert !build(:user, user_type: nil).valid?, 'Should have user type'
    assert !build(:user, role: nil).valid?, 'Staff must have a role set'

    # staff specific validations
    assert !build(:user, admin: true, location: nil).valid?, 'Staff must have a location set'
    assert !build(:user, email: 'whwoow').valid?, 'Email should follow proper format'

    # ensure uid is unique
    create(:user, uid: 'woot')
    assert !build(:user, uid: 'woot').valid?, 'UID must be unique'
  end

  should 'have staff and users scopes' do
    create_list(:user, 2, admin: true, role: User::MANAGER_ROLE)
    create_list(:user, 3, admin: false)

    assert_equal 2, User.admin.size, 'Should be 2 staff'
    assert_equal 3, User.users.size, 'Should be 3 regular users'
  end
end
