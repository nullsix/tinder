source 'https://rubygems.org'

ruby '2.0.0'

gem 'rails', '~> 3.2.14'

# Process management
gem 'foreman', '~> 0.63.0'

# Database
gem 'pg', '~> 0.14.1'

# Authentication
gem 'omniauth',               '~> 1.1.1'
gem 'omniauth-google-oauth2', '~> 0.1.19'

group :development, :test do
  gem 'rspec-rails',        '~> 2.13.2' # Rspec in Rails
  gem 'taps',               '~> 0.3.24' # Database import/export for local/remote servers
  gem 'guard-rspec',        '~> 2.5.4'  # Automatically run tests when they change
  gem 'guard-livereload',   '~> 1.1.3'  # Reload browsers when views change
  gem 'rack-livereload',    '~> 0.3.15' # Makes using guard-livereload easy
  gem 'yajl-ruby',          '~> 1.1.0'  # JSON parser
  gem 'factory_girl_rails', '~> 4.2.0'  # For creating test data
  gem 'annotate',           '~> 2.5.0'  # Annodate the models
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer',            '~> 0.11.4', :platforms => :ruby # Use V8 JS interpreter in Ruby
  gem 'uglifier',                '~> 1.3.0'   # Javascript compressor
  gem 'sass-rails',              '~> 3.2.6'   # Use SASS with rails 
  gem 'bootstrap-sass',          '~> 2.3.0.1' # Use bootstrap with SASS
  gem 'font-awesome-sass-rails', '~> 3.0.2.2' # Use fontawesome
  gem 'coffee-rails',            '~> 3.2.2'   # Use coffeescript in rails
end

gem 'jquery-rails', '~> 2.1.4' # Use jquery in rails
gem 'haml',         '~> 3.1.8' # Easier templating than ERB

group :test do
  gem 'faker',            '~> 1.1.2' # Fake test data
  gem 'capybara',         '~> 2.0.2' # Integration specs
  gem 'database_cleaner', '~> 0.9.1' # Clean database between tests
  gem 'spork',            '~> 0.9.2' # Keep rails loaded for specs
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

