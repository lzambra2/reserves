namespace :send do
  desc 'Database Populate Tasks, Test Data'

  task expiry_notices: :environment do
    report 'Sending Expiring notices'
    requests = Request.expiring_soon

    requests = Request.expiring_soon(ENV['EXPIRE_DATE']) if ENV['EXPIRE_DATE']

    report "Found Requests: #{requests.size}"

    requests_notified = []

    requests.each do |request|
      sender = if ENV['SENDER']
                 User.find(ENV['SENDER'])
               else
                 User.new(name: 'Reserves System', email: Setting.email_from)
               end

      RequestMailer.expiry_notice(request, sender).deliver_now unless ENV['DRY_RUN'] == 'true'

      requests_notified << request.id
    end

    # report "Requests: #{requests_notified.join(",")}"
    report '----------'
    report 'DRY RUN' if ENV['DRY_RUN'] == 'true'
    report "Sent #{requests_notified.size} notices"
    report '----------'
    report "IDs: #{requests_notified.join(', ')}"

    if ENV['EMAIL_REPORT_TO']
      ReportMailer.mail_report(ENV['EMAIL_REPORT_TO'], 'Expiry Notices Report', @report_log.join("\n")).deliver_now
    end
  end

  # Crude logging
  def report(string)
    @report_log = [] if @report_log.nil?

    @report_log << "#{Time.now.strftime('%Y-%m-%d %H:%M:%S')} --- #{string}"

    puts "#{Time.now.strftime('%Y-%m-%d %H:%M:%S')} --- #{string}" unless ENV['REPORT'].nil?
  end
end
