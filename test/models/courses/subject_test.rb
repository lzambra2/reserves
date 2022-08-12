# frozen_string_literal: true

require 'test_helper'

module Courses
  class SubjectTest < ActiveSupport::TestCase
    test 'Create Subject course' do
      course = Courses::Subject.new(name: 'Alfa', code: '')
      refute course.valid?, 'Subject course need a code'
      course2 = Courses::Subject.new(name: 'Alfa', code: '123')
      assert course2.valid?
    end
  end
end
