# frozen_string_literal: true

source 'http://rubygems.org'

## RAILS and related ##
gem 'puma', '~> 5.6', '>= 5.6.4'
gem 'rails', '~> 7.0', '>= 7.0.3.1'

## RAILS related ##
gem 'bcrypt-ruby', '~> 3.1.2'
gem 'jbuilder', '~> 2.5'
gem 'sass-rails', '~> 6.0'
gem 'sprockets', '3.6.3'
gem 'uglifier', '>= 1.3.0'

## DEPLOYMENT ##
gem 'capistrano', '3.8.0'
gem 'capistrano-bundler', '1.2.0'
gem 'capistrano-rails', '1.2.3'
gem 'capistrano-rbenv', '2.1.0'

## DATABASES ##
gem 'mysql2', '0.5.3', group: :production

## CSS AND JAVASCRIPT ##
gem 'jquery-rails', '4.3.1'
gem 'jquery-ui-rails', '6.0.1'
gem 'mini_racer', '~> 0.6.2'

## BOOTSTRAP & SIMPLE_FORM & FONTAWESOME ##
gem 'font-awesome-rails', '~> 4.7'
gem 'simple_form', '~> 5.1'

## TOOLS AND UTILITIES ##
gem 'audited', '~> 5.0'
gem 'bigdecimal', '1.3.5'
gem 'cancancan', '~> 3.4'
gem 'devise', '~> 4.8', '>= 4.8.1'
gem 'email_validator', '1.4.0'
gem 'kaminari', '0.17.0'
gem 'liquid', '4.0.0'
gem 'rails-settings-cached', '~> 2.8', '>= 2.8.2'
gem 'rsolr', '1.0.10'
gem 'rufus-scheduler', '3.0.9'
gem 'worldcatapi', git: 'https://github.com/taras-yorku/worldcatapi.git',
                   ref: 'ed6d0cb849e86a032dc84741a5d169da19b8e385'

gem 'caxlsx', '3.2.0'
gem 'caxlsx_rails', '0.6.3'

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
gem 'yaml_db', '~> 0.7.0'

# NOTIFICATIONS
gem 'exception_notification', '~> 4.4', '>= 4.4.1'

## TESTING && DEVELOPMENT ##
gem 'awesome_print', '1.8.0'
gem 'rb-readline'

gem 'populator', git: 'https://github.com/ryanb/populator.git'

group :test do
  gem 'bullet' # Testing SQL queries
  gem 'byebug'
  gem 'capybara', '2.1.0'
  gem 'database_cleaner', '1.2.0'
  gem 'factory_girl_rails', '4.8.0'
  gem 'faker'
  gem 'guard-minitest', '2.4.6'
  gem 'minitest', '~> 5.16', '>= 5.16.2'
  gem 'mocha', '0.14', require: false
  gem 'rack-livereload'
  gem 'shoulda', '~> 4.0'
  gem 'shoulda-context', '~> 2.0'
  gem 'shoulda-matchers', '~> 4.0'
  gem 'webrat', '0.7.3'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'ruby-prof'
  gem 'spring', '1.3.6'
  gem 'web-console', '~> 4.2'
end

group :development, :test do
  gem 'guard-bundler', '~> 3.0'
  gem 'guard-livereload', require: false
  gem 'sqlite3', '~> 1.4', '>= 1.4.4'
end
