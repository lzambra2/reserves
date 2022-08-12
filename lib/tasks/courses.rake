# frozen_string_literal: true

namespace :courses do
  desc 'Courses Tasks'

  #######################################################
  ############### SEND EXPIRY NOTICES ###################
  #######################################################

  task update_course_code_fields: :environment do
    report 'Updating course code fields'

    Course.all.each do |c|
      c.save
      puts c.inspect
    end
  end

  #######################################################
  ############### LOG PROGRESS FOR LATER ################
  #######################################################

  def report(string)
    @report_log = [] if @report_log.nil?

    @report_log << "#{Time.now.strftime('%Y-%m-%d %H:%M:%S')} --- #{string}"

    puts "#{Time.now.strftime('%Y-%m-%d %H:%M:%S')} --- #{string}" unless ENV['REPORT'].nil?
  end
end
