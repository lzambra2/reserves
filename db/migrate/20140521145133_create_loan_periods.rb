# frozen_string_literal: true

class CreateLoanPeriods < ActiveRecord::Migration[5.1]
  def change
    create_table :loan_periods do |t|
      t.string :duration

      t.timestamps
    end
  end
end
