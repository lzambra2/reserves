# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :courses_faculty, class: 'Courses::Faculty' do
    name 'MyString'
    code 'MyString'
  end
end
