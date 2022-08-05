class LoanPeriod < ApplicationRecord
  ## VALIDATIONS
  validates_presence_of :duration, message: 'Cannot be empty'
end
