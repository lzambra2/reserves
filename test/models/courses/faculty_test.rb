# frozen_string_literal: true

require 'test_helper'

module Courses
  class FacultyTest < ActiveSupport::TestCase
    test 'Create faculty course' do
      course = Courses::Faculty.new(name: 'Delta', code: '')
      refute course.valid?, 'faculty course need a code'
      course2 = Courses::Faculty.new(name: 'Delta', code: '123')
      assert course2.valid?
    end
  end
end
