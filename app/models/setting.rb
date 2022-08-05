class Setting < RailsSettings::Base
  cache_prefix { 'v1' }

  field :app_name, default: (ENV['app_name'] || 'Reserves')
  field :app_owner, default: (ENV['app_owner'] || 'York University Libraries')

  ## Maintenance Notice
  field :app_maintenance, default: (ENV['app_maintenance'] || false)
  field :app_maintenance_message, default: (ENV['app_maintenance_message'] ||
                       'Reserves Application will be taken down for maintenance from 12pm - 4pm today. We appologize for any inconvenience this may have caused.')

  ## Reporting
  field :reports_default_interval, default: (ENV['reports_default_interval'] || 30.days)
  field :reports_fiscal_year_start, default: (ENV['reports_fiscal_year_start'] || 'May 1')

  ## Request Related Defaults
  field :request_expiry_notice_interval, default: (ENV['request_expiry_notice_interval'] || 2.weeks)
  field :request_archive_all_after, default: (ENV['request_archive_all_after'] || 60.days)
  field :request_archive_all_user_id, default: (ENV['request_archive_all_user_id'] || 0)
  field :request_archive_all_allow, default: (ENV['request_archive_all_allow'] || false)
  field :request_remove_incomplete_allow, default: (ENV['request_remove_incomplete_allow'] || false)
  field :request_remove_incomplete_after, default: (ENV['request_remove_incomplete_after'] || 1.year)

  ## Email defaults
  field :email_allow, default: (ENV['email_allow'] || true)
  field :email_from, default: (ENV['email_from'] || 'reserves-mailer@library.yorku.ca')
  field :email_welcome_subject, default: (ENV['email_welcome_subject'] || 'Subject of welcome email')
  field :email_welcome_body, default: (ENV['email_welcome_body'] || 'Welcome email text goes here')
  field :email_status_change_subject, default: (ENV['email_status_change_subject'] || 'Subject of status change email')
  field :email_status_change_body, default: (ENV['email_status_change_body'] || 'Status change email text goes here')
  field :email_request_expiry_notice_subject,
        default: (ENV['email_request_expiry_notice_subject'] || 'Subject for Request Expiry Notice email')
  field :email_request_expiry_notice_body,
        default: (ENV['email_request_expiry_notice_body'] || 'Request Expiry Notice email text goes here')

  ## Acquisitions Email
  field :email_acquisitions_to, default: (ENV['email_acquisitions_to'] || 'acquisitions_mailer@yorku.ca')
  field :email_acquisitions_to_bookstore, default: (ENV['email_acquisitions_to_bookstore'] || 'bookstore@test.yorku.ca')
  field :email_acquisitions_subject, default: (ENV['email_acquisitions_subject'] || 'Please Acquire This Item')
  field :email_acquisitions_body, default: (ENV['email_acquisitions_body'] || 'This is the stuff to be emailed')

  ## Acquisition Sources Settings
  field :acquisition_sources,
        default: (ENV['acquisition_sources'] || ['Publisher', 'Requester', 'Library Loan', 'Other'])
  field :acquisition_reasons, default: (ENV['acquisition_reasons'] || ['New Copy Required', 'Missing Item', 'Other'])

  ## Copyright Options Settings
  field :item_copyright_options, default: (ENV['item_copyright_options'] || [
    'I hold the copyright to this material',
    "Use is covered under a York University Libraries' Licence",
    "Material can be placed on reserve under York's Fair Dealing Guidelines",
    'Material is in the public domain',
    'Material is available for this use under a Creative Commons or Open Access licence',
    'I have obtained written permission from the rights holder for this specific use',
    'Other: Explanation is recorded in the box below'
  ])

  ## SEARCH - Using ElasticSearch
  field :search_elastic_enabled, default: (ENV['search_elastic_enabled'] || false)
  field :search_elastic_server, default: (ENV['search_elastic_server'] || '127.0.0.1:9200')
  field :search_elastic_index_prefix, default: (ENV['search_elastic_index_prefix'] || 'reserves')

  ## VUFIND Settings
  field :vufind_url, default: (ENV['vufind_url'] || 'https://www.library.yorku.ca/find/Search/Results')

  ## WORLDCAT
  field :worldcat_key, default: (ENV['worldcat_key'] || 'enter-your-key-here')
  field :worldcat_enable, default: (ENV['worldcat_enable'] || false)

  ## Help Defaults
  field :help_title, default: (ENV['help_title'] || 'Help/Assistance')
  field :help_body, default: (ENV['help_body'] || 'Help/Assistance')
  field :help_contact, default: (ENV['help_contact'] || 'Contact For More Help')
  field :help_link, default: (ENV['help_link'] || 'http://library.yorku.ca')

  ## PRIMO and ALMA Settings
  field :primo_apikey, default: (ENV['primo_apikey'] || '')
  field :primo_inst, default: (ENV['primo_inst'] || '')
  field :primo_vid, default: (ENV['primo_vid'] || '')
  field :primo_region, default: (ENV['primo_region'] || '')
  field :primo_enable_loggable, default: (ENV['primo_enable_loggable'] || true)
  field :primo_scope, default: (ENV['primo_scope'] || '')
  field :primo_pcavailability, default: (ENV['primo_pcavailability'] || true)

  field :alma_apikey, default: (ENV['alma_apikey'] || '')
  field :alma_region, default: (ENV['alma_region'] || '')

  def self.fiscal_date
    d = Date.parse(Setting.reports_fiscal_year_start)

    if d > Date.today
      d - 1.year
    else
      d
    end
  end
end
