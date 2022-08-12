# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :courses_subject, class: 'Courses::Subject' do
    name 'MyString'
    code 'COD'
  end
end
