# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    name 'Jeremy Clarkson'
    sequence(:email, 1000) { |n| "jereymy#{n}@yorku.ca" }
    phone '124'
    user_type User::FACULTY
    role User::INSTRUCTOR_ROLE
    department 'History'
    office 'Some where'
    sequence(:uid, '20900') { |n| "12#{n}" }
    active true
    admin false

    last_login 1.day.ago
    created_by nil

    association :location, factory: :location
  end
end
