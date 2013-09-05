source 'https://rubygems.org'

ruby '2.0.0'

gem 'rails', '~> 4.0.0'

# Process management
gem 'foreman', '~> 0.63.0'

# Database
gem 'pg', '~> 0.16.0'

# Authentication
gem 'omniauth',               '~> 1.1.1'
gem 'omniauth-google-oauth2', '~> 0.2.1'

group :development, :test do
  gem 'rspec-rails',        '~> 2.14.0'   # Rspec in Rails
  gem 'taps',               '~> 0.3.24'   # Database import/export for local/remote servers
  gem 'guard',              '~> 1.8.2'
  gem 'guard-bundler',      '~> 1.0.0'
  gem 'guard-rspec',        '~> 3.0.2'    # Automatically run tests when they change
  gem 'guard-livereload',   '~> 1.4.0'    # Reload browsers when views change
  gem 'rack-livereload',    '~> 0.3.15'   # Makes using guard-livereload easy
  gem 'yajl-ruby',          '~> 1.1.0'    # JSON parser
  gem 'factory_girl_rails', '~> 4.2.0'    # For creating test data
  gem 'annotate',           '~> 2.5.0'    # Annodate the models
  gem 'pry',                '~> 0.9.12.2' # irb replacement
  gem 'awesome_print',      '~> 1.1.0'    # Better print statements for objects
end

# Assets
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer',            '~> 0.11.4', :platforms => :ruby # Use V8 JS interpreter in Ruby
gem 'uglifier',                '~> 2.1.2'   # Javascript compressor
gem 'sass-rails',              '~> 4.0.0'   # Use SASS with rails
gem 'bootstrap-sass',          '~> 2.3.2.1' # Use bootstrap with SASS
gem 'font-awesome-sass-rails', '~> 3.0.2.2' # Use fontawesome
gem 'coffee-rails',            '~> 4.0.0'   # Use coffeescript in rails

gem 'jquery-rails', '~> 3.0.4' # Use jquery in rails
gem 'haml',         '~> 4.0.3' # Easier templating than ERB

group :test do
  gem 'faker',            '~> 1.2.0' # Fake test data
  gem 'capybara',         '~> 2.1.0' # Integration specs
  gem 'database_cleaner', '~> 1.1.1' # Clean database between tests
  gem 'spork-rails',      github: 'sporkrb/spork-rails' # Keep rails loaded for specs
  gem 'guard-spork',      '~> 1.5.1' # Manage spork in guard

  # For watching the file system and notifications on...
  #   linux
  gem 'rb-inotify', '~> 0.9.1', require: false
  gem 'libnotify',  '~> 0.8.1', require: false
  #   os x
  gem 'rb-fsevent', '~> 0.9.3', require: false
  gem 'growl',      '~> 1.0.3', require: false
  #   windows
  gem 'wdm',        '~> 0.1.0', platforms: [:mswin, :mingw], require: false
  gem 'rb-notifu',  '~> 0.0.4', require: false
end

gem 'coveralls', require: false # Code coverage

group :production do
  gem 'rails_12factor', '~> 0.0.2' # Get Rails 4 working on Heroku
end

