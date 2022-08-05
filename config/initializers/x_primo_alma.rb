require 'alma'
require 'primo'

Alma.configure do |config|
  if defined?(Setting)
    config.apikey = Setting.alma_apikey
    config.region = Setting.alma_region
  end
end

Primo.configure do |config|
  if defined?(Setting)
    config.apikey = Setting.primo_apikey
    config.inst = Setting.primo_inst
    config.vid = Setting.primo_vid
    config.region = Setting.primo_region
    config.enable_loggable = Setting.primo_enable_loggable
    config.scope = Setting.primo_scope
    config.pcavailability = Setting.primo_pcavailability
  end
end
