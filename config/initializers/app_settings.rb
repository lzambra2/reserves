################################ IMPORTANT ###############################
## THIS IS FILE WILL SET DEFAULT SETTINGS IF THEY HAVE NOT BEEN SET YET.
## THIS IS NOT GOING TO CHANGE THE DATABASE VALUES IF THEY HAVE BEEN SET
## TO CHANGE THESE SETTINGS, go to the settings path and change it there.
##########################################################################

## A hack to make sure assets precompile or migrate runs properly
if ActiveRecord::Base.connection.data_source_exists? 'settings'

  ## Name and Version
  Setting.save_default(:app_name, 'Reserves')
  Setting.save_default(:app_owner, 'York University Libraries')

  ## Maintenance Notice
  Setting.save_default(:app_maintenance, false)
  Setting.save_default(:app_maintenance_message,
                       'Reserves Application will be taken down for maintenance from 12pm - 4pm today. We appologize for any inconvenience this may have caused.')

  ## Reporting
  Setting.save_default(:reports_default_interval, 30.days)
  Setting.save_default(:reports_fiscal_year_start, 'May 1')

  ## Request Related Defaults
  Setting.save_default(:request_expiry_notice_interval, 2.weeks)
  Setting.save_default(:request_archive_all_after, 60.days)
  Setting.save_default(:request_archive_all_user_id, 0)
  Setting.save_default(:request_archive_all_allow, false)
  Setting.save_default(:request_remove_incomplete_allow, false)
  Setting.save_default(:request_remove_incomplete_after, 1.year)

  ## Email defaults
  Setting.save_default(:email_allow, true)
  Setting.save_default(:email_from,  'reserves-mailer@library.yorku.ca')
  Setting.save_default(:email_welcome_subject, 'Subject of welcome email')
  Setting.save_default(:email_welcome_body, 'Welcome email text goes here')
  Setting.save_default(:email_status_change_subject, 'Subject of status change email')
  Setting.save_default(:email_status_change_body, 'Status change email text goes here')
  Setting.save_default(:email_request_expiry_notice_subject, 'Subject for Request Expiry Notice email')
  Setting.save_default(:email_request_expiry_notice_body, 'Request Expiry Notice email text goes here')

  ## Acquisitions Email
  Setting.save_default(:email_acquisitions_to, 'acquisitions_mailer@yorku.ca')
  Setting.save_default(:email_acquisitions_to_bookstore, 'bookstore@test.yorku.ca')
  Setting.save_default(:email_acquisitions_subject, 'Please Acquire This Item')
  Setting.save_default(:email_acquisitions_body, 'This is the stuff to be emailed')

  ## Acquisition Sources Settings
  Setting.save_default(:acquisition_sources, ['Publisher', 'Requester', 'Library Loan', 'Other'])
  Setting.save_default(:acquisition_reasons, ['New Copy Required', 'Missing Item', 'Other'])

  ## Copyright Options Settings
  Setting.save_default(:item_copyright_options, [
                         'I hold the copyright to this material',
                         "Use is covered under a York University Libraries' Licence",
                         "Material can be placed on reserve under York's Fair Dealing Guidelines",
                         'Material is in the public domain',
                         'Material is available for this use under a Creative Commons or Open Access licence',
                         'I have obtained written permission from the rights holder for this specific use',
                         'Other: Explanation is recorded in the box below'
                       ])

  ## SEARCH - Using ElasticSearch
  Setting.save_default(:search_elastic_enabled, false)
  Setting.save_default(:search_elastic_server, '127.0.0.1:9200')
  Setting.save_default(:search_elastic_index_prefix, 'reserves')

  ## VUFIND Settings
  Setting.save_default(:vufind_url, 'https://www.library.yorku.ca/find/Search/Results')

  ## WORLDCAT
  Setting.save_default(:worldcat_key, 'enter-your-key-here')
  Setting.save_default(:worldcat_enable, false)

  ## Help Defaults
  Setting.save_default(:help_title, 'Help/Assistance')
  Setting.save_default(:help_body, 'Help/Assistance')
  Setting.save_default(:help_contact, 'Contact For More Help')
  Setting.save_default(:help_link, 'http://library.yorku.ca')

  ## PRIMO and ALMA Settings
  Setting.save_default(:primo_apikey, '')
  Setting.save_default(:primo_inst, '')
  Setting.save_default(:primo_vid, '')
  Setting.save_default(:primo_region, '')
  Setting.save_default(:primo_enable_loggable, true)
  Setting.save_default(:primo_scope, '')
  Setting.save_default(:primo_pcavailability, true)

  Setting.save_default(:alma_apikey, '')
  Setting.save_default(:alma_region, '')
end
