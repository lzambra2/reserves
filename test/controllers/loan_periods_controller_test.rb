require 'test_helper'

class LoanPeriodsControllerTest < ActionDispatch::IntegrationTest
  context 'CRUD Controller Location Tests' do
    setup do
      @myloan_period = create(:loan_period)

      @user = create(:user, admin: true, role: User::MANAGER_ROLE)
      log_user_in(@user)
    end

    should 'list all loan_periods' do
      create_list(:loan_period, 10)

      get loan_periods_path
      assert_response :success
      loan_periods = get_instance_var(:loan_periods)
      assert_equal 11, loan_periods.size, '10 Locations + 1 from setup'
    end

    should 'show new loan_period form' do
      get new_loan_period_path
      assert_response :success
    end

    should 'create a new loan_period' do
      assert_difference('LoanPeriod.count') do
        post loan_periods_path, params: { loan_period: attributes_for(:loan_period) }
        loan_period = get_instance_var(:loan_period)
        assert_equal 0, loan_period.errors.size, 'Should be no errors'
        assert_redirected_to loan_periods_path
      end
    end

    should 'show loan_period details' do
      get loan_period_path(@myloan_period)
      assert_response :success
    end

    should 'show get edit form' do
      get edit_loan_period_path(@myloan_period)
      assert_response :success
    end

    should 'update an existing loan_period' do
      old_loan_period_duration = @myloan_period.duration

      patch loan_period_path(@myloan_period), params: { loan_period: { duration: '3 Hours' } }
      loan_period = get_instance_var(:loan_period)
      assert_equal 0, loan_period.errors.size, 'LoanPeriod name did not update'
      assert_response :redirect
      assert_redirected_to loan_periods_path

      assert_not_equal old_loan_period_duration, loan_period.duration, 'Old loan_period duration is not there'
      assert_equal '3 Hours', loan_period.duration, 'Loan Period Duration was updated'
    end

    should 'destroy loan_period' do
      assert_difference('LoanPeriod.count', -1) do
        delete loan_period_path(@myloan_period)
      end

      assert_redirected_to loan_periods_path
    end
  end
end
