# frozen_string_literal: true

require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user, admin: true, role: User::MANAGER_ROLE)
    log_user_in(@user)
  end

  should 'show a list of users ' do
    create_list(:user, 2, admin: true, role: User::MANAGER_ROLE)
    create_list(:user, 4, admin: false)

    get users_url

    users = get_instance_var(:users)

    staff_list = get_instance_var(:staff_list)
    assert !staff_list, 'Should NOT be staff list'
    assert_not_nil users, 'Users should be set'
    assert_equal 4, users.size, 'Should be 4 regular users'
  end

  should 'show staff' do
    create_list(:user, 2, admin: true, role: User::MANAGER_ROLE)
    create_list(:user, 4, admin: false)

    get admin_users_users_url

    users = get_instance_var(:users)

    staff_list = get_instance_var(:staff_list)
    assert staff_list, 'Should be staff list'
    assert_not_nil users, 'Users should be set'
    assert_equal 3, users.size, 'Should be 3 staff (2 + 1)'
  end

  ## SINGLE USER ACTIONS

  should 'show user details' do
    user = create(:user)

    get user_url(user)
    assert get_instance_var(:user)
  end

  should 'show new and edit forms' do
    user = create(:user)
    get edit_user_url(user)
    assert_template :edit
    assert get_instance_var(:user)

    get new_user_url
    assert_template :new
    assert get_instance_var(:user)
  end

  ## CREATING AND UPDATING
  should 'create a new user' do
    user_attrs = attributes_for(:user, user_type: User::FACULTY)

    assert_difference 'User.count', 1 do
      post users_url, params: { user: user_attrs.except(:created_by_id, :active) }
      user = get_instance_var(:user)
      assert user, 'User object was assigned'
      assert_equal 0, user.errors.size, "There should be no errors, #{user.errors.messages.inspect}"
      # assert_equal @user.id, user.created_by.id, "user created by should be as the current user"
      assert_equal User::FACULTY, user.user_type, "user type should be #{User::FACULTY}"
      assert_equal User::INSTRUCTOR_ROLE, user.role, "Regular user should default to #{User::INSTRUCTOR_ROLE} role"

      assert_redirected_to user
    end
  end

  should 'update an existing user' do
    user = create(:user, name: 'Brad', office: '123', created_by: create(:user))

    patch user_url(user), params: { user: { office: 'Ross 439', name: 'Jerome' } }

    updated_user = get_instance_var(:user)
    assert updated_user, 'User object was assigned'
    assert_equal 0, updated_user.errors.size, "SHould be no errors #{updated_user.errors.messages.inspect}"
    assert_equal 'Jerome', updated_user.name, "User's name should have been changed"
    assert_equal 'Ross 439', updated_user.office, 'Office should have changed'
    # assert_equal user.id, updated_user.created_by.id, "Created by id should be the same as the user who created it"

    assert_redirected_to user, 'Should redirect to users path'
  end

  ## DESTROYING is disabling
  should 'disable an existing user, setting the user to inactive' do
    u = create(:user)

    assert_no_difference 'User.count' do
      delete user_url(u)
      user = get_instance_var(:user)
      assert !user.active?, 'User should be inactive'
      assert_redirected_to users_url
    end
  end

  should 'disable an existing user even if user is not valid' do
    u = create(:user)
    u.name = nil
    u.save(validate: false)

    delete user_url(u)
    user = get_instance_var(:user)
    assert !user.active?, 'User should be inactive'
  end

  should 'not be able to dactivate self' do
    delete user_url(@user)
    user = get_instance_var(:user)
    assert user.active?, 'User should still be active'
  end

  should 'reactivate the user' do
    u = create(:user, active: false)
    post reactivate_user_url(u)
    user = get_instance_var(:user)
    assert user.active?, 'User should be active'
    assert_redirected_to users_url
  end

  should 'make user admin or regular user' do
    u = create(:user, admin: false)

    post change_role_user_url(u), params: { admin: 'true' }
    user = get_instance_var(:user)
    assert user.admin?, "Should be admin #{user.role}"
    assert_equal User::STAFF_ROLE, user.role, 'Should be staff role by default'
    assert_redirected_to admin_users_users_url

    post change_role_user_url(u), params: { admin: false }
    user = get_instance_var(:user)
    assert !user.admin?, 'Should not be admin'
    assert_equal User::INSTRUCTOR_ROLE, user.role, 'Should default to Instructor Role'
    assert_redirected_to users_url
  end
end
