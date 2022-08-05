require 'test_helper'

class LoanPeriodTest < ActiveSupport::TestCase
  should 'should create valid Request using defaults from factory girl' do
    loan_period = build(:loan_period)

    assert_difference 'LoanPeriod.count', 1 do
      loan_period.save
    end
  end

  context 'Loan Period Validation' do
    should validate_presence_of(:duration).with_message('Cannot be empty')
  end
end
