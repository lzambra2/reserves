source 'http://rubygems.org'

## RAILS and related ##
gem 'puma', '~> 3.7'
gem 'rails', '5.1.6'

## RAILS related ##
gem 'bcrypt-ruby', '~> 3.1.2'
gem 'coffee-rails', '~> 4.2'
gem 'jbuilder', '~> 2.5'
gem 'sass-rails', '5.0.6'
gem 'sprockets', '3.6.3'
gem 'uglifier', '>= 1.3.0'

## DEPLOYMENT ##
gem 'capistrano', '3.8.0'
gem 'capistrano-bundler', '1.2.0'
gem 'capistrano-rails', '1.2.3'
gem 'capistrano-rbenv', '2.1.0'

## DATABASES ##
gem 'mysql2', '~> 0.5.4'
gem 'sqlite3', '~> 1.3.6'

## CSS AND JAVASCRIPT ##
gem 'jquery-rails', '4.3.1'
gem 'jquery-ui-rails', '6.0.1'
gem 'therubyracer', platforms: :ruby

## BOOTSTRAP & SIMPLE_FORM & FONTAWESOME ##
gem 'font-awesome-rails', '4.7.0.2'
gem 'less-rails'
gem 'simple_form', '3.5.0'
gem 'twitter-bootstrap-rails', '4.0.0'

## TOOLS AND UTILITIES ##
gem 'audited', '~> 4.5'
gem 'cancancan', '2.0.0'
gem 'email_validator', '1.4.0'
gem 'kaminari', '0.17.0'
gem 'liquid', '4.0.0'
gem 'rails-settings-cached', '0.4.1'
gem 'rsolr', '1.0.10'
gem 'rufus-scheduler', '3.0.9'
gem 'worldcatapi', '1.0.5'

gem 'axlsx', '2.0.0'
gem 'axlsx_rails', '0.1.5'

## EX LIBRIS INTEGRATION ALMA, PRIMO
gem 'alma'
gem 'primo', git: 'https://github.com/tulibraries/primo.git', branch: 'main'

## SEARCH - USING ELASTIC SEARCH
gem 'elasticsearch-model', '0.1.9'
gem 'elasticsearch-rails', '0.1.9'

## UPLOADING AND MANIPULATING FILES ##
gem 'carrierwave', '0.9.0'
gem 'mime-types', '1.25.1'
gem 'mini_magick', '3.7.0'

## DUMP DATA INTO YML FILE ##
# rake db:data:dump_dir dir=../tmp/db_june_2017
gem 'yaml_db', '0.6.0'

# NOTIFICATIONS
gem 'exception_notification', '4.0.1'

## TESTING && DEVELOPMENT ##
gem 'awesome_print', '1.8.0'
gem 'rb-readline'
gem 'web-console', '~> 2.0', group: :development

gem 'populator', git: 'https://github.com/ryanb/populator.git'

group :test do
  gem 'bullet' # Testing SQL queries
  gem 'capybara', '2.1.0'
  gem 'database_cleaner', '1.2.0'
  gem 'factory_girl_rails', '4.3.0'
  gem 'faker'
  gem 'guard-bundler', '~> 3.0'
  gem 'guard-livereload', require: false
  gem 'guard-minitest', '2.4.4'
  gem 'minitest'
  gem 'mocha', '0.14', require: false
  gem 'rack-livereload'
  gem 'shoulda', '3.5'
  gem 'shoulda-context'
  gem 'shoulda-matchers'
  gem 'webrat', '0.7.3'
end

group :development do
  gem 'ruby-prof'

  gem 'spring', '1.3.6'

  gem 'better_errors'
  gem 'binding_of_caller'
end
