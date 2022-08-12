# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_girl
require 'date'

FactoryGirl.define do
  factory :request do
    requested_date '2013-04-17'
    completed_date ''
    cancelled_date ''
    reserve_start_date 1.month.ago.to_date.strftime('%Y-%m-%d')
    reserve_end_date 2.month.from_now
    status Request::OPEN
    requester_email nil

    assigned_to_id 1    # association :department, factory: :department

    association :requester, factory: :user
    association :reserve_location, factory: :location
    association :course, factory: :course
    association :assigned_to, factory: :user
  end
end
